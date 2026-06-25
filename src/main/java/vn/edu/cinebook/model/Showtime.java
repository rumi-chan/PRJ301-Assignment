package vn.edu.cinebook.model;

import java.math.BigDecimal;
import java.time.Instant;

public record Showtime(
        long id,
        long movieId,
        String movieTitle,
        long cinemaId,
        String cinemaName,
        long auditoriumId,
        String auditoriumName,
        MovieFormat format,
        Instant startsAt,
        Instant endsAt,
        BigDecimal basePrice,
        int availableSeats
) {
    public long getId() { return id; }
    public long getMovieId() { return movieId; }
    public String getMovieTitle() { return movieTitle; }
    public long getCinemaId() { return cinemaId; }
    public String getCinemaName() { return cinemaName; }
    public long getAuditoriumId() { return auditoriumId; }
    public String getAuditoriumName() { return auditoriumName; }
    public MovieFormat getFormat() { return format; }
    public Instant getStartsAt() { return startsAt; }
    public Instant getStartTime() { return startsAt; }
    public Instant getEndsAt() { return endsAt; }
    public BigDecimal getBasePrice() { return basePrice; }
    public int getAvailableSeats() { return availableSeats; }
}
