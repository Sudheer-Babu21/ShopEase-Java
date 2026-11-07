<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.CartItem" %>
<%@ page import="com.shoppingcart.model.Product" %>
<%@ page import="com.shoppingcart.util.CSRFUtil" %>
<%@ page import="com.shoppingcart.util.CurrencyUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Your Shopping Cart");
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    BigDecimal cartTotal = (BigDecimal) request.getAttribute("cartTotal");
    if (cartTotal == null) cartTotal = BigDecimal.ZERO;
    String csrfToken = CSRFUtil.getToken(session);
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row g-4 mb-5">
    <div class="col-12">
        <h2 class="fw-bold mb-1"><i class="bi bi-cart3 me-2 text-primary"></i>Shopping Cart</h2>
        <p class="text-muted small">Review your items before proceeding to secure checkout</p>
    </div>

    <% if (cartItems == null || cartItems.isEmpty()) { %>
        <div class="col-12">
            <div class="text-center py-5 bg-white rounded-4 shadow-sm border p-4">
                <i class="bi bi-cart-x display-1 text-muted mb-3 d-inline-block"></i>
                <h4 class="fw-bold text-dark">Your Shopping Cart is Empty</h4>
                <p class="text-muted small mb-4">Looks like you haven't added any products to your cart yet.</p>
                <a href="<%= ctx %>/products" class="btn btn-primary px-4 py-2">
                    <i class="bi bi-grid me-1"></i> Start Shopping Now
                </a>
            </div>
        </div>
    <% } else { %>
        <!-- Cart Items List -->
        <div class="col-12 col-lg-8">
            <div class="card border-0 shadow-sm overflow-hidden mb-4">
                <div class="table-responsive">
                    <table class="table align-middle mb-0 cart-table">
                        <thead>
                            <tr>
                                <th scope="col" class="ps-4">Product</th>
                                <th scope="col">Price</th>
                                <th scope="col" style="width: 140px;">Quantity</th>
                                <th scope="col">Subtotal</th>
                                <th scope="col" class="text-end pe-4">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (CartItem ci : cartItems) { 
                                Product prod = ci.getProduct();
                                boolean available = prod != null && prod.isActive() && prod.getStockQty() >= ci.getQuantity();
                            %>
                                <tr>
                                    <td class="ps-4 py-3">
                                        <div class="d-flex align-items-center gap-3">
                                            <img src="<%= ctx %>/<%= (prod != null && prod.getImagePath() != null) ? prod.getImagePath() : "assets/images/placeholder.jpg" %>" 
                                                 alt="<%= (prod != null) ? ValidationUtil.escapeHtml(prod.getName()) : "Item" %>" 
                                                 class="rounded-3 border bg-white p-1" style="width: 64px; height: 64px; object-fit: contain;"
                                                 onerror="this.onerror=null; this.src='<%= ctx %>/assets/images/placeholder.jpg';">
                                            <div>
                                                <h6 class="mb-1 fw-bold">
                                                    <% if (prod != null) { %>
                                                        <a href="<%= ctx %>/products/view?id=<%= prod.getProductId() %>" class="text-dark text-decoration-none">
                                                            <%= prod.getName() %>
                                                        </a>
                                                    <% } else { %>
                                                        Item #<%= ci.getProductId() %>
                                                    <% } %>
                                                </h6>
                                                <span class="text-muted small">
                                                    <%= (prod != null && prod.getCategoryName() != null) ? prod.getCategoryName() : "" %>
                                                </span>
                                                <% if (prod != null && !prod.isActive()) { %>
                                                    <div class="badge bg-danger mt-1">Discontinued</div>
                                                <% } else if (prod != null && prod.getStockQty() < ci.getQuantity()) { %>
                                                    <div class="badge bg-warning text-dark mt-1">Only <%= prod.getStockQty() %> left in stock</div>
                                                <% } %>
                                            </div>
                                        </div>
                                    </td>

                                    <td>
                                        <span class="fw-semibold text-secondary">
                                            <%= (prod != null && prod.getPrice() != null) ? CurrencyUtil.format(prod.getPrice()) : CurrencyUtil.format(BigDecimal.ZERO) %>
                                        </span>
                                    </td>

                                    <td>
                                        <form action="<%= ctx %>/cart/update" method="post" class="d-flex align-items-center gap-1">
                                            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                                            <input type="hidden" name="productId" value="<%= ci.getProductId() %>">
                                            <input type="number" name="quantity" class="form-control form-control-sm text-center" 
                                                   value="<%= ci.getQuantity() %>" min="1" max="<%= (prod != null) ? prod.getStockQty() : 10 %>" 
                                                   style="width: 65px;" required>
                                            <button type="submit" class="btn btn-outline-secondary btn-sm" title="Update Quantity">
                                                <i class="bi bi-arrow-repeat"></i>
                                            </button>
                                        </form>
                                    </td>

                                    <td>
                                        <span class="fw-bold text-primary">
                                            <%= CurrencyUtil.format(ci.getSubtotal()) %>
                                        </span>
                                    </td>

                                    <td class="text-end pe-4">
                                        <form action="<%= ctx %>/cart/remove" method="post" class="d-inline">
                                            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                                            <input type="hidden" name="productId" value="<%= ci.getProductId() %>">
                                            <button type="submit" class="btn btn-outline-danger btn-sm border-0" 
                                                    title="Remove item" data-confirm="Remove this item from your cart?">
                                                <i class="bi bi-trash3"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <div class="card-footer bg-white p-3 d-flex justify-content-between align-items-center">
                    <a href="<%= ctx %>/products" class="btn btn-outline-secondary btn-sm">
                        <i class="bi bi-arrow-left me-1"></i> Continue Shopping
                    </a>
                    <span class="text-muted small">Prices verified against live database catalog</span>
                </div>
            </div>
        </div>

        <!-- Order Summary Side Card -->
        <div class="col-12 col-lg-4">
            <div class="card border-0 shadow-sm p-4">
                <h5 class="fw-bold mb-3">Order Summary</h5>

                <div class="d-flex justify-content-between text-muted mb-2">
                    <span>Items Subtotal</span>
                    <span><%= CurrencyUtil.format(cartTotal) %></span>
                </div>

                <div class="d-flex justify-content-between text-muted mb-2">
                    <span>Estimated Shipping</span>
                    <span class="text-success fw-semibold">FREE</span>
                </div>

                <div class="d-flex justify-content-between text-muted mb-3">
                    <span>Tax (Included)</span>
                    <span><%= CurrencyUtil.format(BigDecimal.ZERO) %></span>
                </div>

                <hr>

                <div class="d-flex justify-content-between align-items-baseline mb-4">
                    <span class="fw-bold fs-5">Estimated Total</span>
                    <span class="display-6 fw-bold text-primary"><%= CurrencyUtil.format(cartTotal) %></span>
                </div>

                <a href="<%= ctx %>/checkout" class="btn btn-primary w-100 py-3 fw-bold shadow-sm mb-3">
                    <i class="bi bi-lock-fill me-1"></i> Proceed to Checkout
                </a>

                <div class="p-3 bg-light rounded-3 small text-secondary">
                    <div class="fw-semibold text-dark mb-1"><i class="bi bi-shield-check text-success me-1"></i> Purchase Protection</div>
                    Your purchase is protected with concurrency-safe inventory allocation upon order placement.
                </div>
            </div>
        </div>
    <% } %>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
