package vn.edu.cinebook.dto;

import java.io.Serial;
import java.io.Serializable;

public record RevenueReportItem(
        String name,
        long totalBookings,
        long totalTickets,
        double totalRevenue
) implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    public String getName() { return name; }
    public long getTotalBookings() { return totalBookings; }
    public long getTotalTickets() { return totalTickets; }
    public double getTotalRevenue() { return totalRevenue; }
}
