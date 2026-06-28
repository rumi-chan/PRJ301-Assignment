package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.ShowtimeDAO;
import vn.edu.cinebook.model.Showtime;
import vn.edu.cinebook.util.Database;
import vn.edu.cinebook.util.DisplayUtil;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcShowtimeDAO implements ShowtimeDAO {
    private static final String SELECT = """
            SELECT s.showtime_id AS id, s.movie_id, m.title AS movie_title,
                   c.cinema_id, c.name AS cinema_name,
                   a.auditorium_id, a.name AS auditorium_name, s.format, s.starts_at, s.ends_at,
                   s.base_price,
                   (SELECT COUNT(*) FROM seats all_seats WHERE all_seats.auditorium_id = a.auditorium_id
                       AND all_seats.is_active = 1
                       AND NOT EXISTS (
                           SELECT 1 FROM booking_seats bs
                           WHERE bs.seat_id = all_seats.seat_id AND bs.showtime_id = s.showtime_id
                           AND bs.status = 'BOOKED')
                       AND NOT EXISTS (
                           SELECT 1 FROM seat_holds h WHERE h.seat_id = all_seats.seat_id
                           AND h.showtime_id = s.showtime_id AND h.status = 'ACTIVE'
                           AND h.expires_at > SYSUTCDATETIME())
                   ) AS available_seats
            FROM showtimes s
            JOIN movies m ON m.movie_id = s.movie_id
            JOIN auditoriums a ON a.auditorium_id = s.auditorium_id
            JOIN cinemas c ON c.cinema_id = a.cinema_id
            """;

    @Override
    public List<Showtime> findForMovie(long movieId, Long cinemaId, LocalDate date) {
        LocalDate selectedDate = date == null ? LocalDate.now(DisplayUtil.DISPLAY_ZONE) : date;
        StringBuilder sql = new StringBuilder(SELECT).append("""
                 WHERE s.movie_id = ? AND s.status = 'SCHEDULED'
                 AND CAST((s.starts_at AT TIME ZONE 'UTC' AT TIME ZONE 'SE Asia Standard Time') AS date) = ?
                """);
        if (cinemaId != null) {
            sql.append(" AND c.cinema_id = ?");
        }
        sql.append(" ORDER BY c.name, s.starts_at");
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            statement.setLong(1, movieId);
            statement.setDate(2, Date.valueOf(selectedDate));
            if (cinemaId != null) {
                statement.setLong(3, cinemaId);
            }
            List<Showtime> showtimes = new ArrayList<>();
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    showtimes.add(map(result));
                }
            }
            return showtimes;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public Optional<Showtime> findById(long id) {
        String sql = SELECT + " WHERE s.showtime_id = ? AND s.status = 'SCHEDULED'";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? Optional.of(map(result)) : Optional.empty();
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private Showtime map(ResultSet result) throws SQLException {
        return new Showtime(
                result.getLong("id"),
                result.getLong("movie_id"),
                result.getString("movie_title"),
                result.getLong("cinema_id"),
                result.getString("cinema_name"),
                result.getLong("auditorium_id"),
                result.getString("auditorium_name"),
                JdbcSupport.format(result.getString("format")),
                result.getTimestamp("starts_at").toInstant(),
                result.getTimestamp("ends_at").toInstant(),
                result.getBigDecimal("base_price"),
                result.getInt("available_seats")
        );
    }
}
