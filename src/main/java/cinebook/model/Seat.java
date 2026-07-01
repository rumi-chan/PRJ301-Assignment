package cinebook.model;

import java.math.BigDecimal;

public class Seat {
    private final long id;
    private final long auditoriumId;
    private final String rowLabel;
    private final int seatNumber;
    private final String label;
    private final SeatType type;
    private final Long pairSeatId;
    private final BigDecimal price;
    private final SeatAvailability availability;

    public Seat(long id, long auditoriumId, String rowLabel, int seatNumber, String label,
                SeatType type, Long pairSeatId, BigDecimal price, SeatAvailability availability) {
        this.id = id;
        this.auditoriumId = auditoriumId;
        this.rowLabel = rowLabel;
        this.seatNumber = seatNumber;
        this.label = label;
        this.type = type;
        this.pairSeatId = pairSeatId;
        this.price = price;
        this.availability = availability;
    }

    public long id() { return id; }
    public long auditoriumId() { return auditoriumId; }
    public String rowLabel() { return rowLabel; }
    public int seatNumber() { return seatNumber; }
    public String label() { return label; }
    public SeatType type() { return type; }
    public Long pairSeatId() { return pairSeatId; }
    public BigDecimal price() { return price; }
    public SeatAvailability availability() { return availability; }

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
