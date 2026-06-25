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
import java.util.Optional;

public class JdbcUserDAO implements UserDAO {
    @Override
    public Optional<User> findByEmail(String email) {
        String sql = """
                SELECT user_id AS id, full_name, email, phone, password_hash, role,
                       CAST(CASE WHEN is_active = 1 AND is_locked = 0 THEN 1 ELSE 0 END AS bit) AS is_active,
                       created_at
                FROM users WHERE email = ?
                """;
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
        String sql = """
                SELECT user_id AS id, full_name, email, phone, password_hash, role,
                       CAST(CASE WHEN is_active = 1 AND is_locked = 0 THEN 1 ELSE 0 END AS bit) AS is_active,
                       created_at
                FROM users WHERE user_id = ?
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
    public User create(String fullName, String email, String phone, String passwordHash) {
        String sql = """
                INSERT INTO users (full_name, email, phone, password_hash, role, is_active, created_at, updated_at)
                VALUES (?, ?, ?, ?, 'CUSTOMER', 1, SYSUTCDATETIME(), SYSUTCDATETIME())
                """;
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
                result.getTimestamp("created_at").toInstant()
        );
    }
}
