<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.util.CSRFUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%
    request.setAttribute("pageTitle", "Customer & Admin Sign In");
    String csrfToken = CSRFUtil.getToken(session);
    String enteredEmail = (String) request.getAttribute("enteredEmail");
    if (enteredEmail == null) enteredEmail = "";
    String redirectParam = request.getParameter("redirect");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row justify-content-center my-4">
    <div class="col-12 col-md-8 col-lg-5">
        <div class="card auth-card shadow-lg border-0">
            <div class="auth-header">
                <i class="bi bi-person-lock display-4 text-info mb-2 d-inline-block"></i>
                <h3 class="fw-bold mb-1">Welcome Back</h3>
                <p class="text-light text-opacity-75 small mb-0">Sign in to your customer account or administrator console</p>
            </div>

            <div class="card-body p-4 p-md-5">
                <% 
                    String regSuccessMsg = null;
                    if ("true".equals(request.getParameter("registered"))) {
                        regSuccessMsg = (String) session.getAttribute("successMessage");
                        if (regSuccessMsg == null || regSuccessMsg.trim().isEmpty()) {
                            regSuccessMsg = "Registration successful! Your account has been created. Please log in.";
                        }
                        session.removeAttribute("successMessage");
                    }
                    String regEmailPrefill = (String) session.getAttribute("registeredEmail");
                    if (regEmailPrefill != null && !regEmailPrefill.trim().isEmpty()) {
                        session.removeAttribute("registeredEmail");
                        if (enteredEmail.isEmpty()) {
                            enteredEmail = regEmailPrefill;
                        }
                    }
                %>

                <% if (regSuccessMsg != null) { %>
                    <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 border-start border-4 border-success p-3 mb-4" role="alert">
                        <div class="d-flex align-items-center">
                            <i class="bi bi-check-circle-fill text-success fs-3 me-3"></i>
                            <div>
                                <h6 class="alert-heading fw-bold mb-1">Registration Successful!</h6>
                                <p class="mb-0 small text-success-emphasis"><%= ValidationUtil.escapeHtml(regSuccessMsg) %></p>
                            </div>
                            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
                        </div>
                    </div>
                <% } %>

                <% 
                    String loginErrorMsg = (String) request.getAttribute("errorMessage");
                    if (loginErrorMsg != null && !loginErrorMsg.trim().isEmpty()) { 
                %>
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0 border-start border-4 border-danger p-3 mb-4" role="alert">
                        <div class="d-flex align-items-center">
                            <i class="bi bi-exclamation-octagon-fill text-danger fs-4 me-3"></i>
                            <div>
                                <h6 class="alert-heading fw-bold mb-1">Sign In Failed</h6>
                                <p class="mb-0 small"><%= ValidationUtil.escapeHtml(loginErrorMsg) %></p>
                            </div>
                            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
                        </div>
                    </div>
                <% } %>

                <% if ("true".equals(request.getParameter("loggedOut"))) { %>
                    <div class="alert alert-info alert-dismissible fade show small" role="alert">
                        <i class="bi bi-info-circle me-1"></i> You have been successfully signed out.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <% if ("auth_required".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-warning alert-dismissible fade show small" role="alert">
                        <i class="bi bi-lock me-1"></i> Please log in with authorized credentials to access this area.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <form action="<%= request.getContextPath() %>/auth/login" method="post">
                    <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                    <% if (redirectParam != null && !redirectParam.trim().isEmpty()) { %>
                        <input type="hidden" name="redirect" value="<%= ValidationUtil.escapeHtml(redirectParam) %>">
                    <% } %>

                    <div class="mb-3">
                        <label for="email" class="form-label fw-semibold">Email Address</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0"><i class="bi bi-envelope text-muted"></i></span>
                            <input type="email" class="form-control border-start-0" id="email" name="email" 
                                   value="<%= ValidationUtil.escapeHtml(enteredEmail) %>" 
                                   placeholder="name@example.com" required autofocus>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label for="password" class="form-label fw-semibold">Password</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0"><i class="bi bi-key text-muted"></i></span>
                            <input type="password" class="form-control border-start-0" id="password" name="password" 
                                   placeholder="Enter your password" required>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2 fs-6 fw-semibold shadow-sm mb-3">
                        <i class="bi bi-box-arrow-in-right me-1"></i> Sign In
                    </button>

                    <div class="text-center small text-muted">
                        Don't have an account yet? 
                        <a href="<%= request.getContextPath() %>/auth/register" class="fw-semibold text-primary">Create Customer Account</a>
                    </div>
                </form>

                <!-- Demo Credentials Box -->
                <div class="mt-4 p-3 bg-light rounded-3 border small">
                    <div class="fw-bold text-dark mb-1"><i class="bi bi-info-circle-fill text-primary me-1"></i> Demo Credentials:</div>
                    <div class="d-flex justify-content-between text-muted border-bottom py-1">
                        <span><strong>Admin:</strong> admin@shoppingcart.com</span>
                        <span class="badge bg-secondary">Admin@123</span>
                    </div>
                    <div class="d-flex justify-content-between text-muted py-1">
                        <span><strong>Customer:</strong> john@example.com</span>
                        <span class="badge bg-secondary">Customer@123</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
