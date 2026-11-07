<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.Product" %>
<%@ page import="com.shoppingcart.model.User" %>
<%@ page import="com.shoppingcart.filter.AuthenticationFilter" %>
<%@ page import="com.shoppingcart.util.CSRFUtil" %>
<%@ page import="com.shoppingcart.util.CurrencyUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%
    Product p = (Product) request.getAttribute("product");
    request.setAttribute("pageTitle", p != null ? p.getName() : "Product Details");
    User currentUser = (User) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
    String csrfToken = CSRFUtil.getToken(session);
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<% if (p != null) { %>
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="<%= ctx %>/products" class="text-decoration-none">Catalog</a></li>
            <li class="breadcrumb-item"><a href="<%= ctx %>/products?category=<%= p.getCategoryId() %>" class="text-decoration-none"><%= p.getCategoryName() %></a></li>
            <li class="breadcrumb-item active" aria-current="page"><%= p.getName() %></li>
        </ol>
    </nav>

    <div class="card border-0 shadow-sm p-4 p-md-5 mb-5">
        <div class="row g-4 align-items-center">
            <!-- Product Image -->
            <div class="col-12 col-md-5 text-center">
                <div class="rounded-4 overflow-hidden shadow-sm border bg-light p-3">
                    <img src="<%= ctx %>/<%= p.getImagePath() != null ? p.getImagePath() : "assets/images/placeholder.jpg" %>" 
                         alt="<%= ValidationUtil.escapeHtml(p.getName()) %>" 
                         class="img-fluid rounded-3"
                         style="max-height: 380px; object-fit: contain;"
                         onerror="this.onerror=null; this.src='<%= ctx %>/assets/images/placeholder.jpg';">
                </div>
            </div>

            <!-- Product Info & Actions -->
            <div class="col-12 col-md-7">
                <span class="badge bg-primary text-uppercase px-3 py-2 mb-2">
                    <%= p.getCategoryName() != null ? p.getCategoryName() : "General" %>
                </span>

                <h1 class="h2 fw-bold text-dark mb-2"><%= p.getName() %></h1>

                <div class="d-flex align-items-baseline gap-3 mb-3">
                    <span class="display-6 fw-bold text-primary"><%= CurrencyUtil.format(p.getPrice()) %></span>
                    <% if (p.getStockQty() > 0) { %>
                        <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-2">
                            <i class="bi bi-check2-circle me-1"></i> In Stock (<%= p.getStockQty() %> available)
                        </span>
                    <% } else { %>
                        <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-3 py-2">
                            <i class="bi bi-x-circle me-1"></i> Out of Stock
                        </span>
                    <% } %>
                </div>

                <hr class="my-4">

                <h6 class="fw-bold text-uppercase text-muted small mb-2">Product Description</h6>
                <p class="text-secondary leading-relaxed mb-4">
                    <%= p.getDescription() != null ? p.getDescription() : "No detailed description available." %>
                </p>

                <% if (p.getStockQty() > 0) { %>
                    <% if (currentUser != null) { %>
                        <form action="<%= ctx %>/cart/add" method="post" class="row g-3 align-items-end mb-4">
                            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                            <input type="hidden" name="productId" value="<%= p.getProductId() %>">

                            <div class="col-auto">
                                <label for="quantityInput" class="form-label fw-semibold small text-muted">Quantity</label>
                                <input type="number" id="quantityInput" name="quantity" class="form-control" 
                                       value="1" min="1" max="<%= p.getStockQty() %>" style="width: 100px;">
                            </div>

                            <div class="col-auto">
                                <button type="submit" class="btn btn-primary px-4 py-2 shadow-sm">
                                    <i class="bi bi-cart-plus me-1"></i> Add to Shopping Cart
                                </button>
                            </div>
                        </form>
                    <% } else { %>
                        <div class="p-3 bg-light rounded-3 border mb-4">
                            <p class="small text-muted mb-2">Please sign in to add this item to your cart and proceed to checkout.</p>
                            <a href="<%= ctx %>/auth/login?redirect=<%= ctx %>/products/view?id=<%= p.getProductId() %>" 
                               class="btn btn-primary btn-sm px-4">
                                <i class="bi bi-box-arrow-in-right me-1"></i> Sign In to Buy
                            </a>
                        </div>
                    <% } %>
                <% } else { %>
                    <div class="alert alert-warning mb-4">
                        <i class="bi bi-clock-history me-1"></i> This item is currently sold out. Please check back later.
                    </div>
                <% } %>

                <!-- Security Feature Highlights -->
                <div class="row g-2 text-muted small border-top pt-3">
                    <div class="col-6"><i class="bi bi-shield-check text-success me-1"></i> Real-Time Inventory Locking</div>
                    <div class="col-6"><i class="bi bi-truck text-primary me-1"></i> Fast Reliable Shipping</div>
                    <div class="col-6"><i class="bi bi-arrow-repeat text-info me-1"></i> Concurrency-Safe Checkout</div>
                    <div class="col-6"><i class="bi bi-cash-stack text-warning me-1"></i> COD & Mock Payment Support</div>
                </div>
            </div>
        </div>
    </div>
<% } %>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
