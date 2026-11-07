package com.shoppingcart.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Represents an immutable snapshot line item within an order.
 * Preserves historical unit price at checkout.
 */
public class OrderItem implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long orderItemId;
    private Long orderId;
    private Long productId;
    private String productName;
    private String productImage;
    private int quantity;
    private BigDecimal unitPrice;

    public OrderItem() {
        this.unitPrice = BigDecimal.ZERO;
    }

    public OrderItem(Long orderItemId, Long orderId, Long productId, String productName, 
                     String productImage, int quantity, BigDecimal unitPrice) {
        this.orderItemId = orderItemId;
        this.orderId = orderId;
        this.productId = productId;
        this.productName = productName;
        this.productImage = productImage;
        this.quantity = quantity;
        this.unitPrice = unitPrice != null ? unitPrice : BigDecimal.ZERO;
    }

    public Long getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(Long orderItemId) {
        this.orderItemId = orderItemId;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getProductImage() {
        return productImage;
    }

    public void setProductImage(String productImage) {
        this.productImage = productImage;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice != null ? unitPrice : BigDecimal.ZERO;
    }

    public BigDecimal getSubtotal() {
        if (unitPrice == null) return BigDecimal.ZERO;
        return unitPrice.multiply(BigDecimal.valueOf(quantity));
    }
}
