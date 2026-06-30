package vn.edu.cinebook.service;

import vn.edu.cinebook.dao.BannerDAO;
import vn.edu.cinebook.dao.CinemaDAO;
import vn.edu.cinebook.dao.MovieDAO;
import vn.edu.cinebook.dao.ShowtimeDAO;
import vn.edu.cinebook.dao.WatchlistDAO;
import vn.edu.cinebook.model.Banner;
import vn.edu.cinebook.model.Auditorium;
import vn.edu.cinebook.model.Cinema;
import vn.edu.cinebook.model.Genre;
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
    private final BannerDAO bannerDAO;
    private final WatchlistDAO watchlistDAO;

    public CatalogService(MovieDAO movieDAO, CinemaDAO cinemaDAO, ShowtimeDAO showtimeDAO,
                          BannerDAO bannerDAO, WatchlistDAO watchlistDAO) {
        this.movieDAO = movieDAO;
        this.cinemaDAO = cinemaDAO;
        this.showtimeDAO = showtimeDAO;
        this.bannerDAO = bannerDAO;
        this.watchlistDAO = watchlistDAO;
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

    public List<Cinema> searchCinemas(String city, String query) {
        return cinemaDAO.search(city, query);
    }

    public List<String> cities() {
        return cinemaDAO.listCities();
    }

    public List<Auditorium> activeAuditoriums() {
        return cinemaDAO.listActiveAuditoriums();
    }

    public List<Showtime> showtimes(long movieId, Long cinemaId, LocalDate date) {
        movie(movieId);
        return showtimeDAO.findForMovie(movieId, cinemaId, date);
    }

    public Showtime showtime(long id) {
        return showtimeDAO.findById(id).orElseThrow(() -> new AppException(404, "Showtime not found."));
    }

    public List<Showtime> adminShowtimes() {
        return showtimeDAO.findAllAdmin();
    }

    public long createShowtime(Showtime showtime) {
        movie(showtime.movieId());
        return showtimeDAO.insert(showtime);
    }

    public void updateShowtime(Showtime showtime) {
        movie(showtime.movieId());
        showtimeDAO.update(showtime);
    }

    public void deleteShowtime(long id) {
        showtimeDAO.delete(id);
    }

    public List<Movie> adminMovies(String query) {
        return movieDAO.findAllAdmin(query);
    }

    public List<Genre> allGenres() {
        return movieDAO.listAllGenres();
    }

    public long createMovie(Movie movie, List<Integer> genreIds, List<MovieFormat> formats) {
        return movieDAO.insert(movie, genreIds, formats);
    }

    public void updateMovie(Movie movie, List<Integer> genreIds, List<MovieFormat> formats) {
        movieDAO.update(movie, genreIds, formats);
    }

    public void deleteMovie(long id) {
        movieDAO.delete(id);
    }

    public List<Banner> adminBanners() {
        return bannerDAO.findAllAdmin();
    }

    public List<Banner> activeHomeBanners() {
        return bannerDAO.findActiveHomeBanners();
    }

    public Banner banner(long id) {
        return bannerDAO.findById(id).orElseThrow(() -> new AppException(404, "Banner not found."));
    }

    public long createBanner(Banner banner, Long createdBy) {
        return bannerDAO.insert(banner, createdBy);
    }

    public void updateBanner(Banner banner) {
        bannerDAO.update(banner);
    }

    public void deleteBanner(long id) {
        bannerDAO.delete(id);
    }

    public List<Movie> watchlist(long userId) {
        return watchlistDAO.findMoviesByUserId(userId);
    }

    public boolean inWatchlist(long userId, long movieId) {
        return watchlistDAO.isWatchlisted(userId, movieId);
    }

    public void toggleWatchlist(long userId, long movieId, boolean add) {
        if (add) {
            watchlistDAO.add(userId, movieId);
        } else {
            watchlistDAO.remove(userId, movieId);
        }
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
