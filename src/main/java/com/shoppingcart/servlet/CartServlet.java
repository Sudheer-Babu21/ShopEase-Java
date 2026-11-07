package com.shoppingcart.servlet;

import com.shoppingcart.exception.AppException;
import com.shoppingcart.filter.AuthenticationFilter;
import com.shoppingcart.model.CartItem;
import com.shoppingcart.model.User;
import com.shoppingcart.service.CartService;
import com.shoppingcart.util.CSRFUtil;
import com.shoppingcart.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * Controller for persistent shopping cart management.
 */
@WebServlet(name = "CartServlet", urlPatterns = {"/cart", "/cart/add", "/cart/update", "/cart/remove"})
public class CartServlet extends HttpServlet {

    private final CartService cartService = new CartService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute(AuthenticationFilter.SESSION_USER_KEY);
        List<CartItem> items = cartService.getCart(user.getUserId());
        BigDecimal total = cartService.calculateCartTotal(items);

        // Update badge count
        int cartCount = cartService.getCartCount(user.getUserId());
        request.getSession().setAttribute("cartCount", cartCount);

        request.setAttribute("cartItems", items);
        request.setAttribute("cartTotal", total);
        CSRFUtil.getToken(request.getSession(true));

        request.getRequestDispatcher("/WEB-INF/views/cart/view.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // Enforce CSRF token
        if (!CSRFUtil.isValid(request)) {
            request.getSession().setAttribute("errorMessage", "Invalid security token. Please try again.");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        User user = (User) request.getSession().getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        try {
            switch (path) {
                case "/cart/add":
                    handleAdd(request, response, user.getUserId());
                    break;
                case "/cart/update":
                    handleUpdate(request, response, user.getUserId());
                    break;
                case "/cart/remove":
                    handleRemove(request, response, user.getUserId());
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/cart");
                    break;
            }
        } catch (AppException e) {
            request.getSession().setAttribute("errorMessage", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response, long userId)
            throws IOException {
        long productId = Long.parseLong(request.getParameter("productId"));
        int quantity = ValidationUtil.parsePositiveInt(request.getParameter("quantity"), 1);

        cartService.addToCart(userId, productId, quantity);
        request.getSession().setAttribute("successMessage", "Item added to your shopping cart!");

        String redirect = request.getParameter("redirect");
        if (redirect != null && !redirect.trim().isEmpty() && redirect.startsWith(request.getContextPath())) {
            response.sendRedirect(redirect);
        } else {
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, long userId)
            throws IOException {
        long productId = Long.parseLong(request.getParameter("productId"));
        int quantity = ValidationUtil.parsePositiveInt(request.getParameter("quantity"), 1);

        cartService.updateQuantity(userId, productId, quantity);
        request.getSession().setAttribute("successMessage", "Cart quantity updated.");
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private void handleRemove(HttpServletRequest request, HttpServletResponse response, long userId)
            throws IOException {
        long productId = Long.parseLong(request.getParameter("productId"));

        cartService.removeFromCart(userId, productId);
        request.getSession().setAttribute("successMessage", "Item removed from your cart.");
        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
