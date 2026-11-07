package com.shoppingcart.servlet.admin;

import com.shoppingcart.dao.UserDAO;
import com.shoppingcart.model.User;
import com.shoppingcart.util.CSRFUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Controller for Administrator Customer & Account Audit.
 */
@WebServlet(name = "AdminUserServlet", urlPatterns = {"/admin/users"})
public class AdminUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> users = userDAO.findAll();
        request.setAttribute("users", users);
        CSRFUtil.getToken(request.getSession(true));

        request.getRequestDispatcher("/WEB-INF/views/admin/users/list.jsp").forward(request, response);
    }
}
