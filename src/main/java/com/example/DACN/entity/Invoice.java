package com.example.DACN.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "invoices")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Invoice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Mã hóa đơn, ví dụ: INV-202605-001
    @Column(name = "invoice_code", unique = true, nullable = false)
    private String invoiceCode;

    // Phòng phát sinh hóa đơn
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    // Người thuê nhận hóa đơn
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tenant_id", nullable = false)
    private User tenant;

    // Chủ trọ tạo hóa đơn
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    // Hợp đồng liên quan nếu có
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "contract_id")
    private Contract contract;

    // Tháng/năm hóa đơn
    @Column(name = "invoice_month")
    private Integer invoiceMonth;

    @Column(name = "invoice_year")
    private Integer invoiceYear;

    // Tiền phòng
    @Column(name = "room_price")
    private Double roomPrice = 0.0;

    // Tiền điện
    @Column(name = "electricity_amount")
    private Double electricityAmount = 0.0;

    // Tiền nước
    @Column(name = "water_amount")
    private Double waterAmount = 0.0;

    // Phí dịch vụ khác
    @Column(name = "service_amount")
    private Double serviceAmount = 0.0;

    // Giảm giá nếu có
    @Column(name = "discount_amount")
    private Double discountAmount = 0.0;

    // Phạt nếu trễ hạn hoặc phát sinh
    @Column(name = "penalty_amount")
    private Double penaltyAmount = 0.0;

    // Tổng tiền
    @Column(name = "total_amount")
    private Double totalAmount = 0.0;

    // Số tiền đã thanh toán
    @Column(name = "paid_amount")
    private Double paidAmount = 0.0;

    // Số tiền còn lại
    @Column(name = "remaining_amount")
    private Double remainingAmount = 0.0;

    // UNPAID, PARTIAL, PAID, OVERDUE, CANCELLED
    @Column(name = "status")
    private String status = "UNPAID";

    @Column(name = "due_date")
    private LocalDate dueDate;

    @Column(name = "paid_date")
    private LocalDate paidDate;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();

        if (this.paidAmount == null) this.paidAmount = 0.0;
        if (this.roomPrice == null) this.roomPrice = 0.0;
        if (this.electricityAmount == null) this.electricityAmount = 0.0;
        if (this.waterAmount == null) this.waterAmount = 0.0;
        if (this.serviceAmount == null) this.serviceAmount = 0.0;
        if (this.discountAmount == null) this.discountAmount = 0.0;
        if (this.penaltyAmount == null) this.penaltyAmount = 0.0;

        calculateTotal();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
        calculateTotal();
    }

    public void calculateTotal() {
        this.totalAmount =
                safe(roomPrice)
                        + safe(electricityAmount)
                        + safe(waterAmount)
                        + safe(serviceAmount)
                        + safe(penaltyAmount)
                        - safe(discountAmount);

        this.remainingAmount = safe(totalAmount) - safe(paidAmount);

        if (this.remainingAmount <= 0) {
            this.status = "PAID";
        } else if (safe(paidAmount) > 0) {
            this.status = "PARTIAL";
        } else {
            this.status = "UNPAID";
        }
    }

    private Double safe(Double value) {
        return value == null ? 0.0 : value;
    }
}