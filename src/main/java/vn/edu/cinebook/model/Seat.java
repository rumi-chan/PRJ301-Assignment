package vn.edu.cinebook.model;

import java.math.BigDecimal;

public record Seat(
        long id,
        long auditoriumId,
        String rowLabel,
        int seatNumber,
        String label,
        SeatType type,
        Long pairSeatId,
        BigDecimal price,
        SeatAvailability availability
) {
    public long getId() { return id; }
    public long getAuditoriumId() { return auditoriumId; }
    public String getRowLabel() { return rowLabel; }
    public int getSeatNumber() { return seatNumber; }
    public String getLabel() { return label; }
    public SeatType getType() { return type; }
    public Long getPairSeatId() { return pairSeatId; }
    public Long getPairId() { return pairSeatId; }
    public BigDecimal getPrice() { return price; }
    public SeatAvailability getAvailability() { return availability; }
    public SeatAvailability getStatus() { return availability; }
}
