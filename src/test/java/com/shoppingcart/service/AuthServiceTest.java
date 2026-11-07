package com.shoppingcart.service;

import com.shoppingcart.dao.UserDAO;
import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.User;
import com.shoppingcart.util.PasswordUtil;
import org.junit.Before;
import org.junit.Test;

import java.sql.Timestamp;
import java.util.Optional;

import static org.junit.Assert.*;

public class AuthServiceTest {

    private FakeUserDAO fakeUserDAO;
    private AuthService authService;

    @Before
    public void setUp() {
        fakeUserDAO = new FakeUserDAO();
        authService = new AuthService(fakeUserDAO);
    }

    // --- REGISTRATION VALIDATION TESTS ---

    @Test(expected = AppException.class)
    public void testRegisterEmptyName() {
        authService.registerCustomer(" ", "valid@example.com", "Password123", "9876543210");
    }

    @Test(expected = AppException.class)
    public void testRegisterShortName() {
        authService.registerCustomer("A", "valid@example.com", "Password123", "9876543210");
    }

    @Test(expected = AppException.class)
    public void testRegisterNameTooLong() {
        String longName = "A".repeat(101);
        authService.registerCustomer(longName, "valid@example.com", "Password123", "9876543210");
    }

    @Test(expected = AppException.class)
    public void testRegisterInvalidEmail() {
        authService.registerCustomer("Alice Wonder", "invalid-email", "Password123", "9876543210");
    }

    @Test(expected = AppException.class)
    public void testRegisterShortPassword() {
        authService.registerCustomer("Alice Wonder", "alice@example.com", "Pass1", "9876543210");
    }

    @Test(expected = AppException.class)
    public void testRegisterPasswordWithoutDigits() {
        authService.registerCustomer("Alice Wonder", "alice@example.com", "PasswordOnly", "9876543210");
    }

    @Test(expected = AppException.class)
    public void testRegisterPasswordWithoutLetters() {
        authService.registerCustomer("Alice Wonder", "alice@example.com", "12345678", "9876543210");
    }

    @Test(expected = AppException.class)
    public void testRegisterInvalidPhoneFormat() {
        authService.registerCustomer("Alice Wonder", "alice@example.com", "Password123", "abc-not-phone");
    }

    @Test(expected = AppException.class)
    public void testRegisterDuplicateEmail() {
        fakeUserDAO.seedUser("alice@example.com", "Existing User", "Password123", User.ROLE_CUSTOMER);
        authService.registerCustomer("Alice New", "alice@example.com", "Password123", "9876543210");
    }

    @Test
    public void testRegisterSuccessWithPhone() {
        User user = authService.registerCustomer("Alice Wonder", "alice@example.com", "Password123", "9876543210");
        assertNotNull(user);
        assertEquals("Alice Wonder", user.getName());
        assertEquals("alice@example.com", user.getEmail());
        assertEquals("9876543210", user.getPhone());
        assertEquals(User.ROLE_CUSTOMER, user.getRole());
        assertTrue(PasswordUtil.checkPassword("Password123", user.getPasswordHash()));
        assertTrue(user.getPasswordHash().startsWith("$2a$"));
    }

    @Test
    public void testRegisterSuccessWithNullPhone() {
        User user = authService.registerCustomer("Bob Builder", "bob@example.com", "SecretPass9", null);
        assertNotNull(user);
        assertNull(user.getPhone());
        assertEquals("bob@example.com", user.getEmail());
    }

    @Test
    public void testRegisterSuccessWithEmptyPhoneNormalized() {
        User user = authService.registerCustomer("Bob Builder", "bob2@example.com", "SecretPass9", "   ");
        assertNotNull(user);
        assertNull(user.getPhone());
    }

    // --- AUTHENTICATION TESTS ---

    @Test(expected = AppException.class)
    public void testAuthenticateEmptyEmail() {
        authService.authenticate("", "Password123");
    }

    @Test(expected = AppException.class)
    public void testAuthenticateEmptyPassword() {
        authService.authenticate("alice@example.com", "");
    }

    @Test(expected = AppException.class)
    public void testAuthenticateUserNotFound() {
        authService.authenticate("nonexistent@example.com", "Password123");
    }

    @Test(expected = AppException.class)
    public void testAuthenticateWrongPassword() {
        fakeUserDAO.seedUser("alice@example.com", "Alice Wonder", "CorrectPass1", User.ROLE_CUSTOMER);
        authService.authenticate("alice@example.com", "WrongPass123");
    }

    @Test
    public void testAuthenticateSuccess() {
        fakeUserDAO.seedUser("alice@example.com", "Alice Wonder", "CorrectPass1", User.ROLE_CUSTOMER);
        User user = authService.authenticate("alice@example.com", "CorrectPass1");
        assertNotNull(user);
        assertEquals("Alice Wonder", user.getName());
        assertEquals("alice@example.com", user.getEmail());
        assertFalse(user.isAdmin());
    }

    @Test
    public void testAuthenticateAdminRole() {
        fakeUserDAO.seedUser("admin@shoppingcart.com", "Admin User", "Admin@123", User.ROLE_ADMIN);
        User user = authService.authenticate("admin@shoppingcart.com", "Admin@123");
        assertNotNull(user);
        assertTrue(user.isAdmin());
        assertEquals(User.ROLE_ADMIN, user.getRole());
    }

    // --- PROFILE UPDATE TESTS ---

    @Test(expected = AppException.class)
    public void testUpdateProfileInvalidUserId() {
        authService.updateProfile(0, "Alice Updated", "9876543210");
    }

    @Test(expected = AppException.class)
    public void testUpdateProfileInvalidName() {
        authService.updateProfile(1, "A", "9876543210");
    }

    @Test(expected = AppException.class)
    public void testUpdateProfileInvalidPhone() {
        authService.updateProfile(1, "Valid Name", "bad-phone-number");
    }

    @Test
    public void testUpdateProfileSuccess() {
        User seeded = fakeUserDAO.seedUser("alice@example.com", "Alice Initial", "Password123", User.ROLE_CUSTOMER);
        authService.updateProfile(seeded.getUserId(), "Alice Updated", "9998887776");
        User updated = fakeUserDAO.findById(seeded.getUserId()).orElseThrow();
        assertEquals("Alice Updated", updated.getName());
        assertEquals("9998887776", updated.getPhone());
    }

    // --- PASSWORD CHANGE TESTS ---

    @Test(expected = AppException.class)
    public void testChangePasswordWrongCurrent() {
        User seeded = fakeUserDAO.seedUser("alice@example.com", "Alice Initial", "OriginalPass1", User.ROLE_CUSTOMER);
        authService.changePassword(seeded.getUserId(), "WrongOldPass1", "NewValidPass2");
    }

    @Test(expected = AppException.class)
    public void testChangePasswordWeakNewPassword() {
        User seeded = fakeUserDAO.seedUser("alice@example.com", "Alice Initial", "OriginalPass1", User.ROLE_CUSTOMER);
        authService.changePassword(seeded.getUserId(), "OriginalPass1", "weak");
    }

    @Test
    public void testChangePasswordSuccess() {
        User seeded = fakeUserDAO.seedUser("alice@example.com", "Alice Initial", "OriginalPass1", User.ROLE_CUSTOMER);
        authService.changePassword(seeded.getUserId(), "OriginalPass1", "NewValidPass2");
        User reloaded = fakeUserDAO.findById(seeded.getUserId()).orElseThrow();
        assertTrue(PasswordUtil.checkPassword("NewValidPass2", reloaded.getPasswordHash()));
        assertFalse(PasswordUtil.checkPassword("OriginalPass1", reloaded.getPasswordHash()));
    }

    // --- In-Memory Test Double for UserDAO ---
    private static class FakeUserDAO extends UserDAO {
        private final java.util.Map<Long, User> users = new java.util.HashMap<>();
        private long idGen = 100;

        User seedUser(String email, String name, String rawPass, String role) {
            User u = new User();
            u.setUserId(++idGen);
            u.setEmail(email.toLowerCase().trim());
            u.setName(name);
            u.setPasswordHash(PasswordUtil.hashPassword(rawPass));
            u.setRole(role);
            u.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            users.put(u.getUserId(), u);
            return u;
        }

        @Override
        public Optional<User> findById(long userId) {
            return Optional.ofNullable(users.get(userId));
        }

        @Override
        public Optional<User> findByEmail(String email) {
            if (email == null) return Optional.empty();
            String norm = email.toLowerCase().trim();
            return users.values().stream()
                    .filter(u -> u.getEmail().equalsIgnoreCase(norm))
                    .findFirst();
        }

        @Override
        public boolean existsByEmail(String email) {
            return findByEmail(email).isPresent();
        }

        @Override
        public User createUser(User user) {
            if (existsByEmail(user.getEmail())) {
                throw new AppException("An account with this email address already exists.");
            }
            user.setUserId(++idGen);
            user.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            users.put(user.getUserId(), user);
            return user;
        }

        @Override
        public void updateProfile(User user) {
            User existing = users.get(user.getUserId());
            if (existing == null) {
                throw new AppException("User not found.");
            }
            existing.setName(user.getName());
            existing.setPhone(user.getPhone());
        }

        @Override
        public void updatePassword(long userId, String newPasswordHash) {
            User existing = users.get(userId);
            if (existing == null) {
                throw new AppException("User not found.");
            }
            existing.setPasswordHash(newPasswordHash);
        }
    }
}
