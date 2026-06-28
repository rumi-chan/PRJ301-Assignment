package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Banner;
import java.util.List;
import java.util.Optional;

public interface BannerDAO {
    List<Banner> findActiveBanners(String placement);
    List<Banner> findAll();
    Optional<Banner> findById(long id);
    void insert(Banner banner);
    void update(Banner banner);
    void delete(long id);
}
