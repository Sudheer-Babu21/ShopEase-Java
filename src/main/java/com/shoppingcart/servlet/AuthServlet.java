package com.shoppingcart.servlet;

import com.shoppingcart.exception.AppException;
import com.shoppingcart.filter.AuthenticationFilter;
import com.shoppingcart.model.User;
import com.shoppingcart.service.AuthService;
import com.shoppingcart.util.CSRFUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller for Customer Authentication and Registration.
 */
@WebServlet(name = "AuthServlet", urlPatterns = {"/auth/login", "/auth/register"})
public class AuthServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AuthServlet.class.getName());
    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // If already logged in, redirect to home or admin dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute(AuthenticationFilter.SESSION_USER_KEY) != null) {
            User user = (User) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/products");
            }
            return;
        }

        // Initialize CSRF token
        CSRFUtil.getToken(request.getSession(true));

        if ("/auth/register".equals(path)) {
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // Enforce CSRF protection for state-changing POST actions
        if (!CSRFUtil.isValid(request)) {
            request.setAttribute("errorMessage", "Invalid security token. Please refresh the page and try again.");
            if ("/auth/register".equals(path)) {
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            }
            return;
        }

        if ("/auth/register".equals(path)) {
            handleRegister(request, response);
        } else {
            handleLogin(request, response);
        }
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String redirect = request.getParameter("redirect");

        try {
            User user = authService.authenticate(email, password);

            // Session Fixation Protection: Renew session ID upon successful login
            request.changeSessionId();

            HttpSession session = request.getSession(true);
            session.setAttribute(AuthenticationFilter.SESSION_USER_KEY, user);

            // Safe redirect handling
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                return;
            }

            if (redirect != null && !redirect.trim().isEmpty() && isSafeRedirect(redirect.trim(), request)) {
                response.sendRedirect(redirect.trim());
            } else {
                response.sendRedirect(request.getContextPath() + "/products");
            }

        } catch (AppException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.setAttribute("enteredEmail", email);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        }
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String phone = request.getParameter("phone");

        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match.");
            request.setAttribute("enteredName", name);
            request.setAttribute("enteredEmail", email);
            request.setAttribute("enteredPhone", phone);
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        try {
            User newUser = authService.registerCustomer(name, email, password, phone);
            if (newUser == null || newUser.getUserId() == null || newUser.getUserId() <= 0) {
                throw new AppException("User registration could not be verified in database.");
            }

            // Ensure clean session state without auto-logging in
            HttpSession session = request.getSession(true);
            session.removeAttribute(AuthenticationFilter.SESSION_USER_KEY);
            session.setAttribute("successMessage", "Registration successful! Your account has been created. Please log in.");
            session.setAttribute("registeredEmail", newUser.getEmail());

            // Post/Redirect/Get to login page
            response.sendRedirect(request.getContextPath() + "/auth/login?registered=true");

        } catch (AppException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.setAttribute("enteredName", name);
            request.setAttribute("enteredEmail", email);
            request.setAttribute("enteredPhone", phone);
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected server error during user registration", e);
            request.setAttribute("errorMessage", "An unexpected server error occurred during registration. Please try again later.");
            request.setAttribute("enteredName", name);
            request.setAttribute("enteredEmail", email);
            request.setAttribute("enteredPhone", phone);
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
        }
    }

    private boolean isSafeRedirect(String redirect, HttpServletRequest request) {
        if (redirect == null || redirect.trim().isEmpty()) {
            return false;
        }
        String ctx = request.getContextPath();
        String clean = redirect.trim();
        if (!clean.startsWith(ctx + "/") && !clean.equals(ctx)) {
            return false;
        }
        if (clean.contains("://") || clean.contains("\\") || clean.contains("@") || clean.startsWith("//")) {
            return false;
        }
        return true;
    }
}
