package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.CinemaDAO;
import vn.edu.cinebook.model.Cinema;
import vn.edu.cinebook.util.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class JdbcCinemaDAO implements CinemaDAO {

    @Override
    public List<Cinema> search(String city, String query) {
        StringBuilder sql = new StringBuilder("""
                SELECT cinema_id, name, slug, city, district, address, phone, is_active
                FROM cinemas WHERE is_active = 1
                """);
        List<String> parameters = new ArrayList<>();
        if (city != null && !city.isBlank()) {
            sql.append(" AND city = ?");
            parameters.add(city.trim());
        }
        if (query != null && !query.isBlank()) {
            sql.append(" AND (LOWER(name) LIKE ? OR LOWER(address) LIKE ?)");
            String wildcard = "%" + query.trim().toLowerCase() + "%";
            parameters.add(wildcard);
            parameters.add(wildcard);
        }
        sql.append(" ORDER BY city, name");
        try (Connection connection = Database.getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            for (int index = 0; index < parameters.size(); index++) {
                statement.setString(index + 1, parameters.get(index));
            }
            List<Cinema> cinemas = new ArrayList<>();
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    cinemas.add(map(result));
                }
            }
            return cinemas;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public List<Cinema> findAll() {
        String sql = """
                SELECT cinema_id, name, slug, city, district, address, phone, is_active
                FROM cinemas WHERE is_active = 1 ORDER BY created_at DESC
                """;
        try (Connection connection = Database.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet result = statement.executeQuery()) {
            List<Cinema> cinemas = new ArrayList<>();
            while (result.next()) {
                cinemas.add(map(result));
            }
            return cinemas;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private Cinema map(ResultSet result) throws SQLException {
        return new Cinema(
                result.getLong("cinema_id"),
                result.getString("name"),
                result.getString("city"),
                result.getString("slug"),
                result.getString("district"),
                result.getString("address"),
                result.getString("phone"),
                result.getBoolean("is_active")
        );
    }

    @Override
    public List<String> listCities() {
        String sql = "SELECT DISTINCT city FROM cinemas WHERE is_active = 1 ORDER BY city";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            List<String> cities = new ArrayList<>();
            while (result.next()) {
                cities.add(result.getString("city"));
            }
            return cities;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public java.util.Optional<Cinema> findById(long id) {
        String sql = "SELECT cinema_id, name, slug, city, district, address, phone, is_active FROM cinemas WHERE cinema_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return java.util.Optional.of(map(result));
                }
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
        return java.util.Optional.empty();
    }

    @Override
    public boolean insert(Cinema cinema) {
        String sql = "INSERT INTO cinemas (name, slug, city, district, address, phone, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, cinema.getName());
            statement.setString(2, cinema.getSlug());
            statement.setString(3, cinema.getCity());
            statement.setString(4, cinema.getDistrict());
            statement.setString(5, cinema.getAddress());
            statement.setString(6, cinema.getPhone());
            statement.setBoolean(7, cinema.isActive());
            return statement.executeUpdate() > 0;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public boolean update(Cinema cinema) {
        String sql = "UPDATE cinemas SET name = ?, slug = ?, city = ?, district = ?, address = ?, phone = ?, is_active = ? WHERE cinema_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, cinema.getName());
            statement.setString(2, cinema.getSlug());
            statement.setString(3, cinema.getCity());
            statement.setString(4, cinema.getDistrict());
            statement.setString(5, cinema.getAddress());
            statement.setString(6, cinema.getPhone());
            statement.setBoolean(7, cinema.isActive());
            statement.setLong(8, cinema.getId());
            return statement.executeUpdate() > 0;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public boolean delete(long id) {
        String sql = "UPDATE cinemas SET is_active = 0 WHERE cinema_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            return statement.executeUpdate() > 0;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }
}
