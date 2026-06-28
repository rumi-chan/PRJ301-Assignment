package vn.edu.cinebook.dao;

import vn.edu.cinebook.dto.ComboSelection;
import vn.edu.cinebook.dto.PaymentResult;
import vn.edu.cinebook.dto.PriceBreakdown;
import vn.edu.cinebook.dto.SeatHoldResult;
import vn.edu.cinebook.model.Booking;
import vn.edu.cinebook.model.Seat;

import java.util.List;
import java.util.Optional;

public interface BookingDAO {
    List<Seat> findSeats(long showtimeId, String holdToken);

    SeatHoldResult replaceHold(long showtimeId, List<Long> seatIds, String holdToken,
                               Long userId, String sessionKey);

    Optional<SeatHoldResult> findActiveHold(String holdToken);

    PaymentResult completePayment(String holdToken, long userId, List<ComboSelection> combos,
                                  PriceBreakdown price, String outcome);

    List<Booking> findByUser(long userId);

    Optional<Booking> findByCode(String code, Long userId);
}
