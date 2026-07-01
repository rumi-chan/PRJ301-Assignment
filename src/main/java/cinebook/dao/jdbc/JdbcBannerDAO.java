package cinebook.dao.jdbc;

import cinebook.dao.BannerDAO;
import cinebook.model.Banner;
import cinebook.util.AppException;
import cinebook.util.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcBannerDAO implements BannerDAO {
    private static final String SELECT = """
            SELECT banner_id AS id, title, subtitle, image_url, target_url, placement,
                   display_order, starts_at, ends_at, is_active
            FROM banners
            """;

    @Override
    public List<Banner> findAllAdmin() {
        String sql = SELECT + " ORDER BY placement, display_order ASC, banner_id DESC";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            List<Banner> list = new ArrayList<>();
            while (result.next()) {
                list.add(map(result));
            }
            return list;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public List<Banner> findActiveHomeBanners() {
        String sql = SELECT + """
                 WHERE is_active = 1 AND placement IN ('HOME_HERO', 'HOME_PROMO')
                   AND starts_at <= SYSUTCDATETIME() AND ends_at >= SYSUTCDATETIME()
                 ORDER BY CASE placement WHEN 'HOME_HERO' THEN 0 ELSE 1 END,
                          display_order ASC, banner_id DESC
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            List<Banner> list = new ArrayList<>();
            while (result.next()) {
                list.add(map(result));
            }
            return list;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public Optional<Banner> findById(long id) {
        String sql = SELECT + " WHERE banner_id = ?";
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
    public long insert(Banner banner, Long createdBy) {
        String sql = """
                INSERT INTO banners (title, subtitle, image_url, target_url, placement,
                                     display_order, starts_at, ends_at, is_active, created_by,
                                     created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSUTCDATETIME(), SYSUTCDATETIME())
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, banner.getTitle());
            statement.setString(2, banner.getSubtitle());
            statement.setString(3, banner.getImageUrl());
            statement.setString(4, banner.getTargetUrl());
            statement.setString(5, banner.getPlacement());
            statement.setInt(6, banner.getDisplayOrder());
            statement.setTimestamp(7, Timestamp.valueOf(banner.getStartsAt()));
            statement.setTimestamp(8, Timestamp.valueOf(banner.getEndsAt()));
            statement.setBoolean(9, banner.isActive());
            if (createdBy != null) {
                statement.setLong(10, createdBy);
            } else {
                statement.setNull(10, java.sql.Types.BIGINT);
            }
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new AppException(500, "Banner created but ID not returned.");
                }
                return keys.getLong(1);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void update(Banner banner) {
        String sql = """
                UPDATE banners
                SET title = ?, subtitle = ?, image_url = ?, target_url = ?, placement = ?,
                    display_order = ?, starts_at = ?, ends_at = ?, is_active = ?, updated_at = SYSUTCDATETIME()
                WHERE banner_id = ?
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, banner.getTitle());
            statement.setString(2, banner.getSubtitle());
            statement.setString(3, banner.getImageUrl());
            statement.setString(4, banner.getTargetUrl());
            statement.setString(5, banner.getPlacement());
            statement.setInt(6, banner.getDisplayOrder());
            statement.setTimestamp(7, Timestamp.valueOf(banner.getStartsAt()));
            statement.setTimestamp(8, Timestamp.valueOf(banner.getEndsAt()));
            statement.setBoolean(9, banner.isActive());
            statement.setLong(10, banner.getId());
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void delete(long id) {
        String sql = "DELETE FROM banners WHERE banner_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private Banner map(ResultSet result) throws SQLException {
        return new Banner(
                result.getLong("id"),
                result.getString("title"),
                result.getString("subtitle"),
                result.getString("image_url"),
                result.getString("target_url"),
                result.getString("placement"),
                result.getInt("display_order"),
                result.getTimestamp("starts_at").toLocalDateTime(),
                result.getTimestamp("ends_at").toLocalDateTime(),
                result.getBoolean("is_active")
        );
    }
}
