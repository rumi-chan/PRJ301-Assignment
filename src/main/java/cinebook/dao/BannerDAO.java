package cinebook.dao;

import cinebook.model.Banner;

import java.util.List;
import java.util.Optional;

public interface BannerDAO {
    List<Banner> findAllAdmin();

    List<Banner> findActiveHomeBanners();

    Optional<Banner> findById(long id);

    long insert(Banner banner, Long createdBy);

    void update(Banner banner);

    void delete(long id);
}
