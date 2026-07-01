package cinebook.model;

import java.io.Serial;
import java.io.Serializable;
import java.time.Instant;

public class User implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    private final long id;
    private final String fullName;
    private final String email;
    private final String phone;
    private final String passwordHash;
    private final UserRole role;
    private final boolean active;
    private final boolean locked;
    private final Instant createdAt;

    public User(long id, String fullName, String email, String phone, String passwordHash,
                UserRole role, boolean active, boolean locked, Instant createdAt) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.passwordHash = passwordHash;
        this.role = role;
        this.active = active;
        this.locked = locked;
        this.createdAt = createdAt;
    }

    public User(long id, String fullName, String email, String phone, String passwordHash, UserRole role, boolean active, Instant createdAt) {
        this(id, fullName, email, phone, passwordHash, role, active, !active, createdAt);
    }

    public boolean isAdmin() {
        return role == UserRole.ADMIN;
    }

    public long id() { return id; }
    public String fullName() { return fullName; }
    public String email() { return email; }
    public String phone() { return phone; }
    public String passwordHash() { return passwordHash; }
    public UserRole role() { return role; }
    public boolean active() { return active; }
    public boolean locked() { return locked; }
    public Instant createdAt() { return createdAt; }

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
