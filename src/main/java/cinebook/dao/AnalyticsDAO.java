package cinebook.dao;

import cinebook.dto.RevenueReportItem;

import java.util.List;

public interface AnalyticsDAO {
    double getTotalRevenue();

    double getTodayRevenue();

    long getTotalBookings();

    long getActiveMoviesCount();

    long getTotalCustomersCount();

    List<RevenueReportItem> getRevenueByMovie();

    List<RevenueReportItem> getRevenueByCinema();

    List<RevenueReportItem> getDailyRevenue(int days);
}
