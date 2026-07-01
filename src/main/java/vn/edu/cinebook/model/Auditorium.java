package vn.edu.cinebook.model;

public record Auditorium(
        long id,
        long cinemaId,
        String cinemaName,
        String name,
        String type,
        int capacity,
        boolean active
) {
    public Auditorium(long id, long cinemaId, String name, String type, int capacity, boolean active) {
        this(id, cinemaId, "", name, type, capacity, active);
    }

    public long getId() { return id; }
    public long getCinemaId() { return cinemaId; }
    public String getCinemaName() { return cinemaName; }
    public String getName() { return name; }
    public String getType() { return type; }
    public int getCapacity() { return capacity; }
    public boolean isActive() { return active; }
}
