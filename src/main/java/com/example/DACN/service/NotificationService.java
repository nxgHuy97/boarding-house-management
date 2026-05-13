package com.example.DACN.service;

import com.example.DACN.entity.InAppNotification;
import com.example.DACN.entity.User;
import com.example.DACN.repository.InAppNotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final InAppNotificationRepository notificationRepository;

    public List<InAppNotification> findAll() {
        return notificationRepository.findAll();
    }

    public InAppNotification findById(Long id) {
        return notificationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông báo"));
    }

    public List<InAppNotification> findByReceiver(User receiver) {
        return notificationRepository.findByReceiver(receiver);
    }

    public List<InAppNotification> findUnreadByReceiver(User receiver) {
        return notificationRepository.findByReceiverAndRead(receiver, false);
    }

    public List<InAppNotification> findReadByReceiver(User receiver) {
        return notificationRepository.findByReceiverAndRead(receiver, true);
    }

    public List<InAppNotification> findByType(String type) {
        return notificationRepository.findByType(type);
    }

    public InAppNotification createNotification(
            User receiver,
            User sender,
            String title,
            String message,
            String type,
            String targetUrl
    ) {
        InAppNotification notification = new InAppNotification();
        notification.setReceiver(receiver);
        notification.setSender(sender);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setType(type);
        notification.setTargetUrl(targetUrl);
        notification.setRead(false);

        return notificationRepository.save(notification);
    }

    public InAppNotification markAsRead(Long id) {
        InAppNotification notification = findById(id);
        notification.markAsRead();

        return notificationRepository.save(notification);
    }

    public void markAllAsRead(User receiver) {
        List<InAppNotification> unreadNotifications = findUnreadByReceiver(receiver);

        for (InAppNotification notification : unreadNotifications) {
            notification.markAsRead();
        }

        notificationRepository.saveAll(unreadNotifications);
    }

    public void deleteNotification(Long id) {
        InAppNotification notification = findById(id);
        notificationRepository.delete(notification);
    }

    public void deleteAllByReceiver(User receiver) {
        List<InAppNotification> notifications = findByReceiver(receiver);
        notificationRepository.deleteAll(notifications);
    }
}