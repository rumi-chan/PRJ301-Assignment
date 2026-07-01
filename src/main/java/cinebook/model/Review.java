package cinebook.model;

import java.io.Serial;
import java.io.Serializable;
import java.time.Instant;

public class Review implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    private final long id;
    private final long userId;
    private final String userName;
    private final long movieId;
    private final String movieTitle;
    private final Long bookingId;
    private final int rating;
    private final String title;
    private final String content;
    private final boolean containsSpoiler;
    private final String status;
    private final Long moderatedBy;
    private final Instant moderatedAt;
    private final String moderationNote;
    private final Instant createdAt;

    public Review(long id, long userId, String userName, long movieId, String movieTitle,
                  Long bookingId, int rating, String title, String content,
                  boolean containsSpoiler, String status, Long moderatedBy,
                  Instant moderatedAt, String moderationNote, Instant createdAt) {
        this.id = id;
        this.userId = userId;
        this.userName = userName;
        this.movieId = movieId;
        this.movieTitle = movieTitle;
        this.bookingId = bookingId;
        this.rating = rating;
        this.title = title;
        this.content = content;
        this.containsSpoiler = containsSpoiler;
        this.status = status;
        this.moderatedBy = moderatedBy;
        this.moderatedAt = moderatedAt;
        this.moderationNote = moderationNote;
        this.createdAt = createdAt;
    }

    public boolean isVisible() {
        return "VISIBLE".equalsIgnoreCase(status);
    }

    public long id() { return id; }
    public long userId() { return userId; }
    public String userName() { return userName; }
    public long movieId() { return movieId; }
    public String movieTitle() { return movieTitle; }
    public Long bookingId() { return bookingId; }
    public int rating() { return rating; }
    public String title() { return title; }
    public String content() { return content; }
    public boolean containsSpoiler() { return containsSpoiler; }
    public String status() { return status; }
    public Long moderatedBy() { return moderatedBy; }
    public Instant moderatedAt() { return moderatedAt; }
    public String moderationNote() { return moderationNote; }
    public Instant createdAt() { return createdAt; }

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
