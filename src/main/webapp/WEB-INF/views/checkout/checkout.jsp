<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.CartItem" %>
<%@ page import="com.shoppingcart.model.User" %>
<%@ page import="com.shoppingcart.util.CSRFUtil" %>
<%@ page import="com.shoppingcart.util.CurrencyUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Secure Checkout");
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    BigDecimal cartTotal = (BigDecimal) request.getAttribute("cartTotal");
    if (cartTotal == null) cartTotal = BigDecimal.ZERO;
    User user = (User) request.getAttribute("user");
    String csrfToken = CSRFUtil.getToken(session);
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row g-4 mb-5">
    <div class="col-12">
        <h2 class="fw-bold mb-1"><i class="bi bi-shield-lock me-2 text-primary"></i>Secure Checkout</h2>
        <p class="text-muted small">Complete your delivery address and payment choice to finalize your order.</p>
    </div>

    <!-- Checkout Form -->
    <div class="col-12 col-lg-7">
        <form action="<%= ctx %>/checkout" method="post" id="checkoutForm">
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">

            <!-- Step 1: Customer Info -->
            <div class="card border-0 shadow-sm p-4 mb-4">
                <h5 class="fw-bold mb-3 d-flex align-items-center gap-2">
                    <span class="badge bg-primary rounded-circle">1</span>
                    <span>Contact Information</span>
                </h5>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label small fw-semibold text-muted">Customer Name</label>
                        <input type="text" class="form-control bg-light" value="<%= user != null ? ValidationUtil.escapeHtml(user.getName()) : "" %>" readonly>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label small fw-semibold text-muted">Email Address</label>
                        <input type="email" class="form-control bg-light" value="<%= user != null ? ValidationUtil.escapeHtml(user.getEmail()) : "" %>" readonly>
                    </div>
                </div>
            </div>

            <!-- Step 2: Shipping Address -->
            <div class="card border-0 shadow-sm p-4 mb-4">
                <h5 class="fw-bold mb-3 d-flex align-items-center gap-2">
                    <span class="badge bg-primary rounded-circle">2</span>
                    <span>Shipping Address</span>
                </h5>

                <div class="mb-3">
                    <label for="shippingAddress" class="form-label fw-semibold">Delivery Address <span class="text-danger">*</span></label>
                    <textarea class="form-control" id="shippingAddress" name="shippingAddress" rows="3" 
                              placeholder="Enter street, apartment/suite, city, state, postal code" required minlength="5"></textarea>
                    <div class="form-text small text-muted">Please provide an accurate delivery destination.</div>
                </div>
            </div>

            <!-- Step 3: Payment Method -->
            <div class="card border-0 shadow-sm p-4 mb-4">
                <h5 class="fw-bold mb-3 d-flex align-items-center gap-2">
                    <span class="badge bg-primary rounded-circle">3</span>
                    <span>Payment Method</span>
                </h5>

                <div class="d-flex flex-column gap-3 mb-2">
                    <div class="form-check p-3 border rounded-3 bg-light">
                        <input class="form-check-input ms-0 me-3" type="radio" name="paymentMethod" id="payCOD" value="COD" checked>
                        <label class="form-check-label w-100" for="payCOD">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="fw-bold text-dark"><i class="bi bi-cash-coin me-1 text-success"></i> Cash on Delivery (COD)</div>
                                    <div class="small text-muted">Pay in cash or UPI when your shipment arrives at your doorstep.</div>
                                </div>
                                <span class="badge bg-secondary">Zero Surcharge</span>
                            </div>
                        </label>
                    </div>

                    <div class="form-check p-3 border rounded-3 bg-light">
                        <input class="form-check-input ms-0 me-3" type="radio" name="paymentMethod" id="payMOCK" value="MOCK">
                        <label class="form-check-label w-100" for="payMOCK">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="fw-bold text-dark"><i class="bi bi-credit-card me-1 text-primary"></i> Mock Payment (Demonstration Only)</div>
                                    <div class="small text-muted">Simulates instant online payment authorization without real bank debit.</div>
                                </div>
                                <span class="badge bg-info text-dark">Instant Simulation</span>
                            </div>
                        </label>
                    </div>
                </div>

                <div class="alert alert-info small mt-3 mb-0" role="alert">
                    <i class="bi bi-info-circle-fill me-1"></i>
                    <strong>Payment Disclaimer:</strong> This application does not collect real credit cards or process actual financial transactions.
                </div>
            </div>

            <!-- Submit Button -->
            <button type="submit" id="submitOrderBtn" class="btn btn-primary w-100 py-3 fw-bold fs-5 shadow-sm">
                <i class="bi bi-check-circle-fill me-1"></i> Place Order (<%= CurrencyUtil.format(cartTotal) %>)
            </button>
        </form>
    </div>

    <!-- Order Review Summary Column -->
    <div class="col-12 col-lg-5">
        <div class="card border-0 shadow-sm p-4 sticky-top" style="top: 85px;">
            <h5 class="fw-bold mb-3">Order Items (<%= cartItems != null ? cartItems.size() : 0 %>)</h5>

            <div class="d-flex flex-column gap-3 mb-4" style="max-height: 320px; overflow-y: auto;">
                <% if (cartItems != null) {
                    for (CartItem ci : cartItems) { %>
                        <div class="d-flex justify-content-between align-items-center pb-2 border-bottom">
                            <div class="d-flex align-items-center gap-2">
                                <img src="<%= ctx %>/<%= (ci.getProduct() != null && ci.getProduct().getImagePath() != null) ? ci.getProduct().getImagePath() : "assets/images/placeholder.jpg" %>" 
                                     alt="<%= (ci.getProduct() != null) ? ValidationUtil.escapeHtml(ci.getProduct().getName()) : "Item" %>" 
                                     class="rounded-2 border bg-white p-1" style="width: 48px; height: 48px; object-fit: contain;"
                                     onerror="this.onerror=null; this.src='<%= ctx %>/assets/images/placeholder.jpg';">
                                <div>
                                    <h6 class="mb-0 small fw-bold"><%= (ci.getProduct() != null) ? ci.getProduct().getName() : "Item" %></h6>
                                    <span class="text-muted small">Qty: <%= ci.getQuantity() %> &times; <%= (ci.getProduct() != null) ? CurrencyUtil.format(ci.getProduct().getPrice()) : CurrencyUtil.format(BigDecimal.ZERO) %></span>
                                </div>
                            </div>
                            <span class="fw-bold small text-dark"><%= CurrencyUtil.format(ci.getSubtotal()) %></span>
                        </div>
                <%  } 
                   } %>
            </div>

            <div class="d-flex justify-content-between text-muted mb-2">
                <span>Subtotal</span>
                <span><%= CurrencyUtil.format(cartTotal) %></span>
            </div>

            <div class="d-flex justify-content-between text-muted mb-3">
                <span>Shipping</span>
                <span class="text-success fw-semibold">FREE</span>
            </div>

            <hr>

            <div class="d-flex justify-content-between align-items-baseline mb-4">
                <span class="fw-bold fs-5">Total to Pay</span>
                <span class="display-6 fw-bold text-primary"><%= CurrencyUtil.format(cartTotal) %></span>
            </div>

            <div class="p-3 bg-light rounded-3 small text-secondary">
                <div class="fw-bold text-dark mb-1"><i class="bi bi-shield-check text-success me-1"></i> Transaction Guarantee</div>
                An atomic database transaction guarantees your stock reservation and creates your immutable order snapshot.
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
