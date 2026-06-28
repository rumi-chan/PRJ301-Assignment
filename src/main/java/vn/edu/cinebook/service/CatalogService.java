package vn.edu.cinebook.service;

import vn.edu.cinebook.dao.CinemaDAO;
import vn.edu.cinebook.dao.MovieDAO;
import vn.edu.cinebook.dao.ShowtimeDAO;
import vn.edu.cinebook.model.Cinema;
import vn.edu.cinebook.model.Movie;
import vn.edu.cinebook.model.MovieFormat;
import vn.edu.cinebook.model.MovieStatus;
import vn.edu.cinebook.model.Showtime;
import vn.edu.cinebook.util.AppException;

import java.time.LocalDate;
import java.util.List;

public class CatalogService {
    private final MovieDAO movieDAO;
    private final CinemaDAO cinemaDAO;
    private final ShowtimeDAO showtimeDAO;

    public CatalogService(MovieDAO movieDAO, CinemaDAO cinemaDAO, ShowtimeDAO showtimeDAO) {
        this.movieDAO = movieDAO;
        this.cinemaDAO = cinemaDAO;
        this.showtimeDAO = showtimeDAO;
    }

    public List<Movie> searchMovies(String status, String query, String genre, String format) {
        return movieDAO.search(parseStatus(status), query, genre, parseFormat(format));
    }

    public Movie movie(long id) {
        return movieDAO.findById(id).orElseThrow(() -> new AppException(404, "Movie not found."));
    }

    public List<String> genres() {
        return movieDAO.listGenres();
    }

    public List<Movie> allMoviesAdmin() {
        return movieDAO.findAllForAdmin();
    }

    public void insertMovie(Movie movie) {
        movieDAO.insert(movie);
    }

    public void updateMovie(Movie movie) {
        movieDAO.update(movie);
    }

    public void deleteMovie(long id) {
        movieDAO.delete(id);
    }

    public List<Cinema> searchCinemas(String city, String query) {
        return cinemaDAO.search(city, query);
    }

    public List<String> cities() {
        return cinemaDAO.listCities();
    }

    public List<Showtime> showtimes(long movieId, Long cinemaId, LocalDate date) {
        movie(movieId);
        return showtimeDAO.findForMovie(movieId, cinemaId, date);
    }

    public Showtime showtime(long id) {
        return showtimeDAO.findById(id).orElseThrow(() -> new AppException(404, "Showtime not found."));
    }

    private MovieStatus parseStatus(String value) {
        if (value == null || value.isBlank() || "all".equalsIgnoreCase(value)) {
            return null;
        }
        try {
            return MovieStatus.valueOf(value.trim().toUpperCase());
        } catch (IllegalArgumentException exception) {
            throw new AppException(400, "Unknown movie status.");
        }
    }

    private MovieFormat parseFormat(String value) {
        if (value == null || value.isBlank() || "all".equalsIgnoreCase(value)) {
            return null;
        }
        return switch (value.trim().toUpperCase()) {
            case "2D", "TWO_D" -> MovieFormat.TWO_D;
            case "3D", "THREE_D" -> MovieFormat.THREE_D;
            case "IMAX" -> MovieFormat.IMAX;
            default -> throw new AppException(400, "Unknown movie format.");
        };
    }
}
