<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.User" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "User Accounts Directory");
    request.setAttribute("activeMenu", "users");
    List<User> users = (List<User>) request.getAttribute("users");
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/admin_header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 class="fw-bold mb-1">Registered Users & Customers</h2>
        <p class="text-muted small mb-0">Total of <strong><%= users != null ? users.size() : 0 %></strong> accounts registered in the database</p>
    </div>
</div>

<div class="card border-0 shadow-sm overflow-hidden mb-4">
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light small">
                <tr>
                    <th class="ps-3">User ID</th>
                    <th>Full Name</th>
                    <th>Email Address</th>
                    <th>Phone</th>
                    <th>System Role</th>
                    <th class="pe-3">Registered At</th>
                </tr>
            </thead>
            <tbody>
                <% if (users == null || users.isEmpty()) { %>
                    <tr>
                        <td colspan="6" class="text-center py-4 text-muted">No users found.</td>
                    </tr>
                <% } else {
                    for (User u : users) { %>
                        <tr>
                            <td class="ps-3 fw-bold text-muted small">#<%= u.getUserId() %></td>
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="rounded-circle bg-secondary bg-opacity-10 text-secondary d-flex align-items-center justify-content-center fw-bold" style="width: 34px; height: 34px; font-size: 0.85rem;">
                                        <%= u.getName() != null && !u.getName().isEmpty() ? u.getName().substring(0, 1).toUpperCase() : "U" %>
                                    </div>
                                    <span class="fw-bold text-dark"><%= u.getName() %></span>
                                </div>
                            </td>
                            <td><code><%= u.getEmail() %></code></td>
                            <td><%= u.getPhone() != null && !u.getPhone().isEmpty() ? u.getPhone() : "-" %></td>
                            <td>
                                <% if (u.isAdmin()) { %>
                                    <span class="badge bg-warning text-dark"><i class="bi bi-shield-lock-fill me-1"></i> ADMIN</span>
                                <% } else { %>
                                    <span class="badge bg-info text-dark"><i class="bi bi-person-fill me-1"></i> CUSTOMER</span>
                                <% } %>
                            </td>
                            <td class="pe-3 small text-muted"><%= u.getCreatedAt() %></td>
                        </tr>
                <%  } 
                   } %>
            </tbody>
        </table>
    </div>
</div>

<div class="alert alert-light border small text-muted">
    <i class="bi bi-shield-check text-success me-1"></i>
    <strong>Security Policy:</strong> Password hashes are strictly omitted from directory queries and will never be rendered in administration interfaces.
</div>

<jsp:include page="/WEB-INF/views/common/admin_footer.jsp" />
