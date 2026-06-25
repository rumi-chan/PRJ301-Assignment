package vn.edu.cinebook.dto;

import java.math.BigDecimal;

public record PriceBreakdown(
        BigDecimal ticketSubtotal,
        BigDecimal comboSubtotal,
        BigDecimal subtotal,
        BigDecimal discount,
        BigDecimal taxableAmount,
        BigDecimal tax,
        BigDecimal serviceFee,
        BigDecimal total,
        String promotionCode
) {
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
