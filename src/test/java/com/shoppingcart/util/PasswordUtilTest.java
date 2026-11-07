package com.shoppingcart.util;

import org.junit.Test;

import static org.junit.Assert.*;

public class PasswordUtilTest {

    @Test
    public void testHashAndVerifyPassword() {
        String plain = "Customer@123";
        String hash = PasswordUtil.hashPassword(plain);

        assertNotNull(hash);
        assertTrue(hash.startsWith("$2a$") || hash.startsWith("$2b$"));
        assertTrue(PasswordUtil.checkPassword(plain, hash));
        assertFalse(PasswordUtil.checkPassword("WrongPassword!", hash));
    }

    @Test
    public void testDifferentSaltsGenerated() {
        String plain = "Admin@123";
        String hash1 = PasswordUtil.hashPassword(plain);
        String hash2 = PasswordUtil.hashPassword(plain);

        assertNotEquals(hash1, hash2); // Salts must differ
        assertTrue(PasswordUtil.checkPassword(plain, hash1));
        assertTrue(PasswordUtil.checkPassword(plain, hash2));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testNullPasswordThrows() {
        PasswordUtil.hashPassword(null);
    }
}
