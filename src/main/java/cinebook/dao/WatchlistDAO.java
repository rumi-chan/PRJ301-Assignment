package cinebook.dao;

import cinebook.model.Movie;

import java.util.List;

public interface WatchlistDAO {
    List<Movie> findMoviesByUserId(long userId);

    boolean isWatchlisted(long userId, long movieId);

    void add(long userId, long movieId);

    void remove(long userId, long movieId);
}
