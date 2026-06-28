package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.UserDAO;
import vn.edu.cinebook.model.User;
import vn.edu.cinebook.model.UserRole;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcUserDAO implements UserDAO {
    @Override
    public Optional<User> findByEmail(String email) {
        String sql = "SELECT user_id AS id, full_name, email, phone, password_hash, role, "
                   + "CAST(CASE WHEN is_active = 1 AND is_locked = 0 THEN 1 ELSE 0 END AS bit) AS is_active, "
                   + "is_locked, created_at FROM users WHERE email = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? Optional.of(map(result)) : Optional.empty();
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public Optional<User> findById(long id) {
        String sql = "SELECT user_id AS id, full_name, email, phone, password_hash, role, "
                   + "CAST(CASE WHEN is_active = 1 AND is_locked = 0 THEN 1 ELSE 0 END AS bit) AS is_active, "
                   + "is_locked, created_at FROM users WHERE user_id = ?";
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
    public List<User> findAll(String query) {
        StringBuilder sql = new StringBuilder("SELECT user_id AS id, full_name, email, phone, password_hash, role, "
                   + "CAST(CASE WHEN is_active = 1 AND is_locked = 0 THEN 1 ELSE 0 END AS bit) AS is_active, "
                   + "is_locked, created_at FROM users");
        boolean hasQuery = query != null && !query.trim().isEmpty();
        if (hasQuery) {
            sql.append(" WHERE full_name LIKE ? OR email LIKE ? OR phone LIKE ?");
        }
        sql.append(" ORDER BY created_at DESC");

        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            if (hasQuery) {
                String pattern = "%" + query.trim() + "%";
                statement.setString(1, pattern);
                statement.setString(2, pattern);
                statement.setString(3, pattern);
            }
            try (ResultSet result = statement.executeQuery()) {
                List<User> users = new ArrayList<>();
                while (result.next()) {
                    users.add(map(result));
                }
                return users;
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void updateLockStatus(long id, boolean locked) {
        String sql = "UPDATE users SET is_locked = ?, updated_at = SYSUTCDATETIME() WHERE user_id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setBoolean(1, locked);
            statement.setLong(2, id);
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public User create(String fullName, String email, String phone, String passwordHash) {
        String sql = "INSERT INTO users (full_name, email, phone, password_hash, role, is_active, is_locked, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, 'CUSTOMER', 1, 0, SYSUTCDATETIME(), SYSUTCDATETIME())";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, fullName);
            statement.setString(2, email);
            statement.setString(3, phone);
            statement.setString(4, passwordHash);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new AppException(500, "The account was created but its identifier was not returned.");
                }
                return findById(keys.getLong(1)).orElseThrow(
                        () -> new AppException(500, "The new account could not be loaded."));
            }
        } catch (SQLException exception) {
            if (exception.getErrorCode() == 2601 || exception.getErrorCode() == 2627) {
                throw new AppException(409, "An account with this email already exists.");
            }
            throw JdbcSupport.databaseError(exception);
        }
    }

    private User map(ResultSet result) throws SQLException {
        return new User(
                result.getLong("id"),
                result.getString("full_name"),
                result.getString("email"),
                result.getString("phone"),
                result.getString("password_hash"),
                UserRole.valueOf(result.getString("role")),
                result.getBoolean("is_active"),
                result.getBoolean("is_locked"),
                result.getTimestamp("created_at").toInstant()
        );
    }
}