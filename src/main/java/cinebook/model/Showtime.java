package cinebook.model;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;

public class Showtime {
    private final long id;
    private final long movieId;
    private final String movieTitle;
    private final long cinemaId;
    private final String cinemaName;
    private final long auditoriumId;
    private final String auditoriumName;
    private final MovieFormat format;
    private final Instant startsAt;
    private final Instant endsAt;
    private final Instant salesOpenAt;
    private final BigDecimal basePrice;
    private final String status;
    private final int availableSeats;

    public Showtime(long id, long movieId, String movieTitle, long cinemaId, String cinemaName,
                    long auditoriumId, String auditoriumName, MovieFormat format, Instant startsAt,
                    Instant endsAt, Instant salesOpenAt, BigDecimal basePrice, String status,
                    int availableSeats) {
        this.id = id;
        this.movieId = movieId;
        this.movieTitle = movieTitle;
        this.cinemaId = cinemaId;
        this.cinemaName = cinemaName;
        this.auditoriumId = auditoriumId;
        this.auditoriumName = auditoriumName;
        this.format = format;
        this.startsAt = startsAt;
        this.endsAt = endsAt;
        this.salesOpenAt = salesOpenAt;
        this.basePrice = basePrice;
        this.status = status;
        this.availableSeats = availableSeats;
    }

    public Showtime(long id, long movieId, String movieTitle, long cinemaId, String cinemaName,
                    long auditoriumId, String auditoriumName, MovieFormat format, Instant startsAt,
                    Instant endsAt, BigDecimal basePrice, int availableSeats) {
        this(id, movieId, movieTitle, cinemaId, cinemaName, auditoriumId, auditoriumName,
                format, startsAt, endsAt, null, basePrice, "SCHEDULED", availableSeats);
    }

    public long id() { return id; }
    public long movieId() { return movieId; }
    public String movieTitle() { return movieTitle; }
    public long cinemaId() { return cinemaId; }
    public String cinemaName() { return cinemaName; }
    public long auditoriumId() { return auditoriumId; }
    public String auditoriumName() { return auditoriumName; }
    public MovieFormat format() { return format; }
    public Instant startsAt() { return startsAt; }
    public Instant endsAt() { return endsAt; }
    public Instant salesOpenAt() { return salesOpenAt; }
    public BigDecimal basePrice() { return basePrice; }
    public String status() { return status; }
    public int availableSeats() { return availableSeats; }

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
