<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.Product" %>
<%@ page import="com.shoppingcart.model.Category" %>
<%@ page import="com.shoppingcart.util.CSRFUtil" %>
<%@ page import="com.shoppingcart.util.CurrencyUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Product Management");
    request.setAttribute("activeMenu", "products");
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    Long selectedCategory = (Long) request.getAttribute("selectedCategory");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    String csrfToken = CSRFUtil.getToken(session);
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/admin_header.jsp" />

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h2 class="fw-bold mb-1">Products & Inventory</h2>
        <p class="text-muted small mb-0">Total of <strong><%= totalCount != null ? totalCount : 0 %></strong> catalog items recorded</p>
    </div>
    <div>
        <a href="<%= ctx %>/admin/products/add" class="btn btn-primary px-3 shadow-sm">
            <i class="bi bi-plus-lg me-1"></i> Add Product
        </a>
    </div>
</div>

<!-- Search & Filter Filter Form -->
<div class="card border-0 shadow-sm p-3 mb-4">
    <form action="<%= ctx %>/admin/products" method="get" class="row g-2 align-items-center">
        <div class="col-12 col-md-5">
            <div class="input-group">
                <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                <input type="text" name="q" class="form-control border-start-0" 
                       placeholder="Search products by title or description..." 
                       value="<%= ValidationUtil.escapeHtml(searchKeyword != null ? searchKeyword : "") %>">
            </div>
        </div>

        <div class="col-12 col-md-4">
            <select name="category" class="form-select">
                <option value="">All Categories</option>
                <% if (categories != null) {
                    for (Category cat : categories) {
                        boolean sel = selectedCategory != null && selectedCategory.equals(cat.getCategoryId());
                %>
                    <option value="<%= cat.getCategoryId() %>" <%= sel ? "selected" : "" %>><%= cat.getName() %></option>
                <%  } 
                   } %>
            </select>
        </div>

        <div class="col-12 col-md-3 d-flex gap-2">
            <button type="submit" class="btn btn-secondary px-3 w-100">Filter</button>
            <a href="<%= ctx %>/admin/products" class="btn btn-outline-secondary">Reset</a>
        </div>
    </form>
</div>

<!-- Products Table -->
<div class="card border-0 shadow-sm overflow-hidden mb-4">
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light small">
                <tr>
                    <th class="ps-3">ID</th>
                    <th>Product</th>
                    <th>Category</th>
                    <th>Price</th>
                    <th>Stock</th>
                    <th>Status</th>
                    <th class="text-end pe-3">Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (products == null || products.isEmpty()) { %>
                    <tr>
                        <td colspan="7" class="text-center py-4 text-muted">No products found.</td>
                    </tr>
                <% } else {
                    for (Product p : products) { %>
                        <tr>
                            <td class="ps-3 fw-bold text-muted small">#<%= p.getProductId() %></td>
                            <td>
                                <div class="d-flex align-items-center gap-3">
                                    <img src="<%= ctx %>/<%= p.getImagePath() != null ? p.getImagePath() : "assets/images/placeholder.jpg" %>" 
                                         alt="<%= ValidationUtil.escapeHtml(p.getName()) %>" 
                                         class="rounded border bg-white p-1" style="width: 48px; height: 48px; object-fit: contain;"
                                         onerror="this.onerror=null; this.src='<%= ctx %>/assets/images/placeholder.jpg';">
                                    <div>
                                        <div class="fw-bold text-dark"><%= p.getName() %></div>
                                        <div class="text-muted small text-truncate" style="max-width: 250px;"><%= p.getDescription() %></div>
                                    </div>
                                </div>
                            </td>
                            <td><span class="badge bg-light text-dark border"><%= p.getCategoryName() %></span></td>
                            <td class="fw-bold text-primary"><%= CurrencyUtil.format(p.getPrice()) %></td>
                            <td>
                                <% if (p.getStockQty() <= 0) { %>
                                    <span class="badge bg-danger">0 (Out of stock)</span>
                                <% } else if (p.getStockQty() <= 5) { %>
                                    <span class="badge bg-warning text-dark"><%= p.getStockQty() %> units</span>
                                <% } else { %>
                                    <span class="badge bg-success-subtle text-success border border-success-subtle"><%= p.getStockQty() %> units</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (p.isActive()) { %>
                                    <span class="badge bg-success"><i class="bi bi-check-circle me-1"></i> Active</span>
                                <% } else { %>
                                    <span class="badge bg-secondary"><i class="bi bi-dash-circle me-1"></i> Deactivated</span>
                                <% } %>
                            </td>
                            <td class="text-end pe-3">
                                <div class="d-inline-flex gap-1">
                                    <a href="<%= ctx %>/admin/products/edit?id=<%= p.getProductId() %>" class="btn btn-outline-primary btn-sm" title="Edit Product">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>
                                    <form action="<%= ctx %>/admin/products/toggle" method="post" class="d-inline">
                                        <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                                        <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                                        <input type="hidden" name="currentActive" value="<%= p.isActive() %>">
                                        <button type="submit" class="btn btn-sm <%= p.isActive() ? "btn-outline-warning" : "btn-outline-success" %>" 
                                                title="<%= p.isActive() ? "Deactivate (Soft-delete)" : "Reactivate" %>"
                                                data-confirm="Are you sure you want to <%= p.isActive() ? "deactivate" : "reactivate" %> '<%= ValidationUtil.escapeHtml(p.getName()) %>'?">
                                            <i class="bi <%= p.isActive() ? "bi-eye-slash" : "bi-eye" %>"></i>
                                        </button>
                                    </form>
                                </div>
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
                <a class="page-link" href="<%= ctx %>/admin/products?page=<%= currentPage - 1 %><%= selectedCategory != null ? "&category=" + selectedCategory : "" %><%= (searchKeyword != null && !searchKeyword.isEmpty()) ? "&q=" + searchKeyword : "" %>">
                    &laquo; Prev
                </a>
            </li>
            <% for (int i = 1; i <= totalPages; i++) { %>
                <li class="page-item <%= (i == currentPage) ? "active" : "" %>">
                    <a class="page-link" href="<%= ctx %>/admin/products?page=<%= i %><%= selectedCategory != null ? "&category=" + selectedCategory : "" %><%= (searchKeyword != null && !searchKeyword.isEmpty()) ? "&q=" + searchKeyword : "" %>">
                        <%= i %>
                    </a>
                </li>
            <% } %>
            <li class="page-item <%= (currentPage >= totalPages) ? "disabled" : "" %>">
                <a class="page-link" href="<%= ctx %>/admin/products?page=<%= currentPage + 1 %><%= selectedCategory != null ? "&category=" + selectedCategory : "" %><%= (searchKeyword != null && !searchKeyword.isEmpty()) ? "&q=" + searchKeyword : "" %>">
                    Next &raquo;
                </a>
            </li>
        </ul>
    </nav>
<% } %>

<jsp:include page="/WEB-INF/views/common/admin_footer.jsp" />
