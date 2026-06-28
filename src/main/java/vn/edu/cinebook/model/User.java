package vn.edu.cinebook.model;

import java.io.Serial;
import java.io.Serializable;
import java.time.Instant;

public record User(
        long id,
        String fullName,
        String email,
        String phone,
        String passwordHash,
        UserRole role,
        boolean active,
        boolean locked,
        Instant createdAt
) implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    public User(long id, String fullName, String email, String phone, String passwordHash, UserRole role, boolean active, Instant createdAt) {
        this(id, fullName, email, phone, passwordHash, role, active, !active, createdAt);
    }

    public boolean isAdmin() {
        return role == UserRole.ADMIN;
    }

    public long getId() { return id; }
    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getPhone() { return phone; }
    public UserRole getRole() { return role; }
    public boolean isActive() { return active; }
    public boolean isLocked() { return locked; }
    public String getCreatedAt() {
        if (createdAt == null) return "";
        return java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss")
                .withZone(java.time.ZoneId.of("Asia/Ho_Chi_Minh"))
                .format(createdAt);
    }
    public String getCreatedAtDisplay() {
        if (createdAt == null) return "";
        return java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")
                .withZone(java.time.ZoneId.of("Asia/Ho_Chi_Minh"))
                .format(createdAt);
    }
}
