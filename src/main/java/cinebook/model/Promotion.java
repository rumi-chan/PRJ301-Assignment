package cinebook.model;

import java.math.BigDecimal;
import java.time.Instant;

public class Promotion {
    private final long id;
    private final String code;
    private final String name;
    private final String description;
    private final String discountType;
    private final BigDecimal discountValue;
    private final BigDecimal maximumDiscount;
    private final BigDecimal minimumOrder;
    private final Instant startsAt;
    private final Instant expiresAt;
    private final boolean active;
    private final Integer usageLimit;
    private final Integer perUserLimit;
    private final int timesRedeemed;

    public Promotion(long id, String code, String name, String description, String discountType,
                     BigDecimal discountValue, BigDecimal maximumDiscount, BigDecimal minimumOrder,
                     Instant startsAt, Instant expiresAt, boolean active, Integer usageLimit,
                     Integer perUserLimit, int timesRedeemed) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.description = description;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.maximumDiscount = maximumDiscount;
        this.minimumOrder = minimumOrder;
        this.startsAt = startsAt;
        this.expiresAt = expiresAt;
        this.active = active;
        this.usageLimit = usageLimit;
        this.perUserLimit = perUserLimit;
        this.timesRedeemed = timesRedeemed;
    }

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

    public long id() { return id; }
    public String code() { return code; }
    public String name() { return name; }
    public String description() { return description; }
    public String discountType() { return discountType; }
    public BigDecimal discountValue() { return discountValue; }
    public BigDecimal maximumDiscount() { return maximumDiscount; }
    public BigDecimal minimumOrder() { return minimumOrder; }
    public Instant startsAt() { return startsAt; }
    public Instant expiresAt() { return expiresAt; }
    public boolean active() { return active; }
    public Integer usageLimit() { return usageLimit; }
    public Integer perUserLimit() { return perUserLimit; }
    public int timesRedeemed() { return timesRedeemed; }

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
