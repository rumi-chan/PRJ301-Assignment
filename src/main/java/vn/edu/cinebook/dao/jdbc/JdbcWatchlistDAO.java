package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.WatchlistDAO;
import vn.edu.cinebook.model.Movie;
import vn.edu.cinebook.model.MovieStatus;
import vn.edu.cinebook.util.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class JdbcWatchlistDAO implements WatchlistDAO {
    private static final String SELECT_MOVIES = """
            SELECT m.movie_id AS id, m.title, m.slug, m.synopsis, m.director, m.cast_text,
                   m.duration_minutes, m.age_rating, m.release_date, m.poster_url,
                   m.backdrop_url, m.trailer_url, m.status,
                   (SELECT STRING_AGG(g.name, ',') FROM movie_genres mg
                    JOIN genres g ON g.genre_id = mg.genre_id WHERE mg.movie_id = m.movie_id) AS genres,
                   (SELECT STRING_AGG(mf.format, ',') FROM movie_formats mf
                    WHERE mf.movie_id = m.movie_id) AS formats
            FROM movies m
            JOIN watchlists w ON w.movie_id = m.movie_id
            WHERE w.user_id = ? AND m.is_active = 1
            ORDER BY w.created_at DESC
            """;

    @Override
    public List<Movie> findMoviesByUserId(long userId) {
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(SELECT_MOVIES)) {
            statement.setLong(1, userId);
            List<Movie> list = new ArrayList<>();
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    list.add(map(result));
                }
            }
            return list;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public boolean isWatchlisted(long userId, long movieId) {
        String sql = "SELECT 1 FROM watchlists WHERE user_id = ? AND movie_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, userId);
            statement.setLong(2, movieId);
            try (ResultSet result = statement.executeQuery()) {
                return result.next();
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void add(long userId, long movieId) {
        String sql = """
                IF NOT EXISTS (SELECT 1 FROM watchlists WHERE user_id = ? AND movie_id = ?)
                    INSERT INTO watchlists (user_id, movie_id, created_at) VALUES (?, ?, SYSUTCDATETIME())
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, userId);
            statement.setLong(2, movieId);
            statement.setLong(3, userId);
            statement.setLong(4, movieId);
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void remove(long userId, long movieId) {
        String sql = "DELETE FROM watchlists WHERE user_id = ? AND movie_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, userId);
            statement.setLong(2, movieId);
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private Movie map(ResultSet result) throws SQLException {
        return new Movie(
                result.getLong("id"),
                result.getString("title"),
                result.getString("slug"),
                result.getString("synopsis"),
                result.getString("director"),
                result.getString("cast_text"),
                result.getInt("duration_minutes"),
                result.getString("age_rating"),
                result.getDate("release_date").toLocalDate(),
                result.getString("poster_url"),
                result.getString("backdrop_url"),
                result.getString("trailer_url"),
                MovieStatus.valueOf(result.getString("status")),
                JdbcSupport.csv(result.getString("genres")),
                JdbcSupport.formats(result.getString("formats"))
        );
    }
}
