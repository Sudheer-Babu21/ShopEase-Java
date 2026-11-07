package com.shoppingcart.service;

import com.shoppingcart.dao.CartDAO;
import com.shoppingcart.dao.ProductDAO;
import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.CartItem;
import com.shoppingcart.model.Product;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * Service managing customer shopping cart operations and stock validations.
 */
public class CartService {

    private final CartDAO cartDAO;
    private final ProductDAO productDAO;

    public CartService() {
        this.cartDAO = new CartDAO();
        this.productDAO = new ProductDAO();
    }

    public CartService(CartDAO cartDAO, ProductDAO productDAO) {
        this.cartDAO = cartDAO;
        this.productDAO = productDAO;
    }

    public List<CartItem> getCart(long userId) {
        return cartDAO.getCartItemsByUserId(userId);
    }

    public BigDecimal calculateCartTotal(List<CartItem> items) {
        if (items == null || items.isEmpty()) {
            return BigDecimal.ZERO;
        }
        BigDecimal total = BigDecimal.ZERO;
        for (CartItem item : items) {
            if (item.getProduct() != null && item.getProduct().isActive()) {
                total = total.add(item.getSubtotal());
            }
        }
        return total;
    }

    public void addToCart(long userId, long productId, int quantity) {
        if (quantity <= 0) {
            throw new AppException("Quantity must be greater than zero.");
        }

        Optional<Product> prodOpt = productDAO.findById(productId);
        if (prodOpt.isEmpty() || !prodOpt.get().isActive()) {
            throw new AppException("This product is currently unavailable.");
        }

        Product product = prodOpt.get();
        if (product.getStockQty() < quantity) {
            throw new AppException("Only " + product.getStockQty() + " unit(s) available in stock.");
        }

        // Check existing cart quantity
        List<CartItem> currentCart = cartDAO.getCartItemsByUserId(userId);
        int existingQty = 0;
        for (CartItem ci : currentCart) {
            if (ci.getProductId().equals(productId)) {
                existingQty = ci.getQuantity();
                break;
            }
        }

        if (existingQty + quantity > product.getStockQty()) {
            throw new AppException("You already have " + existingQty + " in your cart. Only " + product.getStockQty() + " available.");
        }

        cartDAO.addItem(userId, productId, quantity);
    }

    public void updateQuantity(long userId, long productId, int quantity) {
        if (quantity <= 0) {
            cartDAO.removeItem(userId, productId);
            return;
        }

        Optional<Product> prodOpt = productDAO.findById(productId);
        if (prodOpt.isEmpty() || !prodOpt.get().isActive()) {
            cartDAO.removeItem(userId, productId);
            throw new AppException("Product is no longer available and was removed from your cart.");
        }

        Product product = prodOpt.get();
        if (product.getStockQty() < quantity) {
            throw new AppException("Cannot set quantity to " + quantity + ". Only " + product.getStockQty() + " in stock.");
        }

        cartDAO.updateQuantity(userId, productId, quantity);
    }

    public void removeFromCart(long userId, long productId) {
        cartDAO.removeItem(userId, productId);
    }

    public int getCartCount(long userId) {
        return cartDAO.getCartCount(userId);
    }
}
