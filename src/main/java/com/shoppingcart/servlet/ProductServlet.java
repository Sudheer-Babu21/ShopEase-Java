package com.shoppingcart.servlet;

import com.shoppingcart.filter.AuthenticationFilter;
import com.shoppingcart.model.Category;
import com.shoppingcart.model.Product;
import com.shoppingcart.model.User;
import com.shoppingcart.service.CartService;
import com.shoppingcart.service.ProductService;
import com.shoppingcart.util.CSRFUtil;
import com.shoppingcart.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Optional;

/**
 * Controller for customer storefront, product catalog browsing, searching, and details.
 */
@WebServlet(name = "ProductServlet", urlPatterns = {"/products", "/products/view", "/products/detail"})
public class ProductServlet extends HttpServlet {

    private final ProductService productService = new ProductService();
    private final CartService cartService = new CartService();

    private static final int DEFAULT_PAGE_SIZE = 9;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // Populate cart count badge for authenticated users
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute(AuthenticationFilter.SESSION_USER_KEY) != null) {
            User user = (User) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
            int cartCount = cartService.getCartCount(user.getUserId());
            session.setAttribute("cartCount", cartCount);
        }

        CSRFUtil.getToken(request.getSession(true));

        if ("/products/view".equals(path) || "/products/detail".equals(path)) {
            showProductDetail(request, response);
        } else {
            showCatalog(request, response);
        }
    }

    private void showCatalog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int page = ValidationUtil.parsePositiveInt(request.getParameter("page"), 1);
        int pageSize = ValidationUtil.parsePositiveInt(request.getParameter("pageSize"), DEFAULT_PAGE_SIZE);

        String categoryParam = request.getParameter("category");
        Long categoryId = null;
        if (categoryParam != null && !categoryParam.trim().isEmpty()) {
            try {
                categoryId = Long.parseLong(categoryParam.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        String keyword = request.getParameter("q");
        String sortBy = request.getParameter("sort");

        int totalCount = productService.countStorefrontProducts(categoryId, keyword);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<Product> products = productService.getStorefrontProducts(page, pageSize, categoryId, keyword, sortBy);
        List<Category> categories = productService.getAllCategories();
        List<Product> featured = productService.getFeaturedProducts(4);

        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("featuredProducts", featured);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("selectedCategory", categoryId);
        request.setAttribute("searchKeyword", keyword != null ? keyword.trim() : "");
        request.setAttribute("selectedSort", sortBy != null ? sortBy.trim() : "");

        request.getRequestDispatcher("/WEB-INF/views/products/catalog.jsp").forward(request, response);
    }

    private void showProductDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        try {
            long productId = Long.parseLong(idParam.trim());
            Optional<Product> prodOpt = productService.getProductById(productId);

            if (prodOpt.isEmpty() || !prodOpt.get().isActive()) {
                request.setAttribute("errorMessage", "The requested product does not exist or has been discontinued.");
                request.getRequestDispatcher("/WEB-INF/views/errors/404.jsp").forward(request, response);
                return;
            }

            request.setAttribute("product", prodOpt.get());
            request.getRequestDispatcher("/WEB-INF/views/products/detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/products");
        }
    }
}
