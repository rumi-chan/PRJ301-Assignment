package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.PromotionDAO;
import vn.edu.cinebook.model.Promotion;
import vn.edu.cinebook.util.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Optional;

public class JdbcPromotionDAO implements PromotionDAO {
    @Override
    public Optional<Promotion> findByCode(String code) {
        String sql = """
                SELECT promotion_id AS id, code, name, discount_type, discount_value,
                       maximum_discount, minimum_order, starts_at, ends_at AS expires_at, is_active
                FROM promotions WHERE UPPER(code) = UPPER(?)
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, code);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? Optional.of(map(result)) : Optional.empty();
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private Promotion map(ResultSet result) throws SQLException {
        Timestamp starts = result.getTimestamp("starts_at");
        Timestamp expires = result.getTimestamp("expires_at");
        return new Promotion(
                result.getLong("id"),
                result.getString("code"),
                result.getString("name"),
                result.getString("discount_type"),
                result.getBigDecimal("discount_value"),
                result.getBigDecimal("maximum_discount"),
                result.getBigDecimal("minimum_order"),
                starts == null ? null : starts.toInstant(),
                expires == null ? null : expires.toInstant(),
                result.getBoolean("is_active")
        );
    }
}
