package com.shoppingcart.util;

import java.util.regex.Pattern;

/**
 * Validation and sanitization utility for inputs across customer and admin modules.
 */
public final class ValidationUtil {

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,63}$"
    );

    private static final Pattern PHONE_PATTERN = Pattern.compile(
            "^[0-9+\\-()\\s]{7,20}$"
    );

    private ValidationUtil() {
        // Utility class
    }

    public static boolean isValidEmail(String email) {
        if (email == null) return false;
        String trimmed = email.trim();
        return !trimmed.isEmpty() && trimmed.length() <= 100 && EMAIL_PATTERN.matcher(trimmed).matches();
    }

    public static boolean isValidPassword(String password) {
        if (password == null) return false;
        // At least 8 characters, contains at least one letter and one digit
        return password.length() >= 8 &&
               password.chars().anyMatch(Character::isLetter) &&
               password.chars().anyMatch(Character::isDigit);
    }

    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) return true; // Optional field
        return PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    public static boolean isNotEmpty(String value) {
        return value != null && !value.trim().isEmpty();
    }

    public static int parsePositiveInt(String value, int defaultValue) {
        if (value == null) return defaultValue;
        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    public static double parseNonNegativeDouble(String value, double defaultValue) {
        if (value == null) return defaultValue;
        try {
            double parsed = Double.parseDouble(value.trim());
            return parsed >= 0 ? parsed : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /**
     * Sanitizes file names to prevent directory traversal attacks (e.g. ../ or \\).
     */
    public static String sanitizeFileName(String fileName) {
        if (fileName == null) return null;
        // Strip any directory path components
        int lastSlash = Math.max(fileName.lastIndexOf('/'), fileName.lastIndexOf('\\'));
        if (lastSlash >= 0) {
            fileName = fileName.substring(lastSlash + 1);
        }
        String clean = fileName.replaceAll("[/\\\\:*?\"<>|]", "_").trim();
        clean = clean.replaceAll("^\\.+", ""); // Strip leading dots
        return clean.isEmpty() ? "unnamed" : clean;
    }

    /**
     * Escapes untrusted text to prevent Cross-Site Scripting (XSS).
     */
    public static String escapeHtml(String input) {
        if (input == null) return "";
        StringBuilder sb = new StringBuilder(input.length());
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            switch (c) {
                case '&':  sb.append("&amp;"); break;
                case '<':  sb.append("&lt;"); break;
                case '>':  sb.append("&gt;"); break;
                case '"':  sb.append("&quot;"); break;
                case '\'': sb.append("&#x27;"); break;
                case '/':  sb.append("&#x2F;"); break;
                default:   sb.append(c); break;
            }
        }
        return sb.toString();
    }
}
