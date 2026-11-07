package com.shoppingcart.dao;

import com.shoppingcart.model.Category;
import com.shoppingcart.model.Product;
import com.shoppingcart.model.User;
import com.shoppingcart.util.DBConnection;
import org.junit.BeforeClass;
import org.junit.Test;

import java.sql.Connection;
import java.util.List;
import java.util.Optional;

import static org.junit.Assert.*;

public class OracleIntegrationTest {

    private static boolean oracleAvailable = false;

    @BeforeClass
    public static void checkOracle() {
        try (Connection conn = DBConnection.getConnection()) {
            oracleAvailable = (conn != null && !conn.isClosed());
        } catch (Exception e) {
            oracleAvailable = false;
        }
    }

    @Test
    public void testOracleConnection() {
        if (!oracleAvailable) {
            System.out.println("Skipping Oracle DB test - database not reachable.");
            return;
        }
        assertTrue("Oracle XE should be connected", oracleAvailable);
    }

    @Test
    public void testUserLookupFromOracle() {
        if (!oracleAvailable) return;

        UserDAO userDAO = new UserDAO();
        Optional<User> admin = userDAO.findByEmail("admin@shoppingcart.com");
        assertTrue("Admin user should exist in database", admin.isPresent());
        assertEquals("ADMIN", admin.get().getRole());

        Optional<User> customer = userDAO.findByEmail("john@example.com");
        assertTrue("Customer user should exist in database", customer.isPresent());
        assertEquals("CUSTOMER", customer.get().getRole());
    }

    @Test
    public void testProductRownumPaginationFromOracle() {
        if (!oracleAvailable) return;

        ProductDAO productDAO = new ProductDAO();
        List<Product> page1 = productDAO.findProducts(1, 4, null, null, true, null);
        assertNotNull(page1);
        assertEquals("Page size should be 4", 4, page1.size());

        int totalCount = productDAO.countProducts(null, null, true);
        assertTrue("Total active products should be >= 10", totalCount >= 10);
    }

    @Test
    public void testCategoriesFromOracle() {
        if (!oracleAvailable) return;

        CategoryDAO categoryDAO = new CategoryDAO();
        List<Category> categories = categoryDAO.findAll();
        assertNotNull(categories);
        assertTrue("Should have 5 sample categories", categories.size() >= 5);
    }
}
