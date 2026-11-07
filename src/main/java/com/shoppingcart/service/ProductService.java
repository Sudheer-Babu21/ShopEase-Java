package com.shoppingcart.service;

import com.shoppingcart.dao.CategoryDAO;
import com.shoppingcart.dao.ProductDAO;
import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.Category;
import com.shoppingcart.model.Product;
import com.shoppingcart.util.ValidationUtil;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * Service managing product catalog, inventory, and category maintenance.
 */
public class ProductService {

    private final ProductDAO productDAO;
    private final CategoryDAO categoryDAO;

    public ProductService() {
        this.productDAO = new ProductDAO();
        this.categoryDAO = new CategoryDAO();
    }

    public ProductService(ProductDAO productDAO, CategoryDAO categoryDAO) {
        this.productDAO = productDAO;
        this.categoryDAO = categoryDAO;
    }

    public Optional<Product> getProductById(long productId) {
        return productDAO.findById(productId);
    }

    public List<Product> getStorefrontProducts(int page, int pageSize, Long categoryId, String keyword, String sortBy) {
        return productDAO.findProducts(page, pageSize, categoryId, keyword, true, sortBy);
    }

    public int countStorefrontProducts(Long categoryId, String keyword) {
        return productDAO.countProducts(categoryId, keyword, true);
    }

    public List<Product> getAllProductsForAdmin(int page, int pageSize, Long categoryId, String keyword, String sortBy) {
        return productDAO.findProducts(page, pageSize, categoryId, keyword, false, sortBy);
    }

    public int countAllProductsForAdmin(Long categoryId, String keyword) {
        return productDAO.countProducts(categoryId, keyword, false);
    }

    public List<Product> getFeaturedProducts(int limit) {
        return productDAO.findFeatured(limit);
    }

    public List<Category> getAllCategories() {
        return categoryDAO.findAll();
    }

    public Optional<Category> getCategoryById(long categoryId) {
        return categoryDAO.findById(categoryId);
    }

    public Category createCategory(String name, String description) {
        if (!ValidationUtil.isNotEmpty(name) || name.trim().length() < 2) {
            throw new AppException("Category name must be at least 2 characters.");
        }
        if (categoryDAO.existsByName(name.trim(), null)) {
            throw new AppException("A category with this name already exists.");
        }

        Category cat = new Category();
        cat.setName(name.trim());
        cat.setDescription(description != null ? description.trim() : null);
        return categoryDAO.create(cat);
    }

    public void updateCategory(long categoryId, String name, String description) {
        if (!ValidationUtil.isNotEmpty(name) || name.trim().length() < 2) {
            throw new AppException("Category name must be at least 2 characters.");
        }
        if (categoryDAO.existsByName(name.trim(), categoryId)) {
            throw new AppException("Another category already has this name.");
        }

        Category cat = new Category();
        cat.setCategoryId(categoryId);
        cat.setName(name.trim());
        cat.setDescription(description != null ? description.trim() : null);
        categoryDAO.update(cat);
    }

    public void deleteCategory(long categoryId) {
        categoryDAO.delete(categoryId);
    }

    public Product saveProduct(Product product) {
        validateProduct(product);

        if (product.getProductId() == null || product.getProductId() <= 0) {
            return productDAO.create(product);
        } else {
            productDAO.update(product);
            return product;
        }
    }

    public void toggleProductStatus(long productId, boolean active) {
        productDAO.toggleActive(productId, active);
    }

    private void validateProduct(Product product) {
        if (!ValidationUtil.isNotEmpty(product.getName()) || product.getName().trim().length() < 2) {
            throw new AppException("Product name must be at least 2 characters.");
        }

        if (product.getCategoryId() == null || product.getCategoryId() <= 0) {
            throw new AppException("Please select a valid category.");
        }

        if (categoryDAO.findById(product.getCategoryId()).isEmpty()) {
            throw new AppException("Selected category does not exist.");
        }

        if (product.getPrice() == null || product.getPrice().compareTo(BigDecimal.ZERO) < 0) {
            throw new AppException("Product price must be greater than or equal to 0.00.");
        }

        if (product.getStockQty() < 0) {
            throw new AppException("Stock quantity cannot be negative.");
        }
    }
}
