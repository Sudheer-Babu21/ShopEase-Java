<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.Product" %>
<%@ page import="com.shoppingcart.model.Order" %>
<%@ page import="com.shoppingcart.util.CurrencyUtil" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Administration Dashboard");
    request.setAttribute("activeMenu", "dashboard");
    Map<String, Object> metrics = (Map<String, Object>) request.getAttribute("metrics");

    Integer totalOrders = (Integer) (metrics != null ? metrics.get("totalOrders") : 0);
    Integer totalCustomers = (Integer) (metrics != null ? metrics.get("totalCustomers") : 0);
    Integer totalProducts = (Integer) (metrics != null ? metrics.get("totalProducts") : 0);
    BigDecimal totalRevenue = (BigDecimal) (metrics != null ? metrics.get("totalRevenue") : BigDecimal.ZERO);
    Integer pendingOrders = (Integer) (metrics != null ? metrics.get("pendingOrders") : 0);
    List<Product> lowStock = (List<Product>) (metrics != null ? metrics.get("lowStockProducts") : null);
    List<Order> recentOrders = (List<Order>) (metrics != null ? metrics.get("recentOrders") : null);

    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/admin_header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 class="fw-bold mb-1">Store Performance Dashboard</h2>
        <p class="text-muted small mb-0">Real-time overview of Oracle database sales, inventory, and pending fulfillment</p>
    </div>
    <div>
        <a href="<%= ctx %>/admin/products/add" class="btn btn-primary btn-sm px-3 shadow-sm">
            <i class="bi bi-plus-circle me-1"></i> Add New Product
        </a>
    </div>
</div>

<!-- Key Performance Stat Cards -->
<div class="row g-3 mb-4">
    <div class="col-12 col-sm-6 col-xl-3">
        <div class="stat-card d-flex align-items-center gap-3">
            <div class="stat-icon bg-success bg-opacity-10 text-success">
                <i class="bi bi-currency-rupee"></i>
            </div>
            <div>
                <div class="text-muted small text-uppercase fw-semibold">Net Revenue</div>
                <div class="fs-4 fw-bold text-dark"><%= CurrencyUtil.format(totalRevenue) %></div>
                <div class="small text-muted" style="font-size: 0.75rem;">Excludes cancelled orders</div>
            </div>
        </div>
    </div>

    <div class="col-12 col-sm-6 col-xl-3">
        <div class="stat-card d-flex align-items-center gap-3">
            <div class="stat-icon bg-primary bg-opacity-10 text-primary">
                <i class="bi bi-cart-check"></i>
            </div>
            <div>
                <div class="text-muted small text-uppercase fw-semibold">Total Orders</div>
                <div class="fs-4 fw-bold text-dark"><%= totalOrders %></div>
                <div class="small text-muted" style="font-size: 0.75rem;">Lifetime volume</div>
            </div>
        </div>
    </div>

    <div class="col-12 col-sm-6 col-xl-3">
        <div class="stat-card d-flex align-items-center gap-3">
            <div class="stat-icon bg-warning bg-opacity-10 text-warning">
                <i class="bi bi-clock-history"></i>
            </div>
            <div>
                <div class="text-muted small text-uppercase fw-semibold">Pending Orders</div>
                <div class="fs-4 fw-bold text-dark"><%= pendingOrders %></div>
                <div class="small text-muted" style="font-size: 0.75rem;">Awaiting packing/shipping</div>
            </div>
        </div>
    </div>

    <div class="col-12 col-sm-6 col-xl-3">
        <div class="stat-card d-flex align-items-center gap-3">
            <div class="stat-icon bg-info bg-opacity-10 text-info">
                <i class="bi bi-people"></i>
            </div>
            <div>
                <div class="text-muted small text-uppercase fw-semibold">Customers</div>
                <div class="fs-4 fw-bold text-dark"><%= totalCustomers %></div>
                <div class="small text-muted" style="font-size: 0.75rem;">Registered accounts</div>
            </div>
        </div>
    </div>
</div>

<div class="row g-4 mb-4">
    <!-- Recent Orders Table -->
    <div class="col-12 col-lg-7">
        <div class="card border-0 shadow-sm p-4 h-100">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold mb-0">Recent Orders</h5>
                <a href="<%= ctx %>/admin/orders" class="small text-primary text-decoration-none fw-semibold">
                    View All Orders <i class="bi bi-arrow-right"></i>
                </a>
            </div>

            <% if (recentOrders == null || recentOrders.isEmpty()) { %>
                <div class="text-center py-4 text-muted small">No recent orders found.</div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 small">
                        <thead class="table-light">
                            <tr>
                                <th>Order #</th>
                                <th>Customer</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Order o : recentOrders) { %>
                                <tr>
                                    <td class="fw-bold">#<%= o.getOrderId() %></td>
                                    <td>
                                        <div class="fw-semibold text-dark"><%= o.getUserName() %></div>
                                        <div class="text-muted" style="font-size: 0.7rem;"><%= o.getUserEmail() %></div>
                                    </td>
                                    <td class="fw-bold text-primary"><%= CurrencyUtil.format(o.getTotalAmount()) %></td>
                                    <td>
                                         <span class="badge badge-status badge-status-<%= o.getStatus() %>"><%= o.getStatus() %></span>
                                    </td>
                                    <td class="text-end">
                                        <a href="<%= ctx %>/admin/orders/detail?id=<%= o.getOrderId() %>" class="btn btn-outline-primary btn-sm py-0 px-2">
                                            Manage
                                        </a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>

    <!-- Low Stock Inventory Alerts -->
    <div class="col-12 col-lg-5">
        <div class="card border-0 shadow-sm p-4 h-100">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold mb-0 text-danger d-flex align-items-center gap-1">
                    <i class="bi bi-exclamation-triangle-fill"></i> Low Stock Alerts
                </h5>
                <span class="badge bg-danger rounded-pill"><%= lowStock != null ? lowStock.size() : 0 %></span>
            </div>

            <% if (lowStock == null || lowStock.isEmpty()) { %>
                <div class="text-center py-4 text-muted small">
                    <i class="bi bi-check-circle text-success fs-3 d-block mb-1"></i>
                    All product inventories are well-stocked (&gt; 5 units).
                </div>
            <% } else { %>
                <div class="list-group list-group-flush">
                    <% for (Product p : lowStock) { %>
                        <div class="list-group-item px-0 py-2 d-flex justify-content-between align-items-center border-bottom">
                            <div>
                                <div class="fw-semibold text-dark small"><%= p.getName() %></div>
                                <div class="text-muted" style="font-size: 0.75rem;"><%= p.getCategoryName() %> &bull; <%= CurrencyUtil.format(p.getPrice()) %></div>
                            </div>
                            <div class="text-end">
                                <span class="badge <%= p.getStockQty() == 0 ? "bg-danger" : "bg-warning text-dark" %> mb-1">
                                    <%= p.getStockQty() %> left
                                </span>
                                <div>
                                    <a href="<%= ctx %>/admin/products/edit?id=<%= p.getProductId() %>" class="small text-decoration-none">
                                        Restock <i class="bi bi-pencil-square"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/admin_footer.jsp" />
