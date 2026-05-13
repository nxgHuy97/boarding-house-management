package com.example.DACN.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "meters")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Meter {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Phòng được ghi chỉ số
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    // Chủ trọ ghi chỉ số
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @Column(name = "month")
    private Integer month;

    @Column(name = "year")
    private Integer year;

    // Chỉ số điện cũ
    @Column(name = "old_electricity")
    private Double oldElectricity = 0.0;

    // Chỉ số điện mới
    @Column(name = "new_electricity")
    private Double newElectricity = 0.0;

    // Số điện đã dùng
    @Column(name = "electricity_used")
    private Double electricityUsed = 0.0;

    // Đơn giá điện
    @Column(name = "electricity_unit_price")
    private Double electricityUnitPrice = 0.0;

    // Thành tiền điện
    @Column(name = "electricity_amount")
    private Double electricityAmount = 0.0;

    // Chỉ số nước cũ
    @Column(name = "old_water")
    private Double oldWater = 0.0;

    // Chỉ số nước mới
    @Column(name = "new_water")
    private Double newWater = 0.0;

    // Số nước đã dùng
    @Column(name = "water_used")
    private Double waterUsed = 0.0;

    // Đơn giá nước
    @Column(name = "water_unit_price")
    private Double waterUnitPrice = 0.0;

    // Thành tiền nước
    @Column(name = "water_amount")
    private Double waterAmount = 0.0;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        calculateAmount();
    }

    @PreUpdate
    protected void onUpdate() {
        calculateAmount();
    }

    public void calculateAmount() {
        this.electricityUsed = safe(newElectricity) - safe(oldElectricity);
        this.waterUsed = safe(newWater) - safe(oldWater);

        if (this.electricityUsed < 0) this.electricityUsed = 0.0;
        if (this.waterUsed < 0) this.waterUsed = 0.0;

        this.electricityAmount = this.electricityUsed * safe(electricityUnitPrice);
        this.waterAmount = this.waterUsed * safe(waterUnitPrice);
    }

    private Double safe(Double value) {
        return value == null ? 0.0 : value;
    }
}