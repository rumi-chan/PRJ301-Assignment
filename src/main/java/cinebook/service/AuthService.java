package cinebook.service;

import cinebook.dao.UserDAO;
import cinebook.model.User;
import cinebook.util.AppException;
import cinebook.util.PasswordUtil;
import cinebook.util.Validation;

import java.util.List;

public class AuthService {
    private final UserDAO userDAO;

    public AuthService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    public List<User> searchUsers(String query) {
        return userDAO.findAll(query);
    }

    public void toggleLockStatus(long userId, boolean lock) {
        User user = userDAO.findById(userId)
                .orElseThrow(() -> new AppException(404, "User account not found."));
        if (user.isAdmin()) {
            throw new AppException(403, "Administrator accounts cannot be locked.");
        }
        userDAO.updateLockStatus(userId, lock);
    }

    public User login(String email, String password) {
        String normalizedEmail = Validation.email(email);
        User user = userDAO.findByEmail(normalizedEmail)
                .orElseThrow(() -> new AppException(401, "Email or password is incorrect."));
        if (!user.active() || user.isLocked()) {
            throw new AppException(403, "This account is locked. Contact an administrator.");
        }
        if (!PasswordUtil.matches(password, user.passwordHash())) {
            throw new AppException(401, "Email or password is incorrect.");
        }
        return user;
    }

    public User register(String fullName, String email, String phone,
                         String password, String confirmation) {
        String name = Validation.required(fullName, "Full name", 120);
        String normalizedEmail = Validation.email(email);
        String normalizedPhone = phone == null ? "" : phone.trim();
        if (normalizedPhone.length() > 30) {
            throw new AppException(400, "Phone number is too long.");
        }
        if (password == null || password.length() < 8) {
            throw new AppException(400, "Password must contain at least 8 characters.");
        }
        if (!password.equals(confirmation)) {
            throw new AppException(400, "Password confirmation does not match.");
        }
        if (userDAO.findByEmail(normalizedEmail).isPresent()) {
            throw new AppException(409, "An account with this email already exists.");
        }
        return userDAO.create(name, normalizedEmail, normalizedPhone, PasswordUtil.hash(password));
    }
}
