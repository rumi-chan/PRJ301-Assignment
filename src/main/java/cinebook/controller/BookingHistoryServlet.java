package cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import cinebook.model.User;
import cinebook.service.ServiceRegistry;
import cinebook.util.WebUtil;

import java.io.IOException;

@WebServlet("/profile/bookings")
public class BookingHistoryServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("currentUser");
        request.setAttribute("bookings", ServiceRegistry.BOOKING.history(user.id()));
        WebUtil.view(request, response, "profile/bookings");
    }
}
