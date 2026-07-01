package cinebook.dto;

import java.io.Serial;
import java.io.Serializable;

public class DashboardMetric implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    private final String label;
    private final String value;
    private final boolean positive;
    private final String change;

    public DashboardMetric(String label, String value, boolean positive, String change) {
        this.label = label;
        this.value = value;
        this.positive = positive;
        this.change = change;
    }

    public String label() { return label; }
    public String value() { return value; }
    public boolean positive() { return positive; }
    public String change() { return change; }

    public String getLabel() { return label; }
    public String getValue() { return value; }
    public boolean isPositive() { return positive; }
    public String getChange() { return change; }
}
