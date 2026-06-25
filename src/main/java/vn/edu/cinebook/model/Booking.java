package vn.edu.cinebook.model;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public record Booking(
        long id,
        String bookingCode,
        long userId,
        BookingStatus status,
        PaymentStatus paymentStatus,
        String movieTitle,
        String cinemaName,
        String auditoriumName,
        Instant showtime,
        List<String> seatLabels,
        BigDecimal subtotal,
        BigDecimal discount,
        BigDecimal tax,
        BigDecimal serviceFee,
        BigDecimal total,
        Instant createdAt,
        Instant paidAt
) {
    public long getId() { return id; }
    public String getBookingCode() { return bookingCode; }
    public long getUserId() { return userId; }
    public BookingStatus getStatus() { return status; }
    public PaymentStatus getPaymentStatus() { return paymentStatus; }
    public String getMovieTitle() { return movieTitle; }
    public String getCinemaName() { return cinemaName; }
    public String getAuditoriumName() { return auditoriumName; }
    public Instant getShowtime() { return showtime; }
    public Instant getShowtimeAt() { return showtime; }
    public List<String> getSeatLabels() { return seatLabels; }
    public BigDecimal getSubtotal() { return subtotal; }
    public BigDecimal getDiscount() { return discount; }
    public BigDecimal getTax() { return tax; }
    public BigDecimal getServiceFee() { return serviceFee; }
    public BigDecimal getTotal() { return total; }
    public BigDecimal getTotalAmount() { return total; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getPaidAt() { return paidAt; }
}
