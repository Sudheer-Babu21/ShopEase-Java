package com.shoppingcart.dao;

import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.User;
import com.shoppingcart.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for USERS table in Oracle XE 10g.
 */
public class UserDAO {

    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    public Optional<User> findById(long userId) {
        String sql = "SELECT USER_ID, NAME, EMAIL, PASSWORD_HASH, PHONE, ROLE, CREATED_AT FROM USERS WHERE USER_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapUser(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by ID: " + userId, e);
            throw new AppException("Failed to load user data.", e);
        }
        return Optional.empty();
    }

    public Optional<User> findByEmail(String email) {
        if (email == null) return Optional.empty();
        String sql = "SELECT USER_ID, NAME, EMAIL, PASSWORD_HASH, PHONE, ROLE, CREATED_AT FROM USERS WHERE LOWER(EMAIL) = LOWER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapUser(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by email", e);
            throw new AppException("Failed to look up user.", e);
        }
        return Optional.empty();
    }

    public boolean existsByEmail(String email) {
        if (email == null) return false;
        String sql = "SELECT 1 FROM USERS WHERE LOWER(EMAIL) = LOWER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking user email existence", e);
            throw new AppException("Failed to verify email availability.", e);
        }
    }

    public User createUser(User user) {
        String seqSql = "SELECT SEQ_USERS.NEXTVAL FROM DUAL";
        String insertSql = "INSERT INTO USERS (USER_ID, NAME, EMAIL, PASSWORD_HASH, PHONE, ROLE, CREATED_AT) " +
                           "VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            boolean prevAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);

            long newId;
            try (PreparedStatement seqPs = conn.prepareStatement(seqSql);
                 ResultSet rs = seqPs.executeQuery()) {
                if (rs.next()) {
                    newId = rs.getLong(1);
                } else {
                    conn.rollback();
                    throw new AppException("Unable to generate user ID sequence.");
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setLong(1, newId);
                ps.setString(2, user.getName().trim());
                ps.setString(3, user.getEmail().trim().toLowerCase());
                ps.setString(4, user.getPasswordHash());
                ps.setString(5, (user.getPhone() != null && !user.getPhone().trim().isEmpty()) ? user.getPhone().trim() : null);
                ps.setString(6, user.getRole() != null ? user.getRole() : User.ROLE_CUSTOMER);
                int rows = ps.executeUpdate();
                if (rows != 1) {
                    conn.rollback();
                    throw new AppException("User registration failed: Expected 1 inserted row, but affected " + rows + " rows.");
                }
            }

            conn.commit();
            conn.setAutoCommit(prevAutoCommit);

            user.setUserId(newId);
            return user;
        } catch (SQLException e) {
            DBConnection.rollbackQuietly(conn);
            LOGGER.log(Level.SEVERE, "SQL error creating user (code: " + e.getErrorCode() + ", state: " + e.getSQLState() + ")", e);
            if (e.getErrorCode() == 1 || (e.getMessage() != null && e.getMessage().contains("UQ_USERS_EMAIL"))) {
                throw new AppException("An account with this email address already exists.");
            }
            throw new AppException("Failed to register user due to database error: " + e.getMessage(), e);
        } finally {
            DBConnection.closeQuietly(conn);
        }
    }

    public void updateProfile(User user) {
        String sql = "UPDATE USERS SET NAME = ?, PHONE = ? WHERE USER_ID = ?";
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            boolean prevAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, user.getName().trim());
                ps.setString(2, (user.getPhone() != null && !user.getPhone().trim().isEmpty()) ? user.getPhone().trim() : null);
                ps.setLong(3, user.getUserId());
                int rows = ps.executeUpdate();
                if (rows != 1) {
                    conn.rollback();
                    throw new AppException("Profile update failed: User not found in database (affected " + rows + " rows).");
                }
            }

            conn.commit();
            conn.setAutoCommit(prevAutoCommit);
        } catch (SQLException e) {
            DBConnection.rollbackQuietly(conn);
            LOGGER.log(Level.SEVERE, "SQL error updating user profile (user: " + user.getUserId() + ", code: " + e.getErrorCode() + ", state: " + e.getSQLState() + ")", e);
            throw new AppException("Failed to update profile due to database error.", e);
        } finally {
            DBConnection.closeQuietly(conn);
        }
    }

    public void updatePassword(long userId, String newPasswordHash) {
        String sql = "UPDATE USERS SET PASSWORD_HASH = ? WHERE USER_ID = ?";
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            boolean prevAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newPasswordHash);
                ps.setLong(2, userId);
                int rows = ps.executeUpdate();
                if (rows != 1) {
                    conn.rollback();
                    throw new AppException("Password update failed: User not found in database (affected " + rows + " rows).");
                }
            }

            conn.commit();
            conn.setAutoCommit(prevAutoCommit);
        } catch (SQLException e) {
            DBConnection.rollbackQuietly(conn);
            LOGGER.log(Level.SEVERE, "SQL error updating password (user: " + userId + ", code: " + e.getErrorCode() + ", state: " + e.getSQLState() + ")", e);
            throw new AppException("Failed to update password due to database error.", e);
        } finally {
            DBConnection.closeQuietly(conn);
        }
    }

    public List<User> findAll() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT USER_ID, NAME, EMAIL, PHONE, ROLE, CREATED_AT FROM USERS ORDER BY USER_ID DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getLong("USER_ID"));
                u.setName(rs.getString("NAME"));
                u.setEmail(rs.getString("EMAIL"));
                u.setPhone(rs.getString("PHONE"));
                u.setRole(rs.getString("ROLE"));
                u.setCreatedAt(rs.getTimestamp("CREATED_AT"));
                // Note: passwordHash is deliberately omitted for user listing security
                list.add(u);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error listing users", e);
            throw new AppException("Failed to load users list.", e);
        }
        return list;
    }

    public int countCustomers() {
        String sql = "SELECT COUNT(*) FROM USERS WHERE ROLE = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, User.ROLE_CUSTOMER);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting customers", e);
        }
        return 0;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getLong("USER_ID"));
        u.setName(rs.getString("NAME"));
        u.setEmail(rs.getString("EMAIL"));
        u.setPasswordHash(rs.getString("PASSWORD_HASH"));
        u.setPhone(rs.getString("PHONE"));
        u.setRole(rs.getString("ROLE"));
        u.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        return u;
    }
}
