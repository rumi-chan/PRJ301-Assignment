package vn.edu.cinebook.util;

import org.mindrot.jbcrypt.BCrypt;

public final class PasswordUtil {
    private PasswordUtil() {
    }

    public static String hash(String password) {
        if (password == null || password.length() < 8) {
            throw new IllegalArgumentException("Password must contain at least 8 characters.");
        }
        return BCrypt.hashpw(password, BCrypt.gensalt(12));
    }

    public static boolean matches(String password, String hash) {
        if (password == null || hash == null || hash.isBlank()) {
            return false;
        }
        try {
            return BCrypt.checkpw(password, hash);
        } catch (IllegalArgumentException ignored) {
            return false;
        }
    }
}
