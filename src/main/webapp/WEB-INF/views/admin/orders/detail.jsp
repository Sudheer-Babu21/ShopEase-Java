<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.Order" %>
<%@ page import="com.shoppingcart.model.OrderItem" %>
<%@ page import="com.shoppingcart.util.CSRFUtil" %>
<%@ page import="com.shoppingcart.util.CurrencyUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%
    Order order = (Order) request.getAttribute("order");
    request.setAttribute("pageTitle", "Manage Order #" + (order != null ? order.getOrderId() : ""));
    request.setAttribute("activeMenu", "orders");
    String csrfToken = CSRFUtil.getToken(session);
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/admin_header.jsp" />

<% if (order != null) { 
    String currentStatus = order.getStatus();
    boolean isTerminal = Order.STATUS_DELIVERED.equals(currentStatus) || Order.STATUS_CANCELLED.equals(currentStatus);
%>
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-1">
                Order Fulfillment #<%= order.getOrderId() %>
                <span class="badge badge-status badge-status-<%= currentStatus %> fs-6 ms-2"><%= currentStatus %></span>
            </h2>
            <p class="text-muted small mb-0">Placed by <%= order.getUserName() %> on <%= order.getOrderDate() %></p>
        </div>
        <div>
            <a href="<%= ctx %>/admin/orders" class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-arrow-left me-1"></i> Back to Orders
            </a>
        </div>
    </div>

    <div class="row g-4 mb-5">
        <!-- Order Items List -->
        <div class="col-12 col-lg-8">
            <div class="card border-0 shadow-sm p-4 mb-4">
                <h5 class="fw-bold mb-3 border-bottom pb-2">Purchased Items</h5>
                <div class="table-responsive">
                    <table class="table align-middle mb-0">
                        <thead class="table-light small">
                            <tr>
                                <th>Product</th>
                                <th class="text-center">Quantity</th>
                                <th>Historical Price</th>
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
                                                 class="rounded border bg-white p-1" style="width: 44px; height: 44px; object-fit: contain;"
                                                 onerror="this.onerror=null; this.src='<%= ctx %>/assets/images/placeholder.jpg';">
                                            <div>
                                                <div class="fw-semibold text-dark"><%= item.getProductName() %></div>
                                                <span class="text-muted small">Product ID: #<%= item.getProductId() %></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="text-center fw-bold"><%= item.getQuantity() %></td>
                                    <td><%= CurrencyUtil.format(item.getUnitPrice()) %></td>
                                    <td class="text-end fw-bold text-primary"><%= CurrencyUtil.format(item.getSubtotal()) %></td>
                                </tr>
                            <% } %>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="3" class="text-end">Order Total:</th>
                                <th class="text-end text-primary fs-5"><%= CurrencyUtil.format(order.getTotalAmount()) %></th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>

            <!-- Customer & Shipping Card -->
            <div class="card border-0 shadow-sm p-4">
                <h5 class="fw-bold mb-3 border-bottom pb-2">Customer & Shipping Summary</h5>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="text-muted small fw-semibold">Customer</label>
                        <div class="fw-bold text-dark"><%= order.getUserName() %></div>
                        <div class="text-muted small"><%= order.getUserEmail() %></div>
                    </div>
                    <div class="col-md-6">
                        <label class="text-muted small fw-semibold">Payment Method</label>
                        <div class="fw-semibold text-dark"><%= order.getPaymentMethod() %></div>
                    </div>
                    <div class="col-12">
                        <label class="text-muted small fw-semibold">Shipping Address</label>
                        <div class="p-3 bg-light rounded-3 text-dark fw-semibold">
                            <%= ValidationUtil.escapeHtml(order.getShippingAddress()) %>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Status Transition Action Column -->
        <div class="col-12 col-lg-4">
            <div class="card border-0 shadow-sm p-4 sticky-top" style="top: 85px;">
                <h5 class="fw-bold mb-3 border-bottom pb-2">Lifecycle Management</h5>

                <div class="mb-3">
                    <label class="text-muted small fw-semibold">Current State</label>
                    <div><span class="badge badge-status badge-status-<%= currentStatus %> fs-6"><%= currentStatus %></span></div>
                </div>

                <% if (isTerminal) { %>
                    <div class="alert alert-secondary small mb-0">
                        <i class="bi bi-info-circle me-1"></i>
                        This order is in a terminal status (<strong><%= currentStatus %></strong>) and cannot be modified further.
                    </div>
                <% } else { %>
                    <form action="<%= ctx %>/admin/orders/status" method="post">
                        <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                        <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">

                        <div class="mb-3">
                            <label for="statusSelect" class="form-label small fw-semibold">Advance Status To:</label>
                            <select name="status" id="statusSelect" class="form-select" required>
                                <% if (Order.STATUS_PLACED.equals(currentStatus)) { %>
                                    <option value="PACKED">PACKED (Order packaged in warehouse)</option>
                                    <option value="CANCELLED">CANCELLED (Cancel & restore stock)</option>
                                <% } else if (Order.STATUS_PACKED.equals(currentStatus)) { %>
                                    <option value="SHIPPED">SHIPPED (Handed to carrier courier)</option>
                                    <option value="CANCELLED">CANCELLED (Cancel & restore stock)</option>
                                <% } else if (Order.STATUS_SHIPPED.equals(currentStatus)) { %>
                                    <option value="DELIVERED">DELIVERED (Customer delivery confirmed)</option>
                                    <option value="CANCELLED">CANCELLED (Cancel & restore stock)</option>
                                <% } %>
                            </select>
                            <div class="form-text small text-muted">
                                Status transitions are strictly audited and validated on the backend.
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold shadow-sm"
                                data-confirm="Are you sure you want to update this order's status? Cancellation automatically restores inventory.">
                            <i class="bi bi-check2-circle me-1"></i> Update Status
                        </button>
                    </form>
                <% } %>
            </div>
        </div>
    </div>
<% } %>

<jsp:include page="/WEB-INF/views/common/admin_footer.jsp" />
