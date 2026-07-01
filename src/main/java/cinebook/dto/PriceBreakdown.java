package cinebook.dto;

import java.math.BigDecimal;

public class PriceBreakdown {
    private final BigDecimal ticketSubtotal;
    private final BigDecimal comboSubtotal;
    private final BigDecimal subtotal;
    private final BigDecimal discount;
    private final BigDecimal taxableAmount;
    private final BigDecimal tax;
    private final BigDecimal serviceFee;
    private final BigDecimal total;
    private final String promotionCode;

    public PriceBreakdown(BigDecimal ticketSubtotal, BigDecimal comboSubtotal, BigDecimal subtotal,
                          BigDecimal discount, BigDecimal taxableAmount, BigDecimal tax,
                          BigDecimal serviceFee, BigDecimal total, String promotionCode) {
        this.ticketSubtotal = ticketSubtotal;
        this.comboSubtotal = comboSubtotal;
        this.subtotal = subtotal;
        this.discount = discount;
        this.taxableAmount = taxableAmount;
        this.tax = tax;
        this.serviceFee = serviceFee;
        this.total = total;
        this.promotionCode = promotionCode;
    }

    public BigDecimal ticketSubtotal() { return ticketSubtotal; }
    public BigDecimal comboSubtotal() { return comboSubtotal; }
    public BigDecimal subtotal() { return subtotal; }
    public BigDecimal discount() { return discount; }
    public BigDecimal taxableAmount() { return taxableAmount; }
    public BigDecimal tax() { return tax; }
    public BigDecimal serviceFee() { return serviceFee; }
    public BigDecimal total() { return total; }
    public String promotionCode() { return promotionCode; }

    public BigDecimal getTicketSubtotal() { return ticketSubtotal; }
    public BigDecimal getComboSubtotal() { return comboSubtotal; }
    public BigDecimal getSubtotal() { return subtotal; }
    public BigDecimal getDiscount() { return discount; }
    public BigDecimal getDiscountAmount() { return discount; }
    public BigDecimal getTaxableAmount() { return taxableAmount; }
    public BigDecimal getTax() { return tax; }
    public BigDecimal getTaxAmount() { return tax; }
    public BigDecimal getServiceFee() { return serviceFee; }
    public BigDecimal getTotal() { return total; }
    public String getPromotionCode() { return promotionCode; }
}
