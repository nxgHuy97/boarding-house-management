package com.example.DACN.service;

import com.example.DACN.entity.Invoice;
import com.example.DACN.entity.Payment;
import com.example.DACN.entity.User;
import com.example.DACN.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final InvoiceService invoiceService;
    private final NotificationService notificationService;

    public List<Payment> findAll() {
        return paymentRepository.findAll();
    }

    public Payment findById(Long id) {
        return paymentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thanh toán"));
    }

    public List<Payment> findByTenant(User tenant) {
        return paymentRepository.findByTenant(tenant);
    }

    public List<Payment> findByOwner(User owner) {
        return paymentRepository.findByOwner(owner);
    }

    public List<Payment> findByInvoice(Invoice invoice) {
        return paymentRepository.findByInvoice(invoice);
    }

    public List<Payment> findByStatus(String status) {
        return paymentRepository.findByStatus(status);
    }

    public List<Payment> findByTenantAndStatus(User tenant, String status) {
        return paymentRepository.findByTenantAndStatus(tenant, status);
    }

    public List<Payment> findByOwnerAndStatus(User owner, String status) {
        return paymentRepository.findByOwnerAndStatus(owner, status);
    }

    public Payment createPayment(
            Invoice invoice,
            User tenant,
            User owner,
            Double amount,
            String method,
            String transactionCode,
            String proofImage,
            String note
    ) {
        if ("PAID".equalsIgnoreCase(invoice.getStatus())) {
            throw new RuntimeException("Hóa đơn này đã thanh toán xong");
        }

        if (amount == null || amount <= 0) {
            throw new RuntimeException("Số tiền thanh toán phải lớn hơn 0");
        }

        Payment payment = new Payment();
        payment.setPaymentCode(generatePaymentCode());
        payment.setInvoice(invoice);
        payment.setTenant(tenant);
        payment.setOwner(owner);
        payment.setAmount(amount);
        payment.setMethod(method);
        payment.setTransactionCode(transactionCode);
        payment.setProofImage(proofImage);
        payment.setNote(note);
        payment.setStatus("PENDING");
        payment.setPaidAt(LocalDateTime.now());

        Payment savedPayment = paymentRepository.save(payment);

        notificationService.createNotification(
                owner,
                tenant,
                "Thanh toán mới",
                "Người thuê " + tenant.getUsername() + " vừa gửi yêu cầu thanh toán hóa đơn " + invoice.getInvoiceCode(),
                "PAYMENT",
                "/owner/invoices/" + invoice.getId()
        );

        return savedPayment;
    }

    public Payment approvePayment(Long paymentId, User approvedBy) {
        Payment payment = findById(paymentId);

        if (!"PENDING".equalsIgnoreCase(payment.getStatus())) {
            throw new RuntimeException("Thanh toán này không còn ở trạng thái chờ duyệt");
        }

        payment.setStatus("APPROVED");
        payment.setApprovedBy(approvedBy);
        payment.setApprovedAt(LocalDateTime.now());

        Payment savedPayment = paymentRepository.save(payment);

        invoiceService.addPaymentAmount(payment.getInvoice().getId(), payment.getAmount());

        notificationService.createNotification(
                payment.getTenant(),
                payment.getOwner(),
                "Thanh toán đã được duyệt",
                "Thanh toán " + payment.getPaymentCode() + " đã được chủ trọ xác nhận.",
                "PAYMENT",
                "/tenant/invoices/" + payment.getInvoice().getId()
        );

        return savedPayment;
    }

    public Payment rejectPayment(Long paymentId, User approvedBy, String reason) {
        Payment payment = findById(paymentId);

        if (!"PENDING".equalsIgnoreCase(payment.getStatus())) {
            throw new RuntimeException("Thanh toán này không còn ở trạng thái chờ duyệt");
        }

        payment.setStatus("REJECTED");
        payment.setApprovedBy(approvedBy);
        payment.setApprovedAt(LocalDateTime.now());

        if (reason != null && !reason.isBlank()) {
            payment.setNote(payment.getNote() + "\nLý do từ chối: " + reason);
        }

        Payment savedPayment = paymentRepository.save(payment);

        notificationService.createNotification(
                payment.getTenant(),
                payment.getOwner(),
                "Thanh toán bị từ chối",
                "Thanh toán " + payment.getPaymentCode() + " đã bị từ chối.",
                "PAYMENT",
                "/tenant/invoices/" + payment.getInvoice().getId()
        );

        return savedPayment;
    }

    public void deletePayment(Long id) {
        Payment payment = findById(id);

        if ("APPROVED".equalsIgnoreCase(payment.getStatus())) {
            throw new RuntimeException("Không thể xóa thanh toán đã duyệt");
        }

        paymentRepository.delete(payment);
    }

    private String generatePaymentCode() {
        return "PAY-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}