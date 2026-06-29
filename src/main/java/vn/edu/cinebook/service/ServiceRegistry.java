package vn.edu.cinebook.service;

import vn.edu.cinebook.dao.*;
import vn.edu.cinebook.dao.jdbc.*;

public final class ServiceRegistry {
    private static final UserDAO USERS = new JdbcUserDAO();
    private static final MovieDAO MOVIES = new JdbcMovieDAO();
    private static final CinemaDAO CINEMAS = new JdbcCinemaDAO();
    private static final ShowtimeDAO SHOWTIMES = new JdbcShowtimeDAO();
    private static final ComboDAO COMBOS = new JdbcComboDAO();
    private static final PromotionDAO PROMOTIONS = new JdbcPromotionDAO();
    private static final BookingDAO BOOKINGS = new JdbcBookingDAO();
    private static final ReviewDAO REVIEWS = new JdbcReviewDAO();
    private static final AnalyticsDAO ANALYTICS_DAO = new JdbcAnalyticsDAO();
    private static final BannerDAO BANNERS = new JdbcBannerDAO();
    private static final WatchlistDAO WATCHLISTS = new JdbcWatchlistDAO();
    private static final PricingService PRICING = new PricingService();

    public static final AuthService AUTH = new AuthService(USERS);
    public static final CatalogService CATALOG = new CatalogService(MOVIES, CINEMAS, SHOWTIMES, BANNERS, WATCHLISTS);
    public static final BookingService BOOKING =
            new BookingService(BOOKINGS, COMBOS, PROMOTIONS, PRICING);
    public static final ReviewService REVIEW = new ReviewService(REVIEWS, BOOKINGS);
    public static final AnalyticsService ANALYTICS = new AnalyticsService(ANALYTICS_DAO);

    private ServiceRegistry() {
    }
}
