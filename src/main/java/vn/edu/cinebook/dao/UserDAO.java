package vn.edu.cinebook.dao;

import vn.edu.cinebook.model.User;

import java.util.Optional;

public interface UserDAO {
    Optional<User> findByEmail(String email);

    Optional<User> findById(long id);

    User create(String fullName, String email, String phone, String passwordHash);
}
