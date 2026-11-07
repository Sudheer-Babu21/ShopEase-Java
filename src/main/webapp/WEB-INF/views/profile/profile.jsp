<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.User" %>
<%@ page import="com.shoppingcart.model.Order" %>
<%@ page import="com.shoppingcart.filter.AuthenticationFilter" %>
<%@ page import="com.shoppingcart.util.CSRFUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "User Profile");
    User user = (User) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
    List<Order> recentOrders = (List<Order>) request.getAttribute("recentOrders");
    String csrfToken = CSRFUtil.getToken(session);
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row g-4 mb-5">
    <div class="col-12">
        <h2 class="fw-bold mb-1"><i class="bi bi-person-circle me-2 text-primary"></i>My Profile</h2>
        <p class="text-muted small">Manage your account information and security preferences</p>
    </div>

    <!-- Personal Info Card -->
    <div class="col-12 col-md-6">
        <div class="card border-0 shadow-sm p-4 h-100">
            <h5 class="fw-bold mb-3 border-bottom pb-2">Profile Information</h5>

            <form action="<%= ctx %>/profile" method="post">
                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">

                <div class="mb-3">
                    <label class="form-label small fw-semibold text-muted">Email Address (Account ID)</label>
                    <input type="email" class="form-control bg-light" value="<%= user != null ? ValidationUtil.escapeHtml(user.getEmail()) : "" %>" readonly>
                    <div class="form-text small text-muted">Email addresses are unique and cannot be modified.</div>
                </div>

                <div class="mb-3">
                    <label for="name" class="form-label small fw-semibold">Full Name</label>
                    <input type="text" class="form-control" id="name" name="name" 
                           value="<%= user != null ? ValidationUtil.escapeHtml(user.getName()) : "" %>" required minlength="2">
                </div>

                <div class="mb-4">
                    <label for="phone" class="form-label small fw-semibold">Phone Number</label>
                    <input type="tel" class="form-control" id="phone" name="phone" 
                           value="<%= (user != null && user.getPhone() != null) ? ValidationUtil.escapeHtml(user.getPhone()) : "" %>" 
                           placeholder="e.g. 9876543210">
                </div>

                <button type="submit" class="btn btn-primary px-4">
                    <i class="bi bi-check2 me-1"></i> Save Changes
                </button>
            </form>
        </div>
    </div>

    <!-- Password Modification Card -->
    <div class="col-12 col-md-6">
        <div class="card border-0 shadow-sm p-4 h-100">
            <h5 class="fw-bold mb-3 border-bottom pb-2">Security & Password</h5>

            <form action="<%= ctx %>/profile/password" method="post">
                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">

                <div class="mb-3">
                    <label for="currentPassword" class="form-label small fw-semibold">Current Password</label>
                    <input type="password" class="form-control" id="currentPassword" name="currentPassword" required>
                </div>

                <div class="mb-3">
                    <label for="newPassword" class="form-label small fw-semibold">New Password</label>
                    <input type="password" class="form-control" id="newPassword" name="newPassword" required minlength="8">
                    <div class="form-text small text-muted">Minimum 8 characters with letters and numbers.</div>
                </div>

                <div class="mb-4">
                    <label for="confirmPassword" class="form-label small fw-semibold">Confirm New Password</label>
                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required minlength="8">
                </div>

                <button type="submit" class="btn btn-outline-primary px-4">
                    <i class="bi bi-shield-lock me-1"></i> Update Password
                </button>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
