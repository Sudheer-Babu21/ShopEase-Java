package com.shoppingcart.service;

import com.shoppingcart.dao.UserDAO;
import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.User;
import com.shoppingcart.util.PasswordUtil;
import com.shoppingcart.util.ValidationUtil;

import java.util.Optional;

/**
 * Service handling user authentication, customer registration, and profile operations.
 */
public class AuthService {

    private final UserDAO userDAO;

    public AuthService() {
        this.userDAO = new UserDAO();
    }

    public AuthService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    /**
     * Authenticates credentials. Returns user on success, throws AppException with generic message on failure.
     */
    public User authenticate(String email, String password) {
        if (!ValidationUtil.isNotEmpty(email) || !ValidationUtil.isNotEmpty(password)) {
            throw new AppException("Invalid email or password.");
        }

        Optional<User> userOpt = userDAO.findByEmail(email.trim());
        if (userOpt.isEmpty()) {
            throw new AppException("Invalid email or password.");
        }

        User user = userOpt.get();
        if (!PasswordUtil.checkPassword(password, user.getPasswordHash())) {
            throw new AppException("Invalid email or password.");
        }

        return user;
    }

    /**
     * Registers a new customer account.
     * Enforces CUSTOMER role to prevent privilege escalation.
     */
    public User registerCustomer(String name, String email, String password, String phone) {
        if (!ValidationUtil.isNotEmpty(name) || name.trim().length() < 2) {
            throw new AppException("Please provide a valid full name (at least 2 characters).");
        }
        if (name.trim().length() > 100) {
            throw new AppException("Full name cannot exceed 100 characters.");
        }

        if (!ValidationUtil.isValidEmail(email)) {
            throw new AppException("Please enter a valid email address.");
        }

        if (!ValidationUtil.isValidPassword(password)) {
            throw new AppException("Password must be at least 8 characters long and contain both letters and digits.");
        }

        if (!ValidationUtil.isValidPhone(phone)) {
            throw new AppException("Please enter a valid phone number (digits and optional hyphens).");
        }
        if (phone != null && phone.trim().length() > 20) {
            throw new AppException("Phone number cannot exceed 20 characters.");
        }

        if (userDAO.existsByEmail(email.trim())) {
            throw new AppException("An account with this email address already exists.");
        }

        String passwordHash = PasswordUtil.hashPassword(password);

        User newUser = new User();
        newUser.setName(name.trim());
        newUser.setEmail(email.trim().toLowerCase());
        newUser.setPasswordHash(passwordHash);
        newUser.setPhone(phone != null && !phone.trim().isEmpty() ? phone.trim() : null);
        newUser.setRole(User.ROLE_CUSTOMER); // Strictly forced to CUSTOMER

        return userDAO.createUser(newUser);
    }

    public void updateProfile(long userId, String name, String phone) {
        if (userId <= 0) {
            throw new AppException("Invalid user ID.");
        }
        if (!ValidationUtil.isNotEmpty(name) || name.trim().length() < 2) {
            throw new AppException("Please provide a valid full name (at least 2 characters).");
        }
        if (name.trim().length() > 100) {
            throw new AppException("Full name cannot exceed 100 characters.");
        }
        if (!ValidationUtil.isValidPhone(phone)) {
            throw new AppException("Please enter a valid phone number (digits and optional hyphens).");
        }
        if (phone != null && phone.trim().length() > 20) {
            throw new AppException("Phone number cannot exceed 20 characters.");
        }

        User user = new User();
        user.setUserId(userId);
        user.setName(name.trim());
        user.setPhone(phone != null && !phone.trim().isEmpty() ? phone.trim() : null);
        userDAO.updateProfile(user);
    }

    public void changePassword(long userId, String currentPassword, String newPassword) {
        if (userId <= 0) {
            throw new AppException("Invalid user ID.");
        }
        if (!ValidationUtil.isNotEmpty(currentPassword)) {
            throw new AppException("Current password is required.");
        }
        Optional<User> userOpt = userDAO.findById(userId);
        if (userOpt.isEmpty()) {
            throw new AppException("User account not found.");
        }

        User user = userOpt.get();
        if (!PasswordUtil.checkPassword(currentPassword, user.getPasswordHash())) {
            throw new AppException("Current password is incorrect.");
        }

        if (!ValidationUtil.isValidPassword(newPassword)) {
            throw new AppException("New password must be at least 8 characters long and contain both letters and digits.");
        }

        String newHash = PasswordUtil.hashPassword(newPassword);
        userDAO.updatePassword(userId, newHash);
    }
}
