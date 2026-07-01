package cinebook.dto;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

public class ComboSelection implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    private final long comboId;
    private final String name;
    private final int quantity;
    private final BigDecimal unitPrice;

    public ComboSelection(long comboId, String name, int quantity, BigDecimal unitPrice) {
        this.comboId = comboId;
        this.name = name;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }

    public long comboId() { return comboId; }
    public String name() { return name; }
    public int quantity() { return quantity; }
    public BigDecimal unitPrice() { return unitPrice; }

    public BigDecimal lineTotal() {
        return unitPrice.multiply(BigDecimal.valueOf(quantity));
    }

    public long getComboId() { return comboId; }
    public String getName() { return name; }
    public int getQuantity() { return quantity; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public BigDecimal getTotal() { return lineTotal(); }
}
