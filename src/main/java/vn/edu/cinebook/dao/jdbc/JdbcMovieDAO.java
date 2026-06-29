package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.MovieDAO;
import vn.edu.cinebook.model.Movie;
import vn.edu.cinebook.model.MovieFormat;
import vn.edu.cinebook.model.MovieStatus;
import vn.edu.cinebook.util.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcMovieDAO implements MovieDAO {
    private static final String SELECT = """
            SELECT m.movie_id AS id, m.title, m.slug, m.synopsis, m.director, m.cast_text,
                   m.duration_minutes, m.age_rating, m.release_date, m.poster_url,
                   m.backdrop_url, m.trailer_url, m.status,
                   (SELECT STRING_AGG(g.name, ',') FROM movie_genres mg
                    JOIN genres g ON g.genre_id = mg.genre_id WHERE mg.movie_id = m.movie_id) AS genres,
                   (SELECT STRING_AGG(mf.format, ',') FROM movie_formats mf
                    WHERE mf.movie_id = m.movie_id) AS formats
            FROM movies m
            """;

    @Override
    public List<Movie> search(MovieStatus status, String query, String genre, MovieFormat format) {
        StringBuilder sql = new StringBuilder(SELECT).append(" WHERE m.is_active = 1");
        List<Object> parameters = new ArrayList<>();
        if (status != null) {
            sql.append(" AND m.status = ?");
            parameters.add(status.name());
        }
        if (query != null && !query.isBlank()) {
            sql.append(" AND LOWER(m.title) LIKE ?");
            parameters.add("%" + query.trim().toLowerCase() + "%");
        }
        if (genre != null && !genre.isBlank()) {
            sql.append("""
                     AND EXISTS (SELECT 1 FROM movie_genres xmg
                     JOIN genres xg ON xg.genre_id = xmg.genre_id
                     WHERE xmg.movie_id = m.movie_id AND LOWER(xg.name) = ?)
                    """);
            parameters.add(genre.trim().toLowerCase());
        }
        if (format != null) {
            sql.append(" AND EXISTS (SELECT 1 FROM movie_formats xs WHERE xs.movie_id = m.movie_id AND xs.format = ?)");
            parameters.add(format.getLabel());
        }
        sql.append(" ORDER BY m.release_date DESC, m.title");

        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bind(statement, parameters);
            List<Movie> movies = new ArrayList<>();
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    movies.add(map(result));
                }
            }
            return movies;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public Optional<Movie> findById(long id) {
        String sql = SELECT + " WHERE m.movie_id = ? AND m.is_active = 1";
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
    public List<String> listGenres() {
        String sql = "SELECT name FROM genres ORDER BY name";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            List<String> genres = new ArrayList<>();
            while (result.next()) {
                genres.add(result.getString(1));
            }
            return genres;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private static void bind(PreparedStatement statement, List<Object> parameters) throws SQLException {
        for (int index = 0; index < parameters.size(); index++) {
            statement.setObject(index + 1, parameters.get(index));
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
                result.getObject("duration_minutes", Integer.class),
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
