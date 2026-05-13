package com.example.DACN.repository;

import com.example.DACN.entity.Invoice;
import com.example.DACN.entity.Room;
import com.example.DACN.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, Long> {

    // Tìm hóa đơn theo mã hóa đơn
    Optional<Invoice> findByInvoiceCode(String invoiceCode);

    // Chủ trọ xem tất cả hóa đơn mình tạo
    List<Invoice> findByOwner(User owner);

    // Người thuê xem hóa đơn của mình
    List<Invoice> findByTenant(User tenant);

    // Tìm hóa đơn theo phòng
    List<Invoice> findByRoom(Room room);

    // Chủ trọ xem hóa đơn theo ownerId
    List<Invoice> findByOwner_Id(Long ownerId);

    // Người thuê xem hóa đơn theo tenantId
    List<Invoice> findByTenant_Id(Long tenantId);

    // Tìm hóa đơn theo trạng thái: UNPAID, PARTIAL, PAID, OVERDUE, CANCELLED
    List<Invoice> findByStatus(String status);

    // Tìm hóa đơn của một người thuê theo trạng thái
    List<Invoice> findByTenantAndStatus(User tenant, String status);

    // Tìm hóa đơn của một chủ trọ theo trạng thái
    List<Invoice> findByOwnerAndStatus(User owner, String status);

    // Tìm hóa đơn theo tháng/năm
    List<Invoice> findByInvoiceMonthAndInvoiceYear(Integer invoiceMonth, Integer invoiceYear);

    // Kiểm tra phòng đã có hóa đơn tháng/năm chưa
    Optional<Invoice> findByRoomAndInvoiceMonthAndInvoiceYear(Room room, Integer invoiceMonth, Integer invoiceYear);

    // Chủ trọ tìm hóa đơn theo tháng/năm
    List<Invoice> findByOwnerAndInvoiceMonthAndInvoiceYear(User owner, Integer invoiceMonth, Integer invoiceYear);

    // Người thuê tìm hóa đơn theo tháng/năm
    List<Invoice> findByTenantAndInvoiceMonthAndInvoiceYear(User tenant, Integer invoiceMonth, Integer invoiceYear);
}