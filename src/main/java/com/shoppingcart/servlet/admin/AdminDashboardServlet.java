package com.shoppingcart.servlet.admin;

import com.shoppingcart.service.OrderService;
import com.shoppingcart.util.CSRFUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

/**
 * Controller for Administrator Dashboard overview and business analytics.
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin", "/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, Object> metrics = orderService.getDashboardSummary();
        request.setAttribute("metrics", metrics);
        CSRFUtil.getToken(request.getSession(true));

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
    }
}
