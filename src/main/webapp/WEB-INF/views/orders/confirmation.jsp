<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.Order" %>
<%@ page import="com.shoppingcart.model.OrderItem" %>
<%@ page import="com.shoppingcart.util.CurrencyUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%
    Order order = (Order) request.getAttribute("order");
    request.setAttribute("pageTitle", "Order Confirmation #" + (order != null ? order.getOrderId() : ""));
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row justify-content-center my-4">
    <div class="col-12 col-lg-8">
        <div class="card border-0 shadow-sm p-4 p-md-5 mb-4 text-center">
            <div class="display-3 text-success mb-3">
                <i class="bi bi-patch-check-fill"></i>
            </div>
            <h2 class="fw-bold text-dark mb-1">Thank You for Your Order!</h2>
            <p class="text-muted mb-4">
                Your order <strong>#<%= order != null ? order.getOrderId() : "" %></strong> has been placed and confirmed into our Oracle database.
            </p>

            <div class="d-flex justify-content-center gap-3">
                <a href="<%= ctx %>/orders/detail?id=<%= order != null ? order.getOrderId() : "" %>" class="btn btn-primary px-4">
                    <i class="bi bi-receipt me-1"></i> View Order Details
                </a>
                <a href="<%= ctx %>/products" class="btn btn-outline-secondary px-4">
                    Continue Shopping
                </a>
            </div>
        </div>

        <% if (order != null) { %>
            <!-- Order Snapshot Recap -->
            <div class="card border-0 shadow-sm p-4">
                <h5 class="fw-bold mb-3 border-bottom pb-2">Order Summary</h5>
                <div class="row g-3 mb-4 small">
                    <div class="col-6 col-md-3">
                        <div class="text-muted">Order Date</div>
                        <div class="fw-bold"><%= order.getOrderDate() %></div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="text-muted">Payment Method</div>
                        <div class="fw-bold"><%= order.getPaymentMethod() %></div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="text-muted">Current Status</div>
                        <div><span class="badge badge-status badge-status-<%= order.getStatus() %>"><%= order.getStatus() %></span></div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="text-muted">Total Amount</div>
                        <div class="fw-bold text-primary fs-6"><%= CurrencyUtil.format(order.getTotalAmount()) %></div>
                    </div>
                    <div class="col-12">
                        <div class="text-muted">Delivery Address</div>
                        <div class="fw-semibold"><%= ValidationUtil.escapeHtml(order.getShippingAddress()) %></div>
                    </div>
                </div>

                <h6 class="fw-bold mb-2">Purchased Items</h6>
                <div class="table-responsive">
                    <table class="table table-sm align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Product</th>
                                <th>Quantity</th>
                                <th>Unit Price</th>
                                <th class="text-end">Subtotal</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (OrderItem item : order.getItems()) { %>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <img src="<%= ctx %>/<%= item.getProductImage() != null ? item.getProductImage() : "assets/images/placeholder.jpg" %>" 
                                                 alt="<%= ValidationUtil.escapeHtml(item.getProductName()) %>" 
                                                 class="rounded border bg-white p-1" style="width: 40px; height: 40px; object-fit: contain;"
                                                 onerror="this.onerror=null; this.src='<%= ctx %>/assets/images/placeholder.jpg';">
                                            <span class="fw-semibold small"><%= item.getProductName() %></span>
                                        </div>
                                    </td>
                                    <td><%= item.getQuantity() %></td>
                                    <td><%= CurrencyUtil.format(item.getUnitPrice()) %></td>
                                    <td class="text-end fw-bold"><%= CurrencyUtil.format(item.getSubtotal()) %></td>
                                </tr>
                            <% } %>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="3" class="text-end">Total Paid:</th>
                                <th class="text-end text-primary fs-6"><%= CurrencyUtil.format(order.getTotalAmount()) %></th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        <% } %>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
