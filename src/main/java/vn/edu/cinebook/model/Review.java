package vn.edu.cinebook.model;

import java.io.Serial;
import java.io.Serializable;
import java.time.Instant;

public record Review(
        long id,
        long userId,
        String userName,
        long movieId,
        String movieTitle,
        Long bookingId,
        int rating,
        String title,
        String content,
        boolean containsSpoiler,
        String status,
        Long moderatedBy,
        Instant moderatedAt,
        String moderationNote,
        Instant createdAt
) implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    public boolean isVisible() {
        return "VISIBLE".equalsIgnoreCase(status);
    }

    public long getId() { return id; }
    public long getUserId() { return userId; }
    public String getUserName() { return userName; }
    public long getMovieId() { return movieId; }
    public String getMovieTitle() { return movieTitle; }
    public Long getBookingId() { return bookingId; }
    public int getRating() { return rating; }
    public String getTitle() { return title; }
    public String getContent() { return content; }
    public boolean isContainsSpoiler() { return containsSpoiler; }
    public boolean getContainsSpoiler() { return containsSpoiler; }
    public String getStatus() { return status; }
    public Long getModeratedBy() { return moderatedBy; }
    public Instant getModeratedAt() { return moderatedAt; }
    public String getModerationNote() { return moderationNote; }
    public String getCreatedAt() {
        if (createdAt == null) return "";
        return java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss")
                .withZone(java.time.ZoneId.of("Asia/Ho_Chi_Minh"))
                .format(createdAt);
    }
    public String getCreatedAtDisplay() {
        if (createdAt == null) return "";
        return java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")
                .withZone(java.time.ZoneId.of("Asia/Ho_Chi_Minh"))
                .format(createdAt);
    }
}