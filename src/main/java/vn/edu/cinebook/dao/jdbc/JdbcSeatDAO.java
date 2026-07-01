package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.SeatDAO;
import vn.edu.cinebook.model.Seat;
import vn.edu.cinebook.model.SeatAvailability;
import vn.edu.cinebook.model.SeatType;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.Database;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

public class JdbcSeatDAO implements SeatDAO {
    @Override
    public List<Seat> getSeatsByAuditorium(long auditoriumId) {
        String sql = """
                SELECT seat_id, auditorium_id, row_label, seat_number, seat_label,
                       seat_type, pair_seat_id, is_active
                FROM seats
                WHERE auditorium_id = ?
                ORDER BY row_label, seat_number
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, auditoriumId);
            List<Seat> seats = new ArrayList<>();
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    seats.add(mapSeat(result));
                }
            }
            return seats;
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public List<Seat> findByAuditoriumId(long auditoriumId) {
        return getSeatsByAuditorium(auditoriumId);
    }

    @Override
    public void updateSeatType(long seatId, String newType) {
        updateSeatTypes(Map.of(seatId, newType));
    }

    @Override
    public void updateSeatTypes(Map<Long, String> updates) {
        if (updates == null || updates.isEmpty()) {
            return;
        }
        Map<Long, SeatLayoutType> normalized = normalizeUpdates(updates);
        try (Connection connection = Database.getConnection()) {
            boolean previousAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try {
                List<SeatRow> selectedRows = lockSeats(connection, normalized.keySet());
                if (selectedRows.size() != normalized.size()) {
                    throw new AppException(400, "One or more seats no longer exist.");
                }
                validateRequestedCouplePairs(selectedRows, normalized);

                Set<Long> selectedIds = normalized.keySet();
                Set<Long> affectedIds = new HashSet<>(selectedIds);
                Set<Long> partnerIdsToNormalize = new HashSet<>();
                for (SeatRow row : selectedRows) {
                    if (row.pairSeatId() != null) {
                        affectedIds.add(row.pairSeatId());
                        if (!selectedIds.contains(row.pairSeatId())) {
                            partnerIdsToNormalize.add(row.pairSeatId());
                        }
                    }
                }

                clearPairLinks(connection, affectedIds);
                for (Long partnerId : partnerIdsToNormalize) {
                    updateSeatState(connection, partnerId, SeatLayoutType.STANDARD);
                }
                for (Map.Entry<Long, SeatLayoutType> entry : normalized.entrySet()) {
                    updateSeatState(connection, entry.getKey(), entry.getValue());
                }
                linkRequestedCouplePairs(connection, selectedRows, normalized);
                connection.commit();
            } catch (RuntimeException | SQLException exception) {
                rollbackQuietly(connection);
                throw exception;
            } finally {
                connection.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void insert(Seat seat) {
        String sql = """
                INSERT INTO seats
                    (auditorium_id, row_label, seat_number, seat_label, seat_type, is_active, is_accessible)
                VALUES (?, ?, ?, ?, ?, 1, 0)
                """;
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, seat.getAuditoriumId());
            statement.setString(2, seat.getRowLabel());
            statement.setInt(3, seat.getSeatNumber());
            statement.setString(4, seat.getLabel());
            statement.setString(5, seat.getType().name());
            statement.executeUpdate();
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void insertCoupleSeats(long auditoriumId, int pairIndex) {
        int firstSeatNum = pairIndex * 2 - 1;
        int secondSeatNum = pairIndex * 2;
        String row = "G";
        try (Connection connection = Database.getConnection()) {
            boolean previousAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try {
                long firstId = insertSeat(connection, auditoriumId, row, firstSeatNum,
                        row + String.format("%02d", firstSeatNum), SeatLayoutType.COUPLE);
                long secondId = insertSeat(connection, auditoriumId, row, secondSeatNum,
                        row + String.format("%02d", secondSeatNum), SeatLayoutType.COUPLE);
                linkPair(connection, firstId, secondId);
                connection.commit();
            } catch (RuntimeException | SQLException exception) {
                rollbackQuietly(connection);
                throw exception;
            } finally {
                connection.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void deleteAllSeats(long auditoriumId) {
        String clearPairsSql = "UPDATE seats SET pair_seat_id = NULL WHERE auditorium_id = ?";
        String archiveSql = """
                UPDATE seats
                   SET seat_type = 'STANDARD', is_active = 0, is_accessible = 0,
                       updated_at = SYSUTCDATETIME()
                 WHERE auditorium_id = ?
                """;
        try (Connection connection = Database.getConnection()) {
            boolean previousAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try (PreparedStatement clearPairs = connection.prepareStatement(clearPairsSql);
                 PreparedStatement archive = connection.prepareStatement(archiveSql)) {
                clearPairs.setLong(1, auditoriumId);
                clearPairs.executeUpdate();
                archive.setLong(1, auditoriumId);
                archive.executeUpdate();
                connection.commit();
            } catch (RuntimeException | SQLException exception) {
                rollbackQuietly(connection);
                throw exception;
            } finally {
                connection.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    @Override
    public void resetToDefaultLayout(long auditoriumId) {
        List<SeatTemplate> templates = defaultTemplates();
        try (Connection connection = Database.getConnection()) {
            boolean previousAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try {
                Map<String, SeatRow> existingByPosition = lockAuditoriumSeats(connection, auditoriumId);
                clearAuditoriumPairs(connection, auditoriumId);

                Set<Long> defaultSeatIds = new HashSet<>();
                Map<String, Long> defaultIdsByPosition = new HashMap<>();
                for (SeatTemplate template : templates) {
                    String key = positionKey(template.rowLabel(), template.seatNumber());
                    SeatRow existing = existingByPosition.get(key);
                    long seatId = existing == null
                            ? insertSeat(connection, auditoriumId, template.rowLabel(), template.seatNumber(),
                                    template.seatLabel(), template.type())
                            : existing.id();
                    if (existing != null) {
                        updateSeatTemplate(connection, seatId, template);
                    }
                    defaultSeatIds.add(seatId);
                    defaultIdsByPosition.put(key, seatId);
                }

                archiveNonDefaultSeats(connection, auditoriumId, defaultSeatIds);
                for (int pairIndex = 1; pairIndex <= 3; pairIndex++) {
                    int firstSeatNum = pairIndex * 2 - 1;
                    int secondSeatNum = pairIndex * 2;
                    Long firstId = defaultIdsByPosition.get(positionKey("G", firstSeatNum));
                    Long secondId = defaultIdsByPosition.get(positionKey("G", secondSeatNum));
                    if (firstId == null || secondId == null) {
                        throw new AppException(500, "Default couple seat layout could not be generated.");
                    }
                    linkPair(connection, firstId, secondId);
                }
                connection.commit();
            } catch (RuntimeException | SQLException exception) {
                rollbackQuietly(connection);
                throw exception;
            } finally {
                connection.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException exception) {
            throw JdbcSupport.databaseError(exception);
        }
    }

    private Seat mapSeat(ResultSet result) throws SQLException {
        SeatType type = SeatType.valueOf(result.getString("seat_type").toUpperCase(Locale.ROOT));
        SeatAvailability availability = result.getBoolean("is_active")
                ? SeatAvailability.AVAILABLE
                : SeatAvailability.UNAVAILABLE;
        return new Seat(
                result.getLong("seat_id"),
                result.getLong("auditorium_id"),
                result.getString("row_label"),
                result.getInt("seat_number"),
                result.getString("seat_label"),
                type,
                result.getObject("pair_seat_id", Long.class),
                BigDecimal.ZERO,
                availability
        );
    }

    private Map<Long, SeatLayoutType> normalizeUpdates(Map<Long, String> updates) {
        Map<Long, SeatLayoutType> normalized = new LinkedHashMap<>();
        for (Map.Entry<Long, String> entry : updates.entrySet()) {
            if (entry.getKey() == null) {
                throw new AppException(400, "Seat id is required.");
            }
            normalized.put(entry.getKey(), SeatLayoutType.from(entry.getValue()));
        }
        return normalized;
    }

    private List<SeatRow> lockSeats(Connection connection, Set<Long> seatIds) throws SQLException {
        String sql = "SELECT seat_id, auditorium_id, row_label, seat_number, pair_seat_id "
                + "FROM seats WITH (UPDLOCK, HOLDLOCK) WHERE seat_id IN (" + placeholders(seatIds.size()) + ")";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            int parameter = 1;
            for (Long seatId : seatIds) {
                statement.setLong(parameter++, seatId);
            }
            List<SeatRow> rows = new ArrayList<>();
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    rows.add(mapSeatRow(result));
                }
            }
            return rows;
        }
    }

    private Map<String, SeatRow> lockAuditoriumSeats(Connection connection, long auditoriumId) throws SQLException {
        String sql = """
                SELECT seat_id, auditorium_id, row_label, seat_number, pair_seat_id
                FROM seats WITH (UPDLOCK, HOLDLOCK)
                WHERE auditorium_id = ?
                """;
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, auditoriumId);
            Map<String, SeatRow> rows = new HashMap<>();
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    SeatRow row = mapSeatRow(result);
                    rows.put(positionKey(row.rowLabel(), row.seatNumber()), row);
                }
            }
            return rows;
        }
    }

    private SeatRow mapSeatRow(ResultSet result) throws SQLException {
        return new SeatRow(
                result.getLong("seat_id"),
                result.getLong("auditorium_id"),
                result.getString("row_label"),
                result.getInt("seat_number"),
                result.getObject("pair_seat_id", Long.class)
        );
    }

    private void validateRequestedCouplePairs(List<SeatRow> selectedRows, Map<Long, SeatLayoutType> updates) {
        List<SeatRow> coupleRows = selectedRows.stream()
                .filter(row -> updates.get(row.id()) == SeatLayoutType.COUPLE)
                .sorted(Comparator
                        .comparingLong(SeatRow::auditoriumId)
                        .thenComparing(SeatRow::rowLabel)
                        .thenComparingInt(SeatRow::seatNumber))
                .toList();
        if (coupleRows.isEmpty()) {
            return;
        }
        if (coupleRows.size() % 2 != 0) {
            throw new AppException(400, "Couple seats must be saved as adjacent pairs.");
        }
        for (int index = 0; index < coupleRows.size(); index += 2) {
            SeatRow first = coupleRows.get(index);
            SeatRow second = coupleRows.get(index + 1);
            boolean adjacentPair = first.auditoriumId() == second.auditoriumId()
                    && first.rowLabel().equals(second.rowLabel())
                    && second.seatNumber() == first.seatNumber() + 1;
            if (!adjacentPair) {
                throw new AppException(400, "Couple seats must be saved as adjacent pairs.");
            }
        }
    }

    private void linkRequestedCouplePairs(Connection connection, List<SeatRow> selectedRows,
                                          Map<Long, SeatLayoutType> updates) throws SQLException {
        List<SeatRow> coupleRows = selectedRows.stream()
                .filter(row -> updates.get(row.id()) == SeatLayoutType.COUPLE)
                .sorted(Comparator
                        .comparingLong(SeatRow::auditoriumId)
                        .thenComparing(SeatRow::rowLabel)
                        .thenComparingInt(SeatRow::seatNumber))
                .toList();
        for (int index = 0; index < coupleRows.size(); index += 2) {
            linkPair(connection, coupleRows.get(index).id(), coupleRows.get(index + 1).id());
        }
    }

    private void clearPairLinks(Connection connection, Set<Long> seatIds) throws SQLException {
        if (seatIds.isEmpty()) {
            return;
        }
        String sql = "UPDATE seats SET pair_seat_id = NULL, updated_at = SYSUTCDATETIME() "
                + "WHERE seat_id IN (" + placeholders(seatIds.size()) + ")";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            int parameter = 1;
            for (Long seatId : seatIds) {
                statement.setLong(parameter++, seatId);
            }
            statement.executeUpdate();
        }
    }

    private void clearAuditoriumPairs(Connection connection, long auditoriumId) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "UPDATE seats SET pair_seat_id = NULL, updated_at = SYSUTCDATETIME() WHERE auditorium_id = ?")) {
            statement.setLong(1, auditoriumId);
            statement.executeUpdate();
        }
    }

    private void updateSeatState(Connection connection, long seatId, SeatLayoutType type) throws SQLException {
        String sql = """
                UPDATE seats
                   SET seat_type = ?, is_active = ?, updated_at = SYSUTCDATETIME()
                 WHERE seat_id = ?
                """;
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, type.databaseType());
            statement.setBoolean(2, type.active());
            statement.setLong(3, seatId);
            statement.executeUpdate();
        }
    }

    private void updateSeatTemplate(Connection connection, long seatId, SeatTemplate template) throws SQLException {
        String sql = """
                UPDATE seats
                   SET seat_label = ?, seat_type = ?, is_active = 1, is_accessible = 0,
                       updated_at = SYSUTCDATETIME()
                 WHERE seat_id = ?
                """;
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, template.seatLabel());
            statement.setString(2, template.type().databaseType());
            statement.setLong(3, seatId);
            statement.executeUpdate();
        }
    }

    private long insertSeat(Connection connection, long auditoriumId, String rowLabel, int seatNumber,
                            String seatLabel, SeatLayoutType type) throws SQLException {
        String sql = """
                INSERT INTO seats
                    (auditorium_id, row_label, seat_number, seat_label, seat_type, is_active, is_accessible)
                VALUES (?, ?, ?, ?, ?, ?, 0)
                """;
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setLong(1, auditoriumId);
            statement.setString(2, rowLabel);
            statement.setInt(3, seatNumber);
            statement.setString(4, seatLabel);
            statement.setString(5, type.databaseType());
            statement.setBoolean(6, type.active());
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
        }
        throw new AppException(500, "Seat id was not returned after insert.");
    }

    private void archiveNonDefaultSeats(Connection connection, long auditoriumId, Set<Long> defaultSeatIds)
            throws SQLException {
        if (defaultSeatIds.isEmpty()) {
            return;
        }
        String sql = """
                UPDATE seats
                   SET seat_type = 'STANDARD', is_active = 0, is_accessible = 0,
                       updated_at = SYSUTCDATETIME()
                 WHERE auditorium_id = ?
                   AND seat_id NOT IN (
                """ + placeholders(defaultSeatIds.size()) + ")";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, auditoriumId);
            int parameter = 2;
            for (Long seatId : defaultSeatIds) {
                statement.setLong(parameter++, seatId);
            }
            statement.executeUpdate();
        }
    }

    private void linkPair(Connection connection, long firstSeatId, long secondSeatId) throws SQLException {
        String sql = "UPDATE seats SET pair_seat_id = ?, updated_at = SYSUTCDATETIME() WHERE seat_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, secondSeatId);
            statement.setLong(2, firstSeatId);
            statement.executeUpdate();
            statement.setLong(1, firstSeatId);
            statement.setLong(2, secondSeatId);
            statement.executeUpdate();
        }
    }

    private List<SeatTemplate> defaultTemplates() {
        List<SeatTemplate> templates = new ArrayList<>();
        for (char row = 'A'; row <= 'F'; row++) {
            SeatLayoutType type = row <= 'C' ? SeatLayoutType.STANDARD : SeatLayoutType.VIP;
            for (int number = 1; number <= 10; number++) {
                String rowLabel = String.valueOf(row);
                templates.add(new SeatTemplate(rowLabel, number, rowLabel + String.format("%02d", number), type));
            }
        }
        for (int number = 1; number <= 6; number++) {
            templates.add(new SeatTemplate("G", number, "G" + String.format("%02d", number), SeatLayoutType.COUPLE));
        }
        return templates;
    }

    private String placeholders(int count) {
        return String.join(",", Collections.nCopies(count, "?"));
    }

    private String positionKey(String rowLabel, int seatNumber) {
        return rowLabel + ":" + seatNumber;
    }

    private void rollbackQuietly(Connection connection) {
        try {
            connection.rollback();
        } catch (SQLException ignored) {
        }
    }

    private enum SeatLayoutType {
        STANDARD("STANDARD", true),
        VIP("VIP", true),
        COUPLE("COUPLE", true),
        EMPTY("STANDARD", false);

        private final String databaseType;
        private final boolean active;

        SeatLayoutType(String databaseType, boolean active) {
            this.databaseType = databaseType;
            this.active = active;
        }

        private String databaseType() {
            return databaseType;
        }

        private boolean active() {
            return active;
        }

        private static SeatLayoutType from(String value) {
            if (value == null || value.isBlank()) {
                throw new AppException(400, "Seat type is required.");
            }
            try {
                return SeatLayoutType.valueOf(value.trim().toUpperCase(Locale.ROOT));
            } catch (IllegalArgumentException exception) {
                throw new AppException(400, "Unknown seat type.");
            }
        }
    }

    private record SeatRow(long id, long auditoriumId, String rowLabel, int seatNumber, Long pairSeatId) {
    }

    private record SeatTemplate(String rowLabel, int seatNumber, String seatLabel, SeatLayoutType type) {
    }
}
