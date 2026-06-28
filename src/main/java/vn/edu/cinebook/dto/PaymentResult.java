package vn.edu.cinebook.dto;

import vn.edu.cinebook.model.PaymentStatus;

public record PaymentResult(PaymentStatus status, String bookingCode, String message) {
    public PaymentStatus getStatus() { return status; }
    public String getBookingCode() { return bookingCode; }
    public String getMessage() { return message; }
}
