package vn.edu.cinebook.service;

import vn.edu.cinebook.dao.BookingDAO;
import vn.edu.cinebook.dao.CinemaDAO;
import vn.edu.cinebook.dao.ComboDAO;
import vn.edu.cinebook.dao.MovieDAO;
import vn.edu.cinebook.dao.PromotionDAO;
import vn.edu.cinebook.dao.ShowtimeDAO;
import vn.edu.cinebook.dao.UserDAO;
import vn.edu.cinebook.dao.jdbc.JdbcBookingDAO;
import vn.edu.cinebook.dao.jdbc.JdbcCinemaDAO;
import vn.edu.cinebook.dao.jdbc.JdbcComboDAO;
import vn.edu.cinebook.dao.jdbc.JdbcMovieDAO;
import vn.edu.cinebook.dao.jdbc.JdbcPromotionDAO;
import vn.edu.cinebook.dao.jdbc.JdbcShowtimeDAO;
import vn.edu.cinebook.dao.jdbc.JdbcUserDAO;

public final class ServiceRegistry {
    private static final UserDAO USERS = new JdbcUserDAO();
    private static final MovieDAO MOVIES = new JdbcMovieDAO();
    private static final CinemaDAO CINEMAS = new JdbcCinemaDAO();
    private static final ShowtimeDAO SHOWTIMES = new JdbcShowtimeDAO();
    private static final ComboDAO COMBOS = new JdbcComboDAO();
    private static final PromotionDAO PROMOTIONS = new JdbcPromotionDAO();
    private static final BookingDAO BOOKINGS = new JdbcBookingDAO();
    private static final PricingService PRICING = new PricingService();

    public static final AuthService AUTH = new AuthService(USERS);
    public static final CatalogService CATALOG = new CatalogService(MOVIES, CINEMAS, SHOWTIMES);
    public static final BookingService BOOKING =
            new BookingService(BOOKINGS, COMBOS, PROMOTIONS, PRICING);

    private ServiceRegistry() {
    }
}
