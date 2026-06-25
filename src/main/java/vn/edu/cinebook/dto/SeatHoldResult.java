package vn.edu.cinebook.dto;

import vn.edu.cinebook.model.Seat;

import java.time.Instant;
import java.util.List;

public record SeatHoldResult(
        String holdToken,
        long showtimeId,
        Instant expiresAt,
        List<Seat> seats,
        PriceBreakdown pricing
) {
    public String getHoldToken() { return holdToken; }
    public String getToken() { return holdToken; }
    public long getShowtimeId() { return showtimeId; }
    public Instant getExpiresAt() { return expiresAt; }
    public List<Seat> getSeats() { return seats; }
    public PriceBreakdown getPricing() { return pricing; }
}
