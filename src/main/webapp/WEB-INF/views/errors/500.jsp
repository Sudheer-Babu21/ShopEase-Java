<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%
    request.setAttribute("pageTitle", "500 Server Error");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row justify-content-center my-5">
    <div class="col-md-7 col-lg-5 text-center">
        <div class="p-5 bg-white rounded-4 shadow-sm border">
            <div class="text-warning display-1 mb-3">
                <i class="bi bi-exclamation-triangle"></i>
            </div>
            <h2 class="fw-bold text-dark">500 - Server Error</h2>
            <p class="text-muted mb-4">
                An unexpected technical error occurred while processing your request. 
                Our engineering team has been notified in system logs. Please try again shortly.
            </p>
            <div class="d-flex justify-content-center gap-3">
                <a href="<%= request.getContextPath() %>/products" class="btn btn-primary px-4">
                    <i class="bi bi-house-door me-1"></i> Return Home
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
