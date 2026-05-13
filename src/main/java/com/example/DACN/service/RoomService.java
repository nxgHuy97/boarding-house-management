package com.example.DACN.service;

import com.example.DACN.entity.Room;
import com.example.DACN.entity.User;
import com.example.DACN.repository.RoomRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class RoomService {

    @Autowired
    private RoomRepository roomRepository;

    // 1. Lấy toàn bộ danh sách phòng (Dùng cho Admin giám sát hệ thống)
    public List<Room> getAllRooms() {
        return roomRepository.findAll();
    }

    // 2. Lấy danh sách phòng theo chủ sở hữu (Owner) - Tham số User
    public List<Room> getRoomsByOwner(User owner) {
        return roomRepository.findByOwner(owner);
    }

    // Lấy danh sách phòng theo ID của Owner
    public List<Room> getRoomsByOwnerId(Long ownerId) {
        return roomRepository.findByOwner_Id(ownerId);
    }

    // 3. Tìm phòng theo ID
    public Room getRoomById(Long id) {
        return roomRepository.findById(id).orElse(null);
    }

    // BỔ SUNG: Tìm phòng theo roomCode
    public Room getRoomByCode(String roomCode) {
        return roomRepository.findByRoomCode(roomCode);
    }

    // BỔ SUNG: Tự động tạo mã dãy trọ theo quy chuẩn M[OwnerID]_[4_Ky_Tu_Ngau_Nhien]
    public String generateMotelCode(Long ownerId) {
        String randomSuffix = UUID.randomUUID().toString().substring(0, 4).toUpperCase();
        return "M" + ownerId + "_" + randomSuffix;
    }

    // 4. Lưu hoặc cập nhật thông tin phòng
    public void saveRoom(Room room) {
        // Kiểm tra trùng số phòng khi thêm mới
        if (room.getId() == null) {
            Optional<Room> existingRoom = roomRepository.findByRoomNumber(room.getRoomNumber());
            if (existingRoom.isPresent()) {
                throw new RuntimeException("Số phòng " + room.getRoomNumber() + " đã tồn tại!");
            }
        }
        roomRepository.save(room);
    }

    // 5. Xóa phòng
    public void deleteRoom(Long id) {
        roomRepository.deleteById(id);
    }

    // 6. Cập nhật trạng thái quản lý (AVAILABLE, OCCUPIED, MAINTENANCE)
    public void updateStatus(Long id, String status) {
        Optional<Room> optionalRoom = roomRepository.findById(id);
        if (optionalRoom.isPresent()) {
            Room room = optionalRoom.get();
            room.setStatus(status);
            roomRepository.save(room);
        }
    }

    // 7. Tìm phòng theo số phòng
    public Room getRoomByNumber(String roomNumber) {
        return roomRepository.findByRoomNumber(roomNumber).orElse(null);
    }
}