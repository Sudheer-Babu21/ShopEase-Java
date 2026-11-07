package com.shoppingcart.util;

import com.shoppingcart.dao.UserDAO;
import com.shoppingcart.model.User;

import java.util.Optional;

/**
 * Command-line utility to safely create or reset the initial administrator account.
 * Never exposed via public HTTP endpoints.
 *
 * Usage:
 * java -cp ... com.shoppingcart.util.AdminSetupUtil [name] [email] [password] [phone]
 */
public class AdminSetupUtil {

    public static void main(String[] args) {
        String name = args.length > 0 ? args[0] : "System Administrator";
        String email = args.length > 1 ? args[1] : "admin@shoppingcart.com";
        String password = args.length > 2 ? args[2] : "Admin@123";
        String phone = args.length > 3 ? args[3] : "9876543210";

        System.out.println("=== Online Shopping Cart Administrator Setup ===");
        System.out.println("Target Email: " + email);

        if (!ValidationUtil.isValidEmail(email)) {
            System.err.println("Error: Invalid email address.");
            System.exit(1);
        }

        if (!ValidationUtil.isValidPassword(password)) {
            System.err.println("Error: Password does not meet security requirements (min 8 chars, letter + digit).");
            System.exit(1);
        }

        UserDAO userDAO = new UserDAO();
        Optional<User> existing = userDAO.findByEmail(email);

        String hash = PasswordUtil.hashPassword(password);

        if (existing.isPresent()) {
            User user = existing.get();
            userDAO.updatePassword(user.getUserId(), hash);
            System.out.println("Updated existing user #" + user.getUserId() + " (" + user.getEmail() + ") with new BCrypt password.");
        } else {
            User newAdmin = new User();
            newAdmin.setName(name);
            newAdmin.setEmail(email.toLowerCase());
            newAdmin.setPasswordHash(hash);
            newAdmin.setPhone(phone);
            newAdmin.setRole(User.ROLE_ADMIN);
            User created = userDAO.createUser(newAdmin);
            System.out.println("Administrator successfully initialized with User ID: " + created.getUserId());
        }

        System.out.println("Setup completed successfully. You can now log in at /OnlineShoppingCart/auth/login");
    }
}
