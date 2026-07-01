package cinebook.model;

public class Genre {
    private final int id;
    private final String name;
    private final String slug;

    public Genre(int id, String name, String slug) {
        this.id = id;
        this.name = name;
        this.slug = slug;
    }

    public int id() { return id; }
    public String name() { return name; }
    public String slug() { return slug; }

    public int getId() { return id; }
    public String getName() { return name; }
    public String getSlug() { return slug; }
}
