<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.Order" %>
<%@ page import="com.shoppingcart.model.OrderItem" %>
<%@ page import="com.shoppingcart.util.CurrencyUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "My Order History");
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row g-4 mb-5">
    <div class="col-12">
        <h2 class="fw-bold mb-1"><i class="bi bi-receipt me-2 text-primary"></i>My Order History</h2>
        <p class="text-muted small">Track your past purchases, shipment statuses, and view itemized invoices</p>
    </div>

    <% if (orders == null || orders.isEmpty()) { %>
        <div class="col-12">
            <div class="text-center py-5 bg-white rounded-4 shadow-sm border p-4">
                <i class="bi bi-inbox display-1 text-muted mb-3 d-inline-block"></i>
                <h4 class="fw-bold text-dark">No Orders Placed Yet</h4>
                <p class="text-muted small mb-4">You have not completed any purchases yet.</p>
                <a href="<%= ctx %>/products" class="btn btn-primary px-4 py-2">
                    <i class="bi bi-grid me-1"></i> Browse Products
                </a>
            </div>
        </div>
    <% } else { %>
        <div class="col-12">
            <div class="d-flex flex-column gap-4">
                <% for (Order o : orders) { %>
                    <div class="card border-0 shadow-sm overflow-hidden">
                        <div class="card-header bg-white p-3 p-md-4 border-bottom d-flex flex-wrap justify-content-between align-items-center gap-2">
                            <div>
                                <span class="badge badge-status badge-status-<%= o.getStatus() %> me-2"><%= o.getStatus() %></span>
                                <span class="fw-bold text-dark fs-6">Order #<%= o.getOrderId() %></span>
                                <span class="text-muted small ms-2">&bull; Placed on <%= o.getOrderDate() %></span>
                            </div>
                            <div class="d-flex align-items-center gap-3">
                                <span class="fw-bold text-primary fs-5"><%= CurrencyUtil.format(o.getTotalAmount()) %></span>
                                <a href="<%= ctx %>/orders/detail?id=<%= o.getOrderId() %>" class="btn btn-outline-primary btn-sm px-3">
                                    <i class="bi bi-eye me-1"></i> Details
                                </a>
                            </div>
                        </div>

                        <div class="card-body p-3 p-md-4">
                            <div class="row g-3 align-items-center">
                                <div class="col-12 col-md-8">
                                    <div class="d-flex flex-wrap gap-2 align-items-center">
                                        <% if (o.getItems() != null) {
                                            for (OrderItem item : o.getItems()) { %>
                                                <div class="d-flex align-items-center gap-2 bg-light p-2 rounded-2 border">
                                                    <img src="<%= ctx %>/<%= item.getProductImage() != null ? item.getProductImage() : "assets/images/placeholder.jpg" %>" 
                                                         alt="<%= item.getProductName() %>" class="rounded border bg-white p-1" style="width: 36px; height: 36px; object-fit: contain;"
                                                         onerror="this.onerror=null; this.src='<%= ctx %>/assets/images/placeholder.jpg';">
                                                    <span class="small fw-semibold text-truncate" style="max-width: 140px;"><%= item.getProductName() %></span>
                                                    <span class="badge bg-secondary" style="font-size: 0.65rem;">&times;<%= item.getQuantity() %></span>
                                                </div>
                                        <%  } 
                                           } %>
                                    </div>
                                </div>

                                <div class="col-12 col-md-4 text-md-end small text-muted">
                                    <div>Payment: <strong><%= o.getPaymentMethod() %></strong></div>
                                    <div class="text-truncate" style="max-width: 300px; display: inline-block;">
                                        Ship To: <%= o.getShippingAddress() %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    <% } %>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
