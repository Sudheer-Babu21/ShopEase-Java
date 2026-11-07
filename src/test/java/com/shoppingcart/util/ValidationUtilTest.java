package com.shoppingcart.util;

import org.junit.Test;

import static org.junit.Assert.*;

public class ValidationUtilTest {

    @Test
    public void testValidEmail() {
        assertTrue(ValidationUtil.isValidEmail("john.doe@example.com"));
        assertTrue(ValidationUtil.isValidEmail("customer+test@shop.co.uk"));
        assertFalse(ValidationUtil.isValidEmail("invalid-email"));
        assertFalse(ValidationUtil.isValidEmail("@missinguser.com"));
        assertFalse(ValidationUtil.isValidEmail("user@.com"));
        assertFalse(ValidationUtil.isValidEmail(null));
        assertFalse(ValidationUtil.isValidEmail(""));
    }

    @Test
    public void testPasswordStrength() {
        // Min 8 chars, letters and digits required
        assertTrue(ValidationUtil.isValidPassword("Customer@123"));
        assertTrue(ValidationUtil.isValidPassword("adminPass99"));
        assertFalse(ValidationUtil.isValidPassword("short1")); // < 8 chars
        assertFalse(ValidationUtil.isValidPassword("allletterslowercase")); // No digits
        assertFalse(ValidationUtil.isValidPassword("1234567890")); // No letters
        assertFalse(ValidationUtil.isValidPassword(null));
    }

    @Test
    public void testPhoneValidation() {
        assertTrue(ValidationUtil.isValidPhone("9876543210"));
        assertTrue(ValidationUtil.isValidPhone("+1-555-0199"));
        assertTrue(ValidationUtil.isValidPhone(null)); // Optional
        assertTrue(ValidationUtil.isValidPhone("")); // Optional
        assertFalse(ValidationUtil.isValidPhone("123")); // Too short
        assertFalse(ValidationUtil.isValidPhone("abc-phone-xyz")); // Non-digits
    }

    @Test
    public void testHtmlEscaping() {
        String input = "<script>alert('XSS')</script>";
        String escaped = ValidationUtil.escapeHtml(input);
        assertFalse(escaped.contains("<script>"));
        assertTrue(escaped.contains("&lt;script&gt;"));
    }

    @Test
    public void testSanitizeFileName() {
        assertEquals("normal.jpg", ValidationUtil.sanitizeFileName("normal.jpg"));
        assertEquals("passwd", ValidationUtil.sanitizeFileName("../../etc/passwd"));
        assertEquals("test_image.png", ValidationUtil.sanitizeFileName("..\\..\\test:image.png"));
    }

    @Test
    public void testPositiveIntParsing() {
        assertEquals(5, ValidationUtil.parsePositiveInt("5", 1));
        assertEquals(1, ValidationUtil.parsePositiveInt("-3", 1));
        assertEquals(1, ValidationUtil.parsePositiveInt("invalid", 1));
        assertEquals(1, ValidationUtil.parsePositiveInt(null, 1));
    }
}
