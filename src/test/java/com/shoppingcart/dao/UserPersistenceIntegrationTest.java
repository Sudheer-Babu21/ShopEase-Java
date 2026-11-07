package com.shoppingcart.dao;

import com.shoppingcart.model.User;
import com.shoppingcart.service.AuthService;
import com.shoppingcart.util.DBConnection;
import com.shoppingcart.util.PasswordUtil;
import org.junit.After;
import org.junit.BeforeClass;
import org.junit.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Optional;
import java.util.UUID;

import static org.junit.Assert.*;

/**
 * End-to-end integration and persistence tests against Oracle Database XE 10g.
 * Verifies that writes commit properly and can be read by separate connections.
 */
public class UserPersistenceIntegrationTest {

    private static boolean oracleAvailable = false;
    private final UserDAO userDAO = new UserDAO();
    private final AuthService authService = new AuthService(userDAO);
    private Long createdTestUserId = null;

    @BeforeClass
    public static void checkOracleConnection() {
        try (Connection conn = DBConnection.getConnection()) {
            oracleAvailable = (conn != null && !conn.isClosed());
        } catch (Exception e) {
            oracleAvailable = false;
        }
    }

    @After
    public void cleanUpTestUser() {
        if (!oracleAvailable || createdTestUserId == null) return;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM USERS WHERE USER_ID = ?")) {
            ps.setLong(1, createdTestUserId);
            ps.executeUpdate();
        } catch (Exception e) {
            System.err.println("Failed to clean up test user " + createdTestUserId + ": " + e.getMessage());
        }
    }

    @Test
    public void testFullRegistrationPersistenceAndProfileLifecycle() throws Exception {
        if (!oracleAvailable) {
            System.out.println("Skipping Oracle DB test - Oracle XE not reachable.");
            return;
        }

        String uniqueSuffix = UUID.randomUUID().toString().substring(0, 8);
        String testEmail = "testuser_" + uniqueSuffix + "@example.com";
        String testName = "Test Candidate " + uniqueSuffix;
        String rawPassword = "TestPassword@123";
        String testPhone = "9876543299";

        // 1. Register customer via AuthService
        User registered = authService.registerCustomer(testName, testEmail, rawPassword, testPhone);
        assertNotNull("Registered user must not be null", registered);
        assertNotNull("User ID must be assigned by sequence", registered.getUserId());
        assertTrue("User ID must be positive", registered.getUserId() > 0);
        createdTestUserId = registered.getUserId();

        // 2. Query Oracle with a SEPARATE, INDEPENDENT connection to verify committed persistence
        try (Connection verifyConn = DBConnection.getConnection();
             PreparedStatement ps = verifyConn.prepareStatement(
                     "SELECT USER_ID, NAME, EMAIL, PASSWORD_HASH, PHONE, ROLE, CREATED_AT FROM USERS WHERE USER_ID = ?")) {
            ps.setLong(1, createdTestUserId);
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue("User row MUST exist in Oracle USERS table", rs.next());
                assertEquals("Name in Oracle must match input", testName, rs.getString("NAME"));
                assertEquals("Email in Oracle must be lowercased", testEmail.toLowerCase(), rs.getString("EMAIL"));
                assertEquals("Phone in Oracle must match input", testPhone, rs.getString("PHONE"));
                assertEquals("Role in Oracle must be CUSTOMER", User.ROLE_CUSTOMER, rs.getString("ROLE"));
                assertNotNull("Created timestamp must be populated", rs.getTimestamp("CREATED_AT"));

                String storedHash = rs.getString("PASSWORD_HASH");
                assertNotNull("Password hash in Oracle must not be null", storedHash);
                assertNotEquals("Password in Oracle MUST NOT be plaintext", rawPassword, storedHash);
                assertTrue("Password in Oracle must be valid BCrypt hash ($2a$)", storedHash.startsWith("$2a$"));
                assertTrue("Stored hash must verify against original plaintext", PasswordUtil.checkPassword(rawPassword, storedHash));
            }
        }

        // 3. Test Authentication with correct credentials
        User authenticated = authService.authenticate(testEmail, rawPassword);
        assertNotNull("Authentication must succeed with valid credentials", authenticated);
        assertEquals(createdTestUserId, authenticated.getUserId());
        assertEquals(testName, authenticated.getName());
        assertEquals(User.ROLE_CUSTOMER, authenticated.getRole());

        // 4. Test Authentication rejection with incorrect credentials
        try {
            authService.authenticate(testEmail, "WrongPassword@999");
            fail("Authentication must fail with incorrect password");
        } catch (Exception e) {
            assertTrue("Error message must indicate invalid credentials", e.getMessage().contains("Invalid email or password"));
        }

        // 5. Test Duplicate Registration rejection
        try {
            authService.registerCustomer("Duplicate Person", testEmail.toUpperCase(), "AnotherPass@1", "1234567890");
            fail("Registration must reject duplicate email");
        } catch (Exception e) {
            assertTrue("Error message must indicate email already exists", e.getMessage().contains("already exists"));
        }

        // 6. Test Profile Update and verify persistence with separate connection
        String updatedName = "Updated Name " + uniqueSuffix;
        String updatedPhone = "9988776655";
        authService.updateProfile(createdTestUserId, updatedName, updatedPhone);

        try (Connection verifyConn = DBConnection.getConnection();
             PreparedStatement ps = verifyConn.prepareStatement(
                     "SELECT NAME, PHONE FROM USERS WHERE USER_ID = ?")) {
            ps.setLong(1, createdTestUserId);
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue("User record must exist", rs.next());
                assertEquals("Updated name must persist in Oracle", updatedName, rs.getString("NAME"));
                assertEquals("Updated phone must persist in Oracle", updatedPhone, rs.getString("PHONE"));
            }
        }

        // 7. Test Password Change and verify persistence
        String newPassword = "NewSecuredPassword@456";
        authService.changePassword(createdTestUserId, rawPassword, newPassword);

        // Old password should now fail
        try {
            authService.authenticate(testEmail, rawPassword);
            fail("Old password must no longer authenticate");
        } catch (Exception e) {
            assertTrue(e.getMessage().contains("Invalid email or password"));
        }

        // New password must succeed
        User reAuth = authService.authenticate(testEmail, newPassword);
        assertNotNull("New password must successfully authenticate", reAuth);
        assertEquals(createdTestUserId, reAuth.getUserId());
    }
}
