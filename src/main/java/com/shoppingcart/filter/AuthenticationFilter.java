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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Filter that requires authentication for customer protected areas:
 * /cart/*, /checkout/*, /orders/*, /profile/*
 */
@WebFilter(filterName = "AuthenticationFilter", urlPatterns = {
        "/cart", "/cart/*",
        "/checkout", "/checkout/*",
        "/orders", "/orders/*",
        "/profile", "/profile/*"
})
public class AuthenticationFilter implements Filter {

    public static final String SESSION_USER_KEY = "currentUser";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute(SESSION_USER_KEY) : null;

        if (user == null) {
            String requestURI = request.getRequestURI();
            String query = request.getQueryString();
            String fullPath = requestURI + (query != null ? "?" + query : "");
            String encoded = URLEncoder.encode(fullPath, StandardCharsets.UTF_8);

            response.sendRedirect(request.getContextPath() + "/auth/login?redirect=" + encoded);
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
    }
}
