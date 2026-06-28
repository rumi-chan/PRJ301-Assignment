package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.ReviewDAO;
import vn.edu.cinebook.model.Review;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcReviewDAO implements ReviewDAO {
    private static final String SELECT_BASE = """
            SELECT r.review_id, r.user_id, u.full_name AS user_name, r.movie_id, m.title AS movie_title,
                   r.booking_id, r.rating, r.title, r.content, r.contains_spoiler, r.status,
                   r.moderated_by, r.moderated_at, r.moderation_note, r.created_at
            FROM reviews r
            JOIN users u ON r.user_id = u.user_id
            JOIN movies m ON r.movie_id = m.movie_id
            """;

    @Override
    public List<Review> findByMovie(long movieId) {
        String sql = SELECT_BASE + " WHERE r.movie_id = ? AND r.status = 'VISIBLE' ORDER BY r.created_at DESC";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, movieId);
            try (ResultSet result = statement.executeQuery()) {
                List<Review> list = new ArrayList<>();
                while (result.next()) {
                    list.add(map(result));
                }
                return list;
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public List<Review> findByUser(long userId) {
        String sql = SELECT_BASE + " WHERE r.user_id = ? ORDER BY r.created_at DESC";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, userId);
            try (ResultSet result = statement.executeQuery()) {
                List<Review> list = new ArrayList<>();
                while (result.next()) {
                    list.add(map(result));
                }
                return list;
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public List<Review> findAll(String query) {
        StringBuilder sql = new StringBuilder(SELECT_BASE);
        boolean hasQuery = query != null && !query.trim().isEmpty();
        if (hasQuery) {
            sql.append(" WHERE u.full_name LIKE ? OR m.title LIKE ? OR r.content LIKE ?");
        }
        sql.append(" ORDER BY r.created_at DESC");

        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            if (hasQuery) {
                String pattern = "%" + query.trim() + "%";
                statement.setString(1, pattern);
                statement.setString(2, pattern);
                statement.setString(3, pattern);
            }
            try (ResultSet result = statement.executeQuery()) {
                List<Review> list = new ArrayList<>();
                while (result.next()) {
                    list.add(map(result));
                }
                return list;
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public Optional<Review> findById(long reviewId) {
        String sql = SELECT_BASE + " WHERE r.review_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, reviewId);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? Optional.of(map(result)) : Optional.empty();
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public Review create(long userId, long movieId, Long bookingId, int rating, String title, String content, boolean containsSpoiler) {
        String sql = """
                INSERT INTO reviews (user_id, movie_id, booking_id, rating, title, content, contains_spoiler, status, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, 'VISIBLE', SYSUTCDATETIME(), SYSUTCDATETIME())
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setLong(1, userId);
            statement.setLong(2, movieId);
            if (bookingId != null) {
                statement.setLong(3, bookingId);
            } else {
                statement.setNull(3, Types.BIGINT);
            }
            statement.setInt(4, rating);
            statement.setString(5, title);
            statement.setString(6, content);
            statement.setBoolean(7, containsSpoiler);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new AppException(500, "Review created but ID was not returned.");
                }
                return findById(keys.getLong(1)).orElseThrow(() -> new AppException(500, "Review could not be loaded after creation."));
            }
        } catch (SQLException exception) {
            if (exception.getErrorCode() == 2601 || exception.getErrorCode() == 2627) {
                throw new AppException(409, "You have already submitted a review for this movie.");
            }
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void updateStatus(long reviewId, String status, Long moderatorId, String note) {
        String sql;
        if ("VISIBLE".equalsIgnoreCase(status)) {
            sql = "UPDATE reviews SET status = 'VISIBLE', moderated_by = NULL, moderated_at = NULL, moderation_note = ?, updated_at = SYSUTCDATETIME() WHERE review_id = ?";
        } else {
            sql = "UPDATE reviews SET status = ?, moderated_by = ?, moderated_at = SYSUTCDATETIME(), moderation_note = ?, updated_at = SYSUTCDATETIME() WHERE review_id = ?";
        }

        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            if ("VISIBLE".equalsIgnoreCase(status)) {
                statement.setString(1, note);
                statement.setLong(2, reviewId);
            } else {
                statement.setString(1, status.toUpperCase());
                statement.setLong(2, moderatorId != null ? moderatorId : 1L);
                statement.setString(3, note);
                statement.setLong(4, reviewId);
            }
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private Review map(ResultSet result) throws SQLException {
        long bookingIdVal = result.getLong("booking_id");
        Long bookingId = result.wasNull() ? null : bookingIdVal;

        long modByVal = result.getLong("moderated_by");
        Long moderatedBy = result.wasNull() ? null : modByVal;

        var modAtTs = result.getTimestamp("moderated_at");
        var moderatedAt = modAtTs != null ? modAtTs.toInstant() : null;

        return new Review(
                result.getLong("review_id"),
                result.getLong("user_id"),
                result.getString("user_name"),
                result.getLong("movie_id"),
                result.getString("movie_title"),
                bookingId,
                result.getInt("rating"),
                result.getString("title"),
                result.getString("content"),
                result.getBoolean("contains_spoiler"),
                result.getString("status"),
                moderatedBy,
                moderatedAt,
                result.getString("moderation_note"),
                result.getTimestamp("created_at").toInstant()
        );
    }
}
