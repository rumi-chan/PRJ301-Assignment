package cinebook.model;

import java.time.LocalDateTime;

public class Banner {
    private final long id;
    private final String title;
    private final String subtitle;
    private final String imageUrl;
    private final String targetUrl;
    private final String placement;
    private final int displayOrder;
    private final LocalDateTime startsAt;
    private final LocalDateTime endsAt;
    private final boolean active;

    public Banner(long id, String title, String subtitle, String imageUrl, String targetUrl,
                  String placement, int displayOrder, LocalDateTime startsAt,
                  LocalDateTime endsAt, boolean active) {
        this.id = id;
        this.title = title;
        this.subtitle = subtitle;
        this.imageUrl = imageUrl;
        this.targetUrl = targetUrl;
        this.placement = placement;
        this.displayOrder = displayOrder;
        this.startsAt = startsAt;
        this.endsAt = endsAt;
        this.active = active;
    }

    public long id() { return id; }
    public String title() { return title; }
    public String subtitle() { return subtitle; }
    public String imageUrl() { return imageUrl; }
    public String targetUrl() { return targetUrl; }
    public String placement() { return placement; }
    public int displayOrder() { return displayOrder; }
    public LocalDateTime startsAt() { return startsAt; }
    public LocalDateTime endsAt() { return endsAt; }
    public boolean active() { return active; }

    public long getId() { return id; }
    public String getTitle() { return title; }
    public String getSubtitle() { return subtitle; }
    public String getImageUrl() { return imageUrl; }
    public String getTargetUrl() { return targetUrl; }
    public String getPlacement() { return placement; }
    public int getDisplayOrder() { return displayOrder; }
    public LocalDateTime getStartsAt() { return startsAt; }
    public LocalDateTime getEndsAt() { return endsAt; }
    public boolean isActive() { return active; }
}
