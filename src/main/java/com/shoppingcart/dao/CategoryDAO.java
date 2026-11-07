package com.shoppingcart.dao;

import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.Category;
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
 * Data Access Object for CATEGORIES table in Oracle XE 10g.
 */
public class CategoryDAO {

    private static final Logger LOGGER = Logger.getLogger(CategoryDAO.class.getName());

    public List<Category> findAll() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT CATEGORY_ID, NAME, DESCRIPTION FROM CATEGORIES ORDER BY NAME ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapCategory(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error listing categories", e);
            throw new AppException("Failed to load categories.", e);
        }
        return list;
    }

    public Optional<Category> findById(long categoryId) {
        String sql = "SELECT CATEGORY_ID, NAME, DESCRIPTION FROM CATEGORIES WHERE CATEGORY_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapCategory(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding category by ID: " + categoryId, e);
            throw new AppException("Failed to load category.", e);
        }
        return Optional.empty();
    }

    public boolean existsByName(String name, Long excludeId) {
        String sql = "SELECT 1 FROM CATEGORIES WHERE LOWER(NAME) = LOWER(?)" +
                     (excludeId != null ? " AND CATEGORY_ID <> ?" : "");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            if (excludeId != null) {
                ps.setLong(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking category existence: " + name, e);
            throw new AppException("Failed to verify category name.", e);
        }
    }

    public Category create(Category category) {
        String seqSql = "SELECT SEQ_CATEGORIES.NEXTVAL FROM DUAL";
        String insertSql = "INSERT INTO CATEGORIES (CATEGORY_ID, NAME, DESCRIPTION) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            long newId;
            try (PreparedStatement seqPs = conn.prepareStatement(seqSql);
                 ResultSet rs = seqPs.executeQuery()) {
                if (rs.next()) {
                    newId = rs.getLong(1);
                } else {
                    throw new AppException("Unable to generate category ID.");
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setLong(1, newId);
                ps.setString(2, category.getName().trim());
                ps.setString(3, category.getDescription());
                ps.executeUpdate();
            }

            category.setCategoryId(newId);
            return category;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error inserting category", e);
            throw new AppException("Failed to create category. Name may already exist.", e);
        }
    }

    public void update(Category category) {
        String sql = "UPDATE CATEGORIES SET NAME = ?, DESCRIPTION = ? WHERE CATEGORY_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category.getName().trim());
            ps.setString(2, category.getDescription());
            ps.setLong(3, category.getCategoryId());
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating category: " + category.getCategoryId(), e);
            throw new AppException("Failed to update category.", e);
        }
    }

    public void delete(long categoryId) {
        // Prevent deletion if products exist in category
        String countSql = "SELECT COUNT(*) FROM PRODUCTS WHERE CATEGORY_ID = ?";
        String deleteSql = "DELETE FROM CATEGORIES WHERE CATEGORY_ID = ?";

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setLong(1, categoryId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        throw new AppException("Cannot delete category because it contains " + rs.getInt(1) + " product(s). Please reassign or remove them first.");
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                ps.setLong(1, categoryId);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting category: " + categoryId, e);
            throw new AppException("Failed to delete category.", e);
        }
    }

    private Category mapCategory(ResultSet rs) throws SQLException {
        return new Category(
                rs.getLong("CATEGORY_ID"),
                rs.getString("NAME"),
                rs.getString("DESCRIPTION")
        );
    }
}
