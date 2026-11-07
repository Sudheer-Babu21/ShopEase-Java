<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.util.CSRFUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%
    request.setAttribute("pageTitle", "Create Customer Account");
    String csrfToken = CSRFUtil.getToken(session);
    String enteredName = (String) request.getAttribute("enteredName");
    if (enteredName == null) enteredName = "";
    String enteredEmail = (String) request.getAttribute("enteredEmail");
    if (enteredEmail == null) enteredEmail = "";
    String enteredPhone = (String) request.getAttribute("enteredPhone");
    if (enteredPhone == null) enteredPhone = "";
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="row justify-content-center my-4">
    <div class="col-12 col-md-8 col-lg-6">
        <div class="card auth-card shadow-lg border-0">
            <div class="auth-header">
                <i class="bi bi-person-plus-fill display-4 text-info mb-2 d-inline-block"></i>
                <h3 class="fw-bold mb-1">Create Account</h3>
                <p class="text-light text-opacity-75 small mb-0">Join ShopEase for fast checkout and order tracking</p>
            </div>

            <div class="card-body p-4 p-md-5">
                <% 
                    String regError = (String) request.getAttribute("errorMessage");
                    if (regError != null && !regError.trim().isEmpty()) { 
                %>
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0 border-start border-4 border-danger p-3 mb-4" role="alert">
                        <div class="d-flex align-items-center">
                            <i class="bi bi-exclamation-triangle-fill text-danger fs-4 me-3"></i>
                            <div>
                                <h6 class="alert-heading fw-bold mb-1">Registration Incomplete</h6>
                                <p class="mb-0 small"><%= ValidationUtil.escapeHtml(regError) %></p>
                            </div>
                            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
                        </div>
                    </div>
                <% } %>

                <form id="registerForm" action="<%= request.getContextPath() %>/auth/register" method="post" novalidate>
                    <input type="hidden" name="csrfToken" value="<%= csrfToken %>">

                    <div class="mb-3">
                        <label for="name" class="form-label fw-semibold">Full Name <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0"><i class="bi bi-person text-muted"></i></span>
                            <input type="text" class="form-control border-start-0" id="name" name="name" 
                                   value="<%= ValidationUtil.escapeHtml(enteredName) %>" 
                                   placeholder="e.g. Sarah Jenkins" required autofocus minlength="2" maxlength="100">
                        </div>
                        <div class="invalid-feedback" id="nameFeedback">Please enter your full name (at least 2 characters).</div>
                    </div>

                    <div class="mb-3">
                        <label for="email" class="form-label fw-semibold">Email Address <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0"><i class="bi bi-envelope text-muted"></i></span>
                            <input type="email" class="form-control border-start-0" id="email" name="email" 
                                   value="<%= ValidationUtil.escapeHtml(enteredEmail) %>" 
                                   placeholder="name@example.com" required maxlength="100">
                        </div>
                        <div class="invalid-feedback" id="emailFeedback">Please enter a valid email address.</div>
                    </div>

                    <div class="row g-2 mb-3">
                        <div class="col-md-6">
                            <label for="password" class="form-label fw-semibold">Password <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="password" name="password" 
                                   placeholder="Min. 8 chars (letters + numbers)" required minlength="8">
                            <div class="invalid-feedback" id="passwordFeedback">Must be at least 8 chars with letters & numbers.</div>
                        </div>
                        <div class="col-md-6">
                            <label for="confirmPassword" class="form-label fw-semibold">Confirm Password <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                   placeholder="Re-type password" required minlength="8">
                            <div class="invalid-feedback" id="confirmPasswordFeedback">Passwords do not match.</div>
                        </div>
                        <div class="form-text small text-muted">
                            Must be at least 8 characters long and contain both letters and numbers.
                        </div>
                    </div>

                    <div class="mb-4">
                        <label for="phone" class="form-label fw-semibold">Phone Number <span class="text-muted fw-normal">(Optional)</span></label>
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0"><i class="bi bi-telephone text-muted"></i></span>
                            <input type="tel" class="form-control border-start-0" id="phone" name="phone" 
                                   value="<%= ValidationUtil.escapeHtml(enteredPhone) %>" 
                                   placeholder="e.g. 9876543210" maxlength="20">
                        </div>
                    </div>

                    <div class="mb-4 form-check small">
                        <input type="checkbox" class="form-check-input" id="termsCheck" required checked>
                        <label class="form-check-label text-muted" for="termsCheck">
                            I agree to the terms of service and understand this is an enterprise demonstration storefront.
                        </label>
                    </div>

                    <button type="submit" id="registerSubmitBtn" class="btn btn-primary w-100 py-2 fs-6 fw-semibold shadow-sm mb-3">
                        <i class="bi bi-check2-circle me-1"></i> Complete Registration
                    </button>

                    <div class="text-center small text-muted">
                        Already have an account? 
                        <a href="<%= request.getContextPath() %>/auth/login" class="fw-semibold text-primary">Sign In here</a>
                    </div>
                </form>

                <script>
                document.addEventListener('DOMContentLoaded', function() {
                    const form = document.getElementById('registerForm');
                    const submitBtn = document.getElementById('registerSubmitBtn');
                    const passInput = document.getElementById('password');
                    const confirmPassInput = document.getElementById('confirmPassword');
                    const nameInput = document.getElementById('name');
                    const emailInput = document.getElementById('email');

                    function validatePasswordMatch() {
                        if (confirmPassInput.value && passInput.value !== confirmPassInput.value) {
                            confirmPassInput.classList.add('is-invalid');
                            confirmPassInput.classList.remove('is-valid');
                            return false;
                        } else if (confirmPassInput.value && passInput.value === confirmPassInput.value) {
                            confirmPassInput.classList.remove('is-invalid');
                            confirmPassInput.classList.add('is-valid');
                            return true;
                        }
                        return false;
                    }

                    confirmPassInput.addEventListener('input', validatePasswordMatch);
                    passInput.addEventListener('input', function() {
                        if (confirmPassInput.value) {
                            validatePasswordMatch();
                        }
                    });

                    form.addEventListener('submit', function(e) {
                        let valid = true;

                        if (!nameInput.value || nameInput.value.trim().length < 2) {
                            nameInput.classList.add('is-invalid');
                            valid = false;
                        } else {
                            nameInput.classList.remove('is-invalid');
                        }

                        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                        if (!emailInput.value || !emailRegex.test(emailInput.value.trim())) {
                            emailInput.classList.add('is-invalid');
                            valid = false;
                        } else {
                            emailInput.classList.remove('is-invalid');
                        }

                        const passRegex = /^(?=.*[A-Za-z])(?=.*\d).{8,}$/;
                        if (!passInput.value || !passRegex.test(passInput.value)) {
                            passInput.classList.add('is-invalid');
                            valid = false;
                        } else {
                            passInput.classList.remove('is-invalid');
                        }

                        if (!validatePasswordMatch()) {
                            valid = false;
                        }

                        if (!valid) {
                            e.preventDefault();
                            e.stopPropagation();
                            return;
                        }

                        // Prevent duplicate form submission
                        submitBtn.disabled = true;
                        submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Creating account...';
                    });
                });
                </script>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
