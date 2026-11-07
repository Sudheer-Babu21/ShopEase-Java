package com.shoppingcart.servlet;

import com.shoppingcart.exception.AppException;
import com.shoppingcart.filter.AuthenticationFilter;
import com.shoppingcart.model.CartItem;
import com.shoppingcart.model.Order;
import com.shoppingcart.model.User;
import com.shoppingcart.service.CartService;
import com.shoppingcart.service.CheckoutService;
import com.shoppingcart.util.CSRFUtil;

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
 * Controller managing checkout flow, payment selection, and transactional order execution.
 */
@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout", "/checkout/place"})
public class CheckoutServlet extends HttpServlet {

    private final CartService cartService = new CartService();
    private final CheckoutService checkoutService = new CheckoutService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        List<CartItem> cartItems = cartService.getCart(user.getUserId());
        if (cartItems.isEmpty()) {
            session.setAttribute("errorMessage", "Your cart is currently empty. Please add items before checking out.");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        BigDecimal total = cartService.calculateCartTotal(cartItems);

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartTotal", total);
        request.setAttribute("user", user);
        CSRFUtil.getToken(session);

        request.getRequestDispatcher("/WEB-INF/views/checkout/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        // Enforce CSRF protection
        if (!CSRFUtil.isValid(request)) {
            session.setAttribute("errorMessage", "Security token expired or invalid. Please submit the form again.");
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        User user = (User) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
        String address = request.getParameter("shippingAddress");
        String paymentMethod = request.getParameter("paymentMethod");

        try {
            Order placedOrder = checkoutService.processCheckout(user.getUserId(), address, paymentMethod);

            // Update session cart count badge
            session.setAttribute("cartCount", 0);

            response.sendRedirect(request.getContextPath() + "/orders/confirmation?id=" + placedOrder.getOrderId());

        } catch (AppException e) {
            session.setAttribute("errorMessage", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/checkout");
        }
    }
}
