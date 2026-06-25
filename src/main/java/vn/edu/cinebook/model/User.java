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
        Instant createdAt
) implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    public boolean isAdmin() {
        return role == UserRole.ADMIN;
    }

    public long getId() { return id; }
    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getPhone() { return phone; }
    public UserRole getRole() { return role; }
    public boolean isActive() { return active; }
}
