package cinebook.dto;

import java.io.Serial;
import java.io.Serializable;

public class RevenueReportItem implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    private final String name;
    private final long totalBookings;
    private final long totalTickets;
    private final double totalRevenue;

    public RevenueReportItem(String name, long totalBookings, long totalTickets, double totalRevenue) {
        this.name = name;
        this.totalBookings = totalBookings;
        this.totalTickets = totalTickets;
        this.totalRevenue = totalRevenue;
    }

    public String name() { return name; }
    public long totalBookings() { return totalBookings; }
    public long totalTickets() { return totalTickets; }
    public double totalRevenue() { return totalRevenue; }

    public String getName() { return name; }
    public long getTotalBookings() { return totalBookings; }
    public long getTotalTickets() { return totalTickets; }
    public double getTotalRevenue() { return totalRevenue; }
}
