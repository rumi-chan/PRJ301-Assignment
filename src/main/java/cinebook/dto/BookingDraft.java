package cinebook.dto;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

public class BookingDraft implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    private final String holdToken;
    private final long showtimeId;
    private final List<ComboSelection> combos;
    private final String promotionCode;

    public BookingDraft(String holdToken, long showtimeId, List<ComboSelection> combos, String promotionCode) {
        this.holdToken = holdToken;
        this.showtimeId = showtimeId;
        this.combos = combos == null ? List.of() : List.copyOf(combos);
        this.promotionCode = promotionCode;
    }

    public BookingDraft withCombos(List<ComboSelection> selections) {
        return new BookingDraft(holdToken, showtimeId, List.copyOf(selections), promotionCode);
    }

    public BookingDraft withPromotion(String code) {
        return new BookingDraft(holdToken, showtimeId, combos, code);
    }

    public String holdToken() { return holdToken; }
    public long showtimeId() { return showtimeId; }
    public List<ComboSelection> combos() { return combos; }
    public String promotionCode() { return promotionCode; }

    public String getHoldToken() { return holdToken; }
    public long getShowtimeId() { return showtimeId; }
    public List<ComboSelection> getCombos() { return combos; }
    public List<ComboSelection> getSelectedCombos() { return combos; }
    public String getPromotionCode() { return promotionCode; }
}
