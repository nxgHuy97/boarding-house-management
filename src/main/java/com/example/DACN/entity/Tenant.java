package com.example.DACN.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "tenants")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
public class Tenant {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String fullName;
    private String email;
    private String phone;
    private String username;
    private String password;

    // Trạng thái phê duyệt (PENDING, ACTIVE, REJECTED)
    @Column(name = "status")
    private String status = "PENDING";

    // Mã dãy trọ người thuê đăng ký vào
    @Column(name = "motel_code")
    private String motelCode;

    // Liên kết trực tiếp tới Owner quản lý dãy trọ này
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id")
    private User owner;

    // Liên kết với phòng trọ (nếu có)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id")
    private Room room;

    // Bổ sung liên kết với User (Khắc phục lỗi getUser() trong Controller)
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}