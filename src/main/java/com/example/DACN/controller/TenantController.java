package com.example.DACN.controller;

import com.example.DACN.entity.Contract;
import com.example.DACN.entity.Room;
import com.example.DACN.entity.User;
import com.example.DACN.repository.ContractRepository;
import com.example.DACN.repository.RoomRepository;
import com.example.DACN.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/tenant")
@RequiredArgsConstructor
public class TenantController {

    private final RoomRepository roomRepository;
    private final ContractRepository contractRepository;
    private final UserRepository userRepository;

    // Trang dashboard người thuê
    @GetMapping("/dashboard")
    public String dashboard(Authentication authentication, Model model) {
        User currentUser = getCurrentUser(authentication);

        List<Contract> contracts = contractRepository.findByTenant(currentUser);

        model.addAttribute("user", currentUser);
        model.addAttribute("contracts", contracts);

        return "tenant/dashboard";
    }

    // Danh sách phòng còn trống
    @GetMapping("/rooms")
    public String rooms(Model model) {
        List<Room> rooms = roomRepository.findByStatus("AVAILABLE");

        model.addAttribute("rooms", rooms);

        return "tenant/rooms";
    }

    // Chi tiết phòng
    @GetMapping("/rooms/{id}")
    public String roomDetail(@PathVariable Long id, Model model) {
        Room room = roomRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy phòng"));

        model.addAttribute("room", room);

        return "tenant/room_detail";
    }

    // Hợp đồng của người thuê đang đăng nhập
    @GetMapping("/contracts")
    public String contracts(Authentication authentication, Model model) {
        User currentUser = getCurrentUser(authentication);

        List<Contract> contracts = contractRepository.findByTenant(currentUser);

        model.addAttribute("user", currentUser);
        model.addAttribute("contracts", contracts);

        return "tenant/contracts";
    }

    // Thông tin cá nhân người thuê
    @GetMapping("/profile")
    public String profile(Authentication authentication, Model model) {
        User currentUser = getCurrentUser(authentication);

        model.addAttribute("user", currentUser);

        return "tenant/profile";
    }

    // Lấy user hiện tại từ username đăng nhập
    private User getCurrentUser(Authentication authentication) {
        String username = authentication.getName();

        return userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng đang đăng nhập"));
    }
}