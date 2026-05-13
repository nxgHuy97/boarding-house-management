package com.example.DACN.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

@Entity
@Table(name = "users")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
public class User implements UserDetails {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    private String password;

    private String email;
    private String phone;

    @Column(name = "full_name")
    private String fullName;

    private LocalDateTime createdAt;

    private boolean resetPasswordRequested; // Mặc định là false

    // Trường mới để quản lý việc phê duyệt của Admin
    @Column(name = "status")
    private String status = "PENDING";

    // BỔ SUNG: Trường lưu mã dãy trọ khi User đăng ký
    @Column(name = "motel_code")
    private String motelCode;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "role_id")
    private Role role;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id")
    private User owner; // Liên kết User này với Owner quản lý dãy trọ

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // Trả về role với prefix ROLE_ để Spring Security hiểu đúng
        return List.of(new SimpleGrantedAuthority(role.getName()));
    }

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() {
        return !"LOCKED".equalsIgnoreCase(this.status);
    }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() {
        // Chỉ những người dùng có trạng thái ACTIVE mới được đăng nhập
        return "ACTIVE".equalsIgnoreCase(this.status);
    }

    // CẬP NHẬT: Gán giá trị vào thuộc tính thay vì để trống
    public void setMotelCode(String motelCode) {
        this.motelCode = motelCode;
    }

    public String getMotelCode() {
        return motelCode;
    }
}