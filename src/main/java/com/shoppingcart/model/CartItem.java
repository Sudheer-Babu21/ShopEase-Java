package com.shoppingcart.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Represents a single line item in a customer's persistent shopping cart.
 */
public class CartItem implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long cartItemId;
    private Long userId;
    private Long productId;
    private int quantity;
    private Product product;

    public CartItem() {
    }

    public CartItem(Long cartItemId, Long userId, Long productId, int quantity, Product product) {
        this.cartItemId = cartItemId;
        this.userId = userId;
        this.productId = productId;
        this.quantity = quantity;
        this.product = product;
    }

    public Long getCartItemId() {
        return cartItemId;
    }

    public void setCartItemId(Long cartItemId) {
        this.cartItemId = cartItemId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public BigDecimal getSubtotal() {
        if (product == null || product.getPrice() == null) {
            return BigDecimal.ZERO;
        }
        return product.getPrice().multiply(BigDecimal.valueOf(quantity));
    }
}
