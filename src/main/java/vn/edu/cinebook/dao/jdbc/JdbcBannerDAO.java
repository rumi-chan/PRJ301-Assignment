package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.BannerDAO;
import vn.edu.cinebook.model.Banner;
import vn.edu.cinebook.util.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcBannerDAO implements BannerDAO {
    private static final String SELECT = """
            SELECT banner_id, title, subtitle, image_url, target_url, placement,
                   display_order, starts_at, ends_at, is_active, created_by
            FROM banners
            """;

    @Override
    public List<Banner> findActiveBanners(String placement) {
        String sql = SELECT + """
                 WHERE is_active = 1 AND placement = ?
                   AND starts_at <= SYSUTCDATETIME() AND ends_at >= SYSUTCDATETIME()
                 ORDER BY display_order ASC, banner_id DESC
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, placement);
            List<Banner> banners = new ArrayList<>();
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    banners.add(map(result));
                }
            }
            return banners;
        } catch (SQLException exception) {
            System.err.println("Warning: Could not fetch active banners: " + exception.getMessage());
            return new ArrayList<>();
        }
    }

    @Override
    public List<Banner> findAll() {
        String sql = SELECT + " ORDER BY placement, display_order ASC, banner_id DESC";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            List<Banner> banners = new ArrayList<>();
            while (result.next()) {
                banners.add(map(result));
            }
            return banners;
        } catch (SQLException exception) {
            System.err.println("Warning: Could not fetch all banners: " + exception.getMessage());
            return new ArrayList<>();
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
    public void insert(Banner banner) {
        String sql = """
                INSERT INTO banners (title, subtitle, image_url, target_url, placement,
                                     display_order, starts_at, ends_at, is_active, created_by)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bind(statement, banner);
            if (banner.createdBy() != null) {
                statement.setLong(10, banner.createdBy());
            } else {
                statement.setNull(10, java.sql.Types.BIGINT);
            }
            statement.executeUpdate();
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
            bind(statement, banner);
            statement.setLong(10, banner.id());
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

    private void bind(PreparedStatement statement, Banner banner) throws SQLException {
        statement.setString(1, banner.title());
        statement.setString(2, banner.subtitle());
        statement.setString(3, banner.imageUrl());
        statement.setString(4, banner.targetUrl());
        statement.setString(5, banner.placement());
        statement.setInt(6, banner.displayOrder());
        statement.setTimestamp(7, Timestamp.valueOf(banner.startsAt()));
        statement.setTimestamp(8, Timestamp.valueOf(banner.endsAt()));
        statement.setBoolean(9, banner.isActive());
    }

    private Banner map(ResultSet result) throws SQLException {
        Timestamp startTs = result.getTimestamp("starts_at");
        Timestamp endTs = result.getTimestamp("ends_at");
        long createdByVal = result.getLong("created_by");
        Long createdBy = result.wasNull() ? null : createdByVal;
        return new Banner(
                result.getLong("banner_id"),
                result.getString("title"),
                result.getString("subtitle"),
                result.getString("image_url"),
                result.getString("target_url"),
                result.getString("placement"),
                result.getInt("display_order"),
                startTs != null ? startTs.toLocalDateTime() : LocalDateTime.now(),
                endTs != null ? endTs.toLocalDateTime() : LocalDateTime.now().plusDays(30),
                result.getBoolean("is_active"),
                createdBy
        );
    }
}
