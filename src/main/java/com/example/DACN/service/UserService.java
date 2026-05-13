package com.example.DACN.service;

import com.example.DACN.entity.User;
import com.example.DACN.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    // Lấy danh sách người dùng chưa được phê duyệt (Sử dụng cho trang Pending)
    public List<User> getPendingUsers() {
        return userRepository.findAll().stream()
                .filter(user -> "PENDING".equals(user.getStatus()))
                .collect(Collectors.toList());
    }

    public User getUserById(Long id) {
        return userRepository.findById(id).orElse(null);
    }

    public User getUserByUsername(String username) {
        return userRepository.findByUsername(username).orElse(null);
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public void createUser(User user) {
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        userRepository.save(user);
    }

    public void updateUser(User user) {
        userRepository.save(user);
    }

    // BỔ SUNG: Hàm saveUser() để đồng bộ với các Controller
    public void saveUser(User user) {
        userRepository.save(user);
    }

    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    // CẬP NHẬT: Hàm Reset mật khẩu
    public void resetPassword(Long userId, String newPassword) {
        User user = userRepository.findById(userId).orElse(null);
        if (user != null) {
            // 1. Mã hóa mật khẩu mới
            user.setPassword(passwordEncoder.encode(newPassword));

            // 2. Đánh dấu là đã xử lý xong yêu cầu reset
            user.setResetPasswordRequested(false);

            userRepository.save(user);
        }
    }
}