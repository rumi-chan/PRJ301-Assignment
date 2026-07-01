package cinebook.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import cinebook.dao.UserDAO;
import cinebook.model.User;
import cinebook.model.UserRole;
import cinebook.util.AppException;
import cinebook.util.PasswordUtil;

import java.time.Instant;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {
    @Mock
    private UserDAO users;

    private AuthService service;

    @BeforeEach
    void setUp() {
        service = new AuthService(users);
    }

    @Test
    void logsInActiveUserWithValidPassword() {
        User user = user(true, PasswordUtil.hash("cinema123"));
        when(users.findByEmail("customer@cinebook.vn")).thenReturn(Optional.of(user));

        User result = service.login("CUSTOMER@cinebook.vn", "cinema123");

        assertEquals(user.id(), result.id());
    }

    @Test
    void rejectsLockedAccount() {
        when(users.findByEmail(anyString())).thenReturn(
                Optional.of(user(false, PasswordUtil.hash("cinema123"))));

        AppException exception = assertThrows(
                AppException.class,
                () -> service.login("customer@cinebook.vn", "cinema123"));

        assertEquals(403, exception.getStatusCode());
    }

    @Test
    void rejectsWrongPasswordWithoutLeakingWhichCredentialFailed() {
        when(users.findByEmail(anyString())).thenReturn(
                Optional.of(user(true, PasswordUtil.hash("cinema123"))));

        AppException exception = assertThrows(
                AppException.class,
                () -> service.login("customer@cinebook.vn", "wrong-password"));

        assertEquals(401, exception.getStatusCode());
        assertEquals("Email or password is incorrect.", exception.getMessage());
    }

    private User user(boolean active, String passwordHash) {
        return new User(1, "Demo Customer", "customer@cinebook.vn", "0900000000",
                passwordHash, UserRole.CUSTOMER, active, Instant.now());
    }
}
