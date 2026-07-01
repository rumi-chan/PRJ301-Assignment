package cinebook.dao.jdbc;

import cinebook.dao.ComboDAO;
import cinebook.model.Combo;
import cinebook.util.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import cinebook.util.AppException;

public class JdbcComboDAO implements ComboDAO {
    @Override
    public List<Combo> findActive() {
        String sql = """
                SELECT combo_id AS id, sku, name, description, image_url, price, is_active, display_order
                FROM combos WHERE is_active = 1 ORDER BY display_order, price, name
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            List<Combo> combos = new ArrayList<>();
            while (result.next()) {
                combos.add(map(result));
            }
            return combos;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public Optional<Combo> findById(long id) {
        String sql = """
                SELECT combo_id AS id, sku, name, description, image_url, price, is_active, display_order
                FROM combos WHERE combo_id = ? AND is_active = 1
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? Optional.of(map(result)) : Optional.empty();
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public Optional<Combo> findAdminById(long id) {
        String sql = """
                SELECT combo_id AS id, sku, name, description, image_url, price, is_active, display_order
                FROM combos WHERE combo_id = ?
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? Optional.of(map(result)) : Optional.empty();
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public List<Combo> findAllAdmin() {
        String sql = """
                SELECT combo_id AS id, sku, name, description, image_url, price, is_active, display_order
                FROM combos ORDER BY display_order, name
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            List<Combo> combos = new ArrayList<>();
            while (result.next()) {
                combos.add(map(result));
            }
            return combos;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public long insert(Combo combo) {
        String sql = """
                INSERT INTO combos (sku, name, description, price, currency, image_url,
                                    is_active, display_order, created_at, updated_at)
                VALUES (?, ?, ?, ?, 'VND', ?, ?, ?, SYSUTCDATETIME(), SYSUTCDATETIME())
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bindWrite(statement, combo);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) throw new AppException(500, "Combo created but ID not returned.");
                return keys.getLong(1);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void update(Combo combo) {
        String sql = """
                UPDATE combos
                SET sku = ?, name = ?, description = ?, price = ?, image_url = ?,
                    is_active = ?, display_order = ?, updated_at = SYSUTCDATETIME()
                WHERE combo_id = ?
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bindWrite(statement, combo);
            statement.setLong(8, combo.id());
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void delete(long id) {
        String sql = "UPDATE combos SET is_active = 0, updated_at = SYSUTCDATETIME() WHERE combo_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private void bindWrite(PreparedStatement statement, Combo combo) throws SQLException {
        statement.setString(1, combo.sku());
        statement.setString(2, combo.name());
        statement.setString(3, combo.description());
        statement.setBigDecimal(4, combo.price());
        statement.setString(5, combo.imageUrl());
        statement.setBoolean(6, combo.active());
        statement.setInt(7, combo.displayOrder());
    }

    private Combo map(ResultSet result) throws SQLException {
        return new Combo(
                result.getLong("id"),
                result.getString("sku"),
                result.getString("name"),
                result.getString("description"),
                result.getString("image_url"),
                result.getBigDecimal("price"),
                result.getBoolean("is_active"),
                result.getInt("display_order")
        );
    }
}
