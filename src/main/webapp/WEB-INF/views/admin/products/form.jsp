<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.Product" %>
<%@ page import="com.shoppingcart.model.Category" %>
<%@ page import="com.shoppingcart.util.CSRFUtil" %>
<%@ page import="com.shoppingcart.util.CurrencyUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%
    Product p = (Product) request.getAttribute("product");
    boolean isEdit = (p != null && p.getProductId() != null);
    request.setAttribute("pageTitle", isEdit ? "Edit Product #" + p.getProductId() : "Add New Product");
    request.setAttribute("activeMenu", "products");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    String csrfToken = CSRFUtil.getToken(session);
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/admin_header.jsp" />

<div class="row justify-content-center">
    <div class="col-12 col-lg-8">
        <div class="card border-0 shadow-sm p-4 p-md-5 mb-4">
            <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-4">
                <h4 class="fw-bold mb-0">
                    <i class="bi <%= isEdit ? "bi-pencil-square" : "bi-plus-circle" %> me-2 text-primary"></i>
                    <%= isEdit ? "Edit Product #" + p.getProductId() : "Add New Product" %>
                </h4>
                <a href="<%= ctx %>/admin/products" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left me-1"></i> Back to Products
                </a>
            </div>

            <form action="<%= ctx %>/admin/products<%= isEdit ? "/edit" : "/add" %>" method="post" enctype="multipart/form-data">
                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                <% if (isEdit) { %>
                    <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                    <input type="hidden" name="existingImagePath" value="<%= p.getImagePath() != null ? p.getImagePath() : "" %>">
                <% } %>

                <div class="row g-3 mb-3">
                    <div class="col-md-8">
                        <label for="name" class="form-label fw-semibold">Product Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="name" name="name" 
                               value="<%= (p != null && p.getName() != null) ? ValidationUtil.escapeHtml(p.getName()) : "" %>" 
                               required minlength="2" placeholder="e.g. Wireless Noise Cancelling Headphones">
                    </div>

                    <div class="col-md-4">
                        <label for="categoryId" class="form-label fw-semibold">Category <span class="text-danger">*</span></label>
                        <select class="form-select" id="categoryId" name="categoryId" required>
                            <option value="">Select Category...</option>
                            <% if (categories != null) {
                                for (Category cat : categories) {
                                    boolean sel = (p != null && cat.getCategoryId().equals(p.getCategoryId()));
                            %>
                                <option value="<%= cat.getCategoryId() %>" <%= sel ? "selected" : "" %>><%= cat.getName() %></option>
                            <%  } 
                               } %>
                        </select>
                    </div>
                </div>

                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label for="price" class="form-label fw-semibold">Price (<%= CurrencyUtil.getSymbol() %> INR) <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text"><%= CurrencyUtil.getSymbol() %></span>
                            <input type="number" step="0.01" min="0.00" class="form-control" id="price" name="price" 
                                   value="<%= (p != null && p.getPrice() != null) ? p.getPrice() : "0.00" %>" required>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <label for="stockQty" class="form-label fw-semibold">Stock Quantity <span class="text-danger">*</span></label>
                        <input type="number" min="0" class="form-control" id="stockQty" name="stockQty" 
                               value="<%= (p != null) ? p.getStockQty() : "10" %>" required>
                    </div>
                </div>

                <div class="mb-3">
                    <label for="description" class="form-label fw-semibold">Description</label>
                    <textarea class="form-control" id="description" name="description" rows="3" 
                              placeholder="Key specifications, materials, warranty, features..."><%= (p != null && p.getDescription() != null) ? p.getDescription() : "" %></textarea>
                </div>

                <!-- Image Upload Section -->
                <div class="card bg-light border p-3 mb-4">
                    <label class="form-label fw-semibold mb-1">Product Image</label>
                    <p class="small text-muted mb-2">Max file size: 2MB. Supported formats: JPG, PNG, WEBP.</p>

                    <div class="d-flex align-items-center gap-3">
                        <div style="width: 80px; height: 80px;" class="border rounded bg-white overflow-hidden d-flex align-items-center justify-content-center p-1">
                            <img id="imagePreviewTarget" 
                                 src="<%= (p != null && p.getImagePath() != null) ? ctx + "/" + p.getImagePath() : ctx + "/assets/images/placeholder.jpg" %>" 
                                 alt="Preview" class="img-fluid" style="max-height: 100%; object-fit: contain;"
                                 onerror="this.onerror=null; this.src='<%= ctx %>/assets/images/placeholder.jpg';">
                        </div>

                        <div class="flex-grow-1">
                            <input class="form-control" type="file" id="imageFileInput" name="imageFile" accept="image/jpeg,image/png,image/webp">
                            <% if (isEdit && p.getImagePath() != null) { %>
                                <div class="form-text small text-muted">Current file: <code><%= p.getImagePath() %></code> (Leave empty to keep existing).</div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Active Status -->
                <div class="form-check form-switch mb-4">
                    <input class="form-check-input" type="checkbox" id="active" name="active" value="1" 
                           <%= (p == null || p.isActive()) ? "checked" : "" %>>
                    <label class="form-check-label fw-semibold" for="active">Product is Active & Visible in Storefront</label>
                </div>

                <div class="d-flex justify-content-end gap-2 border-top pt-3">
                    <a href="<%= ctx %>/admin/products" class="btn btn-outline-secondary px-4">Cancel</a>
                    <button type="submit" class="btn btn-primary px-4 shadow-sm">
                        <i class="bi bi-save me-1"></i> Save Product
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/admin_footer.jsp" />
