package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Auditorium;
import vn.edu.cinebook.model.Cinema;

import java.util.List;
import java.util.Optional;

public interface CinemaDAO {
    List<Cinema> search(String city, String query);

    List<String> listCities();

    List<Auditorium> listActiveAuditoriums();

    List<Cinema> findAll();

    Optional<Cinema> findById(long id);

    boolean insert(Cinema cinema);

    boolean update(Cinema cinema);

    boolean delete(long id);
}
