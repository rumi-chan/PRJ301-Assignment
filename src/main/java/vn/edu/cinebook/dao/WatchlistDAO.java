package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Movie;
import java.util.List;

public interface WatchlistDAO {
    void add(long userId, long movieId);
    void remove(long userId, long movieId);
    boolean exists(long userId, long movieId);
    List<Movie> findMoviesByUserId(long userId);
}
