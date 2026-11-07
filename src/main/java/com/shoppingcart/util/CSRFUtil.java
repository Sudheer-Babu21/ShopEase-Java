package com.shoppingcart.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Utility for Cross-Site Request Forgery (CSRF) token generation and validation.
 */
public final class CSRFUtil {

    public static final String CSRF_SESSION_ATTR = "CSRF_TOKEN";
    public static final String CSRF_PARAM_NAME = "csrfToken";

    private static final SecureRandom RANDOM = new SecureRandom();

    private CSRFUtil() {
        // Utility class
    }

    /**
     * Retrieves the current session CSRF token, or creates a new cryptographically secure token.
     */
    public static String getToken(HttpSession session) {
        if (session == null) return "";
        synchronized (session) {
            String token = (String) session.getAttribute(CSRF_SESSION_ATTR);
            if (token == null || token.isEmpty()) {
                byte[] bytes = new byte[32];
                RANDOM.nextBytes(bytes);
                token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
                session.setAttribute(CSRF_SESSION_ATTR, token);
            }
            return token;
        }
    }

    /**
     * Validates that the submitted request contains a matching CSRF token.
     */
    public static boolean isValid(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        String sessionToken = (String) session.getAttribute(CSRF_SESSION_ATTR);
        if (sessionToken == null || sessionToken.isEmpty()) {
            return false;
        }

        String requestToken = request.getParameter(CSRF_PARAM_NAME);
        if (requestToken == null || requestToken.isEmpty()) {
            requestToken = request.getHeader("X-CSRF-Token");
        }

        return sessionToken.equals(requestToken);
    }
}
