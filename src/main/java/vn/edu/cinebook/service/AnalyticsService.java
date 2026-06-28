package vn.edu.cinebook.service;

import vn.edu.cinebook.dao.AnalyticsDAO;
import vn.edu.cinebook.dto.DashboardMetric;
import vn.edu.cinebook.dto.RevenueReportItem;

import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;

public class AnalyticsService {
    private final AnalyticsDAO analyticsDAO;
    private final NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));

    public AnalyticsService(AnalyticsDAO analyticsDAO) {
        this.analyticsDAO = analyticsDAO;
    }

    public List<DashboardMetric> getDashboardMetrics() {
        double todayRev = analyticsDAO.getTodayRevenue();
        double totalRev = analyticsDAO.getTotalRevenue();
        long bookings = analyticsDAO.getTotalBookings();
        long activeMovies = analyticsDAO.getActiveMoviesCount();
        long customers = analyticsDAO.getTotalCustomersCount();

        return List.of(
                new DashboardMetric("Revenue today", currencyFormat.format(todayRev), true, "Total rev: " + currencyFormat.format(totalRev)),
                new DashboardMetric("Paid Bookings", String.format("%,d", bookings), true, "Completed orders"),
                new DashboardMetric("Active Movies", String.format("%,d", activeMovies), true, "Now showing in catalog"),
                new DashboardMetric("Customers", String.format("%,d", customers), true, "Registered user accounts")
        );
    }

    public List<RevenueReportItem> getMovieRevenueReport() {
        return analyticsDAO.getRevenueByMovie();
    }

    public List<RevenueReportItem> getCinemaRevenueReport() {
        return analyticsDAO.getRevenueByCinema();
    }

    public List<RevenueReportItem> getDailyRevenueReport(int days) {
        return analyticsDAO.getDailyRevenue(days);
    }
}
