package cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import cinebook.model.User;
import cinebook.service.ServiceRegistry;
import cinebook.util.AppException;
import cinebook.util.WebUtil;

import java.io.IOException;

@WebServlet("/tickets/*")
public class TicketServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getPathInfo();
        if (path == null || path.length() <= 1) {
            throw new AppException(404, "Ticket not found.");
        }
        User user = (User) request.getSession().getAttribute("currentUser");
        request.setAttribute("booking", ServiceRegistry.BOOKING.ticket(
                path.substring(1), user.isAdmin() ? null : user.id()));
        WebUtil.view(request, response, "tickets/detail");
    }
}
