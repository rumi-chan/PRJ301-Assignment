package vn.edu.cinebook.model;

import java.math.BigDecimal;

public record Combo(
        long id,
        String sku,
        String name,
        String description,
        String imageUrl,
        BigDecimal price,
        boolean active,
        int displayOrder
) {
    public Combo(long id, String name, String description, String imageUrl, BigDecimal price, boolean active) {
        this(id, "", name, description, imageUrl, price, active, 0);
    }

    public long getId() { return id; }
    public String getSku() { return sku; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public String getImageUrl() { return imageUrl; }
    public BigDecimal getPrice() { return price; }
    public boolean isActive() { return active; }
    public int getDisplayOrder() { return displayOrder; }
}
