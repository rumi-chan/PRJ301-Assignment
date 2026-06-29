package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.model.Movie;
import vn.edu.cinebook.model.MovieFormat;
import vn.edu.cinebook.model.MovieStatus;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.Validation;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@WebServlet({"/admin/movies", "/admin/movies/*"})
public class AdminMovieServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        request.setAttribute("adminSection", "movies");

        if ("create".equals(action)) {
            request.setAttribute("allGenres", ServiceRegistry.CATALOG.allGenres());
            request.setAttribute("allFormats", MovieFormat.values());
            request.setAttribute("allStatuses", MovieStatus.values());
            WebUtil.view(request, response, "admin/movie-form");
            return;
        }

        if ("edit".equals(action)) {
            long id = Validation.positiveLong(request.getParameter("id"), "Movie ID");
            Movie movie = ServiceRegistry.CATALOG.movie(id);
            request.setAttribute("movie", movie);
            request.setAttribute("allGenres", ServiceRegistry.CATALOG.allGenres());
            request.setAttribute("allFormats", MovieFormat.values());
            request.setAttribute("allStatuses", MovieStatus.values());
            WebUtil.view(request, response, "admin/movie-form");
            return;
        }

        String query = request.getParameter("q");
        List<Movie> movies = ServiceRegistry.CATALOG.adminMovies(query);
        request.setAttribute("items", movies);
        request.setAttribute("q", query);
        request.setAttribute("totalCount", movies.size());
        WebUtil.view(request, response, "admin/movies");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String method = request.getParameter("_method");
        if ("DELETE".equalsIgnoreCase(method) || "delete".equals(request.getParameter("action"))) {
            long id = Validation.positiveLong(request.getParameter("id"), "Movie ID");
            ServiceRegistry.CATALOG.deleteMovie(id);
            WebUtil.flash(request, "success", "Movie archived successfully.");
            WebUtil.redirect(request, response, "/admin/movies");
            return;
        }

        try {
            String title = Validation.required(request.getParameter("title"), "Title", 200);
            String slug = Validation.required(request.getParameter("slug"), "Slug", 220);
            String synopsis = Validation.required(request.getParameter("synopsis"), "Synopsis", 4000);
            String director = Validation.required(request.getParameter("director"), "Director", 200);
            String cast = request.getParameter("cast");
            if (cast == null) cast = "";
            int duration = Validation.positiveLong(request.getParameter("durationMinutes"), "Duration") > 600 ? 600 : (int) Long.parseLong(request.getParameter("durationMinutes"));
            String ageRating = Validation.required(request.getParameter("ageRating"), "Age rating", 20);
            LocalDate releaseDate = LocalDate.parse(Validation.required(request.getParameter("releaseDate"), "Release date", 20));
            String posterUrl = request.getParameter("posterUrl");
            String backdropUrl = request.getParameter("backdropUrl");
            String trailerUrl = request.getParameter("trailerUrl");
            MovieStatus status = MovieStatus.valueOf(request.getParameter("status"));

            String[] genreParams = request.getParameterValues("genreIds");
            List<Integer> genreIds = new ArrayList<>();
            if (genreParams != null) {
                for (String gp : genreParams) genreIds.add(Integer.parseInt(gp));
            }

            String[] formatParams = request.getParameterValues("formats");
            List<MovieFormat> formats = new ArrayList<>();
            if (formatParams != null) {
                for (String fp : formatParams) formats.add(MovieFormat.valueOf(fp));
            }

            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isBlank()) {
                Movie movie = new Movie(0, title, slug, synopsis, director, cast, duration, ageRating, releaseDate,
                        posterUrl, backdropUrl, trailerUrl, status, Collections.emptyList(), formats);
                ServiceRegistry.CATALOG.createMovie(movie, genreIds, formats);
                WebUtil.flash(request, "success", "Movie created successfully.");
            } else {
                long id = Validation.positiveLong(idParam, "Movie ID");
                Movie movie = new Movie(id, title, slug, synopsis, director, cast, duration, ageRating, releaseDate,
                        posterUrl, backdropUrl, trailerUrl, status, Collections.emptyList(), formats);
                ServiceRegistry.CATALOG.updateMovie(movie, genreIds, formats);
                WebUtil.flash(request, "success", "Movie updated successfully.");
            }
            WebUtil.redirect(request, response, "/admin/movies");
        } catch (Exception ex) {
            String msg = ex instanceof AppException ae ? ae.getMessage() : "An error occurred saving the movie.";
            request.setAttribute("error", msg);
            request.setAttribute("allGenres", ServiceRegistry.CATALOG.allGenres());
            request.setAttribute("allFormats", MovieFormat.values());
            request.setAttribute("allStatuses", MovieStatus.values());
            request.setAttribute("adminSection", "movies");
            WebUtil.view(request, response, "admin/movie-form");
        }
    }
}
