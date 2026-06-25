package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Promotion;

import java.util.Optional;

public interface PromotionDAO {
    Optional<Promotion> findByCode(String code);
}
