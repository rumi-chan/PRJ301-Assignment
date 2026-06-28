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
    private static final PricingService PRICING = new PricingService();
    public static final AuthService AUTH = new AuthService(USERS);
    public static final CatalogService CATALOG = new CatalogService(MOVIES, CINEMAS, SHOWTIMES);
    public static final BookingService BOOKING
            = new BookingService(BOOKINGS, COMBOS, PROMOTIONS, PRICING);
            
    // 2 dòng đăng ký cho Người thứ 4 nằm chuẩn ở đây:
    public static final ReviewService REVIEW = new ReviewService(REVIEWS);
    public static final AnalyticsService ANALYTICS = new AnalyticsService(ANALYTICS_DAO);
    private ServiceRegistry() {
    }
}