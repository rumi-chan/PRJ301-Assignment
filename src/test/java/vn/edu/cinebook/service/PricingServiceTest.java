package vn.edu.cinebook.service;

import org.junit.jupiter.api.Test;
import vn.edu.cinebook.dto.ComboSelection;
import vn.edu.cinebook.dto.PriceBreakdown;
import vn.edu.cinebook.model.Promotion;
import vn.edu.cinebook.model.Seat;
import vn.edu.cinebook.model.SeatAvailability;
import vn.edu.cinebook.model.SeatType;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

class PricingServiceTest {
    private final PricingService service = new PricingService();

    @Test
    void calculatesTicketsCombosTaxAndFee() {
        List<Seat> seats = List.of(
                seat(1, "A1", SeatType.STANDARD, null, "90000"),
                seat(2, "B1", SeatType.VIP, null, "120000")
        );
        List<ComboSelection> combos = List.of(
                new ComboSelection(1, "Movie Night", 2, new BigDecimal("75000"))
        );

        PriceBreakdown result = service.calculate(seats, combos, null);

        assertEquals(new BigDecimal("210000"), result.ticketSubtotal());
        assertEquals(new BigDecimal("150000"), result.comboSubtotal());
        assertEquals(new BigDecimal("360000"), result.subtotal());
        assertEquals(new BigDecimal("28800"), result.tax());
        assertEquals(new BigDecimal("10000"), result.serviceFee());
        assertEquals(new BigDecimal("398800"), result.total());
    }

    @Test
    void pricesCouplePairOnlyOnce() {
        List<Seat> seats = List.of(
                seat(10, "J1", SeatType.COUPLE, 11L, "220000"),
                seat(11, "J2", SeatType.COUPLE, 10L, "220000")
        );

        PriceBreakdown result = service.calculate(seats, List.of(), null);

        assertEquals(new BigDecimal("220000"), result.ticketSubtotal());
        assertEquals(new BigDecimal("247600"), result.total());
    }

    @Test
    void appliesCappedPromotionBeforeTax() {
        Promotion promotion = new Promotion(
                1, "WELCOME20", "Welcome", "PERCENT", new BigDecimal("20"),
                new BigDecimal("50000"), new BigDecimal("100000"),
                Instant.now().minusSeconds(60), Instant.now().plusSeconds(3600), true);

        PriceBreakdown result = service.calculate(
                List.of(seat(1, "A1", SeatType.STANDARD, null, "300000")),
                List.of(), promotion);

        assertEquals(new BigDecimal("50000"), result.discount());
        assertEquals(new BigDecimal("20000"), result.tax());
        assertEquals(new BigDecimal("280000"), result.total());
        assertEquals("WELCOME20", result.promotionCode());
    }

    private Seat seat(long id, String label, SeatType type, Long pairId, String price) {
        return new Seat(id, 1, label.substring(0, 1), 1, label, type, pairId,
                new BigDecimal(price), SeatAvailability.AVAILABLE);
    }
}
