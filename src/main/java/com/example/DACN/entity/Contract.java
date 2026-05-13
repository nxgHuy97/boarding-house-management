package com.example.DACN.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "contracts")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
public class Contract {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "contract_number", unique = true, nullable = false)
    private String contractNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    // Lưu ý: Nếu bạn dùng Tenant thay vì User, hãy đổi lại thành Tenant
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tenant_id", nullable = false)
    private User tenant;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @Column(name = "start_date")
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @Column(name = "price", nullable = false)
    private Double price;

    // Đã thêm trường deposit (tiền cọc) và phương thức get/set chuẩn
    @Column(name = "deposit", nullable = false)
    private Double deposit;

    @Column(name = "status", nullable = false)
    private String status = "ACTIVE"; // ACTIVE, TERMINATED

    // --- Các phương thức bổ sung ---

    // Getter cho deposit
    public Double getDeposit() {
        return deposit;
    }

    // Setter cho deposit
    public void setDeposit(Double deposit) {
        this.deposit = deposit;
    }
}