package vn.edu.cinebook.service;

import vn.edu.cinebook.dto.ComboSelection;
import vn.edu.cinebook.dto.PriceBreakdown;
import vn.edu.cinebook.model.Promotion;
import vn.edu.cinebook.model.Seat;
import vn.edu.cinebook.model.SeatType;
import vn.edu.cinebook.util.AppException;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class PricingService {
    public static final BigDecimal TAX_RATE = new BigDecimal("0.08");
    public static final BigDecimal SERVICE_FEE = new BigDecimal("10000");

    public PriceBreakdown calculate(List<Seat> seats, List<ComboSelection> combos, Promotion promotion) {
        BigDecimal ticketSubtotal = ticketSubtotal(seats);
        BigDecimal comboSubtotal = (combos == null ? List.<ComboSelection>of() : combos).stream()
                .filter(selection -> selection.quantity() > 0)
                .map(ComboSelection::lineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal subtotal = ticketSubtotal.add(comboSubtotal);
        BigDecimal discount = discount(subtotal, promotion);
        BigDecimal taxable = subtotal.subtract(discount).max(BigDecimal.ZERO);
        BigDecimal tax = taxable.multiply(TAX_RATE).setScale(0, RoundingMode.HALF_UP);
        BigDecimal total = taxable.add(tax).add(SERVICE_FEE).setScale(0, RoundingMode.HALF_UP);
        return new PriceBreakdown(
                money(ticketSubtotal),
                money(comboSubtotal),
                money(subtotal),
                money(discount),
                money(taxable),
                money(tax),
                money(SERVICE_FEE),
                total,
                promotion == null ? null : promotion.code()
        );
    }

    public BigDecimal ticketSubtotal(List<Seat> seats) {
        if (seats == null || seats.isEmpty()) {
            return BigDecimal.ZERO.setScale(0, RoundingMode.HALF_UP);
        }
        BigDecimal total = BigDecimal.ZERO;
        Set<Long> couplePairs = new HashSet<>();
        for (Seat seat : seats) {
            if (seat.type() == SeatType.COUPLE) {
                if (seat.pairSeatId() == null) {
                    throw new AppException(500, "A couple seat is missing its pair configuration.");
                }
                long pairKey = Math.min(seat.id(), seat.pairSeatId());
                if (!couplePairs.add(pairKey)) {
                    continue;
                }
            }
            total = total.add(seat.price());
        }
        return money(total);
    }

    private BigDecimal discount(BigDecimal subtotal, Promotion promotion) {
        if (promotion == null) {
            return BigDecimal.ZERO;
        }
        if (!promotion.isValidAt(Instant.now())) {
            throw new AppException(400, "This promotion is inactive or expired.");
        }
        if (promotion.minimumOrder() != null && subtotal.compareTo(promotion.minimumOrder()) < 0) {
            throw new AppException(400, "This order does not meet the promotion minimum.");
        }
        BigDecimal value;
        if ("FIXED".equalsIgnoreCase(promotion.discountType())) {
            value = promotion.discountValue();
        } else {
            value = subtotal.multiply(promotion.discountValue())
                    .divide(new BigDecimal("100"), 0, RoundingMode.HALF_UP);
        }
        if (promotion.maximumDiscount() != null
                && promotion.maximumDiscount().signum() > 0
                && value.compareTo(promotion.maximumDiscount()) > 0) {
            value = promotion.maximumDiscount();
        }
        return money(value.min(subtotal));
    }

    private BigDecimal money(BigDecimal value) {
        return value.setScale(0, RoundingMode.HALF_UP);
    }
}
