package vn.edu.cinebook.model;

import java.math.BigDecimal;
import java.time.Instant;

public record Promotion(
        long id,
        String code,
        String name,
        String description,
        String discountType,
        BigDecimal discountValue,
        BigDecimal maximumDiscount,
        BigDecimal minimumOrder,
        Instant startsAt,
        Instant expiresAt,
        boolean active,
        Integer usageLimit,
        Integer perUserLimit,
        int timesRedeemed
) {
    public Promotion(long id, String code, String name, String discountType,
                     BigDecimal discountValue, BigDecimal maximumDiscount, BigDecimal minimumOrder,
                     Instant startsAt, Instant expiresAt, boolean active) {
        this(id, code, name, "", discountType, discountValue, maximumDiscount, minimumOrder,
                startsAt, expiresAt, active, null, null, 0);
    }

    public boolean isValidAt(Instant instant) {
        return active
                && (startsAt == null || !instant.isBefore(startsAt))
                && (expiresAt == null || instant.isBefore(expiresAt));
    }

    public long getId() { return id; }
    public String getCode() { return code; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public String getDiscountType() { return discountType; }
    public BigDecimal getDiscountValue() { return discountValue; }
    public BigDecimal getMaximumDiscount() { return maximumDiscount; }
    public BigDecimal getMinimumOrder() { return minimumOrder; }
    public Instant getStartsAt() { return startsAt; }
    public Instant getExpiresAt() { return expiresAt; }
    public boolean isActive() { return active; }
    public Integer getUsageLimit() { return usageLimit; }
    public Integer getPerUserLimit() { return perUserLimit; }
    public int getTimesRedeemed() { return timesRedeemed; }
}
