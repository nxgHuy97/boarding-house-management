package com.example.DACN.controller;

import com.example.DACN.entity.Invoice;
import com.example.DACN.entity.Payment;
import com.example.DACN.entity.User;
import com.example.DACN.repository.UserRepository;
import com.example.DACN.service.InvoiceService;
import com.example.DACN.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Objects;

@Controller
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;
    private final InvoiceService invoiceService;
    private final UserRepository userRepository;

    // =========================================================
    // OWNER - DANH SÁCH TẤT CẢ PAYMENT
    // =========================================================

    @GetMapping("/owner/payments")
    public String ownerPayments(Authentication authentication, Model model) {
        User owner = getCurrentUser(authentication);

        List<Payment> payments = paymentService.findByOwner(owner);

        model.addAttribute("payments", payments);

        return "owner/payments/list";
    }

    // =========================================================
    // OWNER - DUYỆT PAYMENT
    // =========================================================

    @PostMapping("/owner/payments/{id}/approve")
    public String approvePayment(
            Authentication authentication,
            @PathVariable Long id,
            RedirectAttributes redirectAttributes
    ) {
        User owner = getCurrentUser(authentication);

        try {
            Payment payment = paymentService.findById(id);

            checkOwnerPermission(payment, owner);

            paymentService.approvePayment(id, owner);

            redirectAttributes.addFlashAttribute("success", "Đã duyệt thanh toán thành công");

            return "redirect:/owner/payments";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/owner/payments";
        }
    }

    // =========================================================
    // OWNER - TỪ CHỐI PAYMENT
    // =========================================================

    @PostMapping("/owner/payments/{id}/reject")
    public String rejectPayment(
            Authentication authentication,
            @PathVariable Long id,
            @RequestParam(required = false) String reason,
            RedirectAttributes redirectAttributes
    ) {
        User owner = getCurrentUser(authentication);

        try {
            Payment payment = paymentService.findById(id);

            checkOwnerPermission(payment, owner);

            paymentService.rejectPayment(id, owner, reason);

            redirectAttributes.addFlashAttribute("success", "Đã từ chối thanh toán");

            return "redirect:/owner/payments";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/owner/payments";
        }
    }

    // =========================================================
    // TENANT - DANH SÁCH PAYMENT CỦA TÔI
    // =========================================================

    @GetMapping("/tenant/payments")
    public String myPayments(Authentication authentication, Model model) {
        User tenant = getCurrentUser(authentication);

        List<Payment> payments = paymentService.findByTenant(tenant);

        model.addAttribute("payments", payments);

        return "tenant/payments/my_payments";
    }

    // =========================================================
    // TENANT - FORM GỬI PAYMENT
    // =========================================================

    @GetMapping("/tenant/payments/create")
    public String createPaymentForm(
            Authentication authentication,
            @RequestParam Long invoiceId,
            Model model
    ) {
        User tenant = getCurrentUser(authentication);

        Invoice invoice = invoiceService.findById(invoiceId);

        checkTenantPermission(invoice, tenant);

        if ("PAID".equalsIgnoreCase(invoice.getStatus())) {
            throw new RuntimeException("Hóa đơn này đã thanh toán xong");
        }

        model.addAttribute("invoice", invoice);

        return "tenant/payments/create";
    }

    // =========================================================
    // TENANT - XỬ LÝ GỬI PAYMENT
    // =========================================================

    @PostMapping("/tenant/payments/create")
    public String createPayment(
            Authentication authentication,
            @RequestParam Long invoiceId,
            @RequestParam Double amount,
            @RequestParam String method,
            @RequestParam(required = false) String transactionCode,
            @RequestParam(required = false) String proofImage,
            @RequestParam(required = false) String note,
            RedirectAttributes redirectAttributes
    ) {
        User tenant = getCurrentUser(authentication);

        try {
            Invoice invoice = invoiceService.findById(invoiceId);

            checkTenantPermission(invoice, tenant);

            if ("PAID".equalsIgnoreCase(invoice.getStatus())) {
                throw new RuntimeException("Hóa đơn này đã thanh toán xong");
            }

            if (amount == null || amount <= 0) {
                throw new RuntimeException("Số tiền thanh toán phải lớn hơn 0");
            }

            if (amount > invoice.getRemainingAmount()) {
                throw new RuntimeException("Số tiền thanh toán không được lớn hơn số tiền còn lại");
            }

            paymentService.createPayment(
                    invoice,
                    tenant,
                    invoice.getOwner(),
                    amount,
                    method,
                    transactionCode,
                    proofImage,
                    note
            );

            redirectAttributes.addFlashAttribute(
                    "success",
                    "Đã gửi yêu cầu thanh toán. Vui lòng chờ chủ trọ xác nhận."
            );

            return "redirect:/tenant/payments";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/tenant/payments/create?invoiceId=" + invoiceId;
        }
    }

    // =========================================================
    // HELPER
    // =========================================================

    private User getCurrentUser(Authentication authentication) {
        String username = authentication.getName();

        return userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng đang đăng nhập"));
    }

    private void checkTenantPermission(Invoice invoice, User tenant) {
        if (invoice.getTenant() == null || !Objects.equals(invoice.getTenant().getId(), tenant.getId())) {
            throw new RuntimeException("Bạn không có quyền thanh toán hóa đơn này");
        }
    }

    private void checkOwnerPermission(Payment payment, User owner) {
        if (payment.getOwner() == null || !Objects.equals(payment.getOwner().getId(), owner.getId())) {
            throw new RuntimeException("Bạn không có quyền xử lý thanh toán này");
        }
    }
}