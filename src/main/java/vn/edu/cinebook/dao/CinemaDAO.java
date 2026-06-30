package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Cinema;
import vn.edu.cinebook.model.Auditorium;

import java.util.List;

public interface CinemaDAO {
    List<Cinema> search(String city, String query);

    List<String> listCities();

    List<Auditorium> listActiveAuditoriums();
}
