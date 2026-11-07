package com.shoppingcart.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility for hashing and verifying passwords using BCrypt.
 */
public final class PasswordUtil {

    private static final int LOG_ROUNDS = 10;

    private PasswordUtil() {
        // Utility class
    }

    /**
     * Generates a BCrypt hash for a plaintext password.
     *
     * @param plainPassword plaintext string
     * @return BCrypt hash string
     */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            throw new IllegalArgumentException("Password cannot be null or empty.");
        }
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(LOG_ROUNDS));
    }

    /**
     * Verifies a plaintext password against a BCrypt hash.
     *
     * @param plainPassword plaintext candidate
     * @param hashedPassword stored BCrypt hash
     * @return true if matches, false otherwise
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}
