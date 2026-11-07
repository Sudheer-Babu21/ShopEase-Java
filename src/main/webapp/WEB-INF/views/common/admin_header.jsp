<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.User" %>
<%@ page import="com.shoppingcart.filter.AuthenticationFilter" %>
<%@ page import="com.shoppingcart.util.CSRFUtil" %>
<%
    User adminUser = (User) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
    String csrfToken = CSRFUtil.getToken(session);
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) pageTitle = "Admin Console";
    String ctx = request.getContextPath();
    String activeMenu = (String) request.getAttribute("activeMenu");
    if (activeMenu == null) activeMenu = "dashboard";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - ShopEase Admin</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Custom Application CSS -->
    <link href="<%= ctx %>/assets/css/style.css" rel="stylesheet">
</head>
<body class="bg-light">

<!-- Admin Top Navbar -->
<nav class="navbar navbar-dark bg-dark px-3 py-2 border-bottom border-secondary sticky-top">
    <div class="container-fluid">
        <a class="navbar-brand d-flex align-items-center gap-2" href="<%= ctx %>/admin/dashboard">
            <i class="bi bi-shield-lock-fill text-warning fs-4"></i>
            <span class="fw-bold">Shop<span class="brand-gradient">Ease</span> <span class="badge bg-warning text-dark ms-1">Admin</span></span>
        </a>

        <div class="d-flex align-items-center gap-3">
            <a href="<%= ctx %>/products" class="btn btn-outline-light btn-sm" target="_blank">
                <i class="bi bi-box-arrow-up-right me-1"></i> View Storefront
            </a>
            <span class="text-secondary small d-none d-md-inline">
                Logged in as <strong class="text-light"><%= adminUser != null ? adminUser.getName() : "Admin" %></strong>
            </span>
            <form action="<%= ctx %>/auth/logout" method="post" class="m-0">
                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                <button type="submit" class="btn btn-danger btn-sm">
                    <i class="bi bi-box-arrow-right"></i>
                </button>
            </form>
        </div>
    </div>
</nav>

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar Navigation -->
        <nav class="col-md-3 col-lg-2 d-md-block admin-sidebar collapse show p-0">
            <div class="position-sticky pt-3">
                <ul class="nav flex-column gap-1">
                    <li class="nav-item">
                        <a class="nav-link <%= "dashboard".equals(activeMenu) ? "active" : "" %>" href="<%= ctx %>/admin/dashboard">
                            <i class="bi bi-speedometer2 me-2"></i> Dashboard
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link <%= "products".equals(activeMenu) ? "active" : "" %>" href="<%= ctx %>/admin/products">
                            <i class="bi bi-box-seam me-2"></i> Products & Stock
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link <%= "categories".equals(activeMenu) ? "active" : "" %>" href="<%= ctx %>/admin/categories">
                            <i class="bi bi-tags me-2"></i> Categories
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link <%= "orders".equals(activeMenu) ? "active" : "" %>" href="<%= ctx %>/admin/orders">
                            <i class="bi bi-cart-check me-2"></i> Orders Management
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link <%= "users".equals(activeMenu) ? "active" : "" %>" href="<%= ctx %>/admin/users">
                            <i class="bi bi-people me-2"></i> Customers & Users
                        </a>
                    </li>
                </ul>

                <hr class="text-secondary mx-3 my-4">

                <div class="px-3 small text-secondary">
                    <div><strong>Database:</strong> Oracle XE 10g</div>
                    <div><strong>Server:</strong> Tomcat 9.0</div>
                    <div><strong>Port:</strong> 8086</div>
                </div>
            </div>
        </nav>

        <!-- Main Content Area -->
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
            <!-- Global Flash Messages -->
            <% 
                String successMsg = (String) request.getAttribute("successMessage");
                if (successMsg == null && session != null) { 
                    successMsg = (String) session.getAttribute("successMessage");
                    if (successMsg != null) {
                        session.removeAttribute("successMessage");
                    }
                }
                if (successMsg != null) { 
            %>
                <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i><%= com.shoppingcart.util.ValidationUtil.escapeHtml(successMsg) %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <% 
                String errorMsg = (String) request.getAttribute("errorMessage");
                if (errorMsg == null && session != null) { 
                    errorMsg = (String) session.getAttribute("errorMessage");
                    if (errorMsg != null) {
                        session.removeAttribute("errorMessage");
                    }
                }
                if (errorMsg != null) { 
            %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i><%= com.shoppingcart.util.ValidationUtil.escapeHtml(errorMsg) %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
