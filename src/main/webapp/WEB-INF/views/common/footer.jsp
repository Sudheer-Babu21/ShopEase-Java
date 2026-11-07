<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    </div>
</main>

<!-- Footer -->
<footer class="footer-custom">
    <div class="container">
        <div class="row g-4 mb-4">
            <div class="col-12 col-md-4">
                <h5 class="text-white fw-bold d-flex align-items-center gap-2 mb-3">
                    <i class="bi bi-bag-check-fill text-info"></i> ShopEase
                </h5>
                <p class="small text-secondary">
                    Your full-featured modern online shopping platform built with Java Servlets, Oracle Database XE 10g, and responsive Bootstrap 5.
                </p>
                <div class="text-secondary small">
                    <i class="bi bi-shield-check text-success me-1"></i> BCrypt Secured &bull; Concurrency Protected
                </div>
            </div>

            <div class="col-6 col-md-2">
                <h6 class="text-white fw-semibold mb-3">Storefront</h6>
                <ul class="list-unstyled small">
                    <li class="mb-2"><a href="<%= request.getContextPath() %>/products">All Products</a></li>
                    <li class="mb-2"><a href="<%= request.getContextPath() %>/cart">Shopping Cart</a></li>
                    <li class="mb-2"><a href="<%= request.getContextPath() %>/orders">Order History</a></li>
                </ul>
            </div>

            <div class="col-6 col-md-2">
                <h6 class="text-white fw-semibold mb-3">Account</h6>
                <ul class="list-unstyled small">
                    <li class="mb-2"><a href="<%= request.getContextPath() %>/auth/login">Customer Sign In</a></li>
                    <li class="mb-2"><a href="<%= request.getContextPath() %>/auth/register">Create Account</a></li>
                    <li class="mb-2"><a href="<%= request.getContextPath() %>/profile">My Profile</a></li>
                </ul>
            </div>

            <div class="col-12 col-md-4">
                <h6 class="text-white fw-semibold mb-3">Technology Stack</h6>
                <div class="d-flex flex-wrap gap-2">
                    <span class="badge bg-secondary">JDK 21</span>
                    <span class="badge bg-secondary">Java Servlets 4.0</span>
                    <span class="badge bg-secondary">Oracle XE 10g</span>
                    <span class="badge bg-secondary">Tomcat 9.0.120</span>
                    <span class="badge bg-secondary">JDBC</span>
                    <span class="badge bg-secondary">Bootstrap 5</span>
                </div>
                <div class="mt-3 small text-secondary">
                    Demonstration application for secure enterprise Java web architecture.
                </div>
            </div>
        </div>

        <div class="border-top border-secondary pt-3 text-center small text-secondary">
            &copy; 2026 ShopEase Online Shopping Cart. All rights reserved.
        </div>
    </div>
</footer>

<!-- Bootstrap 5 Bundle JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<!-- Custom Application JS -->
<script src="<%= request.getContextPath() %>/assets/js/app.js"></script>
</body>
</html>
