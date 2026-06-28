package vn.edu.cinebook.util;

import java.util.Locale;
import java.util.regex.Pattern;

public final class Validation {
    private static final Pattern EMAIL = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");

    private Validation() {
    }

    public static String required(String value, String field, int maxLength) {
        String normalized = value == null ? "" : value.trim();
        if (normalized.isEmpty()) {
            throw new AppException(400, field + " is required.");
        }
        if (normalized.length() > maxLength) {
            throw new AppException(400, field + " is too long.");
        }
        return normalized;
    }

    public static String email(String value) {
        String normalized = required(value, "Email", 255).toLowerCase(Locale.ROOT);
        if (!EMAIL.matcher(normalized).matches()) {
            throw new AppException(400, "Enter a valid email address.");
        }
        return normalized;
    }

    public static long positiveLong(String value, String field) {
        try {
            long parsed = Long.parseLong(value);
            if (parsed <= 0) {
                throw new NumberFormatException();
            }
            return parsed;
        } catch (NumberFormatException exception) {
            throw new AppException(400, field + " is invalid.");
        }
    }

    public static int nonNegativeInt(String value, String field) {
        try {
            int parsed = Integer.parseInt(value);
            if (parsed < 0) {
                throw new NumberFormatException();
            }
            return parsed;
        } catch (NumberFormatException exception) {
            throw new AppException(400, field + " is invalid.");
        }
    }
}
