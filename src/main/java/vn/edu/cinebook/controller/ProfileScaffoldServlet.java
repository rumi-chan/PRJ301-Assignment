package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.model.User;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.Validation;
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

        User user = (User) request.getSession().getAttribute("currentUser");
        if ("watchlist".equals(section) && user != null) {
            request.setAttribute("movies", ServiceRegistry.CATALOG.watchlist(user.id()));
        }

        WebUtil.view(request, response, "profile/" + section);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null) {
            WebUtil.redirect(request, response, "/login");
            return;
        }
        String section = request.getServletPath().substring(request.getServletPath().lastIndexOf('/') + 1);
        if ("watchlist".equals(section)) {
            long movieId = Validation.positiveLong(request.getParameter("movieId"), "Movie ID");
            String method = request.getParameter("_method");
            if ("DELETE".equalsIgnoreCase(method)) {
                ServiceRegistry.CATALOG.toggleWatchlist(user.id(), movieId, false);
                WebUtil.flash(request, "success", "Removed from watchlist.");
            } else {
                ServiceRegistry.CATALOG.toggleWatchlist(user.id(), movieId, true);
                WebUtil.flash(request, "success", "Added to watchlist.");
            }
            String referer = request.getHeader("Referer");
            if (referer != null && !referer.isBlank()) {
                response.sendRedirect(referer);
            } else {
                WebUtil.redirect(request, response, "/profile/watchlist");
            }
            return;
        }

        WebUtil.flash(request, "info",
                "This profile module is a navigable scaffold ready for its member implementation.");
        WebUtil.redirect(request, response, request.getServletPath());
    }
}
