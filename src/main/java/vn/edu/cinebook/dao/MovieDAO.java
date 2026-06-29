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

    List<Movie> findAllAdmin(String query);

    List<vn.edu.cinebook.model.Genre> listAllGenres();

    long insert(Movie movie, List<Integer> genreIds, List<MovieFormat> formats);

    void update(Movie movie, List<Integer> genreIds, List<MovieFormat> formats);

    void delete(long id);
}
