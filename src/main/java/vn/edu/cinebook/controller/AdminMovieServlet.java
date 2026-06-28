package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.model.Movie;
import vn.edu.cinebook.model.MovieFormat;
import vn.edu.cinebook.model.MovieStatus;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.Validation;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class AdminMovieServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("adminSection", "movies");
        String action = request.getParameter("action");

        if ("create".equals(action) || "edit".equals(action)) {
            request.setAttribute("mode", "form");
            request.setAttribute("allGenres", ServiceRegistry.CATALOG.genres());
            request.setAttribute("allFormats", List.of(MovieFormat.TWO_D, MovieFormat.THREE_D, MovieFormat.IMAX));
            request.setAttribute("allStatuses", MovieStatus.values());

            if ("edit".equals(action)) {
                long id = Validation.positiveLong(request.getParameter("id"), "Movie ID");
                request.setAttribute("formTitle", "Edit Movie");
                try {
                    request.setAttribute("movie", ServiceRegistry.CATALOG.movie(id));
                } catch (Exception e) {
                    WebUtil.flash(request, "error", "Movie not found.");
                    WebUtil.redirect(request, response, "/admin/movies");
                    return;
                }
            } else {
                request.setAttribute("formTitle", "Add New Movie");
            }
            WebUtil.view(request, response, "admin/movies");
            return;
        }

        List<Movie> movies = ServiceRegistry.CATALOG.allMoviesAdmin();
        request.setAttribute("movies", movies);
        request.setAttribute("totalCount", movies.size());
        WebUtil.view(request, response, "admin/movies");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action) || "DELETE".equalsIgnoreCase(request.getParameter("_method"))) {
            long id = Validation.positiveLong(request.getParameter("id"), "Movie ID");
            ServiceRegistry.CATALOG.deleteMovie(id);
            WebUtil.flash(request, "success", "Movie retired successfully.");
            WebUtil.redirect(request, response, "/admin/movies");
            return;
        }

        String title = request.getParameter("title");
        String slug = request.getParameter("slug");
        if (slug == null || slug.isBlank()) {
            slug = makeSlug(title);
        }
        String synopsis = request.getParameter("synopsis");
        String director = request.getParameter("director");
        String cast = request.getParameter("cast");
        int durationMinutes = Validation.positiveInt(request.getParameter("durationMinutes"), "Duration");
        String ageRating = request.getParameter("ageRating");
        LocalDate releaseDate = parseDate(request.getParameter("releaseDate"));
        String posterUrl = request.getParameter("posterUrl");
        String backdropUrl = request.getParameter("backdropUrl");
        String trailerUrl = request.getParameter("trailerUrl");
        MovieStatus status = MovieStatus.valueOf(request.getParameter("status"));

        String[] genreArray = request.getParameterValues("genres");
        List<String> genres = genreArray != null ? Arrays.asList(genreArray) : List.of();

        String[] formatArray = request.getParameterValues("formats");
        List<MovieFormat> formats = new ArrayList<>();
        if (formatArray != null) {
            for (String f : formatArray) {
                switch (f.toUpperCase()) {
                    case "3D" -> formats.add(MovieFormat.THREE_D);
                    case "IMAX" -> formats.add(MovieFormat.IMAX);
                    default -> formats.add(MovieFormat.TWO_D);
                }
            }
        }

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isBlank()) {
            long id = Validation.positiveLong(idParam, "Movie ID");
            Movie movie = new Movie(id, title, slug, synopsis, director, cast, durationMinutes, ageRating, releaseDate, posterUrl, backdropUrl, trailerUrl, status, genres, formats);
            ServiceRegistry.CATALOG.updateMovie(movie);
            WebUtil.flash(request, "success", "Movie updated successfully.");
        } else {
            Movie movie = new Movie(0, title, slug, synopsis, director, cast, durationMinutes, ageRating, releaseDate, posterUrl, backdropUrl, trailerUrl, status, genres, formats);
            ServiceRegistry.CATALOG.insertMovie(movie);
            WebUtil.flash(request, "success", "Movie added successfully.");
        }
        WebUtil.redirect(request, response, "/admin/movies");
    }

    private LocalDate parseDate(String val) {
        if (val == null || val.isBlank()) return LocalDate.now();
        try {
            return LocalDate.parse(val);
        } catch (Exception e) {
            return LocalDate.now();
        }
    }

    private String makeSlug(String title) {
        if (title == null) return "movie-" + System.currentTimeMillis();
        String slug = title.toLowerCase().replaceAll("[^a-z0-9]+", "-").replaceAll("^-|-$", "");
        return slug.isEmpty() ? "movie-" + System.currentTimeMillis() : slug;
    }
}
