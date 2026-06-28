package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Showtime;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface ShowtimeDAO {
    List<Showtime> findForMovie(long movieId, Long cinemaId, LocalDate date);

    Optional<Showtime> findById(long id);
}
