package com.shoppingcart.filter;

import com.shoppingcart.model.User;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Logger;

/**
 * Filter that enforces administrator role authorization for all /admin/* endpoints.
 */
@WebFilter(filterName = "AdminAuthorizationFilter", urlPatterns = {"/admin", "/admin/*"})
public class AdminAuthorizationFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(AdminAuthorizationFilter.class.getName());

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY) : null;

        if (user == null) {
            LOGGER.warning("Unauthenticated access attempt to: " + request.getRequestURI());
            response.sendRedirect(request.getContextPath() + "/auth/login?error=auth_required");
            return;
        }

        if (!user.isAdmin()) {
            LOGGER.warning("Unauthorized access attempt to admin area by user: " + user.getEmail() + " (" + user.getRole() + ")");
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("errorMessage", "Access Denied: You do not have administrator permissions.");
            request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(request, response);
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
    }
}
