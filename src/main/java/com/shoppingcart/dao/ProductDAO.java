package com.shoppingcart.dao;

import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.Product;
import com.shoppingcart.util.DBConnection;

import java.math.BigDecimal;
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
 * Data Access Object for PRODUCTS table in Oracle XE 10g.
 * Implements ROWNUM pagination and parameterized filtering.
 */
public class ProductDAO {

    private static final Logger LOGGER = Logger.getLogger(ProductDAO.class.getName());

    public Optional<Product> findById(long productId) {
        String sql = "SELECT p.PRODUCT_ID, p.CATEGORY_ID, c.NAME AS CATEGORY_NAME, " +
                     "       p.NAME, p.DESCRIPTION, p.PRICE, p.STOCK_QTY, p.IMAGE_PATH, p.IS_ACTIVE " +
                     "FROM PRODUCTS p " +
                     "JOIN CATEGORIES c ON p.CATEGORY_ID = c.CATEGORY_ID " +
                     "WHERE p.PRODUCT_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapProduct(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding product by ID: " + productId, e);
            throw new AppException("Failed to load product details.", e);
        }
        return Optional.empty();
    }

    /**
     * Finds paginated products with category filtering, search keyword, active filter, and sorting.
     * Compatible with Oracle XE 10g ROWNUM syntax.
     */
    public List<Product> findProducts(int page, int pageSize, Long categoryId, String keyword, 
                                     Boolean onlyActive, String sortBy) {
        List<Product> list = new ArrayList<>();
        StringBuilder where = new StringBuilder(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            where.append(" AND p.CATEGORY_ID = ? ");
            params.add(categoryId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append(" AND (LOWER(p.NAME) LIKE ? OR LOWER(p.DESCRIPTION) LIKE ?) ");
            String kw = "%" + keyword.trim().toLowerCase() + "%";
            params.add(kw);
            params.add(kw);
        }

        if (onlyActive != null && onlyActive) {
            where.append(" AND p.IS_ACTIVE = 1 ");
        }

        String orderByClause = " ORDER BY p.PRODUCT_ID DESC ";
        if ("price_asc".equalsIgnoreCase(sortBy)) {
            orderByClause = " ORDER BY p.PRICE ASC, p.PRODUCT_ID DESC ";
        } else if ("price_desc".equalsIgnoreCase(sortBy)) {
            orderByClause = " ORDER BY p.PRICE DESC, p.PRODUCT_ID DESC ";
        } else if ("name_asc".equalsIgnoreCase(sortBy)) {
            orderByClause = " ORDER BY LOWER(p.NAME) ASC, p.PRODUCT_ID DESC ";
        } else if ("name_desc".equalsIgnoreCase(sortBy)) {
            orderByClause = " ORDER BY LOWER(p.NAME) DESC, p.PRODUCT_ID DESC ";
        }

        int upperBound = page * pageSize;
        int lowerBound = (page - 1) * pageSize;

        String sql = "SELECT * FROM ( " +
                     "  SELECT a.*, ROWNUM rnum FROM ( " +
                     "    SELECT p.PRODUCT_ID, p.CATEGORY_ID, c.NAME AS CATEGORY_NAME, " +
                     "           p.NAME, p.DESCRIPTION, p.PRICE, p.STOCK_QTY, p.IMAGE_PATH, p.IS_ACTIVE " +
                     "    FROM PRODUCTS p " +
                     "    JOIN CATEGORIES c ON p.CATEGORY_ID = c.CATEGORY_ID " +
                     where.toString() +
                     orderByClause +
                     "  ) a WHERE ROWNUM <= ? " +
                     ") WHERE rnum > ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int pIndex = 1;
            for (Object p : params) {
                ps.setObject(pIndex++, p);
            }
            ps.setInt(pIndex++, upperBound);
            ps.setInt(pIndex, lowerBound);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error querying products", e);
            throw new AppException("Failed to retrieve products.", e);
        }
        return list;
    }

    public int countProducts(Long categoryId, String keyword, Boolean onlyActive) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM PRODUCTS p WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.CATEGORY_ID = ? ");
            params.add(categoryId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(p.NAME) LIKE ? OR LOWER(p.DESCRIPTION) LIKE ?) ");
            String kw = "%" + keyword.trim().toLowerCase() + "%";
            params.add(kw);
            params.add(kw);
        }

        if (onlyActive != null && onlyActive) {
            sql.append(" AND p.IS_ACTIVE = 1 ");
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int pIndex = 1;
            for (Object p : params) {
                ps.setObject(pIndex++, p);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting products", e);
        }
        return 0;
    }

    public Product create(Product product) {
        String seqSql = "SELECT SEQ_PRODUCTS.NEXTVAL FROM DUAL";
        String insertSql = "INSERT INTO PRODUCTS (PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            long newId;
            try (PreparedStatement seqPs = conn.prepareStatement(seqSql);
                 ResultSet rs = seqPs.executeQuery()) {
                if (rs.next()) {
                    newId = rs.getLong(1);
                } else {
                    throw new AppException("Unable to generate product ID.");
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setLong(1, newId);
                ps.setLong(2, product.getCategoryId());
                ps.setString(3, product.getName().trim());
                ps.setString(4, product.getDescription());
                ps.setBigDecimal(5, product.getPrice());
                ps.setInt(6, product.getStockQty());
                ps.setString(7, product.getImagePath());
                ps.setInt(8, product.isActive() ? 1 : 0);
                ps.executeUpdate();
            }

            product.setProductId(newId);
            return product;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating product", e);
            throw new AppException("Failed to add product.", e);
        }
    }

    public void update(Product product) {
        String sql = "UPDATE PRODUCTS SET CATEGORY_ID = ?, NAME = ?, DESCRIPTION = ?, " +
                     "PRICE = ?, STOCK_QTY = ?, IMAGE_PATH = ?, IS_ACTIVE = ? " +
                     "WHERE PRODUCT_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, product.getCategoryId());
            ps.setString(2, product.getName().trim());
            ps.setString(3, product.getDescription());
            ps.setBigDecimal(4, product.getPrice());
            ps.setInt(5, product.getStockQty());
            ps.setString(6, product.getImagePath());
            ps.setInt(7, product.isActive() ? 1 : 0);
            ps.setLong(8, product.getProductId());
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating product: " + product.getProductId(), e);
            throw new AppException("Failed to update product details.", e);
        }
    }

    public void toggleActive(long productId, boolean active) {
        String sql = "UPDATE PRODUCTS SET IS_ACTIVE = ? WHERE PRODUCT_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, active ? 1 : 0);
            ps.setLong(2, productId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error toggling product status: " + productId, e);
            throw new AppException("Failed to update product active state.", e);
        }
    }

    public List<Product> findFeatured(int limit) {
        return findProducts(1, limit, null, null, true, null);
    }

    public List<Product> getLowStockProducts(int threshold) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.PRODUCT_ID, p.CATEGORY_ID, c.NAME AS CATEGORY_NAME, " +
                     "       p.NAME, p.DESCRIPTION, p.PRICE, p.STOCK_QTY, p.IMAGE_PATH, p.IS_ACTIVE " +
                     "FROM PRODUCTS p " +
                     "JOIN CATEGORIES c ON p.CATEGORY_ID = c.CATEGORY_ID " +
                     "WHERE p.STOCK_QTY <= ? AND p.IS_ACTIVE = 1 " +
                     "ORDER BY p.STOCK_QTY ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error querying low stock products", e);
        }
        return list;
    }

    private Product mapProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getLong("PRODUCT_ID"));
        p.setCategoryId(rs.getLong("CATEGORY_ID"));
        p.setCategoryName(rs.getString("CATEGORY_NAME"));
        p.setName(rs.getString("NAME"));
        p.setDescription(rs.getString("DESCRIPTION"));
        p.setPrice(rs.getBigDecimal("PRICE"));
        p.setStockQty(rs.getInt("STOCK_QTY"));
        p.setImagePath(rs.getString("IMAGE_PATH"));
        p.setActive(rs.getInt("IS_ACTIVE") == 1);
        return p;
    }
}
