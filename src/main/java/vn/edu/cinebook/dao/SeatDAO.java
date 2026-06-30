package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.Seat;
import java.util.List;

public interface SeatDAO {
    List<Seat> findByAuditoriumId(long auditoriumId);

    void updateSeatType(long seatId, String newType);

    void insert(Seat seat);

    void insertCoupleSeats(long auditoriumId, int pairIndex);
    
    List<Seat> getSeatsByAuditorium(long auditoriumId);
    
    void deleteAllSeats(long auditoriumId);
}
