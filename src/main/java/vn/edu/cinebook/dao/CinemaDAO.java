package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Cinema;

import java.util.List;

public interface CinemaDAO {
    List<Cinema> search(String city, String query);

    List<String> listCities();
}
