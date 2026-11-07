package com.shoppingcart.servlet.admin;

import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.Order;
import com.shoppingcart.service.OrderService;
import com.shoppingcart.util.CSRFUtil;
import com.shoppingcart.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Controller for Administrator Order tracking, lifecycle status updates, and audit review.
 */
@WebServlet(name = "AdminOrderServlet", urlPatterns = {
        "/admin/orders",
        "/admin/orders/detail",
        "/admin/orders/status"
})
public class AdminOrderServlet extends HttpServlet {

    private final OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        CSRFUtil.getToken(request.getSession(true));

        if ("/admin/orders/detail".equals(path)) {
            showOrderDetail(request, response);
        } else {
            showOrderList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!CSRFUtil.isValid(request)) {
            request.getSession().setAttribute("errorMessage", "Invalid security token. Please try again.");
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        String path = request.getServletPath();
        if ("/admin/orders/status".equals(path)) {
            handleStatusUpdate(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
        }
    }

    private void showOrderList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int page = ValidationUtil.parsePositiveInt(request.getParameter("page"), 1);
        int pageSize = 10;
        String statusFilter = request.getParameter("status");
        String search = request.getParameter("q");

        int totalCount = orderService.countAdminOrders(statusFilter, search);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<Order> orders = orderService.getAdminOrders(page, pageSize, statusFilter, search);

        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("selectedStatus", statusFilter);
        request.setAttribute("searchQuery", search != null ? search.trim() : "");

        request.getRequestDispatcher("/WEB-INF/views/admin/orders/list.jsp").forward(request, response);
    }

    private void showOrderDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        try {
            long orderId = Long.parseLong(idParam.trim());
            Order order = orderService.getOrderForAdmin(orderId);
            request.setAttribute("order", order);
            request.getRequestDispatcher("/WEB-INF/views/admin/orders/detail.jsp").forward(request, response);
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/orders");
        }
    }

    private void handleStatusUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        long orderId = Long.parseLong(request.getParameter("orderId"));
        String newStatus = request.getParameter("status");

        try {
            orderService.updateOrderStatus(orderId, newStatus);
            request.getSession().setAttribute("successMessage", "Order #" + orderId + " status updated to " + newStatus);
        } catch (AppException e) {
            request.getSession().setAttribute("errorMessage", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/orders/detail?id=" + orderId);
    }
}
