package vn.edu.cinebook.model;

import java.time.LocalDateTime;

public record Banner(
        long id,
        String title,
        String subtitle,
        String imageUrl,
        String targetUrl,
        String placement,
        int displayOrder,
        LocalDateTime startsAt,
        LocalDateTime endsAt,
        boolean active,
        Long createdBy
) {
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
    public Long getCreatedBy() { return createdBy; }
}
