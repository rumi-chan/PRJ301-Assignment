package vn.edu.cinebook.model;

public record Cinema(
        long id,
        String name,
        String city,
        String slug,
        String district,
        String address,
        String phone,
        boolean active
) {
    public long getId() { return id; }
    public String getName() { return name; }
    public String getSlug() { return slug; }
    public String getCity() { return city; }
    public String getDistrict() { return district; }
    public String getAddress() { return address; }
    public String getPhone() { return phone; }
    public boolean isActive() { return active; }
}
