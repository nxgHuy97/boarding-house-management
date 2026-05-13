package com.example.DACN.repository;

import com.example.DACN.entity.InAppNotification;
import com.example.DACN.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InAppNotificationRepository extends JpaRepository<InAppNotification, Long> {

    // Người dùng xem tất cả thông báo của mình
    List<InAppNotification> findByReceiver(User receiver);

    // Người dùng xem thông báo theo receiverId
    List<InAppNotification> findByReceiver_Id(Long receiverId);

    // Người dùng xem thông báo chưa đọc / đã đọc
    List<InAppNotification> findByReceiverAndRead(User receiver, Boolean read);

    // Tìm thông báo chưa đọc / đã đọc theo receiverId
    List<InAppNotification> findByReceiver_IdAndRead(Long receiverId, Boolean read);

    // Tìm thông báo theo loại: INVOICE, PAYMENT, CONTRACT, ROOM, SYSTEM
    List<InAppNotification> findByType(String type);

    // Tìm thông báo của receiver theo loại
    List<InAppNotification> findByReceiverAndType(User receiver, String type);

    // Tìm thông báo do một user gửi
    List<InAppNotification> findBySender(User sender);

    // Tìm thông báo do senderId gửi
    List<InAppNotification> findBySender_Id(Long senderId);
}