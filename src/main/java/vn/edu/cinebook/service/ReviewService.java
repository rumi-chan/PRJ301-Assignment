package vn.edu.cinebook.service;

import vn.edu.cinebook.dao.ReviewDAO;
import vn.edu.cinebook.model.Review;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.Validation;

import java.util.List;

public class ReviewService {
    private final ReviewDAO reviewDAO;

    public ReviewService(ReviewDAO reviewDAO) {
        this.reviewDAO = reviewDAO;
    }

    public List<Review> getMovieReviews(long movieId) {
        return reviewDAO.findByMovie(movieId);
    }

    public List<Review> getUserReviews(long userId) {
        return reviewDAO.findByUser(userId);
    }

    public List<Review> searchReviews(String query) {
        return reviewDAO.findAll(query);
    }

    public Review submitReview(long userId, long movieId, int rating, String title, String content, boolean containsSpoiler) {
        if (rating < 1 || rating > 5) {
            throw new AppException(400, "Rating must be between 1 and 5 stars.");
        }
        String validContent = Validation.required(content, "Review content", 2000);
        String validTitle = title == null || title.trim().isEmpty() ? null : title.trim();
        if (validTitle != null && validTitle.length() > 150) {
            throw new AppException(400, "Review title is too long.");
        }
        return reviewDAO.create(userId, movieId, null, rating, validTitle, validContent, containsSpoiler);
    }

    public void moderateReview(long reviewId, String status, long moderatorId, String note) {
        if (!"VISIBLE".equalsIgnoreCase(status) && !"HIDDEN".equalsIgnoreCase(status) && !"DELETED".equalsIgnoreCase(status)) {
            throw new AppException(400, "Invalid moderation status.");
        }
        reviewDAO.updateStatus(reviewId, status, moderatorId, note);
    }
}
