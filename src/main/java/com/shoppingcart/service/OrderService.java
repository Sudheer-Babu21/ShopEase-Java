package com.shoppingcart.service;

import com.shoppingcart.dao.OrderDAO;
import com.shoppingcart.dao.ProductDAO;
import com.shoppingcart.dao.UserDAO;
import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.Order;
import com.shoppingcart.model.OrderItem;
import com.shoppingcart.model.Product;
import com.shoppingcart.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service managing customer and administrator order flows, lifecycle transitions, and dashboard metrics.
 */
public class OrderService {

    private static final Logger LOGGER = Logger.getLogger(OrderService.class.getName());

    private final OrderDAO orderDAO;
    private final ProductDAO productDAO;
    private final UserDAO userDAO;

    public OrderService() {
        this.orderDAO = new OrderDAO();
        this.productDAO = new ProductDAO();
        this.userDAO = new UserDAO();
    }

    public OrderService(OrderDAO orderDAO, ProductDAO productDAO, UserDAO userDAO) {
        this.orderDAO = orderDAO;
        this.productDAO = productDAO;
        this.userDAO = userDAO;
    }

    /**
     * Retrieves an order strictly enforcing customer ownership.
     */
    public Order getOrderForCustomer(long orderId, long userId) {
        Optional<Order> orderOpt = orderDAO.findById(orderId);
        if (orderOpt.isEmpty()) {
            throw new AppException("Order #" + orderId + " was not found.");
        }

        Order order = orderOpt.get();
        if (!order.getUserId().equals(userId)) {
            LOGGER.warning("Security violation: User #" + userId + " attempted to view Order #" + orderId + " owned by #" + order.getUserId());
            throw new AppException("Access denied: You do not have permission to view this order.");
        }

        return order;
    }

    public List<Order> getCustomerOrders(long userId) {
        return orderDAO.findOrdersByUserId(userId);
    }

    public Order getOrderForAdmin(long orderId) {
        Optional<Order> orderOpt = orderDAO.findById(orderId);
        if (orderOpt.isEmpty()) {
            throw new AppException("Order #" + orderId + " does not exist.");
        }
        return orderOpt.get();
    }

    public List<Order> getAdminOrders(int page, int pageSize, String statusFilter, String search) {
        return orderDAO.findAllOrders(page, pageSize, statusFilter, search);
    }

    public int countAdminOrders(String statusFilter, String search) {
        return orderDAO.countOrders(statusFilter, search);
    }

    /**
     * Updates order status with strict lifecycle transition rules and automatic inventory restoration upon cancellation.
     */
    public void updateOrderStatus(long orderId, String newStatus) {
        if (newStatus == null) {
            throw new AppException("Invalid status specified.");
        }
        String status = newStatus.trim().toUpperCase();

        Optional<Order> orderOpt = orderDAO.findById(orderId);
        if (orderOpt.isEmpty()) {
            throw new AppException("Order #" + orderId + " not found.");
        }

        Order currentOrder = orderOpt.get();
        String currentStatus = currentOrder.getStatus();

        if (currentStatus.equals(status)) {
            return; // No-op
        }

        // Validate transition
        if (Order.STATUS_DELIVERED.equals(currentStatus)) {
            throw new AppException("A DELIVERED order cannot be modified.");
        }

        if (Order.STATUS_CANCELLED.equals(currentStatus)) {
            throw new AppException("A CANCELLED order cannot be reopened.");
        }

        boolean validTransition = false;
        switch (currentStatus) {
            case Order.STATUS_PLACED:
                validTransition = Order.STATUS_PACKED.equals(status) || Order.STATUS_CANCELLED.equals(status);
                break;
            case Order.STATUS_PACKED:
                validTransition = Order.STATUS_SHIPPED.equals(status) || Order.STATUS_CANCELLED.equals(status);
                break;
            case Order.STATUS_SHIPPED:
                validTransition = Order.STATUS_DELIVERED.equals(status) || Order.STATUS_CANCELLED.equals(status);
                break;
            default:
                break;
        }

        if (!validTransition) {
            throw new AppException("Invalid status transition from " + currentStatus + " to " + status + ".");
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            orderDAO.updateOrderStatus(conn, orderId, status);

            // If order was cancelled, restore stock for all items
            if (Order.STATUS_CANCELLED.equals(status)) {
                String restoreStockSql = "UPDATE PRODUCTS SET STOCK_QTY = STOCK_QTY + ? WHERE PRODUCT_ID = ?";
                for (OrderItem item : currentOrder.getItems()) {
                    try (PreparedStatement ps = conn.prepareStatement(restoreStockSql)) {
                        ps.setInt(1, item.getQuantity());
                        ps.setLong(2, item.getProductId());
                        ps.executeUpdate();
                    }
                }
                LOGGER.info("Stock restored for cancelled order #" + orderId);
            }

            conn.commit();
        } catch (SQLException e) {
            DBConnection.rollbackQuietly(conn);
            LOGGER.log(Level.SEVERE, "Failed to update order status: " + orderId, e);
            throw new AppException("Failed to update order status.", e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {
                }
                DBConnection.closeQuietly(conn);
            }
        }
    }

    /**
     * Compiles aggregate summary data for the Admin Dashboard.
     */
    public Map<String, Object> getDashboardSummary() {
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalOrders", orderDAO.getTotalOrdersCount());
        summary.put("totalCustomers", userDAO.countCustomers());
        summary.put("totalProducts", productDAO.countProducts(null, null, null));
        summary.put("totalRevenue", orderDAO.getTotalRevenue());
        summary.put("pendingOrders", orderDAO.getPendingOrdersCount());
        summary.put("lowStockProducts", productDAO.getLowStockProducts(5));
        summary.put("recentOrders", orderDAO.getRecentOrders(5));
        return summary;
    }
}
