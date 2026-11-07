package com.shoppingcart.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Represents a product in the catalog.
 */
public class Product implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long productId;
    private Long categoryId;
    private String categoryName;
    private String name;
    private String description;
    private BigDecimal price;
    private int stockQty;
    private String imagePath;
    private boolean active;

    public Product() {
        this.active = true;
        this.price = BigDecimal.ZERO;
    }

    public Product(Long productId, Long categoryId, String categoryName, String name, 
                   String description, BigDecimal price, int stockQty, String imagePath, boolean active) {
        this.productId = productId;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.name = name;
        this.description = description;
        this.price = price != null ? price : BigDecimal.ZERO;
        this.stockQty = stockQty;
        this.imagePath = imagePath;
        this.active = active;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price != null ? price : BigDecimal.ZERO;
    }

    public int getStockQty() {
        return stockQty;
    }

    public void setStockQty(int stockQty) {
        this.stockQty = stockQty;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public boolean isAvailable() {
        return active && stockQty > 0;
    }
}
