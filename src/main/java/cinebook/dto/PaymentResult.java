package cinebook.dto;

import cinebook.model.PaymentStatus;

public class PaymentResult {
    private final PaymentStatus status;
    private final String bookingCode;
    private final String message;

    public PaymentResult(PaymentStatus status, String bookingCode, String message) {
        this.status = status;
        this.bookingCode = bookingCode;
        this.message = message;
    }

    public PaymentStatus status() { return status; }
    public String bookingCode() { return bookingCode; }
    public String message() { return message; }

    public PaymentStatus getStatus() { return status; }
    public String getBookingCode() { return bookingCode; }
    public String getMessage() { return message; }
}
