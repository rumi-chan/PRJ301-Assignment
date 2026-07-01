package cinebook.dto;

import cinebook.model.Seat;

import java.time.Instant;
import java.util.List;

public class SeatHoldResult {
    private final String holdToken;
    private final long showtimeId;
    private final Instant expiresAt;
    private final List<Seat> seats;
    private final PriceBreakdown pricing;

    public SeatHoldResult(String holdToken, long showtimeId, Instant expiresAt,
                          List<Seat> seats, PriceBreakdown pricing) {
        this.holdToken = holdToken;
        this.showtimeId = showtimeId;
        this.expiresAt = expiresAt;
        this.seats = seats == null ? List.of() : List.copyOf(seats);
        this.pricing = pricing;
    }

    public String holdToken() { return holdToken; }
    public long showtimeId() { return showtimeId; }
    public Instant expiresAt() { return expiresAt; }
    public List<Seat> seats() { return seats; }
    public PriceBreakdown pricing() { return pricing; }

    public String getHoldToken() { return holdToken; }
    public String getToken() { return holdToken; }
    public long getShowtimeId() { return showtimeId; }
    public Instant getExpiresAt() { return expiresAt; }
    public List<Seat> getSeats() { return seats; }
    public PriceBreakdown getPricing() { return pricing; }
}
