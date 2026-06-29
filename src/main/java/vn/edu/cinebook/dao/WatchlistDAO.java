package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Movie;

import java.util.List;

public interface WatchlistDAO {
    List<Movie> findMoviesByUserId(long userId);

    boolean isWatchlisted(long userId, long movieId);

    void add(long userId, long movieId);

    void remove(long userId, long movieId);
}
