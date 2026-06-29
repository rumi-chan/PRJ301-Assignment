package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.edu.cinebook.model.User;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.Validation;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.net.URI;
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

        HttpSession session = request.getSession(false);
        User currentUser = session == null ? null : (User) session.getAttribute("currentUser");
        if ("reviews".equals(section)) {
            if (currentUser != null) {
                request.setAttribute("reviews", ServiceRegistry.REVIEW.getUserReviews(currentUser.id()));
            }
        }

        if ("watchlist".equals(section) && currentUser != null) {
            request.setAttribute("movies", ServiceRegistry.CATALOG.watchlist(currentUser.id()));
        }

        request.setAttribute("profileSection", section);
        WebUtil.view(request, response, "profile/" + section);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("currentUser");
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
            redirectBackToApp(request, response);
            return;
        }

        WebUtil.flash(request, "info",
                "This profile module is a navigable scaffold ready for its member implementation.");
        WebUtil.redirect(request, response, request.getServletPath());
    }

    private void redirectBackToApp(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String referer = request.getHeader("Referer");
        if (isSameAppReferer(request, referer)) {
            response.sendRedirect(referer);
            return;
        }
        WebUtil.redirect(request, response, "/profile/watchlist");
    }

    private boolean isSameAppReferer(HttpServletRequest request, String referer) {
        if (referer == null || referer.isBlank()) {
            return false;
        }
        try {
            URI uri = URI.create(referer);
            String path = uri.getPath();
            return request.getScheme().equalsIgnoreCase(uri.getScheme())
                    && request.getServerName().equalsIgnoreCase(uri.getHost())
                    && request.getServerPort() == normalizedPort(uri)
                    && path != null
                    && path.startsWith(request.getContextPath() + "/");
        } catch (IllegalArgumentException exception) {
            return false;
        }
    }

    private int normalizedPort(URI uri) {
        if (uri.getPort() != -1) {
            return uri.getPort();
        }
        return "https".equalsIgnoreCase(uri.getScheme()) ? 443 : 80;
    }
}
