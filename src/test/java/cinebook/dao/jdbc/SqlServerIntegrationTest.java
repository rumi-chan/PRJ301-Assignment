package cinebook.dao.jdbc;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import cinebook.dto.SeatHoldResult;
import cinebook.model.Movie;
import cinebook.model.MovieStatus;
import cinebook.util.AppException;
import cinebook.util.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

@EnabledIfEnvironmentVariable(named = "CINEBOOK_IT_DB_URL", matches = ".+")
class SqlServerIntegrationTest {
    @BeforeAll
    static void configureDatabase() {
        System.setProperty("cinebook.db.url", System.getenv("CINEBOOK_IT_DB_URL"));
        System.setProperty("cinebook.db.user", System.getenv("CINEBOOK_IT_DB_USER"));
        System.setProperty("cinebook.db.password", System.getenv("CINEBOOK_IT_DB_PASSWORD"));
    }

    @AfterEach
    void releaseTestHolds() throws Exception {
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement("""
                     UPDATE seat_holds
                     SET status = 'RELEASED', released_at = SYSUTCDATETIME(),
                         updated_at = SYSUTCDATETIME()
                     WHERE status = 'ACTIVE' AND session_key LIKE 'integration-%'
                     """)) {
            statement.executeUpdate();
        }
    }

    @Test
    void catalogQueriesMatchTheSeedSchema() {
        JdbcMovieDAO movies = new JdbcMovieDAO();
        JdbcCinemaDAO cinemas = new JdbcCinemaDAO();

        List<Movie> nowShowing = movies.search(MovieStatus.NOW_SHOWING, null, null, null);
        assertFalse(nowShowing.isEmpty());
        assertTrue(movies.findById(nowShowing.get(0).id()).isPresent());
        assertFalse(movies.listGenres().isEmpty());
        assertFalse(cinemas.search(null, null).isEmpty());
    }

    @Test
    void onlyOneConcurrentSessionCanHoldTheSameSeat() throws Exception {
        long[] selection = availableSeat();
        JdbcBookingDAO bookings = new JdbcBookingDAO();
        CountDownLatch start = new CountDownLatch(1);
        ExecutorService executor = Executors.newFixedThreadPool(2);
        try {
            Future<Object> first = executor.submit(() -> attemptHold(
                    bookings, selection[0], selection[1], "integration-" + UUID.randomUUID(), start));
            Future<Object> second = executor.submit(() -> attemptHold(
                    bookings, selection[0], selection[1], "integration-" + UUID.randomUUID(), start));
            start.countDown();

            Object firstResult = first.get();
            Object secondResult = second.get();
            long successes = List.of(firstResult, secondResult).stream()
                    .filter(SeatHoldResult.class::isInstance).count();
            long conflicts = List.of(firstResult, secondResult).stream()
                    .filter(AppException.class::isInstance)
                    .map(AppException.class::cast)
                    .filter(exception -> exception.getStatusCode() == 409)
                    .count();

            assertEquals(1, successes);
            assertEquals(1, conflicts);
        } finally {
            executor.shutdownNow();
        }
    }

    private Object attemptHold(JdbcBookingDAO bookings, long showtimeId, long seatId,
                               String sessionKey, CountDownLatch start) {
        try {
            start.await();
            return bookings.replaceHold(showtimeId, List.of(seatId), null, null, sessionKey);
        } catch (AppException exception) {
            return exception;
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new AssertionError(exception);
        }
    }

    private long[] availableSeat() throws Exception {
        String sql = """
                SELECT TOP 1 st.showtime_id, s.seat_id
                FROM showtimes st
                JOIN seats s ON s.auditorium_id = st.auditorium_id
                WHERE st.status = 'SCHEDULED' AND st.starts_at > SYSUTCDATETIME()
                  AND s.is_active = 1 AND s.seat_type = 'STANDARD'
                  AND NOT EXISTS (
                      SELECT 1 FROM booking_seats bs
                      WHERE bs.showtime_id = st.showtime_id AND bs.seat_id = s.seat_id
                        AND bs.status = 'BOOKED')
                  AND NOT EXISTS (
                      SELECT 1 FROM seat_holds h
                      WHERE h.showtime_id = st.showtime_id AND h.seat_id = s.seat_id
                        AND h.status = 'ACTIVE' AND h.expires_at > SYSUTCDATETIME())
                ORDER BY st.starts_at, s.seat_id
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            assertTrue(result.next(), "Seed data should contain an available standard seat.");
            return new long[]{result.getLong(1), result.getLong(2)};
        }
    }
}
