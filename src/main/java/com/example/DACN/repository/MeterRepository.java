package com.example.DACN.repository;

import com.example.DACN.entity.Meter;
import com.example.DACN.entity.Room;
import com.example.DACN.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MeterRepository extends JpaRepository<Meter, Long> {

    // Chủ trọ xem tất cả chỉ số điện nước mình ghi
    List<Meter> findByOwner(User owner);

    // Tìm chỉ số theo phòng
    List<Meter> findByRoom(Room room);

    // Tìm chỉ số theo ownerId
    List<Meter> findByOwner_Id(Long ownerId);

    // Tìm chỉ số theo roomId
    List<Meter> findByRoom_Id(Long roomId);

    // Tìm chỉ số theo tháng/năm
    List<Meter> findByMonthAndYear(Integer month, Integer year);

    // Tìm chỉ số của một phòng trong tháng/năm
    Optional<Meter> findByRoomAndMonthAndYear(Room room, Integer month, Integer year);

    // Chủ trọ tìm chỉ số theo tháng/năm
    List<Meter> findByOwnerAndMonthAndYear(User owner, Integer month, Integer year);

    // Chủ trọ tìm chỉ số của một phòng cụ thể trong tháng/năm
    Optional<Meter> findByOwnerAndRoomAndMonthAndYear(User owner, Room room, Integer month, Integer year);
}