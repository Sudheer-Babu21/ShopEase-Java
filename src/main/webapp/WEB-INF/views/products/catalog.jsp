<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.Product" %>
<%@ page import="com.shoppingcart.model.Category" %>
<%@ page import="com.shoppingcart.model.User" %>
<%@ page import="com.shoppingcart.filter.AuthenticationFilter" %>
<%@ page import="com.shoppingcart.util.CSRFUtil" %>
<%@ page import="com.shoppingcart.util.CurrencyUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="java.util.List" %>
<%!
    // Helper to select an intuitive Bootstrap icon for categories
    private String getCategoryIcon(String catName) {
        if (catName == null) return "bi-tag-fill";
        String lower = catName.toLowerCase();
        if (lower.contains("electronic")) return "bi-laptop";
        if (lower.contains("fashion") || lower.contains("clothing")) return "bi-bag-heart";
        if (lower.contains("shoe") || lower.contains("footwear")) return "bi-boot";
        if (lower.contains("home") || lower.contains("kitchen")) return "bi-house-heart";
        if (lower.contains("beauty") || lower.contains("personal")) return "bi-flower1";
        if (lower.contains("book") || lower.contains("education")) return "bi-book-half";
        if (lower.contains("sport") || lower.contains("fitness")) return "bi-activity";
        if (lower.contains("watch") || lower.contains("bag") || lower.contains("accessor")) return "bi-watch";
        if (lower.contains("toy") || lower.contains("game")) return "bi-controller";
        if (lower.contains("office") || lower.contains("stationery")) return "bi-pen-fill";
        return "bi-tag-fill";
    }
%>
<%
    request.setAttribute("pageTitle", "Product Catalog");
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Product> featured = (List<Product>) request.getAttribute("featuredProducts");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    Long selectedCategory = (Long) request.getAttribute("selectedCategory");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    String selectedSort = (String) request.getAttribute("selectedSort");
    if (selectedSort == null) selectedSort = "";
    String csrfToken = CSRFUtil.getToken(session);
    User currentUser = (User) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
    String ctx = request.getContextPath();

    // Query string helper to preserve current filters on pagination and cart actions
    StringBuilder filterParams = new StringBuilder();
    if (selectedCategory != null) filterParams.append("&category=").append(selectedCategory);
    if (searchKeyword != null && !searchKeyword.isEmpty()) filterParams.append("&q=").append(searchKeyword);
    if (!selectedSort.isEmpty()) filterParams.append("&sort=").append(selectedSort);
    String filterQuery = filterParams.toString();
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<!-- Hero Banner (Shown only on initial page load without active search or category filters) -->
<% if ((searchKeyword == null || searchKeyword.isEmpty()) && selectedCategory == null && (currentPage == null || currentPage == 1)) { %>
    <div class="hero-banner mb-4">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <span class="badge bg-primary text-uppercase px-3 py-2 mb-2 shadow-sm">
                    <i class="bi bi-patch-check-fill me-1"></i> Live Product Catalog
                </span>
                <h1 class="display-5 fw-bold mb-3">Premium Quality, <span class="brand-gradient">Instant Delivery.</span></h1>
                <p class="lead text-light text-opacity-75 mb-4">
                    Explore our diverse collection across 10 categories including Electronics, Fashion, Footwear, Home & Kitchen, Beauty, Books, Sports, Accessories, Toys, and Stationery.
                </p>
                <div class="d-flex flex-wrap gap-2">
                    <a href="#catalogGrid" class="btn btn-primary px-4 py-2 shadow">
                        <i class="bi bi-bag-check me-1"></i> Explore <%= totalCount != null ? totalCount : 50 %> Products
                    </a>
                </div>
            </div>
        </div>
    </div>
<% } %>

<!-- Catalog Section -->
<div class="row g-4" id="catalogGrid">
    <!-- Category Sidebar -->
    <div class="col-12 col-md-4 col-lg-3">
        <div class="card border-0 shadow-sm p-3 mb-4 sticky-top" style="top: 80px; z-index: 10;">
            <h6 class="fw-bold text-dark text-uppercase mb-3 d-flex align-items-center justify-content-between">
                <span>Categories</span>
                <i class="bi bi-funnel text-muted"></i>
            </h6>

            <div class="d-flex flex-column gap-1">
                <a href="<%= ctx %>/products<%= (searchKeyword != null && !searchKeyword.isEmpty()) ? "?q=" + searchKeyword : "" %>" 
                   class="category-filter-item <%= (selectedCategory == null) ? "active" : "" %>">
                    <span><i class="bi bi-grid-fill me-2 text-primary"></i>All Categories</span>
                    <i class="bi bi-chevron-right small"></i>
                </a>

                <% if (categories != null) {
                    for (Category cat : categories) {
                        boolean isSelected = selectedCategory != null && selectedCategory.equals(cat.getCategoryId());
                        String catUrl = ctx + "/products?category=" + cat.getCategoryId() + 
                                       ((searchKeyword != null && !searchKeyword.isEmpty()) ? "&q=" + searchKeyword : "") +
                                       (!selectedSort.isEmpty() ? "&sort=" + selectedSort : "");
                %>
                    <a href="<%= catUrl %>" class="category-filter-item <%= isSelected ? "active" : "" %>">
                        <span><i class="bi <%= getCategoryIcon(cat.getName()) %> me-2 text-secondary"></i><%= cat.getName() %></span>
                        <i class="bi bi-chevron-right small"></i>
                    </a>
                <%  } 
                   } %>
            </div>
        </div>

        <!-- Trust & Security Highlights -->
        <div class="card bg-dark text-white border-0 shadow-sm p-3 d-none d-md-block mb-4">
            <h6 class="fw-bold text-warning mb-2"><i class="bi bi-shield-check me-1"></i> Verified Inventory</h6>
            <p class="small text-secondary mb-2">
                Live stock availability synced with Oracle XE 10g database. Concurrency-safe atomic checkout with row-level locks.
            </p>
            <div class="small text-light text-opacity-75">
                <i class="bi bi-truck text-info me-1"></i> Fast Shipping &bull; COD Available
            </div>
        </div>
    </div>

    <!-- Main Products Listing -->
    <div class="col-12 col-md-8 col-lg-9">
        <!-- Sort and Controls Bar -->
        <div class="card border-0 shadow-sm p-3 mb-4">
            <div class="row align-items-center justify-content-between g-2">
                <div class="col-12 col-sm-6">
                    <span class="text-muted small">
                        Showing <strong><%= products != null ? products.size() : 0 %></strong> of <strong><%= totalCount != null ? totalCount : 0 %></strong> items
                        <% if (searchKeyword != null && !searchKeyword.isEmpty()) { %>
                            for "<span class="text-dark fw-bold"><%= ValidationUtil.escapeHtml(searchKeyword) %></span>"
                            <a href="<%= ctx %>/products<%= selectedCategory != null ? "?category=" + selectedCategory : "" %>" class="text-danger ms-1 text-decoration-none" title="Clear Search">
                                <i class="bi bi-x-circle-fill"></i>
                            </a>
                        <% } %>
                    </span>
                </div>

                <div class="col-12 col-sm-6 text-sm-end">
                    <form action="<%= ctx %>/products" method="get" class="d-inline-flex align-items-center gap-2">
                        <% if (selectedCategory != null) { %>
                            <input type="hidden" name="category" value="<%= selectedCategory %>">
                        <% } %>
                        <% if (searchKeyword != null && !searchKeyword.isEmpty()) { %>
                            <input type="hidden" name="q" value="<%= ValidationUtil.escapeHtml(searchKeyword) %>">
                        <% } %>
                        <label for="sort" class="small text-muted text-nowrap">Sort By:</label>
                        <select name="sort" id="sort" class="form-select form-select-sm" onchange="this.form.submit()">
                            <option value="" <%= "".equals(selectedSort) ? "selected" : "" %>>Featured / Newest</option>
                            <option value="price_asc" <%= "price_asc".equals(selectedSort) ? "selected" : "" %>>Price: Low to High</option>
                            <option value="price_desc" <%= "price_desc".equals(selectedSort) ? "selected" : "" %>>Price: High to Low</option>
                            <option value="name_asc" <%= "name_asc".equals(selectedSort) ? "selected" : "" %>>Name: A to Z</option>
                            <option value="name_desc" <%= "name_desc".equals(selectedSort) ? "selected" : "" %>>Name: Z to A</option>
                        </select>
                    </form>
                </div>
            </div>
        </div>

        <!-- Products Grid -->
        <% if (products == null || products.isEmpty()) { %>
            <div class="text-center py-5 bg-white rounded-4 shadow-sm border p-4">
                <i class="bi bi-bag-x display-3 text-muted mb-3 d-inline-block"></i>
                <h4 class="fw-bold">No Products Found</h4>
                <p class="text-muted small mb-4">
                    <% if (searchKeyword != null && !searchKeyword.isEmpty()) { %>
                        No products matched your search for "<strong><%= ValidationUtil.escapeHtml(searchKeyword) %></strong>".
                    <% } else { %>
                        There are currently no products available in this category.
                    <% } %>
                    <br>Try checking your spelling, selecting another category, or resetting filters.
                </p>
                <a href="<%= ctx %>/products" class="btn btn-outline-primary btn-sm px-4 py-2">
                    <i class="bi bi-arrow-counterclockwise me-1"></i> Reset All Filters
                </a>
            </div>
        <% } else { %>
            <div class="row row-cols-1 row-cols-sm-2 row-cols-lg-3 g-4 mb-4">
                <% for (Product p : products) { 
                    BigDecimal price = p.getPrice();
                    BigDecimal mrp = price.multiply(new BigDecimal("1.25")).setScale(0, RoundingMode.CEILING);
                    int stock = p.getStockQty();
                    long ratingSeed = p.getProductId() != null ? p.getProductId() : 1L;
                    int reviewsCount = (int) ((ratingSeed * 7) % 65) + 12;
                %>
                    <div class="col">
                        <div class="product-card">
                            <!-- Product Image Container with consistent sizing and stock badge -->
                            <div class="product-image-container">
                                <a href="<%= ctx %>/products/view?id=<%= p.getProductId() %>">
                                    <img src="<%= ctx %>/<%= p.getImagePath() != null ? p.getImagePath() : "assets/images/placeholder.jpg" %>" 
                                         alt="<%= ValidationUtil.escapeHtml(p.getName()) %>"
                                         onerror="this.onerror=null; this.src='<%= ctx %>/assets/images/placeholder.jpg';">
                                </a>

                                <!-- Stock Status Badges -->
                                <% if (stock <= 0) { %>
                                    <span class="position-absolute top-0 end-0 m-2 badge bg-danger shadow-sm">
                                        <i class="bi bi-x-circle me-1"></i>Out of Stock
                                    </span>
                                <% } else if (stock <= 5) { %>
                                    <span class="position-absolute top-0 end-0 m-2 badge bg-warning text-dark shadow-sm">
                                        <i class="bi bi-lightning-fill me-1"></i>Only <%= stock %> Left!
                                    </span>
                                <% } %>
                            </div>

                            <div class="card-body">
                                <!-- Category Badge -->
                                <span class="badge bg-light text-primary border text-uppercase mb-2 align-self-start" style="font-size: 0.7rem; font-weight: 600;">
                                    <i class="bi <%= getCategoryIcon(p.getCategoryName()) %> me-1"></i>
                                    <%= p.getCategoryName() != null ? p.getCategoryName() : "General" %>
                                </span>

                                <!-- Product Title -->
                                <h6 class="card-title fw-bold mb-1">
                                    <a href="<%= ctx %>/products/view?id=<%= p.getProductId() %>" class="text-dark text-decoration-none product-title-link">
                                        <%= p.getName() %>
                                    </a>
                                </h6>

                                <!-- Rating Stars -->
                                <div class="d-flex align-items-center gap-1 mb-2 text-warning" style="font-size: 0.75rem;">
                                    <i class="bi bi-star-fill"></i>
                                    <i class="bi bi-star-fill"></i>
                                    <i class="bi bi-star-fill"></i>
                                    <i class="bi bi-star-fill"></i>
                                    <i class="bi bi-star-half"></i>
                                    <span class="text-muted ms-1">4.<%= (ratingSeed % 4) + 5 %> (<%= reviewsCount %>)</span>
                                </div>

                                <!-- Product Short Description -->
                                <p class="card-text text-muted small flex-grow-1 mb-3 product-desc-clamp">
                                    <%= p.getDescription() != null ? p.getDescription() : "" %>
                                </p>

                                <!-- Price and Stock Indicator -->
                                <div class="d-flex flex-wrap align-items-baseline gap-2 mb-2">
                                    <span class="product-price fs-5 fw-bold"><%= CurrencyUtil.format(price) %></span>
                                    <span class="text-muted text-decoration-line-through small" style="font-size: 0.85rem;"><%= CurrencyUtil.format(mrp) %></span>
                                    <span class="badge bg-success-subtle text-success border border-success-subtle px-1 py-0" style="font-size: 0.65rem; font-weight: 700;">20% OFF</span>
                                </div>

                                <div class="d-flex align-items-center justify-content-between mb-3">
                                    <% if (stock > 5) { %>
                                        <small class="text-success fw-semibold"><i class="bi bi-check-circle-fill me-1"></i>In Stock</small>
                                    <% } else if (stock > 0) { %>
                                        <small class="text-warning-emphasis fw-semibold"><i class="bi bi-exclamation-triangle-fill me-1"></i>Low Stock (<%= stock %> left)</small>
                                    <% } else { %>
                                        <small class="text-danger fw-semibold"><i class="bi bi-x-circle-fill me-1"></i>Temporarily Sold Out</small>
                                    <% } %>
                                </div>

                                <!-- Action Buttons -->
                                <div class="d-flex align-items-center gap-2 mt-auto pt-2 border-top">
                                    <a href="<%= ctx %>/products/view?id=<%= p.getProductId() %>" class="btn btn-outline-secondary btn-sm px-2 flex-grow-1" title="View Full Details">
                                        <i class="bi bi-eye"></i> Details
                                    </a>

                                    <% if (stock > 0) { %>
                                        <% if (currentUser != null) { %>
                                            <form action="<%= ctx %>/cart/add" method="post" class="m-0 flex-grow-1">
                                                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                                                <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                                                <input type="hidden" name="quantity" value="1">
                                                <input type="hidden" name="redirect" value="<%= ctx %>/products?page=<%= currentPage != null ? currentPage : 1 %><%= filterQuery %>">
                                                <button type="submit" class="btn btn-primary btn-sm w-100 px-2" title="Add to Cart">
                                                    <i class="bi bi-cart-plus me-1"></i> Add
                                                </button>
                                            </form>
                                        <% } else { %>
                                            <a href="<%= ctx %>/auth/login?redirect=<%= ctx %>/products?page=<%= currentPage != null ? currentPage : 1 %><%= filterQuery %>" class="btn btn-outline-primary btn-sm flex-grow-1 px-2" title="Sign in to add to cart">
                                                <i class="bi bi-cart-plus me-1"></i> Add
                                            </a>
                                        <% } %>
                                    <% } else { %>
                                        <button class="btn btn-secondary btn-sm flex-grow-1 px-2" disabled title="Product is out of stock">
                                            <i class="bi bi-dash-circle me-1"></i> Sold Out
                                        </button>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>

            <!-- Oracle 10g Compatible Pagination Controls -->
            <% if (totalPages != null && totalPages > 1) { %>
                <nav aria-label="Catalog pagination" class="my-4">
                    <ul class="pagination justify-content-center">
                        <li class="page-item <%= (currentPage <= 1) ? "disabled" : "" %>">
                            <a class="page-link" href="<%= ctx %>/products?page=<%= currentPage - 1 %><%= filterQuery %>">
                                &laquo; Previous
                            </a>
                        </li>

                        <% for (int i = 1; i <= totalPages; i++) { %>
                            <li class="page-item <%= (i == currentPage) ? "active" : "" %>">
                                <a class="page-link" href="<%= ctx %>/products?page=<%= i %><%= filterQuery %>">
                                    <%= i %>
                                </a>
                            </li>
                        <% } %>

                        <li class="page-item <%= (currentPage >= totalPages) ? "disabled" : "" %>">
                            <a class="page-link" href="<%= ctx %>/products?page=<%= currentPage + 1 %><%= filterQuery %>">
                                Next &raquo;
                            </a>
                        </li>
                    </ul>
                </nav>
            <% } %>

        <% } %>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
