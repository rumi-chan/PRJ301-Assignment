package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.AnalyticsDAO;
import vn.edu.cinebook.dto.RevenueReportItem;
import vn.edu.cinebook.util.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class JdbcAnalyticsDAO implements AnalyticsDAO {

    @Override
    public double getTotalRevenue() {
        String sql = "SELECT ISNULL(SUM(total_amount), 0) FROM bookings WHERE status IN ('PAID', 'USED')";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            return result.next() ? result.getDouble(1) : 0.0;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public double getTodayRevenue() {
        String sql = "SELECT ISNULL(SUM(total_amount), 0) FROM bookings WHERE status IN ('PAID', 'USED') AND CAST(paid_at AS DATE) = CAST(SYSUTCDATETIME() AS DATE)";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            return result.next() ? result.getDouble(1) : 0.0;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public long getTotalBookings() {
        String sql = "SELECT COUNT(*) FROM bookings WHERE status IN ('PAID', 'USED')";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            return result.next() ? result.getLong(1) : 0L;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public long getActiveMoviesCount() {
        String sql = "SELECT COUNT(*) FROM movies WHERE status = 'NOW_SHOWING'";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            return result.next() ? result.getLong(1) : 0L;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public long getTotalCustomersCount() {
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'CUSTOMER'";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            return result.next() ? result.getLong(1) : 0L;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public List<RevenueReportItem> getRevenueByMovie() {
        String sql = "SELECT m.title AS name, " +
                "COUNT(b.booking_id) AS total_bookings, " +
                "ISNULL(SUM(b.seat_count), 0) AS total_tickets, " +
                "ISNULL(SUM(b.total_amount), 0) AS total_revenue " +
                "FROM ( " +
                "    SELECT b0.booking_id, b0.showtime_id, b0.total_amount, COUNT(bs.booking_seat_id) AS seat_count " +
                "    FROM bookings b0 " +
                "    LEFT JOIN booking_seats bs ON b0.booking_id = bs.booking_id " +
                "    WHERE b0.status IN ('PAID', 'USED') " +
                "    GROUP BY b0.booking_id, b0.showtime_id, b0.total_amount " +
                ") b " +
                "JOIN showtimes s ON b.showtime_id = s.showtime_id " +
                "JOIN movies m ON s.movie_id = m.movie_id " +
                "GROUP BY m.title " +
                "ORDER BY total_revenue DESC";
        return executeReportQuery(sql);
    }

    @Override
    public List<RevenueReportItem> getRevenueByCinema() {
        String sql = "SELECT c.name AS name, " +
                "COUNT(b.booking_id) AS total_bookings, " +
                "ISNULL(SUM(b.seat_count), 0) AS total_tickets, " +
                "ISNULL(SUM(b.total_amount), 0) AS total_revenue " +
                "FROM ( " +
                "    SELECT b0.booking_id, b0.showtime_id, b0.total_amount, COUNT(bs.booking_seat_id) AS seat_count " +
                "    FROM bookings b0 " +
                "    LEFT JOIN booking_seats bs ON b0.booking_id = bs.booking_id " +
                "    WHERE b0.status IN ('PAID', 'USED') " +
                "    GROUP BY b0.booking_id, b0.showtime_id, b0.total_amount " +
                ") b " +
                "JOIN showtimes s ON b.showtime_id = s.showtime_id " +
                "JOIN auditoriums a ON s.auditorium_id = a.auditorium_id " +
                "JOIN cinemas c ON a.cinema_id = c.cinema_id " +
                "GROUP BY c.name " +
                "ORDER BY total_revenue DESC";
        return executeReportQuery(sql);
    }

    @Override
    public List<RevenueReportItem> getDailyRevenue(int days) {
        String sql = "SELECT FORMAT(b.paid_at, 'yyyy-MM-dd') AS name, " +
                "COUNT(b.booking_id) AS total_bookings, " +
                "ISNULL(SUM(b.seat_count), 0) AS total_tickets, " +
                "ISNULL(SUM(b.total_amount), 0) AS total_revenue " +
                "FROM ( " +
                "    SELECT b0.booking_id, b0.paid_at, b0.total_amount, COUNT(bs.booking_seat_id) AS seat_count " +
                "    FROM bookings b0 " +
                "    LEFT JOIN booking_seats bs ON b0.booking_id = bs.booking_id " +
                "    WHERE b0.status IN ('PAID', 'USED') AND b0.paid_at IS NOT NULL " +
                "    GROUP BY b0.booking_id, b0.paid_at, b0.total_amount " +
                ") b " +
                "WHERE b.paid_at >= DATEADD(day, -?, SYSUTCDATETIME()) " +
                "GROUP BY FORMAT(b.paid_at, 'yyyy-MM-dd') " +
                "ORDER BY name DESC";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, days);
            try (ResultSet result = statement.executeQuery()) {
                List<RevenueReportItem> list = new ArrayList<>();
                while (result.next()) {
                    list.add(new RevenueReportItem(
                            result.getString("name"),
                            result.getLong("total_bookings"),
                            result.getLong("total_tickets"),
                            result.getDouble("total_revenue")
                    ));
                }
                return list;
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private List<RevenueReportItem> executeReportQuery(String sql) {
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            List<RevenueReportItem> list = new ArrayList<>();
            while (result.next()) {
                list.add(new RevenueReportItem(
                        result.getString("name"),
                        result.getLong("total_bookings"),
                        result.getLong("total_tickets"),
                        result.getDouble("total_revenue")
                ));
            }
            return list;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }
}
