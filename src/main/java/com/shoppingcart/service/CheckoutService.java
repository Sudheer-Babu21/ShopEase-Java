package com.shoppingcart.service;

import com.shoppingcart.dao.CartDAO;
import com.shoppingcart.dao.OrderDAO;
import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.CartItem;
import com.shoppingcart.model.Order;
import com.shoppingcart.model.OrderItem;
import com.shoppingcart.util.DBConnection;
import com.shoppingcart.util.ValidationUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Executes transactional checkout with inventory locking and concurrency protection.
 * Follows the 15-step checkout sequence required for high data integrity.
 */
public class CheckoutService {

    private static final Logger LOGGER = Logger.getLogger(CheckoutService.class.getName());

    private final CartDAO cartDAO;
    private final OrderDAO orderDAO;

    public CheckoutService() {
        this.cartDAO = new CartDAO();
        this.orderDAO = new OrderDAO();
    }

    public CheckoutService(CartDAO cartDAO, OrderDAO orderDAO) {
        this.cartDAO = cartDAO;
        this.orderDAO = orderDAO;
    }

    /**
     * Executes the checkout process atomically within a single JDBC transaction.
     *
     * @param userId customer ID
     * @param shippingAddress delivery address
     * @param paymentMethod COD or MOCK
     * @return created Order
     */
    public Order processCheckout(long userId, String shippingAddress, String paymentMethod) {
        if (!ValidationUtil.isNotEmpty(shippingAddress) || shippingAddress.trim().length() < 5) {
            throw new AppException("Please provide a valid shipping address (minimum 5 characters).");
        }

        String validPayment = paymentMethod != null ? paymentMethod.trim().toUpperCase() : "";
        if (!Order.PAYMENT_COD.equals(validPayment) && !Order.PAYMENT_MOCK.equals(validPayment)) {
            throw new AppException("Invalid payment method selected. Allowed: COD or MOCK.");
        }

        // 1. Obtain database connection
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();

            // 2. Disable auto-commit
            conn.setAutoCommit(false);

            // 3. Load customer cart
            List<CartItem> cartItems = cartDAO.getCartItemsByUserId(userId);
            if (cartItems.isEmpty()) {
                throw new AppException("Your cart is empty. Add products before checking out.");
            }

            // Sort by product ID ascending to lock rows in consistent order and prevent database deadlocks
            Collections.sort(cartItems, Comparator.comparing(CartItem::getProductId));

            BigDecimal serverCalculatedTotal = BigDecimal.ZERO;

            // 4, 5, 6. Lock product rows, read current price/active status, verify stock
            String lockSql = "SELECT PRODUCT_ID, NAME, PRICE, STOCK_QTY, IS_ACTIVE " +
                             "FROM PRODUCTS WHERE PRODUCT_ID = ? FOR UPDATE";

            for (CartItem ci : cartItems) {
                try (PreparedStatement lockPs = conn.prepareStatement(lockSql)) {
                    lockPs.setLong(1, ci.getProductId());
                    try (ResultSet rs = lockPs.executeQuery()) {
                        if (!rs.next()) {
                            throw new AppException("Product #" + ci.getProductId() + " no longer exists.");
                        }

                        String prodName = rs.getString("NAME");
                        BigDecimal currentPrice = rs.getBigDecimal("PRICE");
                        int currentStock = rs.getInt("STOCK_QTY");
                        int isActive = rs.getInt("IS_ACTIVE");

                        if (isActive != 1) {
                            throw new AppException("'" + prodName + "' is currently deactivated and cannot be purchased.");
                        }

                        if (currentStock < ci.getQuantity()) {
                            throw new AppException("Insufficient stock for '" + prodName + 
                                                   "'. Requested: " + ci.getQuantity() + ", Available: " + currentStock);
                        }

                        // 7. Calculate total on server using authoritative database price
                        BigDecimal lineSubtotal = currentPrice.multiply(BigDecimal.valueOf(ci.getQuantity()));
                        serverCalculatedTotal = serverCalculatedTotal.add(lineSubtotal);

                        // Attach verified unit price to cart item for order creation
                        ci.getProduct().setPrice(currentPrice);
                        ci.getProduct().setName(prodName);
                    }
                }
            }

            // 8. Insert Order using sequence
            Order order = new Order();
            order.setUserId(userId);
            order.setTotalAmount(serverCalculatedTotal);
            order.setStatus(Order.STATUS_PLACED);
            order.setShippingAddress(shippingAddress.trim());
            order.setPaymentMethod(validPayment);

            long orderId = orderDAO.createOrder(conn, order);

            // 9 & 10. Insert ORDER_ITEMS and reduce stock concurrency-safely
            String stockUpdateSql = "UPDATE PRODUCTS SET STOCK_QTY = STOCK_QTY - ? " +
                                   "WHERE PRODUCT_ID = ? AND STOCK_QTY >= ?";

            for (CartItem ci : cartItems) {
                OrderItem item = new OrderItem();
                item.setOrderId(orderId);
                item.setProductId(ci.getProductId());
                item.setQuantity(ci.getQuantity());
                item.setUnitPrice(ci.getProduct().getPrice());
                orderDAO.createOrderItem(conn, item);

                // 10. Conditional stock update
                try (PreparedStatement stockPs = conn.prepareStatement(stockUpdateSql)) {
                    stockPs.setInt(1, ci.getQuantity());
                    stockPs.setLong(2, ci.getProductId());
                    stockPs.setInt(3, ci.getQuantity());
                    int rowsUpdated = stockPs.executeUpdate();

                    // 11. Check that stock update affects exactly one row
                    if (rowsUpdated != 1) {
                        throw new AppException("Concurrent checkout conflict for product '" + 
                                               ci.getProduct().getName() + "'. Please try again.");
                    }
                }
            }

            // 12. Clear customer's cart
            cartDAO.clearCart(conn, userId);

            // 13. Commit transaction
            conn.commit();
            LOGGER.info("Checkout successful! Order #" + orderId + " placed for user #" + userId);

            return order;

        } catch (Exception e) {
            // 14. Rollback on any failure
            DBConnection.rollbackQuietly(conn);
            LOGGER.log(Level.WARNING, "Checkout transaction rolled back for user #" + userId + ": " + e.getMessage(), e);
            if (e instanceof AppException) {
                throw (AppException) e;
            }
            throw new AppException("Checkout processing failed: " + e.getMessage(), e);
        } finally {
            // 15. Close connection and restore auto-commit
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {
                }
                DBConnection.closeQuietly(conn);
            }
        }
    }
}
