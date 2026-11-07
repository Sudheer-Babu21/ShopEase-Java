package com.shoppingcart.servlet.admin;

import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.Category;
import com.shoppingcart.service.ProductService;
import com.shoppingcart.util.CSRFUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Optional;

/**
 * Controller for Administrator Category Management.
 */
@WebServlet(name = "AdminCategoryServlet", urlPatterns = {
        "/admin/categories",
        "/admin/categories/add",
        "/admin/categories/edit",
        "/admin/categories/delete"
})
public class AdminCategoryServlet extends HttpServlet {

    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        CSRFUtil.getToken(request.getSession(true));

        if ("/admin/categories/edit".equals(path)) {
            String idParam = request.getParameter("id");
            if (idParam != null) {
                try {
                    long id = Long.parseLong(idParam.trim());
                    Optional<Category> catOpt = productService.getCategoryById(id);
                    catOpt.ifPresent(category -> request.setAttribute("editCategory", category));
                } catch (NumberFormatException ignored) {}
            }
        }

        List<Category> categories = productService.getAllCategories();
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/WEB-INF/views/admin/categories/list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!CSRFUtil.isValid(request)) {
            request.getSession().setAttribute("errorMessage", "Invalid security token. Please try again.");
            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        String path = request.getServletPath();
        try {
            if ("/admin/categories/delete".equals(path)) {
                long categoryId = Long.parseLong(request.getParameter("categoryId"));
                productService.deleteCategory(categoryId);
                request.getSession().setAttribute("successMessage", "Category deleted successfully.");
            } else if ("/admin/categories/edit".equals(path)) {
                long categoryId = Long.parseLong(request.getParameter("categoryId"));
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                productService.updateCategory(categoryId, name, description);
                request.getSession().setAttribute("successMessage", "Category updated successfully.");
            } else {
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                productService.createCategory(name, description);
                request.getSession().setAttribute("successMessage", "Category created successfully.");
            }
        } catch (AppException e) {
            request.getSession().setAttribute("errorMessage", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }
}
