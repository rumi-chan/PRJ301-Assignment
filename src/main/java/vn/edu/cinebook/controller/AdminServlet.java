package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.util.Map;

@WebServlet({"/admin", "/admin/*"})
public class AdminServlet extends HttpServlet {
    private static final Map<String, String> SECTIONS = Map.ofEntries(
            Map.entry("dashboard", "Dashboard"),
            Map.entry("movies", "Movie Management"),
            Map.entry("cinemas", "Cinema Management"),
            Map.entry("showrooms", "Showroom Management"),
            Map.entry("showtimes", "Showtime Management"),
            Map.entry("combos", "Combo Management"),
            Map.entry("seat-layouts", "Seat Layouts"),
            Map.entry("analytics", "Revenue Analytics"),
            Map.entry("accounts", "Customer Accounts"),
            Map.entry("promotions", "Promotions"),
            Map.entry("reviews", "Review Moderation"),
            Map.entry("banners", "Homepage Banners")
    );

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getPathInfo();
        String section = path == null || path.equals("/") ? "dashboard" : path.substring(1);
        if (!SECTIONS.containsKey(section)) {
            throw new AppException(404, "Admin section not found.");
        }
        request.setAttribute("adminSection", section);
        request.setAttribute("adminTitle", SECTIONS.get(section));
        request.setAttribute("adminSections", SECTIONS);
        WebUtil.view(request, response, "admin/" + section);
    }
}
