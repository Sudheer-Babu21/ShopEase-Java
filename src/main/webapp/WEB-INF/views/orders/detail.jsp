<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.Order" %>
<%@ page import="com.shoppingcart.model.OrderItem" %>
<%@ page import="com.shoppingcart.util.CurrencyUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%
    Order order = (Order) request.getAttribute("order");
    request.setAttribute("pageTitle", "Order Details #" + (order != null ? order.getOrderId() : ""));
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<% if (order != null) { %>
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="<%= ctx %>/products" class="text-decoration-none">Store</a></li>
            <li class="breadcrumb-item"><a href="<%= ctx %>/orders" class="text-decoration-none">My Orders</a></li>
            <li class="breadcrumb-item active" aria-current="page">Order #<%= order.getOrderId() %></li>
        </ol>
    </nav>

    <div class="row g-4 mb-5">
        <div class="col-12 col-lg-8">
            <div class="card border-0 shadow-sm p-4 mb-4">
                <div class="d-flex flex-wrap justify-content-between align-items-center border-bottom pb-3 mb-4 gap-2">
                    <div>
                        <span class="badge badge-status badge-status-<%= order.getStatus() %> me-2"><%= order.getStatus() %></span>
                        <h4 class="fw-bold text-dark d-inline">Order #<%= order.getOrderId() %></h4>
                    </div>
                    <div class="text-muted small">
                        Placed on <strong class="text-dark"><%= order.getOrderDate() %></strong>
                    </div>
                </div>

                <h5 class="fw-bold mb-3">Order Items</h5>
                <div class="table-responsive">
                    <table class="table align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Item</th>
                                <th class="text-center">Quantity</th>
                                <th>Historical Price</th>
                                <th class="text-end">Subtotal</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (OrderItem item : order.getItems()) { %>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <img src="<%= ctx %>/<%= item.getProductImage() != null ? item.getProductImage() : "assets/images/placeholder.jpg" %>" 
                                                 alt="<%= ValidationUtil.escapeHtml(item.getProductName()) %>" 
                                                 class="rounded-2 border bg-white p-1" style="width: 48px; height: 48px; object-fit: contain;"
                                                 onerror="this.onerror=null; this.src='<%= ctx %>/assets/images/placeholder.jpg';">
                                            <div>
                                                <div class="fw-bold text-dark"><%= item.getProductName() %></div>
                                                <span class="text-muted small">ID: #<%= item.getProductId() %></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="text-center fw-semibold"><%= item.getQuantity() %></td>
                                    <td><%= CurrencyUtil.format(item.getUnitPrice()) %></td>
                                    <td class="text-end fw-bold text-primary"><%= CurrencyUtil.format(item.getSubtotal()) %></td>
                                </tr>
                            <% } %>
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="3" class="text-end">Total Amount:</th>
                                <th class="text-end text-primary fs-5"><%= CurrencyUtil.format(order.getTotalAmount()) %></th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </div>

        <!-- Sidebar Shipping & Payment Details -->
        <div class="col-12 col-lg-4">
            <div class="card border-0 shadow-sm p-4 mb-4">
                <h5 class="fw-bold mb-3 border-bottom pb-2">Delivery Details</h5>

                <div class="mb-3">
                    <label class="text-muted small fw-semibold">Shipping Address</label>
                    <div class="fw-semibold text-dark"><%= ValidationUtil.escapeHtml(order.getShippingAddress()) %></div>
                </div>

                <div class="mb-3">
                    <label class="text-muted small fw-semibold">Payment Method</label>
                    <div class="fw-semibold text-dark">
                        <% if (Order.PAYMENT_COD.equals(order.getPaymentMethod())) { %>
                            <i class="bi bi-cash-coin text-success me-1"></i> Cash on Delivery (COD)
                        <% } else { %>
                            <i class="bi bi-credit-card text-primary me-1"></i> Mock Payment (Demonstration)
                        <% } %>
                    </div>
                </div>

                <div class="mb-0">
                    <label class="text-muted small fw-semibold">Current Order Status</label>
                    <div>
                        <span class="badge badge-status badge-status-<%= order.getStatus() %> fs-6 px-3 py-2">
                            <%= order.getStatus() %>
                        </span>
                    </div>
                </div>
            </div>

            <a href="<%= ctx %>/orders" class="btn btn-outline-secondary w-100 py-2">
                <i class="bi bi-arrow-left me-1"></i> Back to My Orders
            </a>
        </div>
    </div>
<% } %>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
