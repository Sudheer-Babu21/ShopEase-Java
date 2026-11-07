package com.shoppingcart.dao;

import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.CartItem;
import com.shoppingcart.model.Product;
import com.shoppingcart.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for CART_ITEMS table in Oracle XE 10g.
 */
public class CartDAO {

    private static final Logger LOGGER = Logger.getLogger(CartDAO.class.getName());

    public List<CartItem> getCartItemsByUserId(long userId) {
        List<CartItem> list = new ArrayList<>();
        String sql = "SELECT ci.CART_ITEM_ID, ci.USER_ID, ci.PRODUCT_ID, ci.QUANTITY, " +
                     "       p.NAME, p.PRICE, p.STOCK_QTY, p.IMAGE_PATH, p.IS_ACTIVE, " +
                     "       c.CATEGORY_ID, c.NAME AS CATEGORY_NAME " +
                     "FROM CART_ITEMS ci " +
                     "JOIN PRODUCTS p ON ci.PRODUCT_ID = p.PRODUCT_ID " +
                     "JOIN CATEGORIES c ON p.CATEGORY_ID = c.CATEGORY_ID " +
                     "WHERE ci.USER_ID = ? " +
                     "ORDER BY ci.CART_ITEM_ID ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setCartItemId(rs.getLong("CART_ITEM_ID"));
                    item.setUserId(rs.getLong("USER_ID"));
                    item.setProductId(rs.getLong("PRODUCT_ID"));
                    item.setQuantity(rs.getInt("QUANTITY"));

                    Product p = new Product();
                    p.setProductId(rs.getLong("PRODUCT_ID"));
                    p.setCategoryId(rs.getLong("CATEGORY_ID"));
                    p.setCategoryName(rs.getString("CATEGORY_NAME"));
                    p.setName(rs.getString("NAME"));
                    p.setPrice(rs.getBigDecimal("PRICE"));
                    p.setStockQty(rs.getInt("STOCK_QTY"));
                    p.setImagePath(rs.getString("IMAGE_PATH"));
                    p.setActive(rs.getInt("IS_ACTIVE") == 1);
                    item.setProduct(p);

                    list.add(item);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading cart items for user: " + userId, e);
            throw new AppException("Failed to load your cart items.", e);
        }
        return list;
    }

    public void addItem(long userId, long productId, int quantity) {
        if (quantity <= 0) return;

        String checkSql = "SELECT CART_ITEM_ID, QUANTITY FROM CART_ITEMS WHERE USER_ID = ? AND PRODUCT_ID = ?";
        String updateSql = "UPDATE CART_ITEMS SET QUANTITY = QUANTITY + ? WHERE CART_ITEM_ID = ?";
        String seqSql = "SELECT SEQ_CART_ITEMS.NEXTVAL FROM DUAL";
        String insertSql = "INSERT INTO CART_ITEMS (CART_ITEM_ID, USER_ID, PRODUCT_ID, QUANTITY) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            Long existingItemId = null;
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setLong(1, userId);
                checkPs.setLong(2, productId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        existingItemId = rs.getLong("CART_ITEM_ID");
                    }
                }
            }

            if (existingItemId != null) {
                try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                    updatePs.setInt(1, quantity);
                    updatePs.setLong(2, existingItemId);
                    updatePs.executeUpdate();
                }
            } else {
                long newId;
                try (PreparedStatement seqPs = conn.prepareStatement(seqSql);
                     ResultSet rs = seqPs.executeQuery()) {
                    if (rs.next()) {
                        newId = rs.getLong(1);
                    } else {
                        throw new AppException("Failed to generate cart item ID.");
                    }
                }

                try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                    insertPs.setLong(1, newId);
                    insertPs.setLong(2, userId);
                    insertPs.setLong(3, productId);
                    insertPs.setInt(4, quantity);
                    insertPs.executeUpdate();
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error adding item to cart. User: " + userId + ", Product: " + productId, e);
            throw new AppException("Failed to add product to cart.", e);
        }
    }

    public void updateQuantity(long userId, long productId, int quantity) {
        if (quantity <= 0) {
            removeItem(userId, productId);
            return;
        }

        String sql = "UPDATE CART_ITEMS SET QUANTITY = ? WHERE USER_ID = ? AND PRODUCT_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setLong(2, userId);
            ps.setLong(3, productId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating cart quantity", e);
            throw new AppException("Failed to update cart item quantity.", e);
        }
    }

    public void removeItem(long userId, long productId) {
        String sql = "DELETE FROM CART_ITEMS WHERE USER_ID = ? AND PRODUCT_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setLong(2, productId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error removing cart item", e);
            throw new AppException("Failed to remove item from cart.", e);
        }
    }

    public void clearCart(Connection conn, long userId) throws SQLException {
        String sql = "DELETE FROM CART_ITEMS WHERE USER_ID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.executeUpdate();
        }
    }

    public int getCartCount(long userId) {
        String sql = "SELECT NVL(SUM(QUANTITY), 0) FROM CART_ITEMS WHERE USER_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting cart items", e);
        }
        return 0;
    }
}
