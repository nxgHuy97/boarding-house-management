package com.example.DACN.service;

import com.example.DACN.entity.Contract;
import com.example.DACN.entity.Invoice;
import com.example.DACN.entity.Room;
import com.example.DACN.entity.User;
import com.example.DACN.repository.InvoiceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final NotificationService notificationService;

    public List<Invoice> findAll() {
        return invoiceRepository.findAll();
    }

    public Invoice findById(Long id) {
        return invoiceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy hóa đơn"));
    }

    public List<Invoice> findByOwner(User owner) {
        return invoiceRepository.findByOwner(owner);
    }

    public List<Invoice> findByTenant(User tenant) {
        return invoiceRepository.findByTenant(tenant);
    }

    public List<Invoice> findByStatus(String status) {
        return invoiceRepository.findByStatus(status);
    }

    public List<Invoice> findByOwnerAndStatus(User owner, String status) {
        return invoiceRepository.findByOwnerAndStatus(owner, status);
    }

    public List<Invoice> findByTenantAndStatus(User tenant, String status) {
        return invoiceRepository.findByTenantAndStatus(tenant, status);
    }

    public List<Invoice> findByMonthAndYear(Integer month, Integer year) {
        return invoiceRepository.findByInvoiceMonthAndInvoiceYear(month, year);
    }

    public Invoice createInvoice(
            Room room,
            User tenant,
            User owner,
            Contract contract,
            Integer month,
            Integer year,
            Double roomPrice,
            Double electricityAmount,
            Double waterAmount,
            Double serviceAmount,
            Double discountAmount,
            Double penaltyAmount,
            LocalDate dueDate,
            String note
    ) {
        boolean exists = invoiceRepository
                .findByRoomAndInvoiceMonthAndInvoiceYear(room, month, year)
                .isPresent();

        if (exists) {
            throw new RuntimeException("Phòng này đã có hóa đơn trong tháng " + month + "/" + year);
        }

        Invoice invoice = new Invoice();
        invoice.setInvoiceCode(generateInvoiceCode());
        invoice.setRoom(room);
        invoice.setTenant(tenant);
        invoice.setOwner(owner);
        invoice.setContract(contract);
        invoice.setInvoiceMonth(month);
        invoice.setInvoiceYear(year);
        invoice.setRoomPrice(roomPrice);
        invoice.setElectricityAmount(electricityAmount);
        invoice.setWaterAmount(waterAmount);
        invoice.setServiceAmount(serviceAmount);
        invoice.setDiscountAmount(discountAmount);
        invoice.setPenaltyAmount(penaltyAmount);
        invoice.setDueDate(dueDate);
        invoice.setNote(note);

        invoice.calculateTotal();

        Invoice savedInvoice = invoiceRepository.save(invoice);

        notificationService.createNotification(
                tenant,
                owner,
                "Hóa đơn mới",
                "Bạn có hóa đơn mới tháng " + month + "/" + year,
                "INVOICE",
                "/tenant/invoices/" + savedInvoice.getId()
        );

        return savedInvoice;
    }

    public Invoice updateInvoice(
            Long invoiceId,
            Double roomPrice,
            Double electricityAmount,
            Double waterAmount,
            Double serviceAmount,
            Double discountAmount,
            Double penaltyAmount,
            LocalDate dueDate,
            String note
    ) {
        Invoice invoice = findById(invoiceId);

        if ("PAID".equalsIgnoreCase(invoice.getStatus())) {
            throw new RuntimeException("Không thể sửa hóa đơn đã thanh toán");
        }

        invoice.setRoomPrice(roomPrice);
        invoice.setElectricityAmount(electricityAmount);
        invoice.setWaterAmount(waterAmount);
        invoice.setServiceAmount(serviceAmount);
        invoice.setDiscountAmount(discountAmount);
        invoice.setPenaltyAmount(penaltyAmount);
        invoice.setDueDate(dueDate);
        invoice.setNote(note);

        invoice.calculateTotal();

        return invoiceRepository.save(invoice);
    }

    public Invoice markAsPaid(Long invoiceId) {
        Invoice invoice = findById(invoiceId);

        invoice.setPaidAmount(invoice.getTotalAmount());
        invoice.setRemainingAmount(0.0);
        invoice.setStatus("PAID");
        invoice.setPaidDate(LocalDate.now());

        Invoice savedInvoice = invoiceRepository.save(invoice);

        notificationService.createNotification(
                invoice.getTenant(),
                invoice.getOwner(),
                "Hóa đơn đã thanh toán",
                "Hóa đơn " + invoice.getInvoiceCode() + " đã được xác nhận thanh toán.",
                "INVOICE",
                "/tenant/invoices/" + invoice.getId()
        );

        return savedInvoice;
    }

    public Invoice addPaymentAmount(Long invoiceId, Double amount) {
        Invoice invoice = findById(invoiceId);

        double currentPaid = invoice.getPaidAmount() == null ? 0.0 : invoice.getPaidAmount();
        invoice.setPaidAmount(currentPaid + amount);

        invoice.calculateTotal();

        if ("PAID".equalsIgnoreCase(invoice.getStatus())) {
            invoice.setPaidDate(LocalDate.now());
        }

        return invoiceRepository.save(invoice);
    }

    public void deleteInvoice(Long id) {
        Invoice invoice = findById(id);

        if ("PAID".equalsIgnoreCase(invoice.getStatus())) {
            throw new RuntimeException("Không thể xóa hóa đơn đã thanh toán");
        }

        invoiceRepository.delete(invoice);
    }

    private String generateInvoiceCode() {
        return "INV-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}