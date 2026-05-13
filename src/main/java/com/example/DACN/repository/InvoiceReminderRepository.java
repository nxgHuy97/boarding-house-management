package com.example.DACN.repository;

import com.example.DACN.entity.Invoice;
import com.example.DACN.entity.InvoiceReminder;
import com.example.DACN.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface InvoiceReminderRepository extends JpaRepository<InvoiceReminder, Long> {

    // Tìm nhắc nhở theo hóa đơn
    List<InvoiceReminder> findByInvoice(Invoice invoice);

    // Người thuê xem nhắc nhở của mình
    List<InvoiceReminder> findByTenant(User tenant);

    // Chủ trọ xem nhắc nhở mình gửi
    List<InvoiceReminder> findByOwner(User owner);

    // Tìm nhắc nhở theo trạng thái: PENDING, SENT, CANCELLED
    List<InvoiceReminder> findByStatus(String status);

    // Tìm nhắc nhở theo ngày
    List<InvoiceReminder> findByReminderDate(LocalDate reminderDate);

    // Tìm nhắc nhở cần gửi trong ngày theo trạng thái
    List<InvoiceReminder> findByReminderDateAndStatus(LocalDate reminderDate, String status);

    // Người thuê xem nhắc nhở theo trạng thái
    List<InvoiceReminder> findByTenantAndStatus(User tenant, String status);

    // Chủ trọ xem nhắc nhở theo trạng thái
    List<InvoiceReminder> findByOwnerAndStatus(User owner, String status);

    // Tìm theo ownerId
    List<InvoiceReminder> findByOwner_Id(Long ownerId);

    // Tìm theo tenantId
    List<InvoiceReminder> findByTenant_Id(Long tenantId);
}