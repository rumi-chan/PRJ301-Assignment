package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.PromotionDAO;
import vn.edu.cinebook.model.Promotion;
import vn.edu.cinebook.util.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import vn.edu.cinebook.util.AppException;

public class JdbcPromotionDAO implements PromotionDAO {
    private static final String SELECT = """
            SELECT promotion_id AS id, code, name, description, discount_type, discount_value,
                   maximum_discount, minimum_order, starts_at, ends_at AS expires_at,
                   is_active, usage_limit, per_user_limit, times_redeemed
            FROM promotions
            """;

    @Override
    public Optional<Promotion> findByCode(String code) {
        String sql = SELECT + " WHERE UPPER(code) = UPPER(?)";
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

    @Override
    public Optional<Promotion> findById(long id) {
        String sql = SELECT + " WHERE promotion_id = ?";
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
    public List<Promotion> findAllAdmin() {
        String sql = SELECT + " ORDER BY starts_at DESC, code";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            List<Promotion> promotions = new ArrayList<>();
            while (result.next()) {
                promotions.add(map(result));
            }
            return promotions;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public long insert(Promotion promotion) {
        String sql = """
                INSERT INTO promotions (code, name, description, discount_type, discount_value,
                                        minimum_order, maximum_discount, starts_at, ends_at,
                                        usage_limit, per_user_limit, times_redeemed, is_active,
                                        created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, SYSUTCDATETIME(), SYSUTCDATETIME())
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bindWrite(statement, promotion);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) throw new AppException(500, "Promotion created but ID not returned.");
                return keys.getLong(1);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void update(Promotion promotion) {
        String sql = """
                UPDATE promotions
                SET code = ?, name = ?, description = ?, discount_type = ?, discount_value = ?,
                    minimum_order = ?, maximum_discount = ?, starts_at = ?, ends_at = ?,
                    usage_limit = ?, per_user_limit = ?, is_active = ?, updated_at = SYSUTCDATETIME()
                WHERE promotion_id = ?
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bindWrite(statement, promotion);
            statement.setLong(13, promotion.id());
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void delete(long id) {
        String sql = "UPDATE promotions SET is_active = 0, updated_at = SYSUTCDATETIME() WHERE promotion_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private void bindWrite(PreparedStatement statement, Promotion promotion) throws SQLException {
        statement.setString(1, promotion.code());
        statement.setString(2, promotion.name());
        statement.setString(3, promotion.description());
        statement.setString(4, promotion.discountType());
        statement.setBigDecimal(5, promotion.discountValue());
        statement.setBigDecimal(6, promotion.minimumOrder());
        statement.setBigDecimal(7, promotion.maximumDiscount());
        statement.setTimestamp(8, Timestamp.from(promotion.startsAt()));
        statement.setTimestamp(9, Timestamp.from(promotion.expiresAt()));
        if (promotion.usageLimit() == null) {
            statement.setNull(10, java.sql.Types.INTEGER);
        } else {
            statement.setInt(10, promotion.usageLimit());
        }
        if (promotion.perUserLimit() == null) {
            statement.setNull(11, java.sql.Types.INTEGER);
        } else {
            statement.setInt(11, promotion.perUserLimit());
        }
        statement.setBoolean(12, promotion.active());
    }

    private Promotion map(ResultSet result) throws SQLException {
        Timestamp starts = result.getTimestamp("starts_at");
        Timestamp expires = result.getTimestamp("expires_at");
        int usageLimit = result.getInt("usage_limit");
        Integer usageLimitValue = result.wasNull() ? null : usageLimit;
        int perUserLimit = result.getInt("per_user_limit");
        Integer perUserLimitValue = result.wasNull() ? null : perUserLimit;
        return new Promotion(
                result.getLong("id"),
                result.getString("code"),
                result.getString("name"),
                result.getString("description"),
                result.getString("discount_type"),
                result.getBigDecimal("discount_value"),
                result.getBigDecimal("maximum_discount"),
                result.getBigDecimal("minimum_order"),
                starts == null ? null : starts.toInstant(),
                expires == null ? null : expires.toInstant(),
                result.getBoolean("is_active"),
                usageLimitValue,
                perUserLimitValue,
                result.getInt("times_redeemed")
        );
    }
}
