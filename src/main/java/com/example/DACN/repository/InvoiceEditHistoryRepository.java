package com.example.DACN.repository;

import com.example.DACN.entity.Invoice;
import com.example.DACN.entity.InvoiceEditHistory;
import com.example.DACN.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InvoiceEditHistoryRepository extends JpaRepository<InvoiceEditHistory, Long> {

    // Lịch sử chỉnh sửa của một hóa đơn
    List<InvoiceEditHistory> findByInvoice(Invoice invoice);

    // Lịch sử chỉnh sửa theo invoiceId
    List<InvoiceEditHistory> findByInvoice_Id(Long invoiceId);

    // Lịch sử chỉnh sửa bởi một user
    List<InvoiceEditHistory> findByEditedBy(User editedBy);

    // Lịch sử chỉnh sửa bởi userId
    List<InvoiceEditHistory> findByEditedBy_Id(Long editedById);

    // Tìm lịch sử theo field bị sửa
    List<InvoiceEditHistory> findByFieldName(String fieldName);
}