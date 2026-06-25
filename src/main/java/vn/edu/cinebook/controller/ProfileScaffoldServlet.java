package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.util.Set;

@WebServlet({"/profile/watchlist", "/profile/reviews"})
public class ProfileScaffoldServlet extends HttpServlet {
    private static final Set<String> SECTIONS = Set.of("watchlist", "reviews");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String section = request.getServletPath().substring(request.getServletPath().lastIndexOf('/') + 1);
        if (!SECTIONS.contains(section)) {
            throw new AppException(404, "Profile section not found.");
        }
        request.setAttribute("profileSection", section);
        WebUtil.view(request, response, "profile/" + section);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        WebUtil.flash(request, "info",
                "This profile module is a navigable scaffold ready for its member implementation.");
        WebUtil.redirect(request, response, request.getServletPath());
    }
}
