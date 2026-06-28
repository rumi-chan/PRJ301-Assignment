package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
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

public class ProfileScaffoldServlet extends HttpServlet {
    private static final Set<String> SECTIONS = Set.of("watchlist", "reviews");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String section = request.getServletPath().substring(request.getServletPath().lastIndexOf('/') + 1);
        if (!SECTIONS.contains(section)) {
            throw new AppException(404, "Profile section not found.");
        }
        User user = (User) request.getSession().getAttribute("currentUser");
        if ("watchlist".equals(section) && user != null) {
            request.setAttribute("movies", ServiceRegistry.WATCHLIST.findMoviesByUserId(user.getId()));
        }
        request.setAttribute("profileSection", section);
        WebUtil.view(request, response, "profile/" + section);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = (User) request.getSession().getAttribute("currentUser");
        if (request.getServletPath().endsWith("/watchlist") && user != null) {
            long movieId = Validation.positiveLong(request.getParameter("movieId"), "Movie ID");
            String method = request.getParameter("_method");
            if ("DELETE".equalsIgnoreCase(method)) {
                ServiceRegistry.WATCHLIST.remove(user.getId(), movieId);
                WebUtil.flash(request, "success", "Removed movie from your watchlist.");
            } else {
                ServiceRegistry.WATCHLIST.add(user.getId(), movieId);
                WebUtil.flash(request, "success", "Added movie to your watchlist.");
            }
            String referer = request.getHeader("Referer");
            WebUtil.redirect(request, response, referer != null ? referer : request.getServletPath());
            return;
        }
        WebUtil.flash(request, "info",
                "This profile module is a navigable scaffold ready for its member implementation.");
        WebUtil.redirect(request, response, request.getServletPath());
    }
}
