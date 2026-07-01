package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.AuditoriumDAO;
import vn.edu.cinebook.model.Auditorium;
import vn.edu.cinebook.util.Database;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcAuditoriumDAO implements AuditoriumDAO {

    public JdbcAuditoriumDAO() {
    }

    @Override
    public List<Auditorium> findAll() {
        String sql = "SELECT auditorium_id, cinema_id, name, auditorium_type, capacity, is_active FROM auditoriums WHERE is_active = 1";
        List<Auditorium> list = new ArrayList<>();

        try (Connection connection = Database.getConnection();
             PreparedStatement stmt = connection.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                list.add(new Auditorium(
                    rs.getLong("auditorium_id"),
                    rs.getLong("cinema_id"),
                    rs.getString("name"),
                    rs.getString("auditorium_type"),
                    rs.getInt("capacity"),
                    rs.getBoolean("is_active")
                ));
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
        return list;
    }

    @Override
    public boolean insert(Auditorium a) {
        String sql = "INSERT INTO auditoriums (cinema_id, name, auditorium_type, capacity, is_active) VALUES (?, ?, ?, ?, ?)";

        try (Connection connection = Database.getConnection();
             PreparedStatement stmt = connection.prepareStatement(sql)) {

            stmt.setLong(1, a.cinemaId());
            stmt.setString(2, a.name());
            stmt.setString(3, a.type());
            stmt.setInt(4, a.capacity());
            stmt.setBoolean(5, a.isActive());

            return stmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public Optional<Auditorium> findById(long id) {
        String sql = "SELECT auditorium_id, cinema_id, name, auditorium_type, capacity, is_active FROM auditoriums WHERE auditorium_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(new Auditorium(
                        rs.getLong("auditorium_id"),
                        rs.getLong("cinema_id"),
                        rs.getString("name"),
                        rs.getString("auditorium_type"),
                        rs.getInt("capacity"),
                        rs.getBoolean("is_active")
                    ));
                }
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
        return Optional.empty();
    }

    @Override
    public boolean update(Auditorium a) {
        String sql = "UPDATE auditoriums SET cinema_id = ?, name = ?, auditorium_type = ?, capacity = ?, is_active = ? WHERE auditorium_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setLong(1, a.cinemaId());
            stmt.setString(2, a.name());
            stmt.setString(3, a.type());
            stmt.setInt(4, a.capacity());
            stmt.setBoolean(5, a.isActive());
            stmt.setLong(6, a.id());
            return stmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public boolean delete(long id) {
        String sql = "UPDATE auditoriums SET is_active = 0 WHERE auditorium_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }
}
