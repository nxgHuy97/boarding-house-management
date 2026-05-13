package com.example.DACN.repository;

import com.example.DACN.entity.Room;
import com.example.DACN.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RoomRepository extends JpaRepository<Room, Long> {

    // Tìm tất cả phòng thuộc owner
    List<Room> findByOwner(User owner);

    // Tìm phòng theo trạng thái: AVAILABLE, OCCUPIED, MAINTENANCE
    List<Room> findByStatus(String status);

    // Tìm phòng theo số phòng
    Optional<Room> findByRoomNumber(String roomNumber);

    // Tìm phòng theo mã phòng
    Room findByRoomCode(String roomCode);

    // Tìm phòng theo loại phòng
    List<Room> findByCategoryId(Long categoryId);

    // Tìm phòng theo id owner
    List<Room> findByOwner_Id(Long ownerId);
}