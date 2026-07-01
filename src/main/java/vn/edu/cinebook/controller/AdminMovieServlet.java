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
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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
            request.setAttribute("selectedGenres", Collections.emptySet());
            request.setAttribute("selectedFormats", Collections.emptySet());
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
            request.setAttribute("selectedGenres", new HashSet<>(movie.getGenres()));
            request.setAttribute("selectedFormats", new HashSet<>(movie.getFormats()));
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
            long durationValue = Validation.positiveLong(request.getParameter("durationMinutes"), "Duration");
            if (durationValue > 600) {
                throw new AppException(400, "Duration must be 600 minutes or less.");
            }
            int duration = (int) durationValue;
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
            if (genreIds.isEmpty()) {
                throw new AppException(400, "Select at least one genre.");
            }
            if (formats.isEmpty()) {
                throw new AppException(400, "Select at least one format.");
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
            preserveMovieFormState(request);
            request.setAttribute("allGenres", ServiceRegistry.CATALOG.allGenres());
            request.setAttribute("allFormats", MovieFormat.values());
            request.setAttribute("allStatuses", MovieStatus.values());
            request.setAttribute("adminSection", "movies");
            WebUtil.view(request, response, "admin/movie-form");
        }
    }

    private void preserveMovieFormState(HttpServletRequest request) {
        String idParam = request.getParameter("id");
        Long id = null;
        if (idParam != null && !idParam.isBlank()) {
            try {
                id = Long.parseLong(idParam);
            } catch (NumberFormatException ignored) {
                id = null;
            }
        }

        MovieStatus status;
        try {
            status = MovieStatus.valueOf(request.getParameter("status"));
        } catch (Exception ignored) {
            status = MovieStatus.NOW_SHOWING;
        }

        Integer duration = null;
        try {
            duration = Integer.parseInt(request.getParameter("durationMinutes"));
        } catch (NumberFormatException ignored) {
            // Keep null so the form can fall back to its default.
        }

        LocalDate releaseDate = null;
        try {
            String releaseDateParam = request.getParameter("releaseDate");
            if (releaseDateParam != null && !releaseDateParam.isBlank()) {
                releaseDate = LocalDate.parse(releaseDateParam);
            }
        } catch (Exception ignored) {
            releaseDate = null;
        }

        Set<String> selectedGenres = new HashSet<>();
        String[] genreParams = request.getParameterValues("genreIds");
        if (genreParams != null) {
            for (String genreId : genreParams) {
                selectedGenres.add(genreId);
            }
        }

        Set<MovieFormat> selectedFormats = new HashSet<>();
        String[] formatParams = request.getParameterValues("formats");
        if (formatParams != null) {
            for (String format : formatParams) {
                try {
                    selectedFormats.add(MovieFormat.valueOf(format));
                } catch (IllegalArgumentException ignored) {
                    // Invalid values are ignored for redisplay; validation has already failed.
                }
            }
        }

        request.setAttribute("movie", new Movie(
                id == null ? 0 : id,
                request.getParameter("title"),
                request.getParameter("slug"),
                request.getParameter("synopsis"),
                request.getParameter("director"),
                request.getParameter("cast"),
                duration,
                request.getParameter("ageRating"),
                releaseDate,
                request.getParameter("posterUrl"),
                request.getParameter("backdropUrl"),
                request.getParameter("trailerUrl"),
                status,
                Collections.emptyList(),
                new ArrayList<>(selectedFormats)
        ));
        request.setAttribute("selectedGenres", selectedGenres);
        request.setAttribute("selectedFormats", selectedFormats);
    }
}
