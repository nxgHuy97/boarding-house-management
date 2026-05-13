package com.example.DACN.repository;

import com.example.DACN.entity.Invoice;
import com.example.DACN.entity.Payment;
import com.example.DACN.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {

    // Tìm thanh toán theo mã
    Optional<Payment> findByPaymentCode(String paymentCode);

    // Tìm thanh toán theo hóa đơn
    List<Payment> findByInvoice(Invoice invoice);

    // Người thuê xem các thanh toán của mình
    List<Payment> findByTenant(User tenant);

    // Chủ trọ xem các thanh toán mình nhận
    List<Payment> findByOwner(User owner);

    // Tìm thanh toán theo trạng thái: PENDING, APPROVED, REJECTED
    List<Payment> findByStatus(String status);

    // Người thuê xem thanh toán theo trạng thái
    List<Payment> findByTenantAndStatus(User tenant, String status);

    // Chủ trọ xem thanh toán theo trạng thái
    List<Payment> findByOwnerAndStatus(User owner, String status);

    // Tìm thanh toán theo tenantId
    List<Payment> findByTenant_Id(Long tenantId);

    // Tìm thanh toán theo ownerId
    List<Payment> findByOwner_Id(Long ownerId);

    // Tìm thanh toán theo invoiceId
    List<Payment> findByInvoice_Id(Long invoiceId);
}