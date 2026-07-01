package cinebook.model;

public class Cinema {
    private final long id;
    private final String name;
    private final String city;
    private final String slug;
    private final String district;
    private final String address;
    private final String phone;
    private final boolean active;

    public Cinema(long id, String name, String city, String slug, String district,
                  String address, String phone, boolean active) {
        this.id = id;
        this.name = name;
        this.city = city;
        this.slug = slug;
        this.district = district;
        this.address = address;
        this.phone = phone;
        this.active = active;
    }

    public long id() { return id; }
    public String name() { return name; }
    public String city() { return city; }
    public String slug() { return slug; }
    public String district() { return district; }
    public String address() { return address; }
    public String phone() { return phone; }
    public boolean active() { return active; }

    public long getId() { return id; }
    public String getName() { return name; }
    public String getSlug() { return slug; }
    public String getCity() { return city; }
    public String getDistrict() { return district; }
    public String getAddress() { return address; }
    public String getPhone() { return phone; }
    public boolean isActive() { return active; }
}
