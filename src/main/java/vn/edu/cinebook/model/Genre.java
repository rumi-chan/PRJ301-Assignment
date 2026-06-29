package vn.edu.cinebook.model;

public record Genre(int id, String name, String slug) {
    public int getId() { return id; }
    public String getName() { return name; }
    public String getSlug() { return slug; }
}
