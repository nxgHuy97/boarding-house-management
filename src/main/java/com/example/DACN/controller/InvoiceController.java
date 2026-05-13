package com.example.DACN.controller;

import com.example.DACN.entity.Contract;
import com.example.DACN.entity.Invoice;
import com.example.DACN.entity.Room;
import com.example.DACN.entity.User;
import com.example.DACN.repository.ContractRepository;
import com.example.DACN.repository.RoomRepository;
import com.example.DACN.repository.UserRepository;
import com.example.DACN.service.InvoiceService;
import com.example.DACN.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

@Controller
@RequiredArgsConstructor
public class InvoiceController {

    private final InvoiceService invoiceService;
    private final PaymentService paymentService;
    private final RoomRepository roomRepository;
    private final ContractRepository contractRepository;
    private final UserRepository userRepository;

    // ===================== OWNER - DANH SÁCH HÓA ĐƠN =====================

    @GetMapping("/owner/invoices")
    public String ownerInvoices(Authentication authentication, Model model) {
        User owner = getCurrentUser(authentication);

        List<Invoice> invoices = invoiceService.findByOwner(owner);

        model.addAttribute("invoices", invoices);

        return "owner/invoices/list";
    }

    // ===================== OWNER - FORM TẠO HÓA ĐƠN =====================

    @GetMapping("/owner/invoices/create")
    public String createInvoiceForm(Authentication authentication, Model model) {
        User owner = getCurrentUser(authentication);

        List<Room> rooms = roomRepository.findByOwner(owner);

        model.addAttribute("rooms", rooms);

        return "owner/invoices/create";
    }

    // ===================== OWNER - XỬ LÝ TẠO HÓA ĐƠN =====================

    @PostMapping("/owner/invoices/create")
    public String createInvoice(
            Authentication authentication,
            @RequestParam Long roomId,
            @RequestParam Integer month,
            @RequestParam Integer year,
            @RequestParam Double roomPrice,
            @RequestParam(defaultValue = "0") Double electricityAmount,
            @RequestParam(defaultValue = "0") Double waterAmount,
            @RequestParam(defaultValue = "0") Double serviceAmount,
            @RequestParam(defaultValue = "0") Double discountAmount,
            @RequestParam(defaultValue = "0") Double penaltyAmount,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dueDate,
            @RequestParam(required = false) String note,
            RedirectAttributes redirectAttributes
    ) {
        User owner = getCurrentUser(authentication);

        try {
            Room room = roomRepository.findById(roomId)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy phòng"));

            if (room.getOwner() == null || !Objects.equals(room.getOwner().getId(), owner.getId())) {
                throw new RuntimeException("Bạn không có quyền tạo hóa đơn cho phòng này");
            }

            Contract contract = contractRepository.findFirstByRoomAndStatus(room, "ACTIVE")
                    .orElseThrow(() -> new RuntimeException("Phòng này chưa có hợp đồng ACTIVE"));

            User tenant = contract.getTenant();

            invoiceService.createInvoice(
                    room,
                    tenant,
                    owner,
                    contract,
                    month,
                    year,
                    roomPrice,
                    electricityAmount,
                    waterAmount,
                    serviceAmount,
                    discountAmount,
                    penaltyAmount,
                    dueDate,
                    note
            );

            redirectAttributes.addFlashAttribute("success", "Tạo hóa đơn thành công");

            return "redirect:/owner/invoices";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/owner/invoices/create";
        }
    }

    // ===================== OWNER - CHI TIẾT HÓA ĐƠN =====================

    @GetMapping("/owner/invoices/{id}")
    public String ownerInvoiceDetail(
            Authentication authentication,
            @PathVariable Long id,
            Model model
    ) {
        User owner = getCurrentUser(authentication);
        Invoice invoice = invoiceService.findById(id);

        checkOwnerPermission(invoice, owner);

        model.addAttribute("invoice", invoice);
        model.addAttribute("payments", paymentService.findByInvoice(invoice));

        return "owner/invoices/detail";
    }

    // ===================== OWNER - FORM XÁC NHẬN THANH TOÁN =====================

    @GetMapping("/owner/invoices/{id}/mark-paid")
    public String markPaidForm(
            Authentication authentication,
            @PathVariable Long id,
            Model model
    ) {
        User owner = getCurrentUser(authentication);
        Invoice invoice = invoiceService.findById(id);

        checkOwnerPermission(invoice, owner);

        model.addAttribute("invoice", invoice);

        return "owner/invoices/mark-paid";
    }

    // ===================== OWNER - XỬ LÝ XÁC NHẬN THANH TOÁN =====================

    @PostMapping("/owner/invoices/{id}/mark-paid")
    public String markPaid(
            Authentication authentication,
            @PathVariable Long id,
            RedirectAttributes redirectAttributes
    ) {
        User owner = getCurrentUser(authentication);

        try {
            Invoice invoice = invoiceService.findById(id);

            checkOwnerPermission(invoice, owner);

            invoiceService.markAsPaid(id);

            redirectAttributes.addFlashAttribute("success", "Đã xác nhận hóa đơn thanh toán thành công");

            return "redirect:/owner/invoices";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/owner/invoices";
        }
    }

    // ===================== TENANT - DANH SÁCH HÓA ĐƠN =====================

    @GetMapping("/tenant/invoices")
    public String tenantInvoices(Authentication authentication, Model model) {
        User tenant = getCurrentUser(authentication);

        List<Invoice> invoices = invoiceService.findByTenant(tenant);

        model.addAttribute("invoices", invoices);

        return "tenant/invoices/my_invoices";
    }

    // ===================== TENANT - CHI TIẾT HÓA ĐƠN =====================

    @GetMapping("/tenant/invoices/{id}")
    public String tenantInvoiceDetail(
            Authentication authentication,
            @PathVariable Long id,
            Model model
    ) {
        User tenant = getCurrentUser(authentication);
        Invoice invoice = invoiceService.findById(id);

        checkTenantPermission(invoice, tenant);

        model.addAttribute("invoice", invoice);
        model.addAttribute("payments", paymentService.findByInvoice(invoice));

        return "tenant/invoices/detail";
    }

    // ===================== HELPER =====================

    private User getCurrentUser(Authentication authentication) {
        String username = authentication.getName();

        return userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng đang đăng nhập"));
    }

    private void checkOwnerPermission(Invoice invoice, User owner) {
        if (invoice.getOwner() == null || !Objects.equals(invoice.getOwner().getId(), owner.getId())) {
            throw new RuntimeException("Bạn không có quyền truy cập hóa đơn này");
        }
    }

    private void checkTenantPermission(Invoice invoice, User tenant) {
        if (invoice.getTenant() == null || !Objects.equals(invoice.getTenant().getId(), tenant.getId())) {
            throw new RuntimeException("Bạn không có quyền xem hóa đơn này");
        }
    }
}