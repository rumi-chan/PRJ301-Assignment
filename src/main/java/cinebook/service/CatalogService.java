package cinebook.service;

import cinebook.dao.*;
import cinebook.dao.jdbc.JdbcSeatDAO;
import cinebook.model.*;
import cinebook.util.AppException;

import java.text.Normalizer;
import java.time.LocalDate;
import java.util.List;
import java.util.regex.Pattern;

public class CatalogService {
    private final MovieDAO movieDAO;
    private final CinemaDAO cinemaDAO;
    private final ShowtimeDAO showtimeDAO;
    private final BannerDAO bannerDAO;
    private final WatchlistDAO watchlistDAO;
    private final AuditoriumDAO auditoriumDAO;
    private final SeatDAO seatDAO = new JdbcSeatDAO();

    public CatalogService(MovieDAO movieDAO, CinemaDAO cinemaDAO, ShowtimeDAO showtimeDAO,
                          BannerDAO bannerDAO, WatchlistDAO watchlistDAO, AuditoriumDAO auditoriumDAO) {
        this.movieDAO = movieDAO;
        this.cinemaDAO = cinemaDAO;
        this.showtimeDAO = showtimeDAO;
        this.bannerDAO = bannerDAO;
        this.watchlistDAO = watchlistDAO;
        this.auditoriumDAO = auditoriumDAO;
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

    public Showtime adminShowtime(long id) {
        return showtimeDAO.findAdminById(id).orElseThrow(() -> new AppException(404, "Showtime not found."));
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

    // ADMINISTRATIVE CINEMA METHODS
    public List<Cinema> getAllCinemasForAdmin() {
        return cinemaDAO.findAll();
    }

    public boolean addCinema(String name, String city, String district, String address, String phone, boolean isActive) {
        String slug = generateSlug(name);
        Cinema newCinema = new Cinema(0L, name, city, slug, district, address, phone, isActive);
        return requireSuccess(cinemaDAO.insert(newCinema), "Cinema could not be created.");
    }

    public Cinema getCinemaById(long id) {
        return cinemaDAO.findById(id).orElseThrow(() -> new AppException(404, "Cinema not found"));
    }

    public boolean updateCinema(long id, String name, String city, String district, String address, String phone, boolean isActive) {
        String slug = generateSlug(name);
        Cinema updatedCinema = new Cinema(id, name, city, slug, district, address, phone, isActive);
        return requireSuccess(cinemaDAO.update(updatedCinema), "Cinema could not be updated.");
    }

    public boolean deleteCinema(long id) {
        return requireSuccess(cinemaDAO.delete(id), "Cinema could not be archived.");
    }

    private String generateSlug(String input) {
        if (input == null || input.isBlank()) {
            return "";
        }

        String normalized = Normalizer.normalize(input, Normalizer.Form.NFD);
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        String slug = pattern.matcher(normalized).replaceAll("").toLowerCase();

        return slug.replaceAll("[^a-z0-9\\s-]", "").trim().replaceAll("\\s+", "-");
    }

    // ADMINISTRATIVE SHOWROOM/AUDITORIUM METHODS
    public List<Auditorium> getAllShowroomsForAdmin() {
        return auditoriumDAO.findAll();
    }

    public boolean addShowroom(long cinemaId, String name, String type, int capacity, boolean isActive) {
        Auditorium newShowroom = new Auditorium(0L, cinemaId, name, type, capacity, isActive);
        return requireSuccess(auditoriumDAO.insert(newShowroom), "Showroom could not be created.");
    }

    public Auditorium getShowroomById(long id) {
        return auditoriumDAO.findById(id).orElseThrow(() -> new AppException(404, "Showroom not found"));
    }

    public boolean updateShowroom(long id, long cinemaId, String name, String type, int capacity, boolean isActive) {
        Auditorium updatedShowroom = new Auditorium(id, cinemaId, name, type, capacity, isActive);
        return requireSuccess(auditoriumDAO.update(updatedShowroom), "Showroom could not be updated.");
    }

    public boolean deleteShowroom(long id) {
        return requireSuccess(auditoriumDAO.delete(id), "Showroom could not be archived.");
    }

    // SEAT LAYOUT METHODS
    public void generateSeats(long auditoriumId) {
        getShowroomById(auditoriumId);
        seatDAO.resetToDefaultLayout(auditoriumId);
    }

    public void updateSeatTypes(java.util.Map<Long, String> updates) {
        seatDAO.updateSeatTypes(updates);
    }

    private boolean requireSuccess(boolean success, String message) {
        if (!success) {
            throw new AppException(404, message);
        }
        return true;
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
            case "2D", "TWO_D" ->
                MovieFormat.TWO_D;
            case "3D", "THREE_D" ->
                MovieFormat.THREE_D;
            case "IMAX" ->
                MovieFormat.IMAX;
            default ->
                throw new AppException(400, "Unknown movie format.");
        };
    }
}
