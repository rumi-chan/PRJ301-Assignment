package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Review;

import java.util.List;
import java.util.Optional;

public interface ReviewDAO {
    List<Review> findByMovie(long movieId);

    List<Review> findByUser(long userId);

    List<Review> findAll(String query);

    Optional<Review> findById(long reviewId);

    Review create(long userId, long movieId, Long bookingId, int rating, String title, String content, boolean containsSpoiler);

    void updateStatus(long reviewId, String status, Long moderatorId, String note);
}
