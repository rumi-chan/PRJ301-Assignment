package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.model.MovieFormat;
import vn.edu.cinebook.util.AppException;

import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

final class JdbcSupport {
    private JdbcSupport() {
    }

    static AppException databaseError(SQLException exception) {
        return new AppException(500, "Database error: " + exception.getMessage(), exception);
    }

    static List<String> csv(String value) {
        if (value == null || value.isBlank()) {
            return List.of();
        }
        return Arrays.stream(value.split(","))
                .map(String::trim)
                .filter(item -> !item.isEmpty())
                .distinct()
                .toList();
    }

    static List<MovieFormat> formats(String value) {
        return csv(value).stream().map(JdbcSupport::format).distinct().toList();
    }

    static MovieFormat format(String value) {
        if (value == null) {
            return MovieFormat.TWO_D;
        }
        return switch (value.toUpperCase()) {
            case "3D", "THREE_D" -> MovieFormat.THREE_D;
            case "IMAX" -> MovieFormat.IMAX;
            default -> MovieFormat.TWO_D;
        };
    }
}
