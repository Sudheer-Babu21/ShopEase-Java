package com.shoppingcart.servlet;

import com.shoppingcart.exception.AppException;
import com.shoppingcart.filter.AuthenticationFilter;
import com.shoppingcart.model.Order;
import com.shoppingcart.model.User;
import com.shoppingcart.service.OrderService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Controller for Customer Order History, Tracking, and Detail Views.
 */
@WebServlet(name = "OrderServlet", urlPatterns = {"/orders", "/orders/detail", "/orders/confirmation"})
public class OrderServlet extends HttpServlet {

    private final OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        User user = (User) request.getSession().getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        if ("/orders/confirmation".equals(path)) {
            showConfirmation(request, response, user.getUserId());
        } else if ("/orders/detail".equals(path)) {
            showOrderDetail(request, response, user.getUserId());
        } else {
            showOrderList(request, response, user.getUserId());
        }
    }

    private void showOrderList(HttpServletRequest request, HttpServletResponse response, long userId)
            throws ServletException, IOException {
        List<Order> orders = orderService.getCustomerOrders(userId);
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/WEB-INF/views/orders/list.jsp").forward(request, response);
    }

    private void showOrderDetail(HttpServletRequest request, HttpServletResponse response, long userId)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }

        try {
            long orderId = Long.parseLong(idParam.trim());
            // Strictly verifies order ownership against the authenticated customer
            Order order = orderService.getOrderForCustomer(orderId, userId);
            request.setAttribute("order", order);
            request.getRequestDispatcher("/WEB-INF/views/orders/detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/orders");
        } catch (AppException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(request, response);
        }
    }

    private void showConfirmation(HttpServletRequest request, HttpServletResponse response, long userId)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }

        try {
            long orderId = Long.parseLong(idParam.trim());
            Order order = orderService.getOrderForCustomer(orderId, userId);
            request.setAttribute("order", order);
            request.getRequestDispatcher("/WEB-INF/views/orders/confirmation.jsp").forward(request, response);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/orders");
        }
    }
}
