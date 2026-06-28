package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.User;

import java.util.List;
import java.util.Optional;

public interface UserDAO {
    Optional<User> findByEmail(String email);

    Optional<User> findById(long id);

    List<User> findAll(String query);

    void updateLockStatus(long id, boolean locked);

    User create(String fullName, String email, String phone, String passwordHash);
}
