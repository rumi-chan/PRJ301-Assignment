package vn.edu.cinebook.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.edu.cinebook.dao.BookingDAO;
import vn.edu.cinebook.dao.ComboDAO;
import vn.edu.cinebook.dao.PromotionDAO;
import vn.edu.cinebook.dto.PriceBreakdown;
import vn.edu.cinebook.dto.SeatHoldResult;
import vn.edu.cinebook.model.Seat;
import vn.edu.cinebook.model.SeatAvailability;
import vn.edu.cinebook.model.SeatType;
import vn.edu.cinebook.util.AppException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class BookingServiceTest {
    @Mock
    private BookingDAO bookings;
    @Mock
    private ComboDAO combos;
    @Mock
    private PromotionDAO promotions;

    private BookingService service;

    @BeforeEach
    void setUp() {
        service = new BookingService(bookings, combos, promotions, new PricingService());
    }

    @Test
    void recalculatesServerAuthoritativePriceAfterHold() {
        Seat seat = new Seat(1, 1, "A", 1, "A1", SeatType.STANDARD, null,
                new BigDecimal("100000"), SeatAvailability.AVAILABLE);
        PriceBreakdown placeholder = new PriceBreakdown(
                BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO,
                BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, null);
        when(bookings.replaceHold(2, List.of(1L), null, 7L, "session"))
                .thenReturn(new SeatHoldResult("token", 2, Instant.now().plusSeconds(420),
                        List.of(seat), placeholder));

        SeatHoldResult result = service.hold(2, List.of(1L), null, 7L, "session");

        assertEquals(new BigDecimal("118000"), result.pricing().total());
    }

    @Test
    void rejectsExpiredHold() {
        when(bookings.findActiveHold("expired")).thenReturn(Optional.empty());

        AppException exception = assertThrows(
                AppException.class, () -> service.activeHold("expired"));

        assertEquals(409, exception.getStatusCode());
    }
}
