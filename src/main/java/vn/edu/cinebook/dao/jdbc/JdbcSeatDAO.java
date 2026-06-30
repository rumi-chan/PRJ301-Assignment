package vn.edu.cinebook.dao.jdbc;

import vn.edu.cinebook.dao.SeatDAO;
import vn.edu.cinebook.model.*;
import vn.edu.cinebook.util.Database;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class JdbcSeatDAO implements SeatDAO {

    @Override
    public List<Seat> getSeatsByAuditorium(long auditoriumId) {
        String sql = "SELECT * FROM seats WHERE auditorium_id = ? ORDER BY row_label, seat_number";
        List<Seat> seats = new ArrayList<>();
        
        try (Connection con = Database.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, auditoriumId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    seats.add(mapRowToSeat(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("DATABASE ERROR: Lỗi khi truy vấn ghế phòng " + auditoriumId);
            e.printStackTrace();
        }
        return seats;
    }

    private Seat mapRowToSeat(ResultSet rs) throws SQLException {
        long seatId = rs.getLong("seat_id");
        long auditoriumId = rs.getLong("auditorium_id");
        String rowLabel = rs.getString("row_label");
        int seatNumber = rs.getInt("seat_number");
        String seatLabel = rs.getString("seat_label");
        
        String typeStr = rs.getString("seat_type");
        SeatType type = (typeStr != null) ? SeatType.valueOf(typeStr.toUpperCase()) : SeatType.STANDARD;
        
        Long pairSeatId = (Long) rs.getObject("pair_seat_id");
        
        SeatAvailability availability = (rs.getInt("is_active") == 1) ? SeatAvailability.AVAILABLE : SeatAvailability.UNAVAILABLE;

        return new Seat(
                seatId,
                auditoriumId,
                rowLabel,
                seatNumber,
                seatLabel,
                type,
                pairSeatId,
                java.math.BigDecimal.ZERO,
                availability
        );
    }
    
    @Override
    public List<Seat> findByAuditoriumId(long auditoriumId) { return getSeatsByAuditorium(auditoriumId); }

    @Override
    public void updateSeatType(long id, String type) {
        boolean isActive = true;
        String dbType = type.toUpperCase();
        if ("EMPTY".equals(dbType)) {
            isActive = false;
            dbType = "STANDARD";
        }
        String sql = "UPDATE seats SET seat_type = ?, is_active = ? WHERE seat_id = ?";
        try (Connection con = Database.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, dbType);
            ps.setInt(2, isActive ? 1 : 0);
            ps.setLong(3, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void insert(Seat s) {
        String sql = "INSERT INTO seats (auditorium_id, row_label, seat_number, seat_label, seat_type, is_active, is_accessible) VALUES (?, ?, ?, ?, ?, 1, 0)";
        try (Connection con = Database.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, s.getAuditoriumId());
            ps.setString(2, s.getRowLabel());
            ps.setInt(3, s.getSeatNumber());
            ps.setString(4, s.getLabel());
            ps.setString(5, s.getType().name());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void insertCoupleSeats(long auditoriumId, int pairIndex) {
        int firstSeatNum = pairIndex * 2 - 1;
        int secondSeatNum = pairIndex * 2;
        String row = "G";
        
        String sql1 = "INSERT INTO seats (auditorium_id, row_label, seat_number, seat_label, seat_type, is_active) VALUES (?, ?, ?, ?, 'COUPLE', 1)";
        String sql2 = "INSERT INTO seats (auditorium_id, row_label, seat_number, seat_label, seat_type, is_active) VALUES (?, ?, ?, ?, 'COUPLE', 1)";
        
        try (Connection con = Database.getConnection(); 
             PreparedStatement ps1 = con.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
             PreparedStatement ps2 = con.prepareStatement(sql2, Statement.RETURN_GENERATED_KEYS)) {
             
            ps1.setLong(1, auditoriumId);
            ps1.setString(2, row);
            ps1.setInt(3, firstSeatNum);
            ps1.setString(4, row + String.format("%02d", firstSeatNum));
            ps1.executeUpdate();
            
            long seat1Id = 0;
            try (ResultSet rs = ps1.getGeneratedKeys()) {
                if (rs.next()) seat1Id = rs.getLong(1);
            }
            
            ps2.setLong(1, auditoriumId);
            ps2.setString(2, row);
            ps2.setInt(3, secondSeatNum);
            ps2.setString(4, row + String.format("%02d", secondSeatNum));
            ps2.executeUpdate();
            
            long seat2Id = 0;
            try (ResultSet rs = ps2.getGeneratedKeys()) {
                if (rs.next()) seat2Id = rs.getLong(1);
            }
            
            String linkSql = "UPDATE seats SET pair_seat_id = ? WHERE seat_id = ?";
            try (PreparedStatement psLink = con.prepareStatement(linkSql)) {
                psLink.setLong(1, seat2Id);
                psLink.setLong(2, seat1Id);
                psLink.executeUpdate();
                
                psLink.setLong(1, seat1Id);
                psLink.setLong(2, seat2Id);
                psLink.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    @Override
    public void deleteAllSeats(long auditoriumId) {
        String sqlNullify = "UPDATE seats SET pair_seat_id = NULL WHERE auditorium_id = ?";
        String sqlDelete = "DELETE FROM seats WHERE auditorium_id = ?";
        try (Connection con = Database.getConnection(); 
             PreparedStatement ps1 = con.prepareStatement(sqlNullify);
             PreparedStatement ps2 = con.prepareStatement(sqlDelete)) {
             
            ps1.setLong(1, auditoriumId);
            ps1.executeUpdate();
            
            ps2.setLong(1, auditoriumId);
            ps2.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
