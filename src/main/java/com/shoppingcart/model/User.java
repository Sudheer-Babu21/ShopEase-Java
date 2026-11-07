package com.shoppingcart.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Represents an authenticated system user (Customer or Administrator).
 */
public class User implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String ROLE_ADMIN = "ADMIN";
    public static final String ROLE_CUSTOMER = "CUSTOMER";

    private Long userId;
    private String name;
    private String email;
    private String passwordHash;
    private String phone;
    private String role;
    private Timestamp createdAt;

    public User() {
    }

    public User(Long userId, String name, String email, String passwordHash, String phone, String role, Timestamp createdAt) {
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
        this.phone = phone;
        this.role = role;
        this.createdAt = createdAt;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isAdmin() {
        return ROLE_ADMIN.equalsIgnoreCase(this.role);
    }
}
