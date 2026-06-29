package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.BookingDAO;
import vn.edu.cinebook.dto.ComboSelection;
import vn.edu.cinebook.dto.PaymentResult;
import vn.edu.cinebook.dto.PriceBreakdown;
import vn.edu.cinebook.dto.SeatHoldResult;
import vn.edu.cinebook.model.Booking;
import vn.edu.cinebook.model.BookingStatus;
import vn.edu.cinebook.model.PaymentStatus;
import vn.edu.cinebook.model.Seat;
import vn.edu.cinebook.model.SeatAvailability;
import vn.edu.cinebook.model.SeatType;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.Database;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

public class JdbcBookingDAO implements BookingDAO {
    public static final Duration HOLD_DURATION = Duration.ofMinutes(7);
    private static final BigDecimal ZERO = BigDecimal.ZERO.setScale(0, RoundingMode.HALF_UP);

    @Override
    public List<Seat> findSeats(long showtimeId, String holdToken) {
        try (Connection connection = Database.getConnection()) {
            expireHolds(connection);
            return findSeats(connection, showtimeId, holdToken);
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public SeatHoldResult replaceHold(long showtimeId, List<Long> requestedSeatIds, String holdToken,
                                      Long userId, String sessionKey) {
        List<Long> seatIds = requestedSeatIds == null
                ? List.of()
                : requestedSeatIds.stream().filter(id -> id != null && id > 0).distinct().sorted().toList();
        if (seatIds.size() > 10) {
            throw new AppException(400, "A maximum of 10 seats can be held in one booking.");
        }
        if ((userId == null) && (sessionKey == null || sessionKey.isBlank())) {
            throw new AppException(400, "A user or session identifier is required.");
        }

        try (Connection connection = Database.getConnection()) {
            connection.setAutoCommit(false);
            connection.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                expireHolds(connection);
                boolean newToken = holdToken == null || holdToken.isBlank();
                String token = newToken ? UUID.randomUUID().toString() : holdToken.trim();
                Instant expiresAt = newToken
                        ? Instant.now().plus(HOLD_DURATION)
                        : existingExpiration(connection, token, userId, sessionKey)
                                .orElseThrow(() -> new AppException(
                                        409, "The seat hold is invalid or expired. Select seats again."));

                List<Seat> selected = lockAndValidateSeats(connection, showtimeId, seatIds, token);
                validateCouplePairs(selected);
                releaseCurrentSelection(connection, token);
                for (Seat seat : selected) {
                    BigDecimal snapshot = seat.type() == SeatType.COUPLE
                            && seat.pairSeatId() != null
                            && seat.id() > seat.pairSeatId()
                            ? ZERO
                            : seat.price();
                    upsertHold(connection, token, showtimeId, seat.id(), userId, sessionKey,
                            expiresAt, snapshot);
                }
                connection.commit();
                return new SeatHoldResult(token, showtimeId, expiresAt, selected, ticketOnlyPrice(selected));
            } catch (AppException exception) {
                rollback(connection);
                throw exception;
            } catch (SQLException exception) {
                rollback(connection);
                throw JdbcSupport.databaseError(exception);
            } finally {
                restoreAutoCommit(connection);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public Optional<SeatHoldResult> findActiveHold(String holdToken) {
        if (holdToken == null || holdToken.isBlank()) {
            return Optional.empty();
        }
        String sql = """
                SELECT TOP 1 showtime_id, expires_at
                FROM seat_holds
                WHERE hold_token = ? AND status = 'ACTIVE' AND expires_at > SYSUTCDATETIME()
                """;
        try (Connection connection = Database.getConnection()) {
            expireHolds(connection);
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setString(1, holdToken);
                try (ResultSet result = statement.executeQuery()) {
                    if (!result.next()) {
                        return Optional.empty();
                    }
                    long showtimeId = result.getLong("showtime_id");
                    Instant expiresAt = result.getTimestamp("expires_at").toInstant();
                    List<Seat> seats = findSelectedSeats(connection, showtimeId, holdToken);
                    return Optional.of(new SeatHoldResult(
                            holdToken, showtimeId, expiresAt, seats, ticketOnlyPrice(seats)));
                }
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public PaymentResult completePayment(String holdToken, long userId, List<ComboSelection> combos,
                                         PriceBreakdown price, String outcome) {
        String normalizedOutcome = outcome == null ? "success" : outcome.trim().toLowerCase(Locale.ROOT);
        if ("cancel".equals(normalizedOutcome) || "cancelled".equals(normalizedOutcome)) {
            releaseHold(holdToken);
            return new PaymentResult(PaymentStatus.CANCELLED, null, "Payment was cancelled and the seats were released.");
        }
        if ("failure".equals(normalizedOutcome) || "failed".equals(normalizedOutcome)) {
            return new PaymentResult(PaymentStatus.FAILED, null, "The simulated payment failed. You may retry before the hold expires.");
        }
        if (!"success".equals(normalizedOutcome)) {
            throw new AppException(400, "Unknown simulated payment outcome.");
        }

        try (Connection connection = Database.getConnection()) {
            connection.setAutoCommit(false);
            connection.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                Optional<String> existing = existingBookingCode(connection, holdToken, userId);
                if (existing.isPresent()) {
                    connection.commit();
                    return new PaymentResult(PaymentStatus.SUCCEEDED, existing.get(), "This payment was already completed.");
                }

                ActiveHold activeHold = lockActiveHold(connection, holdToken, userId);
                String bookingCode = bookingCode();
                long bookingId = insertBooking(connection, bookingCode, holdToken, userId,
                        activeHold.showtimeId(), price);
                insertBookingSeats(connection, bookingId, activeHold.showtimeId(), holdToken);
                insertBookingCombos(connection, bookingId, combos == null ? List.of() : combos);
                insertPayment(connection, bookingId, price.total());
                convertHold(connection, holdToken);
                connection.commit();
                return new PaymentResult(PaymentStatus.SUCCEEDED, bookingCode, "Payment completed successfully.");
            } catch (AppException exception) {
                rollback(connection);
                throw exception;
            } catch (SQLException exception) {
                rollback(connection);
                throw JdbcSupport.databaseError(exception);
            } finally {
                restoreAutoCommit(connection);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public List<Booking> findByUser(long userId) {
        String sql = bookingSelect() + " WHERE b.user_id = ? ORDER BY b.created_at DESC";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, userId);
            List<Booking> bookings = new ArrayList<>();
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    bookings.add(mapBooking(result));
                }
            }
            return bookings;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public Optional<Booking> findByCode(String code, Long userId) {
        StringBuilder sql = new StringBuilder(bookingSelect()).append(" WHERE b.booking_code = ?");
        if (userId != null) {
            sql.append(" AND b.user_id = ?");
        }
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            statement.setString(1, code);
            if (userId != null) {
                statement.setLong(2, userId);
            }
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? Optional.of(mapBooking(result)) : Optional.empty();
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public Optional<Long> findWatchedBookingId(long userId, long movieId) {
        String sql = """
                SELECT TOP 1 b.booking_id
                FROM bookings b
                JOIN showtimes sh ON sh.showtime_id = b.showtime_id
                WHERE b.user_id = ? AND sh.movie_id = ? AND b.status = 'USED'
                ORDER BY COALESCE(b.used_at, b.paid_at, b.created_at) DESC
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, userId);
            statement.setLong(2, movieId);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? Optional.of(result.getLong(1)) : Optional.empty();
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private List<Seat> findSeats(Connection connection, long showtimeId, String holdToken) throws SQLException {
        String sql = "SELECT st.seat_id AS id, st.auditorium_id, st.row_label, st.seat_number, " +
                "st.seat_label AS label, " +
                "st.seat_type, st.pair_seat_id, COALESCE(sp.price, sh.base_price) AS price, " +
                "CASE " +
                "    WHEN EXISTS ( " +
                "        SELECT 1 FROM booking_seats bs " +
                "        WHERE bs.seat_id = st.seat_id AND bs.showtime_id = sh.showtime_id " +
                "        AND bs.status = 'BOOKED') THEN 'SOLD' " +
                "    WHEN EXISTS ( " +
                "        SELECT 1 FROM seat_holds h WHERE h.seat_id = st.seat_id " +
                "        AND h.showtime_id = sh.showtime_id AND h.status = 'ACTIVE' " +
                "        AND h.expires_at > SYSUTCDATETIME() " +
                "        AND (? IS NULL OR h.hold_token <> ?)) THEN 'HELD' " +
                "    WHEN st.is_active = 0 THEN 'UNAVAILABLE' " +
                "    ELSE 'AVAILABLE' " +
                "END AS availability " +
                "FROM showtimes sh " +
                "JOIN seats st ON st.auditorium_id = sh.auditorium_id " +
                "LEFT JOIN seat_prices sp ON sp.showtime_id = sh.showtime_id AND sp.seat_type = st.seat_type " +
                "WHERE sh.showtime_id = ? " +
                "ORDER BY st.row_label, st.seat_number";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, holdToken);
            statement.setString(2, holdToken);
            statement.setLong(3, showtimeId);
            List<Seat> seats = new ArrayList<>();
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    seats.add(mapSeat(result));
                }
            }
            return seats;
        }
    }

    private List<Seat> lockAndValidateSeats(Connection connection, long showtimeId,
                                            List<Long> seatIds, String token) throws SQLException {
        if (seatIds.isEmpty()) {
            return List.of();
        }
        String placeholders = String.join(",", seatIds.stream().map(ignored -> "?").toList());
        String sql = String.format("SELECT st.seat_id AS id, st.auditorium_id, st.row_label, st.seat_number, " +
                "st.seat_label AS label, " +
                "st.seat_type, st.pair_seat_id, COALESCE(sp.price, sh.base_price) AS price, " +
                "'AVAILABLE' AS availability " +
                "FROM showtimes sh WITH (UPDLOCK, HOLDLOCK) " +
                "JOIN seats st WITH (UPDLOCK, HOLDLOCK) ON st.auditorium_id = sh.auditorium_id " +
                "LEFT JOIN seat_prices sp ON sp.showtime_id = sh.showtime_id AND sp.seat_type = st.seat_type " +
                "WHERE sh.showtime_id = ? AND sh.status = 'SCHEDULED' AND st.is_active = 1 " +
                "  AND st.seat_id IN (%s) " +
                "ORDER BY st.seat_id", placeholders);
        List<Seat> seats = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, showtimeId);
            for (int index = 0; index < seatIds.size(); index++) {
                statement.setLong(index + 2, seatIds.get(index));
            }
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    seats.add(mapSeat(result));
                }
            }
        }
        if (seats.size() != seatIds.size()) {
            throw new AppException(409, "One or more seats are not part of this showtime.");
        }

        String conflictSql = String.format("SELECT COUNT(*) AS conflicts " +
                "FROM seats st " +
                "WHERE st.seat_id IN (%s) AND ( " +
                "    EXISTS (SELECT 1 FROM booking_seats bs " +
                "            WHERE bs.seat_id = st.seat_id AND bs.showtime_id = ? " +
                "            AND bs.status = 'BOOKED') " +
                "    OR EXISTS (SELECT 1 FROM seat_holds h WITH (UPDLOCK, HOLDLOCK) " +
                "            WHERE h.seat_id = st.seat_id AND h.showtime_id = ? " +
                "            AND h.status = 'ACTIVE' AND h.expires_at > SYSUTCDATETIME() " +
                "            AND h.hold_token <> ?) " +
                ")", placeholders);
        try (PreparedStatement statement = connection.prepareStatement(conflictSql)) {
            int parameter = 1;
            for (Long seatId : seatIds) {
                statement.setLong(parameter++, seatId);
            }
            statement.setLong(parameter++, showtimeId);
            statement.setLong(parameter++, showtimeId);
            statement.setString(parameter, token);
            try (ResultSet result = statement.executeQuery()) {
                result.next();
                if (result.getInt("conflicts") > 0) {
                    throw new AppException(409, "One or more selected seats were just taken. Refresh and choose again.");
                }
            }
        }
        return seats;
    }

    private void validateCouplePairs(List<Seat> seats) {
        Set<Long> selected = new HashSet<>(seats.stream().map(Seat::id).toList());
        for (Seat seat : seats) {
            if (seat.type() == SeatType.COUPLE
                    && (seat.pairSeatId() == null || !selected.contains(seat.pairSeatId()))) {
                throw new AppException(400, "Couple seats must be selected as a complete pair.");
            }
        }
    }

    private Optional<Instant> existingExpiration(Connection connection, String token,
                                                 Long userId, String sessionKey) throws SQLException {
        String sql = """
                SELECT TOP 1 expires_at, user_id, session_key
                FROM seat_holds WITH (UPDLOCK, HOLDLOCK)
                WHERE hold_token = ? AND status = 'ACTIVE' AND expires_at > SYSUTCDATETIME()
                """;
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, token);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) {
                    return Optional.empty();
                }
                Long storedUser = result.getObject("user_id", Long.class);
                String storedSession = result.getString("session_key");
                boolean ownerMatches = (storedUser != null && storedUser.equals(userId))
                        || (storedSession != null && storedSession.equals(sessionKey));
                if (!ownerMatches) {
                    throw new AppException(403, "This seat hold belongs to another session.");
                }
                return Optional.of(result.getTimestamp("expires_at").toInstant());
            }
        }
    }

    private void releaseCurrentSelection(Connection connection, String token) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement("""
                UPDATE seat_holds SET status = 'RELEASED', updated_at = SYSUTCDATETIME()
                    , released_at = SYSUTCDATETIME()
                WHERE hold_token = ? AND status = 'ACTIVE'
                """)) {
            statement.setString(1, token);
            statement.executeUpdate();
        }
    }

    private void upsertHold(Connection connection, String token, long showtimeId, long seatId,
                            Long userId, String sessionKey, Instant expiresAt,
                            BigDecimal priceSnapshot) throws SQLException {
        String sql = """
                IF EXISTS (SELECT 1 FROM seat_holds WHERE hold_token = ? AND showtime_id = ? AND seat_id = ?)
                    UPDATE seat_holds
                    SET user_id = ?, session_key = ?, status = 'ACTIVE', expires_at = ?,
                        price_snapshot = ?, released_at = NULL, converted_at = NULL,
                        updated_at = SYSUTCDATETIME()
                    WHERE hold_token = ? AND showtime_id = ? AND seat_id = ?
                ELSE
                    INSERT INTO seat_holds
                        (hold_token, showtime_id, seat_id, user_id, session_key, status,
                         price_snapshot, expires_at, created_at, updated_at)
                    VALUES (?, ?, ?, ?, ?, 'ACTIVE', ?, ?, SYSUTCDATETIME(), SYSUTCDATETIME())
                """;
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            int index = 1;
            statement.setString(index++, token);
            statement.setLong(index++, showtimeId);
            statement.setLong(index++, seatId);
            setNullableLong(statement, index++, userId);
            statement.setString(index++, sessionKey);
            statement.setTimestamp(index++, Timestamp.from(expiresAt));
            statement.setBigDecimal(index++, priceSnapshot);
            statement.setString(index++, token);
            statement.setLong(index++, showtimeId);
            statement.setLong(index++, seatId);
            statement.setString(index++, token);
            statement.setLong(index++, showtimeId);
            statement.setLong(index++, seatId);
            setNullableLong(statement, index++, userId);
            statement.setString(index++, sessionKey);
            statement.setBigDecimal(index++, priceSnapshot);
            statement.setTimestamp(index, Timestamp.from(expiresAt));
            statement.executeUpdate();
        }
    }

    private void releaseHold(String token) {
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement("""
                     UPDATE seat_holds SET status = 'RELEASED', released_at = SYSUTCDATETIME(),
                         updated_at = SYSUTCDATETIME()
                     WHERE hold_token = ? AND status = 'ACTIVE'
                     """)) {
            statement.setString(1, token);
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private ActiveHold lockActiveHold(Connection connection, String token, long userId) throws SQLException {
        expireHolds(connection);
        String sql = """
                SELECT showtime_id, COUNT(*) AS seat_count
                FROM seat_holds WITH (UPDLOCK, HOLDLOCK)
                WHERE hold_token = ? AND user_id = ? AND status = 'ACTIVE'
                  AND expires_at > SYSUTCDATETIME()
                GROUP BY showtime_id
                """;
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, token);
            statement.setLong(2, userId);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next() || result.getInt("seat_count") == 0) {
                    throw new AppException(409, "The seat hold expired. Please select seats again.");
                }
                return new ActiveHold(result.getLong("showtime_id"), result.getInt("seat_count"));
            }
        }
    }

    private Optional<String> existingBookingCode(Connection connection, String token, long userId)
            throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement("""
                SELECT booking_code FROM bookings
                WHERE hold_token = ? AND user_id = ? AND status IN ('PAID','USED')
                """)) {
            statement.setString(1, token);
            statement.setLong(2, userId);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? Optional.of(result.getString(1)) : Optional.empty();
            }
        }
    }

    private long insertBooking(Connection connection, String code, String holdToken, long userId,
                               long showtimeId, PriceBreakdown price) throws SQLException {
        String sql = """
                INSERT INTO bookings
                    (booking_code, hold_token, user_id, showtime_id, promotion_id, status,
                     ticket_subtotal, combo_subtotal, discount_amount, tax_rate, tax_amount,
                     service_fee, total_amount, created_at, updated_at, paid_at)
                VALUES (?, ?, ?, ?,
                        (SELECT promotion_id FROM promotions WHERE UPPER(code) = UPPER(?)),
                        'PAID', ?, ?, ?, ?, ?, ?, ?,
                        SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME())
                """;
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, code);
            statement.setString(2, holdToken);
            statement.setLong(3, userId);
            statement.setLong(4, showtimeId);
            statement.setString(5, price.promotionCode());
            statement.setBigDecimal(6, price.ticketSubtotal());
            statement.setBigDecimal(7, price.comboSubtotal());
            statement.setBigDecimal(8, price.discount());
            statement.setBigDecimal(9, new BigDecimal("0.08"));
            statement.setBigDecimal(10, price.tax());
            statement.setBigDecimal(11, price.serviceFee());
            statement.setBigDecimal(12, price.total());
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new AppException(500, "The booking identifier was not returned.");
                }
                return keys.getLong(1);
            }
        }
    }

    private void insertBookingSeats(Connection connection, long bookingId, long showtimeId,
                                    String holdToken) throws SQLException {
        String sql = """
                INSERT INTO booking_seats
                    (booking_id, showtime_id, seat_id, seat_label_snapshot,
                     seat_type_snapshot, unit_price)
                SELECT ?, ?, st.seat_id, st.seat_label, st.seat_type, h.price_snapshot
                FROM seat_holds h
                JOIN seats st ON st.seat_id = h.seat_id
                WHERE h.hold_token = ? AND h.showtime_id = ? AND h.status = 'ACTIVE'
                """;
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, bookingId);
            statement.setLong(2, showtimeId);
            statement.setString(3, holdToken);
            statement.setLong(4, showtimeId);
            if (statement.executeUpdate() == 0) {
                throw new AppException(409, "No active held seats were found.");
            }
        }
    }

    private void insertBookingCombos(Connection connection, long bookingId,
                                     List<ComboSelection> combos) throws SQLException {
        String sql = """
                INSERT INTO booking_combos
                    (booking_id, combo_id, combo_name_snapshot, quantity, unit_price)
                VALUES (?, ?, ?, ?, ?)
                """;
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            for (ComboSelection combo : combos) {
                if (combo.quantity() <= 0) {
                    continue;
                }
                statement.setLong(1, bookingId);
                statement.setLong(2, combo.comboId());
                statement.setString(3, combo.name());
                statement.setInt(4, combo.quantity());
                statement.setBigDecimal(5, combo.unitPrice());
                statement.addBatch();
            }
            statement.executeBatch();
        }
    }

    private void insertPayment(Connection connection, long bookingId, BigDecimal amount) throws SQLException {
        String sql = """
                INSERT INTO payments
                    (booking_id, provider, provider_reference, amount, status,
                     created_at, updated_at, processed_at)
                VALUES (?, 'SIMULATED', ?, ?, 'SUCCEEDED',
                        SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME())
                """;
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, bookingId);
            statement.setString(2, "SIM-" + UUID.randomUUID());
            statement.setBigDecimal(3, amount);
            statement.executeUpdate();
        }
    }

    private void convertHold(Connection connection, String token) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement("""
                UPDATE seat_holds SET status = 'CONVERTED',
                    converted_at = SYSUTCDATETIME(), released_at = SYSUTCDATETIME(),
                    updated_at = SYSUTCDATETIME()
                WHERE hold_token = ? AND status = 'ACTIVE'
                """)) {
            statement.setString(1, token);
            statement.executeUpdate();
        }
    }

    private List<Seat> findSelectedSeats(Connection connection, long showtimeId, String token)
            throws SQLException {
        return findSeats(connection, showtimeId, token).stream()
                .filter(seat -> isHeldBy(connection, showtimeId, seat.id(), token))
                .toList();
    }

    private boolean isHeldBy(Connection connection, long showtimeId, long seatId, String token) {
        try (PreparedStatement statement = connection.prepareStatement("""
                SELECT 1 FROM seat_holds WHERE showtime_id = ? AND seat_id = ?
                AND hold_token = ? AND status = 'ACTIVE' AND expires_at > SYSUTCDATETIME()
                """)) {
            statement.setLong(1, showtimeId);
            statement.setLong(2, seatId);
            statement.setString(3, token);
            try (ResultSet result = statement.executeQuery()) {
                return result.next();
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private PriceBreakdown ticketOnlyPrice(List<Seat> seats) {
        BigDecimal tickets = BigDecimal.ZERO;
        Set<Long> countedCouplePairs = new HashSet<>();
        for (Seat seat : seats) {
            if (seat.type() == SeatType.COUPLE) {
                long pairKey = Math.min(seat.id(), seat.pairSeatId() == null ? seat.id() : seat.pairSeatId());
                if (!countedCouplePairs.add(pairKey)) {
                    continue;
                }
            }
            tickets = tickets.add(seat.price());
        }
        tickets = tickets.setScale(0, RoundingMode.HALF_UP);
        return new PriceBreakdown(tickets, ZERO, tickets, ZERO, tickets, ZERO, ZERO, tickets, null);
    }

    private void expireHolds(Connection connection) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement("""
                UPDATE seat_holds SET status = 'EXPIRED', released_at = SYSUTCDATETIME(),
                    updated_at = SYSUTCDATETIME()
                WHERE status = 'ACTIVE' AND expires_at <= SYSUTCDATETIME()
                """)) {
            statement.executeUpdate();
        }
    }

    private String bookingSelect() {
        return """
                SELECT b.booking_id AS id, b.booking_code, b.user_id, b.status,
                       COALESCE((SELECT TOP 1 p.status FROM payments p
                                 WHERE p.booking_id = b.booking_id ORDER BY p.created_at DESC),
                                CASE WHEN b.status IN ('PAID','USED') THEN 'SUCCEEDED'
                                     WHEN b.status = 'CANCELLED' THEN 'CANCELLED'
                                     ELSE 'PENDING' END) AS payment_status,
                       m.title AS movie_title, c.name AS cinema_name, a.name AS auditorium_name,
                       sh.starts_at,
                       (SELECT STRING_AGG(bs.seat_label_snapshot, ', ')
                                   WITHIN GROUP (ORDER BY bs.seat_label_snapshot)
                        FROM booking_seats bs WHERE bs.booking_id = b.booking_id) AS seat_labels,
                       (b.ticket_subtotal + b.combo_subtotal) AS subtotal,
                       b.discount_amount AS discount, b.tax_amount AS tax,
                       b.service_fee, b.total_amount AS total,
                       b.created_at, b.paid_at
                FROM bookings b
                JOIN showtimes sh ON sh.showtime_id = b.showtime_id
                JOIN movies m ON m.movie_id = sh.movie_id
                JOIN auditoriums a ON a.auditorium_id = sh.auditorium_id
                JOIN cinemas c ON c.cinema_id = a.cinema_id
                """;
    }

    private Booking mapBooking(ResultSet result) throws SQLException {
        Timestamp paidAt = result.getTimestamp("paid_at");
        return new Booking(
                result.getLong("id"),
                result.getString("booking_code"),
                result.getLong("user_id"),
                BookingStatus.valueOf(result.getString("status")),
                PaymentStatus.valueOf(result.getString("payment_status")),
                result.getString("movie_title"),
                result.getString("cinema_name"),
                result.getString("auditorium_name"),
                result.getTimestamp("starts_at").toInstant(),
                JdbcSupport.csv(result.getString("seat_labels")),
                result.getBigDecimal("subtotal"),
                result.getBigDecimal("discount"),
                result.getBigDecimal("tax"),
                result.getBigDecimal("service_fee"),
                result.getBigDecimal("total"),
                result.getTimestamp("created_at").toInstant(),
                paidAt == null ? null : paidAt.toInstant()
        );
    }

    private Seat mapSeat(ResultSet result) throws SQLException {
        Long pairSeatId = result.getObject("pair_seat_id", Long.class);
        return new Seat(
                result.getLong("id"),
                result.getLong("auditorium_id"),
                result.getString("row_label"),
                result.getInt("seat_number"),
                result.getString("label"),
                SeatType.valueOf(result.getString("seat_type")),
                pairSeatId,
                result.getBigDecimal("price"),
                SeatAvailability.valueOf(result.getString("availability"))
        );
    }

    private String bookingCode() {
        String timestamp = DateTimeFormatter.ofPattern("yyyyMMddHHmmss")
                .withZone(ZoneOffset.UTC)
                .format(Instant.now());
        String random = UUID.randomUUID().toString().substring(0, 6).toUpperCase(Locale.ROOT);
        return "CB-" + timestamp + "-" + random;
    }

    private void setNullableLong(PreparedStatement statement, int index, Long value) throws SQLException {
        if (value == null) {
            statement.setNull(index, java.sql.Types.BIGINT);
        } else {
            statement.setLong(index, value);
        }
    }

    private void rollback(Connection connection) {
        try {
            connection.rollback();
        } catch (SQLException ignored) {
            // Preserve the original exception.
        }
    }

    private void restoreAutoCommit(Connection connection) {
        try {
            connection.setAutoCommit(true);
        } catch (SQLException ignored) {
            // Connection is about to close.
        }
    }

    private record ActiveHold(long showtimeId, int seatCount) {
    }
}
