<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.Order" %>
<%@ page import="com.shoppingcart.util.CurrencyUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Order Fulfillment");
    request.setAttribute("activeMenu", "orders");
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String searchQuery = (String) request.getAttribute("searchQuery");
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/admin_header.jsp" />

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h2 class="fw-bold mb-1">Customer Orders</h2>
        <p class="text-muted small mb-0">Total of <strong><%= totalCount != null ? totalCount : 0 %></strong> orders tracked across all lifecycle stages</p>
    </div>
</div>

<!-- Search & Status Filter Form -->
<div class="card border-0 shadow-sm p-3 mb-4">
    <form action="<%= ctx %>/admin/orders" method="get" class="row g-2 align-items-center">
        <div class="col-12 col-md-5">
            <div class="input-group">
                <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                <input type="text" name="q" class="form-control border-start-0" 
                       placeholder="Search by Order ID, customer name, email..." 
                       value="<%= ValidationUtil.escapeHtml(searchQuery != null ? searchQuery : "") %>">
            </div>
        </div>

        <div class="col-12 col-md-4">
            <select name="status" class="form-select">
                <option value="">All Statuses</option>
                <option value="PLACED" <%= "PLACED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>PLACED</option>
                <option value="PACKED" <%= "PACKED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>PACKED</option>
                <option value="SHIPPED" <%= "SHIPPED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>SHIPPED</option>
                <option value="DELIVERED" <%= "DELIVERED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>DELIVERED</option>
                <option value="CANCELLED" <%= "CANCELLED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>CANCELLED</option>
            </select>
        </div>

        <div class="col-12 col-md-3 d-flex gap-2">
            <button type="submit" class="btn btn-secondary px-3 w-100">Filter</button>
            <a href="<%= ctx %>/admin/orders" class="btn btn-outline-secondary">Reset</a>
        </div>
    </form>
</div>

<!-- Orders Table -->
<div class="card border-0 shadow-sm overflow-hidden mb-4">
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light small">
                <tr>
                    <th class="ps-3">Order #</th>
                    <th>Customer</th>
                    <th>Date</th>
                    <th>Total</th>
                    <th>Payment</th>
                    <th>Status</th>
                    <th class="text-end pe-3">Action</th>
                </tr>
            </thead>
            <tbody>
                <% if (orders == null || orders.isEmpty()) { %>
                    <tr>
                        <td colspan="7" class="text-center py-4 text-muted">No orders match the selected filters.</td>
                    </tr>
                <% } else {
                    for (Order o : orders) { %>
                        <tr>
                            <td class="ps-3 fw-bold text-dark">#<%= o.getOrderId() %></td>
                            <td>
                                <div class="fw-semibold text-dark"><%= o.getUserName() %></div>
                                <div class="text-muted small"><%= o.getUserEmail() %></div>
                            </td>
                            <td class="small text-muted"><%= o.getOrderDate() %></td>
                            <td class="fw-bold text-primary"><%= CurrencyUtil.format(o.getTotalAmount()) %></td>
                            <td><span class="badge bg-light text-dark border"><%= o.getPaymentMethod() %></span></td>
                            <td>
                                <span class="badge badge-status badge-status-<%= o.getStatus() %>"><%= o.getStatus() %></span>
                            </td>
                            <td class="text-end pe-3">
                                <a href="<%= ctx %>/admin/orders/detail?id=<%= o.getOrderId() %>" class="btn btn-outline-primary btn-sm px-3">
                                    <i class="bi bi-gear me-1"></i> Manage
                                </a>
                            </td>
                        </tr>
                <%  } 
                   } %>
            </tbody>
        </table>
    </div>
</div>

<!-- Pagination Controls -->
<% if (totalPages != null && totalPages > 1) { %>
    <nav class="my-4">
        <ul class="pagination justify-content-center">
            <li class="page-item <%= (currentPage <= 1) ? "disabled" : "" %>">
                <a class="page-link" href="<%= ctx %>/admin/orders?page=<%= currentPage - 1 %><%= selectedStatus != null ? "&status=" + selectedStatus : "" %><%= (searchQuery != null && !searchQuery.isEmpty()) ? "&q=" + searchQuery : "" %>">
                    &laquo; Prev
                </a>
            </li>
            <% for (int i = 1; i <= totalPages; i++) { %>
                <li class="page-item <%= (i == currentPage) ? "active" : "" %>">
                    <a class="page-link" href="<%= ctx %>/admin/orders?page=<%= i %><%= selectedStatus != null ? "&status=" + selectedStatus : "" %><%= (searchQuery != null && !searchQuery.isEmpty()) ? "&q=" + searchQuery : "" %>">
                        <%= i %>
                    </a>
                </li>
            <% } %>
            <li class="page-item <%= (currentPage >= totalPages) ? "disabled" : "" %>">
                <a class="page-link" href="<%= ctx %>/admin/orders?page=<%= currentPage + 1 %><%= selectedStatus != null ? "&status=" + selectedStatus : "" %><%= (searchQuery != null && !searchQuery.isEmpty()) ? "&q=" + searchQuery : "" %>">
                    Next &raquo;
                </a>
            </li>
        </ul>
    </nav>
<% } %>

<jsp:include page="/WEB-INF/views/common/admin_footer.jsp" />
