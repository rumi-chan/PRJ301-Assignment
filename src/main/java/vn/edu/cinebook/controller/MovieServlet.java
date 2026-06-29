package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.edu.cinebook.model.User;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.Validation;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/movies/*")
public class MovieServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getPathInfo();
        if (path != null && path.length() > 1) {
            long id = Validation.positiveLong(path.substring(1), "Movie");
            request.setAttribute("movie", ServiceRegistry.CATALOG.movie(id));
            request.setAttribute("reviews", ServiceRegistry.REVIEW.getMovieReviews(id));
            HttpSession session = request.getSession(false);
            User user = session == null ? null : (User) session.getAttribute("currentUser");
            if (user != null) {
                request.setAttribute("inWatchlist", ServiceRegistry.CATALOG.inWatchlist(user.id(), id));
            }
            WebUtil.view(request, response, "movies/detail");
            return;
        }

        String status = request.getParameter("status");
        if (status == null) {
            status = "NOW_SHOWING";
        }
        String query = request.getParameter("q");
        String genre = request.getParameter("genre");
        String format = request.getParameter("format");
        request.setAttribute("filters", Map.of(
                "status", status,
                "query", query == null ? "" : query,
                "genre", genre == null ? "" : genre,
                "format", format == null ? "" : format
        ));
        request.setAttribute("formats", List.of("2D", "3D", "IMAX"));
        request.setAttribute("genres", ServiceRegistry.CATALOG.genres());
        request.setAttribute("banners", ServiceRegistry.CATALOG.activeHomeBanners());
        var movies = ServiceRegistry.CATALOG.searchMovies(status, query, genre, format);
        request.setAttribute("movies", movies);
        request.setAttribute("totalCount", movies.size());
        request.setAttribute("resultLabel", statusLabel(status));
        request.setAttribute("pageTitle", pageTitle(status, query));
        WebUtil.view(request, response, "movies/list");
    }

    private static String statusLabel(String status) {
        if ("COMING_SOON".equalsIgnoreCase(status)) {
            return "Coming soon";
        }
        if ("NOW_SHOWING".equalsIgnoreCase(status)) {
            return "Now showing";
        }
        return "Cinema catalog";
    }

    private static String pageTitle(String status, String query) {
        if (query != null && !query.isBlank()) {
            return "Search results for \"" + query.trim() + "\"";
        }
        if ("COMING_SOON".equalsIgnoreCase(status)) {
            return "Upcoming movies";
        }
        if ("NOW_SHOWING".equalsIgnoreCase(status)) {
            return "Movies playing now";
        }
        return "Movies to watch";
    }
}
