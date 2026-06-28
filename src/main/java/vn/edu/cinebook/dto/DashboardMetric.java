package vn.edu.cinebook.dto;

import java.io.Serial;
import java.io.Serializable;

public record DashboardMetric(
        String label,
        String value,
        boolean positive,
        String change
) implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    public String getLabel() { return label; }
    public String getValue() { return value; }
    public boolean isPositive() { return positive; }
    public String getChange() { return change; }
}