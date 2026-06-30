package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Combo;

import java.util.List;
import java.util.Optional;

public interface ComboDAO {
    List<Combo> findActive();

    Optional<Combo> findById(long id);

    Optional<Combo> findAdminById(long id);

    List<Combo> findAllAdmin();

    long insert(Combo combo);

    void update(Combo combo);

    void delete(long id);
}
