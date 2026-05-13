package com.example.DACN.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "rooms")
@Data
public class Room {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String roomNumber; // Số phòng (Ví dụ: P101, P102)

    // BỔ SUNG: Cho phép mỗi phòng/dãy trọ có thể dùng chung 1 mã phê duyệt (roomCode)
    @Column(name = "room_code", nullable = true)
    private String roomCode;

    @Column(columnDefinition = "TEXT")
    private String description; // Ghi chú hoặc mô tả đặc điểm phòng

    private Double price;       // Giá thuê hàng tháng

    private Double area;        // Diện tích phòng (m2)

    // Trạng thái quản lý nội bộ:
    // AVAILABLE (Trống), OCCUPIED (Đã có người ở), MAINTENANCE (Đang bảo trì)
    private String status;

    @ManyToOne
    @JoinColumn(name = "category_id")
    private Category category; // Liên kết với loại phòng (Phòng đơn, phòng đôi...)

    @ManyToOne
    @JoinColumn(name = "owner_id")
    private User owner;

    private LocalDateTime createdAt = LocalDateTime.now();

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (status == null) {
            status = "AVAILABLE"; // Mặc định phòng mới tạo là phòng trống
        }
    }
}