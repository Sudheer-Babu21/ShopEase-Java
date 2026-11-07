<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%
    request.setAttribute("pageTitle", "404 Not Found");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row justify-content-center my-5">
    <div class="col-md-7 col-lg-5 text-center">
        <div class="p-5 bg-white rounded-4 shadow-sm border">
            <div class="text-primary display-1 mb-3">
                <i class="bi bi-search"></i>
            </div>
            <h2 class="fw-bold text-dark">404 - Page Not Found</h2>
            <p class="text-muted mb-4">
                <%= request.getAttribute("errorMessage") != null ? 
                    request.getAttribute("errorMessage") : 
                    "The product, category, or page you are looking for does not exist or may have been moved." %>
            </p>
            <div class="d-flex justify-content-center gap-3">
                <a href="<%= request.getContextPath() %>/products" class="btn btn-primary px-4">
                    <i class="bi bi-grid me-1"></i> Browse Catalog
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
