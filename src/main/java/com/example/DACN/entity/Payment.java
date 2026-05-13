package com.example.DACN.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "payments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Mã thanh toán, ví dụ: PAY-202605-001
    @Column(name = "payment_code", unique = true, nullable = false)
    private String paymentCode;

    // Hóa đơn được thanh toán
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "invoice_id", nullable = false)
    private Invoice invoice;

    // Người thuê thanh toán
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tenant_id", nullable = false)
    private User tenant;

    // Chủ trọ nhận tiền
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @Column(name = "amount", nullable = false)
    private Double amount;

    // CASH, BANK_TRANSFER, MOMO, VNPAY
    @Column(name = "method")
    private String method = "CASH";

    // PENDING, APPROVED, REJECTED
    @Column(name = "status")
    private String status = "PENDING";

    // Mã giao dịch nếu chuyển khoản hoặc thanh toán online
    @Column(name = "transaction_code")
    private String transactionCode;

    // Ảnh minh chứng chuyển khoản nếu có
    @Column(name = "proof_image")
    private String proofImage;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    // Người duyệt thanh toán
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "approved_by")
    private User approvedBy;

    @Column(name = "approved_at")
    private LocalDateTime approvedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();

        if (this.paidAt == null) {
            this.paidAt = LocalDateTime.now();
        }

        if (this.status == null) {
            this.status = "PENDING";
        }

        if (this.method == null) {
            this.method = "CASH";
        }
    }
}