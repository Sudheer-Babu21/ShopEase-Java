package com.shoppingcart.servlet;

import com.shoppingcart.dao.UserDAO;
import com.shoppingcart.exception.AppException;
import com.shoppingcart.filter.AuthenticationFilter;
import com.shoppingcart.model.User;
import com.shoppingcart.service.AuthService;
import com.shoppingcart.service.OrderService;
import com.shoppingcart.util.CSRFUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Optional;

/**
 * Controller for user profile details and password modification.
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile", "/profile/password"})
public class ProfileServlet extends HttpServlet {

    private final AuthService authService = new AuthService();
    private final UserDAO userDAO = new UserDAO();
    private final OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY) : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login?error=auth_required");
            return;
        }

        // Fetch fresh user record directly from Oracle DB
        Optional<User> freshUser = userDAO.findById(sessionUser.getUserId());
        if (freshUser.isEmpty()) {
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/auth/login?error=auth_required");
            return;
        }

        session.setAttribute(AuthenticationFilter.SESSION_USER_KEY, freshUser.get());

        request.setAttribute("recentOrders", orderService.getCustomerOrders(sessionUser.getUserId()));
        CSRFUtil.getToken(session);

        request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY) : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login?error=auth_required");
            return;
        }

        if (!CSRFUtil.isValid(request)) {
            session.setAttribute("errorMessage", "Invalid security token. Please try again.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        String path = request.getServletPath();

        try {
            if ("/profile/password".equals(path)) {
                String currentPass = request.getParameter("currentPassword");
                String newPass = request.getParameter("newPassword");
                String confirmPass = request.getParameter("confirmPassword");

                if (newPass == null || !newPass.equals(confirmPass)) {
                    throw new AppException("New passwords do not match.");
                }

                authService.changePassword(user.getUserId(), currentPass, newPass);
                session.setAttribute("successMessage", "Password updated successfully!");

            } else {
                String name = request.getParameter("name");
                String phone = request.getParameter("phone");

                authService.updateProfile(user.getUserId(), name, phone);

                // Reload verified user entity from Oracle DB
                Optional<User> updatedUser = userDAO.findById(user.getUserId());
                if (updatedUser.isPresent()) {
                    session.setAttribute(AuthenticationFilter.SESSION_USER_KEY, updatedUser.get());
                }
                session.setAttribute("successMessage", "Profile information updated successfully!");
            }
        } catch (AppException e) {
            session.setAttribute("errorMessage", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/profile");
    }
}
