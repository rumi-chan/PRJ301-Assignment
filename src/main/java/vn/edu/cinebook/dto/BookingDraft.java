package vn.edu.cinebook.dto;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

public record BookingDraft(
        String holdToken,
        long showtimeId,
        List<ComboSelection> combos,
        String promotionCode
) implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    public BookingDraft withCombos(List<ComboSelection> selections) {
        return new BookingDraft(holdToken, showtimeId, List.copyOf(selections), promotionCode);
    }

    public BookingDraft withPromotion(String code) {
        return new BookingDraft(holdToken, showtimeId, combos, code);
    }

    public String getHoldToken() { return holdToken; }
    public long getShowtimeId() { return showtimeId; }
    public List<ComboSelection> getCombos() { return combos; }
    public List<ComboSelection> getSelectedCombos() { return combos; }
    public String getPromotionCode() { return promotionCode; }
}
