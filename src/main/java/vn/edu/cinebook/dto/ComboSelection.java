package vn.edu.cinebook.dto;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

public record ComboSelection(long comboId, String name, int quantity, BigDecimal unitPrice)
        implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    public BigDecimal lineTotal() {
        return unitPrice.multiply(BigDecimal.valueOf(quantity));
    }

    public long getComboId() { return comboId; }
    public String getName() { return name; }
    public int getQuantity() { return quantity; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public BigDecimal getTotal() { return lineTotal(); }
}
