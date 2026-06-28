package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Movie;
import vn.edu.cinebook.model.MovieFormat;
import vn.edu.cinebook.model.MovieStatus;

import java.util.List;
import java.util.Optional;

public interface MovieDAO {
    List<Movie> search(MovieStatus status, String query, String genre, MovieFormat format);

    Optional<Movie> findById(long id);

    List<String> listGenres();

    List<Movie> findAllForAdmin();

    void insert(Movie movie);

    void update(Movie movie);

    void delete(long id);
}
