package com.shoppingcart.model;

import java.io.Serializable;

/**
 * Represents a product category.
 */
public class Category implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long categoryId;
    private String name;
    private String description;

    public Category() {
    }

    public Category(Long categoryId, String name, String description) {
        this.categoryId = categoryId;
        this.name = name;
        this.description = description;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
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
}
