package vn.edu.cinebook.service;

import vn.edu.cinebook.dao.BookingDAO;
import vn.edu.cinebook.dao.ComboDAO;
import vn.edu.cinebook.dao.PromotionDAO;
import vn.edu.cinebook.dto.ComboSelection;
import vn.edu.cinebook.dto.PaymentResult;
import vn.edu.cinebook.dto.PriceBreakdown;
import vn.edu.cinebook.dto.SeatHoldResult;
import vn.edu.cinebook.model.Booking;
import vn.edu.cinebook.model.Combo;
import vn.edu.cinebook.model.Promotion;
import vn.edu.cinebook.model.Seat;
import vn.edu.cinebook.util.AppException;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

public class BookingService {
    private final BookingDAO bookingDAO;
    private final ComboDAO comboDAO;
    private final PromotionDAO promotionDAO;
    private final PricingService pricingService;

    public BookingService(BookingDAO bookingDAO, ComboDAO comboDAO,
                          PromotionDAO promotionDAO, PricingService pricingService) {
        this.bookingDAO = bookingDAO;
        this.comboDAO = comboDAO;
        this.promotionDAO = promotionDAO;
        this.pricingService = pricingService;
    }

    public List<Seat> seats(long showtimeId, String holdToken) {
        return bookingDAO.findSeats(showtimeId, holdToken);
    }

    public SeatHoldResult hold(long showtimeId, List<Long> seatIds, String token,
                               Long userId, String sessionKey) {
        SeatHoldResult result = bookingDAO.replaceHold(showtimeId, seatIds, token, userId, sessionKey);
        PriceBreakdown pricing = pricingService.calculate(result.seats(), List.of(), null);
        return new SeatHoldResult(result.holdToken(), result.showtimeId(),
                result.expiresAt(), result.seats(), pricing);
    }

    public SeatHoldResult activeHold(String token) {
        return bookingDAO.findActiveHold(token)
                .orElseThrow(() -> new AppException(409, "The seat hold expired. Please select seats again."));
    }

    public List<Combo> combos() {
        return comboDAO.findActive();
    }

    public List<ComboSelection> comboSelections(List<Long> ids, List<Integer> quantities) {
        if (ids == null || quantities == null || ids.size() != quantities.size()) {
            return List.of();
        }
        List<ComboSelection> selections = new ArrayList<>();
        for (int index = 0; index < ids.size(); index++) {
            int quantity = quantities.get(index);
            if (quantity <= 0) {
                continue;
            }
            if (quantity > 10) {
                throw new AppException(400, "A combo quantity cannot exceed 10.");
            }
            Combo combo = comboDAO.findById(ids.get(index))
                    .orElseThrow(() -> new AppException(400, "A selected combo is unavailable."));
            selections.add(new ComboSelection(combo.id(), combo.name(), quantity, combo.price()));
        }
        return List.copyOf(selections);
    }

    public PriceBreakdown price(String holdToken, List<ComboSelection> combos, String promotionCode) {
        SeatHoldResult hold = activeHold(holdToken);
        Promotion promotion = promotion(promotionCode).orElse(null);
        return pricingService.calculate(hold.seats(), combos, promotion);
    }

    public PaymentResult pay(String holdToken, long userId, List<ComboSelection> combos,
                             String promotionCode, String outcome) {
        PriceBreakdown price = price(holdToken, combos, promotionCode);
        return bookingDAO.completePayment(holdToken, userId, combos, price, outcome);
    }

    public List<Booking> history(long userId) {
        return bookingDAO.findByUser(userId);
    }

    public Booking ticket(String code, Long userId) {
        return bookingDAO.findByCode(code, userId)
                .orElseThrow(() -> new AppException(404, "Ticket not found."));
    }

    private Optional<Promotion> promotion(String code) {
        if (code == null || code.isBlank()) {
            return Optional.empty();
        }
        String normalized = code.trim().toUpperCase(Locale.ROOT);
        Promotion promotion = promotionDAO.findByCode(normalized)
                .orElseThrow(() -> new AppException(400, "Promotion code was not found."));
        return Optional.of(promotion);
    }
}
