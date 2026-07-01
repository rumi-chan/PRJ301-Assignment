package cinebook.dao;

import cinebook.model.Seat;
import java.util.List;
import java.util.Map;

public interface SeatDAO {
    List<Seat> findByAuditoriumId(long auditoriumId);

    void updateSeatType(long seatId, String newType);

    void updateSeatTypes(Map<Long, String> updates);

    void insert(Seat seat);

    void insertCoupleSeats(long auditoriumId, int pairIndex);

    List<Seat> getSeatsByAuditorium(long auditoriumId);

    void deleteAllSeats(long auditoriumId);

    void resetToDefaultLayout(long auditoriumId);
}
