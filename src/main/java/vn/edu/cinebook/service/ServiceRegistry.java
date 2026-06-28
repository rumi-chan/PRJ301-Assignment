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
import vn.edu.cinebook.dao.WatchlistDAO;
import vn.edu.cinebook.dao.jdbc.JdbcWatchlistDAO;
import vn.edu.cinebook.dao.BannerDAO;
import vn.edu.cinebook.dao.jdbc.JdbcBannerDAO;
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
    public static final BookingService BOOKING =
            new BookingService(BOOKINGS, COMBOS, PROMOTIONS, PRICING);
    public static final WatchlistDAO WATCHLIST = new JdbcWatchlistDAO();
    public static final BannerDAO BANNERS = new JdbcBannerDAO();
    public static final BookingService BOOKING
            = new BookingService(BOOKINGS, COMBOS, PROMOTIONS, PRICING);
            
    // 2 dòng đăng ký cho Người thứ 4 nằm chuẩn ở đây:
    public static final ReviewService REVIEW = new ReviewService(REVIEWS);
    public static final AnalyticsService ANALYTICS = new AnalyticsService(ANALYTICS_DAO);
  
    private ServiceRegistry() {
    }
}