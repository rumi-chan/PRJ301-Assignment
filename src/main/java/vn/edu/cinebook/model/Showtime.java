package vn.edu.cinebook.model;

import java.math.BigDecimal;
import java.time.Duration;
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
        Instant salesOpenAt,
        BigDecimal basePrice,
        String status,
        int availableSeats
) {
    public Showtime(long id, long movieId, String movieTitle, long cinemaId, String cinemaName,
                    long auditoriumId, String auditoriumName, MovieFormat format, Instant startsAt,
                    Instant endsAt, BigDecimal basePrice, int availableSeats) {
        this(id, movieId, movieTitle, cinemaId, cinemaName, auditoriumId, auditoriumName,
                format, startsAt, endsAt, null, basePrice, "SCHEDULED", availableSeats);
    }

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
    public Instant getSalesOpenAt() { return salesOpenAt; }
    public long getDurationMinutes() { return Duration.between(startsAt, endsAt).toMinutes(); }
    public BigDecimal getBasePrice() { return basePrice; }
    public String getStatus() { return status; }
    public int getAvailableSeats() { return availableSeats; }
}
