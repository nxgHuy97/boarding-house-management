package com.example.DACN.controller;

// Các dòng import cần thiết
import com.example.DACN.service.RoomService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/rooms")
public class RoomController {
    @Autowired
    private RoomService roomService;

    @GetMapping
    public String listRooms(Model model) {
        // Lấy danh sách từ DB qua Service
        model.addAttribute("rooms", roomService.getAllRooms());
        // Trả về file room_management.html
        return "room_management";
    }
}