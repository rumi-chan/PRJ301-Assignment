package cinebook.dao.jdbc;

import cinebook.dao.MovieDAO;
import cinebook.model.Movie;
import cinebook.model.MovieFormat;
import cinebook.model.MovieStatus;
import cinebook.util.Database;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import cinebook.model.Genre;
import cinebook.util.AppException;

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
    public List<Movie> findAllAdmin(String query) {
        StringBuilder sql = new StringBuilder(SELECT).append(" WHERE 1=1 ");
        List<Object> parameters = new ArrayList<>();
        if (query != null && !query.isBlank()) {
            sql.append(" AND LOWER(m.title) LIKE ?");
            parameters.add("%" + query.trim().toLowerCase() + "%");
        }
        sql.append(" ORDER BY m.movie_id DESC");

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
    public List<Genre> listAllGenres() {
        String sql = "SELECT genre_id, name, slug FROM genres ORDER BY name";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            List<Genre> genres = new ArrayList<>();
            while (result.next()) {
                genres.add(new Genre(result.getInt("genre_id"), result.getString("name"), result.getString("slug")));
            }
            return genres;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public long insert(Movie movie, List<Integer> genreIds, List<MovieFormat> formats) {
        String sql = """
                INSERT INTO movies (title, slug, synopsis, director, cast_text, duration_minutes,
                                    age_rating, release_date, original_language, country, poster_url,
                                    backdrop_url, trailer_url, status, is_active, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Vietnamese', 'Vietnam', ?, ?, ?, ?, 1, SYSUTCDATETIME(), SYSUTCDATETIME())
                """;
        try (Connection connection = Database.getConnection()) {
            connection.setAutoCommit(false);
            try {
                long movieId;
                try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    statement.setString(1, movie.getTitle());
                    statement.setString(2, movie.getSlug());
                    statement.setString(3, movie.getSynopsis());
                    statement.setString(4, movie.getDirector());
                    statement.setString(5, movie.getCast());
                    statement.setInt(6, movie.getDurationMinutes());
                    statement.setString(7, movie.getAgeRating());
                    statement.setDate(8, Date.valueOf(movie.getReleaseDate()));
                    statement.setString(9, movie.getPosterUrl());
                    statement.setString(10, movie.getBackdropUrl());
                    statement.setString(11, movie.getTrailerUrl());
                    statement.setString(12, movie.getStatus().name());
                    statement.executeUpdate();
                    try (ResultSet keys = statement.getGeneratedKeys()) {
                        if (!keys.next()) throw new AppException(500, "Failed to retrieve generated movie ID.");
                        movieId = keys.getLong(1);
                    }
                }
                saveRelations(connection, movieId, genreIds, formats);
                connection.commit();
                return movieId;
            } catch (Exception ex) {
                connection.rollback();
                if (ex instanceof AppException ae) throw ae;
                throw new SQLException(ex);
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void update(Movie movie, List<Integer> genreIds, List<MovieFormat> formats) {
        String sql = """
                UPDATE movies
                SET title = ?, slug = ?, synopsis = ?, director = ?, cast_text = ?, duration_minutes = ?,
                    age_rating = ?, release_date = ?, poster_url = ?, backdrop_url = ?, trailer_url = ?,
                    status = ?, updated_at = SYSUTCDATETIME()
                WHERE movie_id = ?
                """;
        try (Connection connection = Database.getConnection()) {
            connection.setAutoCommit(false);
            try {
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    statement.setString(1, movie.getTitle());
                    statement.setString(2, movie.getSlug());
                    statement.setString(3, movie.getSynopsis());
                    statement.setString(4, movie.getDirector());
                    statement.setString(5, movie.getCast());
                    statement.setInt(6, movie.getDurationMinutes());
                    statement.setString(7, movie.getAgeRating());
                    statement.setDate(8, Date.valueOf(movie.getReleaseDate()));
                    statement.setString(9, movie.getPosterUrl());
                    statement.setString(10, movie.getBackdropUrl());
                    statement.setString(11, movie.getTrailerUrl());
                    statement.setString(12, movie.getStatus().name());
                    statement.setLong(13, movie.getId());
                    statement.executeUpdate();
                }
                try (PreparedStatement delG = connection.prepareStatement("DELETE FROM movie_genres WHERE movie_id = ?");
                     PreparedStatement delF = connection.prepareStatement("DELETE FROM movie_formats WHERE movie_id = ?")) {
                    delG.setLong(1, movie.getId());
                    delG.executeUpdate();
                    delF.setLong(1, movie.getId());
                    delF.executeUpdate();
                }
                saveRelations(connection, movie.getId(), genreIds, formats);
                connection.commit();
            } catch (Exception ex) {
                connection.rollback();
                if (ex instanceof AppException ae) throw ae;
                throw new SQLException(ex);
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void delete(long id) {
        String sql = "UPDATE movies SET is_active = 0, status = 'ARCHIVED', updated_at = SYSUTCDATETIME() WHERE movie_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private void saveRelations(Connection connection, long movieId, List<Integer> genreIds, List<MovieFormat> formats) throws SQLException {
        if (genreIds != null && !genreIds.isEmpty()) {
            try (PreparedStatement stmt = connection.prepareStatement("INSERT INTO movie_genres (movie_id, genre_id) VALUES (?, ?)")) {
                for (Integer gid : genreIds) {
                    stmt.setLong(1, movieId);
                    stmt.setInt(2, gid);
                    stmt.executeUpdate();
                }
            }
        }
        if (formats != null && !formats.isEmpty()) {
            try (PreparedStatement stmt = connection.prepareStatement("INSERT INTO movie_formats (movie_id, format) VALUES (?, ?)")) {
                for (MovieFormat fmt : formats) {
                    stmt.setLong(1, movieId);
                    stmt.setString(2, fmt.getLabel());
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