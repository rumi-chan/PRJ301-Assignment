package cinebook.dao;

import cinebook.model.Auditorium;
import java.util.List;
import java.util.Optional;

public interface AuditoriumDAO {
    List<Auditorium> findAll();

    Optional<Auditorium> findById(long id);

    boolean insert(Auditorium auditorium);

    boolean update(Auditorium auditorium);

    boolean delete(long id);
}
