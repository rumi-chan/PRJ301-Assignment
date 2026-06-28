package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.ComboDAO;
import vn.edu.cinebook.model.Combo;
import vn.edu.cinebook.util.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcComboDAO implements ComboDAO {
    @Override
    public List<Combo> findActive() {
        String sql = """
                SELECT combo_id AS id, name, description, image_url, price, is_active
                FROM combos WHERE is_active = 1 ORDER BY price, name
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
                SELECT combo_id AS id, name, description, image_url, price, is_active
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

    private Combo map(ResultSet result) throws SQLException {
        return new Combo(
                result.getLong("id"),
                result.getString("name"),
                result.getString("description"),
                result.getString("image_url"),
                result.getBigDecimal("price"),
                result.getBoolean("is_active")
        );
    }
}
