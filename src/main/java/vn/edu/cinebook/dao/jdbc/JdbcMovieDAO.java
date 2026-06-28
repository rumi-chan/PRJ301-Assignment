package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.MovieDAO;
import vn.edu.cinebook.model.Movie;
import vn.edu.cinebook.model.MovieFormat;
import vn.edu.cinebook.model.MovieStatus;
import vn.edu.cinebook.util.Database;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcMovieDAO implements MovieDAO {
    private static final String SELECT = "SELECT m.movie_id AS id, m.title, m.slug, m.synopsis, m.director, m.cast_text, "
            + "m.duration_minutes, m.age_rating, m.release_date, m.poster_url, m.backdrop_url, m.trailer_url, m.status, "
            + "(SELECT STRING_AGG(g.name, ',') FROM movie_genres mg JOIN genres g ON g.genre_id = mg.genre_id WHERE mg.movie_id = m.movie_id) AS genres, "
            + "(SELECT STRING_AGG(mf.format, ',') FROM movie_formats mf WHERE mf.movie_id = m.movie_id) AS formats FROM movies m";

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
            sql.append(" AND EXISTS (SELECT 1 FROM movie_genres xmg JOIN genres xg ON xg.genre_id = xmg.genre_id WHERE xmg.movie_id = m.movie_id AND LOWER(xg.name) = ?)");
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

    @Override
    public List<Movie> findAllForAdmin() {
        String sql = SELECT + " ORDER BY m.release_date DESC, m.title";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            List<Movie> movies = new ArrayList<>();
            while (result.next()) {
                movies.add(map(result));
            }
            return movies;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void insert(Movie movie) {
        String sql = """
                INSERT INTO movies (title, slug, synopsis, director, cast_text, duration_minutes,
                                    age_rating, release_date, end_date, original_language, country,
                                    poster_url, backdrop_url, trailer_url, status, is_active)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, NULL, 'English', 'USA', ?, ?, ?, ?, 1)
                """;
        try (Connection connection = Database.getConnection()) {
            connection.setAutoCommit(false);
            try {
                long movieId;
                try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    bindMovie(statement, movie);
                    statement.executeUpdate();
                    try (ResultSet keys = statement.getGeneratedKeys()) {
                        if (keys.next()) {
                            movieId = keys.getLong(1);
                        } else {
                            throw new SQLException("Failed to retrieve generated movie ID.");
                        }
                    }
                }
                saveRelations(connection, movieId, movie);
                connection.commit();
            } catch (Exception e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void update(Movie movie) {
        String sql = """
                UPDATE movies
                   SET title = ?, slug = ?, synopsis = ?, director = ?, cast_text = ?,
                       duration_minutes = ?, age_rating = ?, release_date = ?,
                       poster_url = ?, backdrop_url = ?, trailer_url = ?, status = ?, updated_at = SYSUTCDATETIME()
                 WHERE movie_id = ?
                """;
        try (Connection connection = Database.getConnection()) {
            connection.setAutoCommit(false);
            try {
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    bindMovie(statement, movie);
                    statement.setLong(13, movie.id());
                    statement.executeUpdate();
                }
                try (PreparedStatement delGenres = connection.prepareStatement("DELETE FROM movie_genres WHERE movie_id = ?");
                     PreparedStatement delFormats = connection.prepareStatement("DELETE FROM movie_formats WHERE movie_id = ?")) {
                    delGenres.setLong(1, movie.id());
                    delGenres.executeUpdate();
                    delFormats.setLong(1, movie.id());
                    delFormats.executeUpdate();
                }
                saveRelations(connection, movie.id(), movie);
                connection.commit();
            } catch (Exception e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void delete(long id) {
        String sql = "UPDATE movies SET is_active = 0, updated_at = SYSUTCDATETIME() WHERE movie_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private void bindMovie(PreparedStatement statement, Movie movie) throws SQLException {
        statement.setString(1, movie.title());
        statement.setString(2, movie.slug());
        statement.setString(3, movie.synopsis());
        statement.setString(4, movie.director());
        statement.setString(5, movie.cast());
        statement.setInt(6, movie.durationMinutes());
        statement.setString(7, movie.ageRating());
        statement.setDate(8, Date.valueOf(movie.releaseDate()));
        statement.setString(9, movie.posterUrl());
        statement.setString(10, movie.backdropUrl());
        statement.setString(11, movie.trailerUrl());
        statement.setString(12, movie.status().name());
    }

    private void saveRelations(Connection connection, long movieId, Movie movie) throws SQLException {
        if (movie.genres() != null && !movie.genres().isEmpty()) {
            String sql = "INSERT INTO movie_genres (movie_id, genre_id) SELECT ?, genre_id FROM genres WHERE name = ?";
            try (PreparedStatement stmt = connection.prepareStatement(sql)) {
                for (String genre : movie.genres()) {
                    stmt.setLong(1, movieId);
                    stmt.setString(2, genre.trim());
                    stmt.executeUpdate();
                }
            }
        }
        if (movie.formats() != null && !movie.formats().isEmpty()) {
            String sql = "INSERT INTO movie_formats (movie_id, format) VALUES (?, ?)";
            try (PreparedStatement stmt = connection.prepareStatement(sql)) {
                for (MovieFormat format : movie.formats()) {
                    stmt.setLong(1, movieId);
                    stmt.setString(2, format.getLabel());
                    stmt.executeUpdate();
                }
            }
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