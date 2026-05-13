package com.example.DACN.controller;

import com.example.DACN.entity.Category;
import com.example.DACN.entity.Utility;
import com.example.DACN.entity.User;
import com.example.DACN.entity.Room;
import com.example.DACN.service.CategoryService;
import com.example.DACN.service.UtilityService;
import com.example.DACN.service.UserService;
import com.example.DACN.service.RoomService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    @Autowired
    private UserService userService;

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private UtilityService utilityService;

    @Autowired
    private RoomService roomService;

    // ==========================================
    // 1. DASHBOARD TỔNG QUAN
    // ==========================================
    @GetMapping("/dashboard")
    public String adminDashboard(Model model) {
        List<User> allUsers = userService.getAllUsers();

        long pendingCount = allUsers.stream()
                .filter(u -> "PENDING".equals(u.getStatus())).count();

        long resetRequestCount = allUsers.stream()
                .filter(User::isResetPasswordRequested).count();

        model.addAttribute("totalUsers", allUsers.size());
        model.addAttribute("pendingCount", pendingCount);
        model.addAttribute("resetRequestCount", resetRequestCount);
        model.addAttribute("totalRooms", roomService.getAllRooms().size());

        return "admin/dashboard";
    }

    // ==========================================
    // 2. PHÊ DUYỆT TÀI KHOẢN (PENDING)
    // ==========================================
    @GetMapping("/users/pending")
    public String listPendingUsers(Model model) {
        List<User> pendingUsers = userService.getAllUsers().stream()
                .filter(u -> "PENDING".equals(u.getStatus()))
                .collect(Collectors.toList());

        model.addAttribute("users", pendingUsers);
        return "admin/users/pending_list";
    }

    @PostMapping("/users/approve/{id}")
    public String approveUser(@PathVariable Long id, RedirectAttributes ra) {
        User user = userService.getUserById(id);
        if (user != null) {
            user.setStatus("ACTIVE");
            userService.updateUser(user);

            // Tự động cấp mã dãy trọ nếu là chủ trọ (OWNER) chưa có mã dãy trọ
            if ("ROLE_OWNER".equals(user.getRole().getName())) {
                List<Room> rooms = roomService.getRoomsByOwnerId(user.getId());
                if (rooms.isEmpty()) {
                    Room newRoom = new Room();
                    newRoom.setOwner(user);
                    newRoom.setRoomNumber("000"); // Phòng mặc định
                    newRoom.setStatus("AVAILABLE");
                    newRoom.setRoomCode(roomService.generateMotelCode(user.getId()));
                    roomService.saveRoom(newRoom);
                } else {
                    Room firstRoom = rooms.get(0);
                    if (firstRoom.getRoomCode() == null || firstRoom.getRoomCode().isEmpty()) {
                        firstRoom.setRoomCode(roomService.generateMotelCode(user.getId()));
                        roomService.saveRoom(firstRoom);
                    }
                }
            }
            ra.addFlashAttribute("message", "Đã phê duyệt tài khoản: " + user.getUsername());
        }
        return "redirect:/admin/users/pending";
    }

    @PostMapping("/users/reject/{id}")
    public String rejectUser(@PathVariable Long id, RedirectAttributes ra) {
        User user = userService.getUserById(id);
        if (user != null) {
            userService.deleteUser(id);
            ra.addFlashAttribute("message", "Đã từ chối và xóa tài khoản: " + user.getUsername());
        }
        return "redirect:/admin/users/pending";
    }

    // ==========================================
    // 3. QUẢN LÝ TOÀN BỘ THÀNH VIÊN & RESET PASS
    // ==========================================
    @GetMapping("/users/all")
    public String listAllUsers(Model model) {
        model.addAttribute("users", userService.getAllUsers());
        return "admin/users/all_users";
    }

    @PostMapping("/users/delete/{id}")
    public String deleteUser(@PathVariable Long id, RedirectAttributes ra) {
        User user = userService.getUserById(id);
        if (user != null) {
            if ("ADMIN".equals(user.getRole().getName())) {
                ra.addFlashAttribute("error", "Không thể xóa tài khoản Admin quản trị!");
            } else {
                try {
                    userService.deleteUser(id);
                    ra.addFlashAttribute("message", "Đã xóa vĩnh viễn tài khoản: " + user.getUsername());
                } catch (Exception e) {
                    ra.addFlashAttribute("error", "Lỗi: Tài khoản này đã có dữ liệu phòng, không thể xóa!");
                }
            }
        }
        return "redirect:/admin/users/all";
    }

    @PostMapping("/users/reset-password/{id}")
    public String resetPassword(@PathVariable Long id, RedirectAttributes ra) {
        User user = userService.getUserById(id);
        if (user != null) {
            userService.resetPassword(id, "123456");
            ra.addFlashAttribute("message", "Đã đặt lại mật khẩu cho " + user.getUsername() + " về mặc định (123456)");
        }
        return "redirect:/admin/users/all";
    }

    // ==========================================
    // 3.1. QUẢN LÝ MÃ DÃY TRỌ (CỦA CHỦ TRỌ - OWNER)
    // ==========================================
    @GetMapping("/owners")
    public String manageOwners(Model model) {
        List<User> owners = userService.getAllUsers().stream()
                .filter(u -> u.getRole() != null && "ROLE_OWNER".equals(u.getRole().getName()))
                .collect(Collectors.toList());

        model.addAttribute("owners", owners);
        return "admin/manage_owners";
    }

    @PostMapping("/owners/update-code/{id}")
    public String updateOwnerMotelCode(@PathVariable Long id,
                                       @RequestParam("motelCode") String motelCode,
                                       RedirectAttributes ra) {
        User owner = userService.getUserById(id);
        if (owner != null && "ROLE_OWNER".equals(owner.getRole().getName())) {
            List<Room> rooms = roomService.getRoomsByOwnerId(owner.getId());

            if (!rooms.isEmpty()) {
                Room room = rooms.get(0);
                room.setRoomCode(motelCode);
                roomService.saveRoom(room);
                ra.addFlashAttribute("message", "Cập nhật mã dãy trọ thành công!");
            } else {
                ra.addFlashAttribute("error", "Chủ trọ này chưa có phòng nào, không thể cập nhật mã!");
            }
        } else {
            ra.addFlashAttribute("error", "Không tìm thấy chủ trọ hoặc không đúng phân quyền!");
        }
        return "redirect:/admin/owners";
    }

    // ==========================================
    // 4. QUẢN LÝ LOẠI PHÒNG (CATEGORY)
    // ==========================================
    @GetMapping("/categories")
    public String listCategories(Model model) {
        model.addAttribute("categories", categoryService.getAll());
        model.addAttribute("newCategory", new Category());
        model.addAttribute("allUtilities", utilityService.getAll());
        return "admin/categories/category_list";
    }

    @PostMapping("/categories/save")
    public String saveCategory(@ModelAttribute("newCategory") Category category, RedirectAttributes ra) {
        categoryService.save(category);
        ra.addFlashAttribute("message", "Lưu loại phòng thành công!");
        return "redirect:/admin/categories";
    }

    @GetMapping("/categories/delete/{id}")
    public String deleteCategory(@PathVariable Long id, RedirectAttributes ra) {
        try {
            categoryService.delete(id);
            ra.addFlashAttribute("message", "Đã xóa loại phòng!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể xóa (dữ liệu đang được sử dụng)!");
        }
        return "redirect:/admin/categories";
    }

    // ==========================================
    // 5. QUẢN LÝ TIỆN ÍCH (UTILITY)
    // ==========================================
    @GetMapping("/utilities")
    public String listUtilities(Model model) {
        model.addAttribute("utilities", utilityService.getAll());
        model.addAttribute("newUtility", new Utility());
        return "admin/utilities/utility_list";
    }

    @PostMapping("/utilities/save")
    public String saveUtility(@ModelAttribute("newUtility") Utility utility, RedirectAttributes ra) {
        utilityService.save(utility);
        ra.addFlashAttribute("message", "Đã cập nhật tiện ích!");
        return "redirect:/admin/utilities";
    }

    @GetMapping("/utilities/delete/{id}")
    public String deleteUtility(@PathVariable Long id, RedirectAttributes ra) {
        try {
            utilityService.delete(id);
            ra.addFlashAttribute("message", "Đã xóa tiện ích!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể xóa tiện ích!");
        }
        return "redirect:/admin/utilities";
    }

    // ==========================================
    // 6. GIÁM SÁT HỆ THỐNG PHÒNG (READ-ONLY)
    // ==========================================
    @GetMapping("/rooms")
    public String listRooms(Model model) {
        model.addAttribute("rooms", roomService.getAllRooms());
        return "admin/rooms/room_list";
    }
}