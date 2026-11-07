package com.shoppingcart.dao;

import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.Order;
import com.shoppingcart.model.OrderItem;
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
 * Data Access Object for ORDERS and ORDER_ITEMS tables in Oracle XE 10g.
 */
public class OrderDAO {

    private static final Logger LOGGER = Logger.getLogger(OrderDAO.class.getName());

    public long createOrder(Connection conn, Order order) throws SQLException {
        String seqSql = "SELECT SEQ_ORDERS.NEXTVAL FROM DUAL";
        String insertSql = "INSERT INTO ORDERS (ORDER_ID, USER_ID, ORDER_DATE, TOTAL_AMOUNT, STATUS, SHIPPING_ADDRESS, PAYMENT_METHOD) " +
                           "VALUES (?, ?, CURRENT_TIMESTAMP, ?, ?, ?, ?)";

        long orderId;
        try (PreparedStatement seqPs = conn.prepareStatement(seqSql);
             ResultSet rs = seqPs.executeQuery()) {
            if (rs.next()) {
                orderId = rs.getLong(1);
            } else {
                throw new SQLException("Unable to generate order ID sequence.");
            }
        }

        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setLong(1, orderId);
            ps.setLong(2, order.getUserId());
            ps.setBigDecimal(3, order.getTotalAmount());
            ps.setString(4, order.getStatus() != null ? order.getStatus() : Order.STATUS_PLACED);
            ps.setString(5, order.getShippingAddress());
            ps.setString(6, order.getPaymentMethod());
            ps.executeUpdate();
        }

        order.setOrderId(orderId);
        return orderId;
    }

    public void createOrderItem(Connection conn, OrderItem item) throws SQLException {
        String seqSql = "SELECT SEQ_ORDER_ITEMS.NEXTVAL FROM DUAL";
        String insertSql = "INSERT INTO ORDER_ITEMS (ORDER_ITEM_ID, ORDER_ID, PRODUCT_ID, QUANTITY, UNIT_PRICE) " +
                           "VALUES (?, ?, ?, ?, ?)";

        long orderItemId;
        try (PreparedStatement seqPs = conn.prepareStatement(seqSql);
             ResultSet rs = seqPs.executeQuery()) {
            if (rs.next()) {
                orderItemId = rs.getLong(1);
            } else {
                throw new SQLException("Unable to generate order item ID sequence.");
            }
        }

        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setLong(1, orderItemId);
            ps.setLong(2, item.getOrderId());
            ps.setLong(3, item.getProductId());
            ps.setInt(4, item.getQuantity());
            ps.setBigDecimal(5, item.getUnitPrice());
            ps.executeUpdate();
        }

        item.setOrderItemId(orderItemId);
    }

    public Optional<Order> findById(long orderId) {
        String sql = "SELECT o.ORDER_ID, o.USER_ID, o.ORDER_DATE, o.TOTAL_AMOUNT, o.STATUS, " +
                     "       o.SHIPPING_ADDRESS, o.PAYMENT_METHOD, u.NAME AS USER_NAME, u.EMAIL AS USER_EMAIL " +
                     "FROM ORDERS o " +
                     "JOIN USERS u ON o.USER_ID = u.USER_ID " +
                     "WHERE o.ORDER_ID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order order = mapOrder(rs);
                    order.setItems(getOrderItems(conn, orderId));
                    return Optional.of(order);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding order by ID: " + orderId, e);
            throw new AppException("Failed to retrieve order details.", e);
        }
        return Optional.empty();
    }

    public List<Order> findOrdersByUserId(long userId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.ORDER_ID, o.USER_ID, o.ORDER_DATE, o.TOTAL_AMOUNT, o.STATUS, " +
                     "       o.SHIPPING_ADDRESS, o.PAYMENT_METHOD, u.NAME AS USER_NAME, u.EMAIL AS USER_EMAIL " +
                     "FROM ORDERS o " +
                     "JOIN USERS u ON o.USER_ID = u.USER_ID " +
                     "WHERE o.USER_ID = ? " +
                     "ORDER BY o.ORDER_ID DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapOrder(rs);
                    list.add(order);
                }
            }

            // Populate items for each order
            for (Order o : list) {
                o.setItems(getOrderItems(conn, o.getOrderId()));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving order history for user: " + userId, e);
            throw new AppException("Failed to load your order history.", e);
        }
        return list;
    }

    public List<Order> findAllOrders(int page, int pageSize, String statusFilter, String search) {
        List<Order> list = new ArrayList<>();
        StringBuilder where = new StringBuilder(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            where.append(" AND o.STATUS = ? ");
            params.add(statusFilter.trim().toUpperCase());
        }

        if (search != null && !search.trim().isEmpty()) {
            where.append(" AND (LOWER(u.NAME) LIKE ? OR LOWER(u.EMAIL) LIKE ? OR TO_CHAR(o.ORDER_ID) = ?) ");
            String q = "%" + search.trim().toLowerCase() + "%";
            params.add(q);
            params.add(q);
            params.add(search.trim());
        }

        int upperBound = page * pageSize;
        int lowerBound = (page - 1) * pageSize;

        String sql = "SELECT * FROM ( " +
                     "  SELECT a.*, ROWNUM rnum FROM ( " +
                     "    SELECT o.ORDER_ID, o.USER_ID, o.ORDER_DATE, o.TOTAL_AMOUNT, o.STATUS, " +
                     "           o.SHIPPING_ADDRESS, o.PAYMENT_METHOD, u.NAME AS USER_NAME, u.EMAIL AS USER_EMAIL " +
                     "    FROM ORDERS o " +
                     "    JOIN USERS u ON o.USER_ID = u.USER_ID " +
                     where.toString() +
                     "    ORDER BY o.ORDER_ID DESC " +
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
                    list.add(mapOrder(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding all orders", e);
            throw new AppException("Failed to load orders list.", e);
        }
        return list;
    }

    public int countOrders(String statusFilter, String search) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM ORDERS o JOIN USERS u ON o.USER_ID = u.USER_ID WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND o.STATUS = ? ");
            params.add(statusFilter.trim().toUpperCase());
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(u.NAME) LIKE ? OR LOWER(u.EMAIL) LIKE ? OR TO_CHAR(o.ORDER_ID) = ?) ");
            String q = "%" + search.trim().toLowerCase() + "%";
            params.add(q);
            params.add(q);
            params.add(search.trim());
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
            LOGGER.log(Level.SEVERE, "Error counting orders", e);
        }
        return 0;
    }

    public void updateOrderStatus(Connection conn, long orderId, String newStatus) throws SQLException {
        String sql = "UPDATE ORDERS SET STATUS = ? WHERE ORDER_ID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setLong(2, orderId);
            ps.executeUpdate();
        }
    }

    public List<OrderItem> getOrderItems(Connection conn, long orderId) throws SQLException {
        List<OrderItem> list = new ArrayList<>();
        String sql = "SELECT oi.ORDER_ITEM_ID, oi.ORDER_ID, oi.PRODUCT_ID, oi.QUANTITY, oi.UNIT_PRICE, " +
                     "       p.NAME AS PRODUCT_NAME, p.IMAGE_PATH AS PRODUCT_IMAGE " +
                     "FROM ORDER_ITEMS oi " +
                     "JOIN PRODUCTS p ON oi.PRODUCT_ID = p.PRODUCT_ID " +
                     "WHERE oi.ORDER_ID = ? " +
                     "ORDER BY oi.ORDER_ITEM_ID ASC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setOrderItemId(rs.getLong("ORDER_ITEM_ID"));
                    item.setOrderId(rs.getLong("ORDER_ID"));
                    item.setProductId(rs.getLong("PRODUCT_ID"));
                    item.setQuantity(rs.getInt("QUANTITY"));
                    item.setUnitPrice(rs.getBigDecimal("UNIT_PRICE"));
                    item.setProductName(rs.getString("PRODUCT_NAME"));
                    item.setProductImage(rs.getString("PRODUCT_IMAGE"));
                    list.add(item);
                }
            }
        }
        return list;
    }

    public BigDecimal getTotalRevenue() {
        // Excludes CANCELLED orders to avoid artificial inflation
        String sql = "SELECT NVL(SUM(TOTAL_AMOUNT), 0) FROM ORDERS WHERE STATUS <> 'CANCELLED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error calculating total revenue", e);
        }
        return BigDecimal.ZERO;
    }

    public int getPendingOrdersCount() {
        String sql = "SELECT COUNT(*) FROM ORDERS WHERE STATUS IN ('PLACED', 'PACKED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting pending orders", e);
        }
        return 0;
    }

    public int getTotalOrdersCount() {
        String sql = "SELECT COUNT(*) FROM ORDERS";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting total orders", e);
        }
        return 0;
    }

    public List<Order> getRecentOrders(int limit) {
        return findAllOrders(1, limit, null, null);
    }

    private Order mapOrder(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getLong("ORDER_ID"));
        o.setUserId(rs.getLong("USER_ID"));
        o.setUserName(rs.getString("USER_NAME"));
        o.setUserEmail(rs.getString("USER_EMAIL"));
        o.setOrderDate(rs.getTimestamp("ORDER_DATE"));
        o.setTotalAmount(rs.getBigDecimal("TOTAL_AMOUNT"));
        o.setStatus(rs.getString("STATUS"));
        o.setShippingAddress(rs.getString("SHIPPING_ADDRESS"));
        o.setPaymentMethod(rs.getString("PAYMENT_METHOD"));
        return o;
    }
}
