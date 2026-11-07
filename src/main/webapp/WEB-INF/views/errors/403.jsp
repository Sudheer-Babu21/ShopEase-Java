<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%
    request.setAttribute("pageTitle", "403 Forbidden");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row justify-content-center my-5">
    <div class="col-md-7 col-lg-5 text-center">
        <div class="p-5 bg-white rounded-4 shadow-sm border">
            <div class="text-danger display-1 mb-3">
                <i class="bi bi-shield-x"></i>
            </div>
            <h2 class="fw-bold text-dark">403 - Access Denied</h2>
            <p class="text-muted mb-4">
                <%= request.getAttribute("errorMessage") != null ? 
                    request.getAttribute("errorMessage") : 
                    "You do not have the required permissions to view this resource or perform this operation." %>
            </p>
            <div class="d-flex justify-content-center gap-3">
                <a href="<%= request.getContextPath() %>/products" class="btn btn-primary px-4">
                    <i class="bi bi-house-door me-1"></i> Return to Store
                </a>
                <a href="<%= request.getContextPath() %>/auth/login" class="btn btn-outline-secondary px-3">
                    Sign In
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
