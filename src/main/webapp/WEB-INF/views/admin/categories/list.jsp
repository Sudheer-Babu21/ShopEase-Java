<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shoppingcart.model.Category" %>
<%@ page import="com.shoppingcart.util.CSRFUtil" %>
<%@ page import="com.shoppingcart.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Category Management");
    request.setAttribute("activeMenu", "categories");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    Category editCategory = (Category) request.getAttribute("editCategory");
    boolean isEdit = (editCategory != null);
    String csrfToken = CSRFUtil.getToken(session);
    String ctx = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/common/admin_header.jsp" />

<div class="row g-4 mb-5">
    <div class="col-12">
        <h2 class="fw-bold mb-1">Product Categories</h2>
        <p class="text-muted small">Organize your product catalog into structured customer-facing classifications</p>
    </div>

    <!-- Add / Edit Form Column -->
    <div class="col-12 col-lg-4">
        <div class="card border-0 shadow-sm p-4 sticky-top" style="top: 85px;">
            <h5 class="fw-bold mb-3 border-bottom pb-2">
                <i class="bi <%= isEdit ? "bi-pencil-square text-warning" : "bi-plus-circle text-primary" %> me-1"></i>
                <%= isEdit ? "Edit Category #" + editCategory.getCategoryId() : "Create Category" %>
            </h5>

            <form action="<%= ctx %>/admin/categories<%= isEdit ? "/edit" : "/add" %>" method="post">
                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                <% if (isEdit) { %>
                    <input type="hidden" name="categoryId" value="<%= editCategory.getCategoryId() %>">
                <% } %>

                <div class="mb-3">
                    <label for="name" class="form-label small fw-semibold">Category Name <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="name" name="name" 
                           value="<%= isEdit ? ValidationUtil.escapeHtml(editCategory.getName()) : "" %>" 
                           required minlength="2" placeholder="e.g. Smart Home">
                </div>

                <div class="mb-4">
                    <label for="description" class="form-label small fw-semibold">Description</label>
                    <textarea class="form-control" id="description" name="description" rows="3" 
                              placeholder="Brief summary of category products..."><%= isEdit && editCategory.getDescription() != null ? editCategory.getDescription() : "" %></textarea>
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary flex-grow-1 shadow-sm">
                        <i class="bi bi-check2 me-1"></i> <%= isEdit ? "Update Category" : "Save Category" %>
                    </button>
                    <% if (isEdit) { %>
                        <a href="<%= ctx %>/admin/categories" class="btn btn-outline-secondary">Cancel</a>
                    <% } %>
                </div>
            </form>
        </div>
    </div>

    <!-- Category Listing Table Column -->
    <div class="col-12 col-lg-8">
        <div class="card border-0 shadow-sm overflow-hidden">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light small">
                        <tr>
                            <th class="ps-3">ID</th>
                            <th>Name</th>
                            <th>Description</th>
                            <th class="text-end pe-3">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (categories == null || categories.isEmpty()) { %>
                            <tr>
                                <td colspan="4" class="text-center py-4 text-muted">No categories created yet.</td>
                            </tr>
                        <% } else {
                            for (Category cat : categories) { %>
                                <tr>
                                    <td class="ps-3 fw-bold text-muted small">#<%= cat.getCategoryId() %></td>
                                    <td>
                                        <span class="fw-bold text-dark"><%= cat.getName() %></span>
                                    </td>
                                    <td class="text-muted small">
                                        <%= cat.getDescription() != null ? cat.getDescription() : "-" %>
                                    </td>
                                    <td class="text-end pe-3">
                                        <div class="d-inline-flex gap-1">
                                            <a href="<%= ctx %>/admin/categories/edit?id=<%= cat.getCategoryId() %>" 
                                               class="btn btn-outline-primary btn-sm" title="Edit Category">
                                                <i class="bi bi-pencil-square"></i>
                                            </a>

                                            <form action="<%= ctx %>/admin/categories/delete" method="post" class="d-inline">
                                                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                                                <input type="hidden" name="categoryId" value="<%= cat.getCategoryId() %>">
                                                <button type="submit" class="btn btn-outline-danger btn-sm" 
                                                        title="Delete Category"
                                                        data-confirm="Are you sure you want to delete category '<%= ValidationUtil.escapeHtml(cat.getName()) %>'? Deletion will be rejected if products are attached.">
                                                    <i class="bi bi-trash3"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                        <%  } 
                           } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/admin_footer.jsp" />
