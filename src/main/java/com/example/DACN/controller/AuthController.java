package com.example.DACN.controller;

import com.example.DACN.dto.RegisterRequest;
import com.example.DACN.entity.Role;
import com.example.DACN.entity.Room;
import com.example.DACN.entity.Tenant;
import com.example.DACN.entity.User;
import com.example.DACN.repository.RoleRepository;
import com.example.DACN.service.RoomService;
import com.example.DACN.service.TenantService;
import com.example.DACN.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private RoomService roomService;

    @Autowired
    private TenantService tenantService;

    @GetMapping("/login")
    public String showLoginForm() {
        return "auth/login";
    }

    @GetMapping("/register")
    public String showRegisterForm(Model model) {
        model.addAttribute("registerRequest", new RegisterRequest());
        return "auth/register";
    }

    @PostMapping("/register")
    public String registerUser(@ModelAttribute("registerRequest") RegisterRequest registerRequest,
                               @RequestParam(value = "roomCode", required = false) String roomCode,
                               RedirectAttributes redirectAttributes) {
        try {
            User user = new User();
            user.setUsername(registerRequest.getUsername());
            user.setPassword(registerRequest.getPassword());
            user.setFullName(registerRequest.getFullName());
            user.setEmail(registerRequest.getEmail());
            user.setPhone(registerRequest.getPhone());
            user.setStatus("PENDING");
            user.setCreatedAt(java.time.LocalDateTime.now());

            if (registerRequest.getRoleId() == null) {
                redirectAttributes.addFlashAttribute("error", "Vui lòng chọn vai trò!");
                return "redirect:/auth/register";
            }

            Role role = roleRepository.findById(registerRequest.getRoleId()).orElse(null);

            if (role == null) {
                redirectAttributes.addFlashAttribute("error", "Vai trò không hợp lệ!");
                return "redirect:/auth/register";
            }

            user.setRole(role);

            // Xử lý đăng ký Người thuê
            if ("ROLE_TENANT".equals(role.getName())) {
                if (roomCode == null || roomCode.trim().isEmpty()) {
                    redirectAttributes.addFlashAttribute("error", "Vui lòng nhập mã phòng/mã dãy trọ để xác thực!");
                    return "redirect:/auth/register";
                }

                Room room = roomService.getRoomByCode(roomCode);
                if (room == null) {
                    redirectAttributes.addFlashAttribute("error", "Mã phòng/dãy trọ không tồn tại trong hệ thống!");
                    return "redirect:/auth/register";
                }

                user.setMotelCode(roomCode);
                user.setOwner(room.getOwner());

                userService.createUser(user);

                Tenant tenant = new Tenant();
                tenant.setFullName(user.getFullName());
                tenant.setUsername(user.getUsername());
                tenant.setEmail(user.getEmail());
                tenant.setPhone(user.getPhone());
                tenant.setMotelCode(roomCode);
                tenant.setOwner(room.getOwner());
                tenant.setRoom(room);

                if (tenantService != null) {
                    tenantService.saveTenant(tenant);
                }

                return "redirect:/auth/pending";
            }

            // Xử lý đăng ký Chủ trọ
            if ("ROLE_OWNER".equals(role.getName())) {
                userService.createUser(user);
                return "redirect:/auth/pending";
            }

            redirectAttributes.addFlashAttribute("error", "Vai trò không được hỗ trợ!");
            return "redirect:/auth/register";

        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Lỗi: " + e.getMessage());
            return "redirect:/auth/register";
        }
    }

    @PostMapping("/forgot-password")
    public String handleForgotPassword(@RequestParam String username, RedirectAttributes ra) {
        User user = userService.getUserByUsername(username);
        if (user != null) {
            user.setResetPasswordRequested(true);
            userService.updateUser(user);
            ra.addFlashAttribute("message", "Yêu cầu đã được gửi. Vui lòng liên hệ quản lý để nhận mật khẩu mới.");
        } else {
            ra.addFlashAttribute("error", "Tên đăng nhập không tồn tại!");
        }
        return "redirect:/auth/login";
    }

    @GetMapping("/pending")
    public String showPendingPage() {
        return "auth/pending";
    }
}