package cinebook.model;

public class Auditorium {
    private final long id;
    private final long cinemaId;
    private final String cinemaName;
    private final String name;
    private final String type;
    private final int capacity;
    private final boolean active;

    public Auditorium(long id, long cinemaId, String cinemaName, String name,
                      String type, int capacity, boolean active) {
        this.id = id;
        this.cinemaId = cinemaId;
        this.cinemaName = cinemaName;
        this.name = name;
        this.type = type;
        this.capacity = capacity;
        this.active = active;
    }

    public Auditorium(long id, long cinemaId, String name, String type, int capacity, boolean active) {
        this(id, cinemaId, "", name, type, capacity, active);
    }

    public long id() { return id; }
    public long cinemaId() { return cinemaId; }
    public String cinemaName() { return cinemaName; }
    public String name() { return name; }
    public String type() { return type; }
    public int capacity() { return capacity; }
    public boolean active() { return active; }

    public long getId() { return id; }
    public long getCinemaId() { return cinemaId; }
    public String getCinemaName() { return cinemaName; }
    public String getName() { return name; }
    public String getType() { return type; }
    public int getCapacity() { return capacity; }
    public boolean isActive() { return active; }
}
