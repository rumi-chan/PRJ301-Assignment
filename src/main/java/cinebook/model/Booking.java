package cinebook.model;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public class Booking {
    private final long id;
    private final String bookingCode;
    private final long userId;
    private final BookingStatus status;
    private final PaymentStatus paymentStatus;
    private final String movieTitle;
    private final String moviePosterUrl;
    private final String cinemaName;
    private final String auditoriumName;
    private final Instant showtime;
    private final List<String> seatLabels;
    private final BigDecimal subtotal;
    private final BigDecimal discount;
    private final BigDecimal tax;
    private final BigDecimal serviceFee;
    private final BigDecimal total;
    private final Instant createdAt;
    private final Instant paidAt;

    public Booking(long id, String bookingCode, long userId, BookingStatus status,
                   PaymentStatus paymentStatus, String movieTitle, String moviePosterUrl,
                   String cinemaName, String auditoriumName, Instant showtime,
                   List<String> seatLabels, BigDecimal subtotal, BigDecimal discount,
                   BigDecimal tax, BigDecimal serviceFee, BigDecimal total,
                   Instant createdAt, Instant paidAt) {
        this.id = id;
        this.bookingCode = bookingCode;
        this.userId = userId;
        this.status = status;
        this.paymentStatus = paymentStatus;
        this.movieTitle = movieTitle;
        this.moviePosterUrl = moviePosterUrl;
        this.cinemaName = cinemaName;
        this.auditoriumName = auditoriumName;
        this.showtime = showtime;
        this.seatLabels = seatLabels == null ? List.of() : List.copyOf(seatLabels);
        this.subtotal = subtotal;
        this.discount = discount;
        this.tax = tax;
        this.serviceFee = serviceFee;
        this.total = total;
        this.createdAt = createdAt;
        this.paidAt = paidAt;
    }

    public long id() { return id; }
    public String bookingCode() { return bookingCode; }
    public long userId() { return userId; }
    public BookingStatus status() { return status; }
    public PaymentStatus paymentStatus() { return paymentStatus; }
    public String movieTitle() { return movieTitle; }
    public String moviePosterUrl() { return moviePosterUrl; }
    public String cinemaName() { return cinemaName; }
    public String auditoriumName() { return auditoriumName; }
    public Instant showtime() { return showtime; }
    public List<String> seatLabels() { return seatLabels; }
    public BigDecimal subtotal() { return subtotal; }
    public BigDecimal discount() { return discount; }
    public BigDecimal tax() { return tax; }
    public BigDecimal serviceFee() { return serviceFee; }
    public BigDecimal total() { return total; }
    public Instant createdAt() { return createdAt; }
    public Instant paidAt() { return paidAt; }

    public long getId() { return id; }
    public String getBookingCode() { return bookingCode; }
    public long getUserId() { return userId; }
    public BookingStatus getStatus() { return status; }
    public PaymentStatus getPaymentStatus() { return paymentStatus; }
    public String getMovieTitle() { return movieTitle; }
    public String getMoviePosterUrl() { return moviePosterUrl; }
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
