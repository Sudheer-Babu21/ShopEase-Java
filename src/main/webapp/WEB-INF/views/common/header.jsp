<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.User" %>
<%@ page import="com.shoppingcart.filter.AuthenticationFilter" %>
<%@ page import="com.shoppingcart.util.CSRFUtil" %>
<%
    User currentUser = (User) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
    Integer cartCount = (Integer) session.getAttribute("cartCount");
    if (cartCount == null) cartCount = 0;
    String csrfToken = CSRFUtil.getToken(session);
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) pageTitle = "Online Shopping Cart";
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - ShopEase</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Custom Application CSS -->
    <link href="<%= ctx %>/assets/css/style.css" rel="stylesheet">
</head>
<body>

<!-- Navigation Bar -->
<nav class="navbar navbar-expand-lg navbar-dark navbar-custom sticky-top">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2" href="<%= ctx %>/products">
            <i class="bi bi-bag-check-fill text-info fs-3"></i>
            <span>Shop<span class="brand-gradient">Ease</span></span>
        </a>

        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarMain">
            <!-- Search bar -->
            <form class="d-flex my-2 my-lg-0 mx-auto col-12 col-lg-5" action="<%= ctx %>/products" method="get">
                <div class="input-group">
                    <input class="form-control bg-dark text-white border-secondary" type="search" name="q" 
                           placeholder="Search laptop, headphones, shirts..." 
                           value="<%= request.getParameter("q") != null ? request.getParameter("q") : "" %>">
                    <button class="btn btn-primary" type="submit">
                        <i class="bi bi-search"></i>
                    </button>
                </div>
            </form>

            <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-2">
                <li class="nav-item">
                    <a class="nav-link" href="<%= ctx %>/products">
                        <i class="bi bi-grid me-1"></i> Catalog
                    </a>
                </li>

                <% if (currentUser != null) { %>
                    <li class="nav-item">
                        <a class="nav-link position-relative" href="<%= ctx %>/cart">
                            <i class="bi bi-cart3 fs-5"></i>
                            <span class="badge rounded-pill bg-danger badge-cart"><%= cartCount %></span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= ctx %>/orders">
                            <i class="bi bi-receipt me-1"></i> My Orders
                        </a>
                    </li>
                    <% if (currentUser.isAdmin()) { %>
                        <li class="nav-item">
                            <a class="nav-link text-warning fw-semibold" href="<%= ctx %>/admin/dashboard">
                                <i class="bi bi-shield-lock-fill me-1"></i> Admin
                            </a>
                        </li>
                    <% } %>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle d-flex align-items-center gap-1" href="#" data-bs-toggle="dropdown">
                            <i class="bi bi-person-circle fs-5"></i>
                            <span><%= currentUser.getName() %></span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end shadow">
                            <li><h6 class="dropdown-header"><%= currentUser.getEmail() %></h6></li>
                            <li><a class="dropdown-item" href="<%= ctx %>/profile"><i class="bi bi-person me-2"></i>My Profile</a></li>
                            <li><a class="dropdown-item" href="<%= ctx %>/orders"><i class="bi bi-box-seam me-2"></i>Order History</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li>
                                <form action="<%= ctx %>/auth/logout" method="post" class="px-3 py-1">
                                    <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                                    <button type="submit" class="btn btn-outline-danger btn-sm w-100">
                                        <i class="bi bi-box-arrow-right me-1"></i> Logout
                                    </button>
                                </form>
                            </li>
                        </ul>
                    </li>
                <% } else { %>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= ctx %>/auth/login">
                            <i class="bi bi-box-arrow-in-right me-1"></i> Sign In
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="btn btn-primary btn-sm px-3" href="<%= ctx %>/auth/register">
                            Register
                        </a>
                    </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

<!-- Main Container -->
<main class="py-4">
    <div class="container">
        <!-- Global Alert Notifications -->
        <% 
            boolean isAuthLoginPage = request.getServletPath() != null && request.getServletPath().contains("/auth/login") && "true".equals(request.getParameter("registered"));
            boolean isAuthFormPage = request.getServletPath() != null && request.getServletPath().startsWith("/auth/");
            String successMsg = (String) request.getAttribute("successMessage");
            if (successMsg == null && session != null && !isAuthLoginPage) { 
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
            if (errorMsg != null && !isAuthFormPage) { 
        %>
            <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i><%= com.shoppingcart.util.ValidationUtil.escapeHtml(errorMsg) %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
