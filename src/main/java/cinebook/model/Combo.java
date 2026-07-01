package cinebook.model;

import java.math.BigDecimal;

public class Combo {
    private final long id;
    private final String sku;
    private final String name;
    private final String description;
    private final String imageUrl;
    private final BigDecimal price;
    private final boolean active;
    private final int displayOrder;

    public Combo(long id, String sku, String name, String description, String imageUrl,
                 BigDecimal price, boolean active, int displayOrder) {
        this.id = id;
        this.sku = sku;
        this.name = name;
        this.description = description;
        this.imageUrl = imageUrl;
        this.price = price;
        this.active = active;
        this.displayOrder = displayOrder;
    }

    public Combo(long id, String name, String description, String imageUrl, BigDecimal price, boolean active) {
        this(id, "", name, description, imageUrl, price, active, 0);
    }

    public long id() { return id; }
    public String sku() { return sku; }
    public String name() { return name; }
    public String description() { return description; }
    public String imageUrl() { return imageUrl; }
    public BigDecimal price() { return price; }
    public boolean active() { return active; }
    public int displayOrder() { return displayOrder; }

    public long getId() { return id; }
    public String getSku() { return sku; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public String getImageUrl() { return imageUrl; }
    public BigDecimal getPrice() { return price; }
    public boolean isActive() { return active; }
    public int getDisplayOrder() { return displayOrder; }
}
