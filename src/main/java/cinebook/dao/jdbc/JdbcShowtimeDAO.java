package cinebook.dao.jdbc;

import cinebook.dao.ShowtimeDAO;
import cinebook.model.Showtime;
import cinebook.util.Database;
import cinebook.util.DisplayUtil;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import cinebook.util.AppException;

public class JdbcShowtimeDAO implements ShowtimeDAO {
    private static final String SELECT = """
            SELECT s.showtime_id AS id, s.movie_id, m.title AS movie_title,
                   c.cinema_id, c.name AS cinema_name,
                   a.auditorium_id, a.name AS auditorium_name, s.format, s.starts_at, s.ends_at,
                   s.sales_open_at, s.base_price, s.status,
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
        return findOne(sql, id);
    }

    @Override
    public Optional<Showtime> findAdminById(long id) {
        String sql = SELECT + " WHERE s.showtime_id = ?";
        return findOne(sql, id);
    }

    private Optional<Showtime> findOne(String sql, long id) {
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

    @Override
    public List<Showtime> findAllAdmin() {
        String sql = SELECT + " ORDER BY s.starts_at DESC, c.name, a.name";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            List<Showtime> showtimes = new ArrayList<>();
            while (result.next()) {
                showtimes.add(map(result));
            }
            return showtimes;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public long insert(Showtime showtime) {
        String sql = """
                INSERT INTO showtimes (movie_id, auditorium_id, starts_at, ends_at, sales_open_at,
                                       format, base_price, audio_language, subtitle_language,
                                       status, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, N'Vietnamese', N'Vietnamese',
                        ?, SYSUTCDATETIME(), SYSUTCDATETIME())
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bindWrite(statement, showtime);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) throw new AppException(500, "Showtime created but ID not returned.");
                return keys.getLong(1);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void update(Showtime showtime) {
        String sql = """
                UPDATE showtimes
                SET movie_id = ?, auditorium_id = ?, starts_at = ?, ends_at = ?, sales_open_at = ?,
                    format = ?, base_price = ?, status = ?, updated_at = SYSUTCDATETIME()
                WHERE showtime_id = ?
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bindWrite(statement, showtime);
            statement.setLong(9, showtime.id());
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void delete(long id) {
        String sql = "UPDATE showtimes SET status = 'CANCELLED', updated_at = SYSUTCDATETIME() WHERE showtime_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private void bindWrite(PreparedStatement statement, Showtime showtime) throws SQLException {
        statement.setLong(1, showtime.movieId());
        statement.setLong(2, showtime.auditoriumId());
        statement.setTimestamp(3, Timestamp.from(showtime.startsAt()));
        statement.setTimestamp(4, Timestamp.from(showtime.endsAt()));
        statement.setTimestamp(5, Timestamp.from(showtime.salesOpenAt()));
        statement.setString(6, showtime.format().getLabel());
        statement.setBigDecimal(7, showtime.basePrice());
        statement.setString(8, showtime.status());
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
                result.getTimestamp("sales_open_at").toInstant(),
                result.getBigDecimal("base_price"),
                result.getString("status"),
                result.getInt("available_seats")
        );
    }
}
