package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Cinema;

import java.util.List;

public interface CinemaDAO {
    List<Cinema> search(String city, String query);

    List<String> listCities();
    
    List<Cinema> findAll();
    
    java.util.Optional<Cinema> findById(long id);

    boolean insert(Cinema cinema);

    boolean update(Cinema cinema);

    boolean delete(long id);
}
