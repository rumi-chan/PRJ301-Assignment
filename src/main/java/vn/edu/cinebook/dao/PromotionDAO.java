package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Promotion;

import java.util.List;
import java.util.Optional;

public interface PromotionDAO {
    Optional<Promotion> findByCode(String code);

    Optional<Promotion> findById(long id);

    List<Promotion> findAllAdmin();

    long insert(Promotion promotion);

    void update(Promotion promotion);

    void delete(long id);
}
