package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.Validation;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;

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
            WebUtil.view(request, response, "movies/detail");
            return;
        }

        String status = request.getParameter("status");
        if (status == null) {
            status = "NOW_SHOWING";
        }
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedGenre", request.getParameter("genre"));
        request.setAttribute("selectedFormat", request.getParameter("format"));
        request.setAttribute("query", request.getParameter("q"));
        request.setAttribute("genres", ServiceRegistry.CATALOG.genres());
        request.setAttribute("movies", ServiceRegistry.CATALOG.searchMovies(
                status, request.getParameter("q"), request.getParameter("genre"),
                request.getParameter("format")));
        WebUtil.view(request, response, "movies/list");
    }
}
