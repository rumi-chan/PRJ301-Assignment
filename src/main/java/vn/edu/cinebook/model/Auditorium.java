package vn.edu.cinebook.model;

public record Auditorium(
        long id,
        long cinemaId,
        String name,
        String type, // map from auditorium_type
        int capacity,
        boolean active
) {
    public long getId() { return id; }
    public long getCinemaId() { return cinemaId; }
    public String getName() { return name; }
    public String getType() { return type; }
    public int getCapacity() { return capacity; }
    public boolean isActive() { return active; }
}
