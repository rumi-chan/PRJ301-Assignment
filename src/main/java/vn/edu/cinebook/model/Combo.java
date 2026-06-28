package vn.edu.cinebook.model;

import java.math.BigDecimal;

public record Combo(
        long id,
        String name,
        String description,
        String imageUrl,
        BigDecimal price,
        boolean active
) {
    public long getId() { return id; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public String getImageUrl() { return imageUrl; }
    public BigDecimal getPrice() { return price; }
    public boolean isActive() { return active; }
}
