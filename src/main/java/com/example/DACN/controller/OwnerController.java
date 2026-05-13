package com.example.DACN.controller;

import com.example.DACN.entity.Contract;
import com.example.DACN.entity.Room;
import com.example.DACN.entity.Tenant;
import com.example.DACN.entity.User;
import com.example.DACN.entity.Role;
import com.example.DACN.repository.RoleRepository;
import com.example.DACN.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/owner")
@PreAuthorize("hasRole('OWNER')")
public class OwnerController {

    @Autowired
    private RoomService roomService;

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private UserService userService;

    @Autowired
    private TenantService tenantService;

    @Autowired
    private ContractService contractService;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/dashboard")
    public String ownerDashboard(Model model, @AuthenticationPrincipal UserDetails userDetails) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());
        List<User> pendingUsers = getPendingUsersForOwner(currentUser);

        List<Room> rooms = roomService.getRoomsByOwner(currentUser);

        String motelCode = "Chưa có mã";
        if (!rooms.isEmpty()) {
            String firstCode = rooms.get(0).getRoomCode();
            if (firstCode != null && !firstCode.isEmpty()) {
                motelCode = firstCode;
            } else {
                motelCode = roomService.generateMotelCode(currentUser.getId());
                rooms.get(0).setRoomCode(motelCode);
                roomService.saveRoom(rooms.get(0));
            }
        }

        model.addAttribute("totalRooms", rooms.size());
        model.addAttribute("ownerName", currentUser.getFullName());
        model.addAttribute("motelCode", motelCode);
        model.addAttribute("pendingCount", pendingUsers.size());
        return "owner/dashboard";
    }

    // ==========================================
    // QUẢN LÝ PHÒNG
    // ==========================================

    @GetMapping("/rooms")
    public String myRooms(Model model, @AuthenticationPrincipal UserDetails userDetails) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());
        model.addAttribute("rooms", roomService.getRoomsByOwner(currentUser));
        return "owner/rooms/my_rooms";
    }

    @GetMapping("/rooms/add")
    public String addRoomForm(Model model, @AuthenticationPrincipal UserDetails userDetails) {
        model.addAttribute("room", new Room());
        model.addAttribute("categories", categoryService.getAll());
        return "owner/rooms/add_room";
    }

    @PostMapping("/rooms/save")
    public String saveRoom(@ModelAttribute("room") Room room,
                           @AuthenticationPrincipal UserDetails userDetails,
                           RedirectAttributes ra) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());
        room.setOwner(currentUser);

        if (room.getRoomCode() == null || room.getRoomCode().isEmpty()) {
            room.setRoomCode(roomService.generateMotelCode(currentUser.getId()));
        }

        try {
            roomService.saveRoom(room);
            ra.addFlashAttribute("message", "Đã thêm phòng mới thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/owner/rooms";
    }

    @GetMapping("/rooms/edit/{id}")
    public String editRoomForm(@PathVariable Long id,
                               Model model,
                               @AuthenticationPrincipal UserDetails userDetails,
                               RedirectAttributes ra) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());
        Room room = roomService.getRoomById(id);

        if (room == null || !room.getOwner().getId().equals(currentUser.getId())) {
            ra.addFlashAttribute("error", "Bạn không có quyền chỉnh sửa phòng này!");
            return "redirect:/owner/rooms";
        }

        model.addAttribute("room", room);
        model.addAttribute("categories", categoryService.getAll());
        return "owner/rooms/edit_room";
    }

    @PostMapping("/rooms/update/{id}")
    public String updateRoom(@PathVariable Long id,
                             @ModelAttribute("room") Room roomDetails,
                             @AuthenticationPrincipal UserDetails userDetails,
                             RedirectAttributes ra) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());
        Room existingRoom = roomService.getRoomById(id);

        if (existingRoom == null || !existingRoom.getOwner().getId().equals(currentUser.getId())) {
            ra.addFlashAttribute("error", "Bạn không có quyền sửa phòng này!");
            return "redirect:/owner/rooms";
        }

        existingRoom.setRoomNumber(roomDetails.getRoomNumber());
        existingRoom.setCategory(roomDetails.getCategory());
        existingRoom.setStatus(roomDetails.getStatus());

        roomService.saveRoom(existingRoom);
        ra.addFlashAttribute("message", "Đã cập nhật phòng thành công!");
        return "redirect:/owner/rooms";
    }

    @GetMapping("/rooms/delete/{id}")
    public String deleteRoom(@PathVariable Long id,
                             @AuthenticationPrincipal UserDetails userDetails,
                             RedirectAttributes ra) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());
        Room room = roomService.getRoomById(id);

        if (room == null || !room.getOwner().getId().equals(currentUser.getId())) {
            ra.addFlashAttribute("error", "Bạn không có quyền xóa phòng này!");
        } else {
            try {
                roomService.deleteRoom(id);
                ra.addFlashAttribute("message", "Đã xóa phòng thành công!");
            } catch (Exception e) {
                ra.addFlashAttribute("error", "Không thể xóa phòng!");
            }
        }
        return "redirect:/owner/rooms";
    }

    @GetMapping("/rooms/edit-code/{id}")
    public String editRoomCodeForm(@PathVariable Long id, Model model,
                                   @AuthenticationPrincipal UserDetails userDetails, RedirectAttributes ra) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());
        Room room = roomService.getRoomById(id);

        if (room == null || !room.getOwner().getId().equals(currentUser.getId())) {
            ra.addFlashAttribute("error", "Bạn không có quyền chỉnh sửa phòng này!");
            return "redirect:/owner/rooms";
        }
        model.addAttribute("room", room);
        return "owner/rooms/edit_code";
    }

    @PostMapping("/rooms/update-code/{id}")
    public String updateRoomCode(@PathVariable Long id, @RequestParam("roomCode") String roomCode,
                                 @AuthenticationPrincipal UserDetails userDetails, RedirectAttributes ra) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());
        Room existingRoom = roomService.getRoomById(id);

        if (existingRoom == null || !existingRoom.getOwner().getId().equals(currentUser.getId())) {
            ra.addFlashAttribute("error", "Bạn không có quyền thao tác với phòng này!");
            return "redirect:/owner/rooms";
        }

        try {
            existingRoom.setRoomCode(roomCode);
            roomService.saveRoom(existingRoom);
            ra.addFlashAttribute("message", "Cập nhật mã phòng thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Mã phòng đã tồn tại hoặc có lỗi xảy ra!");
        }
        return "redirect:/owner/rooms";
    }

    // ==========================================
    // QUẢN LÝ NGƯỜI THUÊ ĐÃ ĐƯỢC DUYỆT
    // ==========================================
    @GetMapping("/tenants")
    public String manageTenants(Model model, @AuthenticationPrincipal UserDetails userDetails) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());

        List<User> activeTenants = userService.getAllUsers().stream()
                .filter(u -> "ROLE_TENANT".equals(u.getRole().getName())
                        && "ACTIVE".equalsIgnoreCase(u.getStatus())
                        && u.getOwner() != null
                        && u.getOwner().getId().equals(currentUser.getId()))
                .collect(Collectors.toList());

        model.addAttribute("tenants", activeTenants);
        return "owner/tenants/list";
    }

    @GetMapping("/tenants/add")
    public String addTenantForm(Model model, @AuthenticationPrincipal UserDetails userDetails) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());
        model.addAttribute("tenant", new Tenant());
        // Lấy danh sách các phòng của chủ trọ để gán cho người thuê
        model.addAttribute("rooms", roomService.getRoomsByOwner(currentUser));
        return "owner/tenants/add";
    }

    @GetMapping("/tenants/edit-room/{id}")
    public String editTenantRoomForm(@PathVariable Long id, Model model,
                                     @AuthenticationPrincipal UserDetails userDetails, RedirectAttributes ra) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());

        // Tìm Tenant theo ID (hoặc User ID tùy thuộc vào cách bạn lưu bảng)
        Tenant tenant = tenantService.getTenantById(id);

        if (tenant == null || !tenant.getOwner().getId().equals(currentUser.getId())) {
            ra.addFlashAttribute("error", "Không tìm thấy người thuê hoặc bạn không có quyền!");
            return "redirect:/owner/tenants";
        }

        model.addAttribute("tenant", tenant);
        // Lấy danh sách các phòng của chủ trọ để lựa chọn
        model.addAttribute("rooms", roomService.getRoomsByOwner(currentUser));
        return "owner/tenants/edit_room";
    }

    @PostMapping("/tenants/update-room/{id}")
    public String updateTenantRoom(@PathVariable Long id, @RequestParam("roomId") Long roomId,
                                   RedirectAttributes ra) {
        try {
            Tenant tenant = tenantService.getTenantById(id);
            Room room = roomService.getRoomById(roomId);

            if (tenant != null && room != null) {
                tenant.setRoom(room);
                tenantService.saveTenant(tenant);
                ra.addFlashAttribute("message", "Đã gán phòng cho người thuê thành công!");
            } else {
                ra.addFlashAttribute("error", "Người thuê hoặc phòng không tồn tại!");
            }
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi: " + e.getMessage());
        }
        return "redirect:/owner/tenants";
    }

    @PostMapping("/tenants/save")
    public String saveTenant(@ModelAttribute("tenant") Tenant tenant,
                             @AuthenticationPrincipal UserDetails userDetails,
                             RedirectAttributes ra) {
        try {
            User currentUser = userService.getUserByUsername(userDetails.getUsername());

            // 1. Tạo tài khoản User tự động (dùng SĐT làm username và mật khẩu mặc định 123456)
            User user = new User();
            user.setUsername(tenant.getPhone());
            user.setFullName(tenant.getFullName());
            user.setEmail(tenant.getEmail());
            user.setPassword(passwordEncoder.encode("123456"));
            user.setStatus("ACTIVE");

            Role tenantRole = roleRepository.findByName("ROLE_TENANT");
            user.setRole(tenantRole);
            user.setOwner(currentUser);

            userService.saveUser(user);

            // 2. Gán User vừa tạo vào Entity Tenant
            tenant.setUser(user);
            tenant.setOwner(currentUser);
            tenant.setStatus("ACTIVE");
            tenant.setUsername(tenant.getPhone());

            // 3. Tự động lấy mã dãy trọ của Owner hiện tại gán cho người thuê
            List<Room> rooms = roomService.getRoomsByOwner(currentUser);
            String motelCode = (rooms != null && !rooms.isEmpty()) ? rooms.get(0).getRoomCode() : "MOTEL_DEFAULT";
            tenant.setMotelCode(motelCode);

            tenantService.saveTenant(tenant);

            ra.addFlashAttribute("message", "Thêm người thuê và tạo tài khoản thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi khi thêm người thuê: " + e.getMessage());
        }
        return "redirect:/owner/tenants";
    }

    @GetMapping("/tenants/pending")
    public String listPendingTenants(Model model, @AuthenticationPrincipal UserDetails userDetails) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());
        List<User> pendingUsers = getPendingUsersForOwner(currentUser);

        model.addAttribute("pendingUsers", pendingUsers);
        model.addAttribute("pendingCount", pendingUsers.size());
        return "owner/tenants/pending";
    }

    private List<User> getPendingUsersForOwner(User currentUser) {
        return userService.getPendingUsers().stream()
                .filter(user -> {
                    if (user.getRole() != null && "ROLE_TENANT".equals(user.getRole().getName())) {
                        String userMotelCode = user.getMotelCode();
                        if (userMotelCode != null && !userMotelCode.isEmpty()) {
                            Room room = roomService.getRoomByCode(userMotelCode);
                            return room != null && room.getOwner() != null &&
                                    room.getOwner().getId().equals(currentUser.getId());
                        }
                    }
                    return false;
                })
                .collect(Collectors.toList());
    }

    @GetMapping("/tenants/approve/{userId}")
    public String approveTenant(@PathVariable Long userId, RedirectAttributes ra) {
        User user = userService.getUserById(userId);

        if (user != null && "ROLE_TENANT".equals(user.getRole().getName())) {
            user.setStatus("ACTIVE");
            userService.saveUser(user);

            Tenant tenant = tenantService.getAllTenants().stream()
                    .filter(t -> t.getUser() != null && t.getUser().getId().equals(userId))
                    .findFirst()
                    .orElse(null);

            if (tenant != null) {
                Room room = tenant.getRoom();
                if (room != null) {
                    Contract contract = new Contract();
                    contract.setContractNumber(contractService.generateContractNumber());
                    contract.setRoom(room);
                    contract.setTenant(user);
                    contract.setOwner(room.getOwner());
                    contract.setStartDate(java.time.LocalDate.now());
                    contract.setPrice(3000000.0);
                    contract.setDeposit(1000000.0);
                    contract.setStatus("ACTIVE");

                    contractService.saveContract(contract);
                }
            }
            ra.addFlashAttribute("message", "Đã phê duyệt người thuê và tạo hợp đồng tự động!");
        } else {
            ra.addFlashAttribute("error", "Không tìm thấy người dùng hoặc không phải là khách thuê!");
        }
        return "redirect:/owner/tenants/pending";
    }

    // ==========================================
    // QUẢN LÝ HỢP ĐỒNG
    // ==========================================

    @GetMapping("/contracts")
    public String listContracts(Model model, @AuthenticationPrincipal UserDetails userDetails) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());
        model.addAttribute("contracts", contractService.getContractsByOwnerId(currentUser.getId()));
        return "owner/contracts/list";
    }

    @GetMapping("/contracts/add")
    public String addContractForm(Model model, @AuthenticationPrincipal UserDetails userDetails) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());

        model.addAttribute("contract", new Contract());
        model.addAttribute("rooms", roomService.getRoomsByOwner(currentUser));

        // Nếu bạn dùng entity Tenant để quản lý
        List<Tenant> activeTenants = tenantService.getAllTenants().stream()
                .filter(t -> t.getOwner() != null && t.getOwner().getId().equals(currentUser.getId()))
                .collect(Collectors.toList());

        model.addAttribute("tenants", activeTenants);
        return "owner/contracts/add";
    }

    @PostMapping("/contracts/save")
    public String saveContract(@ModelAttribute("contract") Contract contract,
                               @AuthenticationPrincipal UserDetails userDetails,
                               RedirectAttributes ra) {
        User currentUser = userService.getUserByUsername(userDetails.getUsername());
        contract.setOwner(currentUser);

        try {
            contractService.saveContract(contract);
            ra.addFlashAttribute("message", "Đã tạo hợp đồng thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi: " + e.getMessage());
        }
        return "redirect:/owner/contracts";
    }

    @GetMapping("/contracts/delete/{id}")
    public String deleteContract(@PathVariable Long id, RedirectAttributes ra) {
        try {
            contractService.deleteContract(id);
            ra.addFlashAttribute("message", "Đã xóa hợp đồng thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể xóa hợp đồng!");
        }
        return "redirect:/owner/contracts";
    }

    @GetMapping("/tenants/delete/{id}")
    public String deleteTenant(@PathVariable Long id, RedirectAttributes ra) {
        try {
            User tenantUser = userService.getUserById(id);

            // 1. Xóa các hợp đồng tham chiếu đến user này
            if (tenantUser != null) {
                List<Contract> contracts = contractService.getContractsByOwnerId(tenantUser.getId());
                for (Contract c : contracts) {
                    contractService.deleteContract(c.getId());
                }

                // 2. Xóa các bản ghi liên kết Tenant
                List<Tenant> tenantList = tenantService.getAllTenants().stream()
                        .filter(t -> t.getUser() != null && t.getUser().getId().equals(id))
                        .collect(Collectors.toList());

                for (Tenant t : tenantList) {
                    tenantService.deleteTenant(t.getId());
                }

                // 3. Xóa User
                userService.deleteUser(id);
                ra.addFlashAttribute("message", "Đã xóa người thuê thành công!");
            } else {
                ra.addFlashAttribute("error", "Không tìm thấy người thuê!");
            }
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể xóa người thuê: " + e.getMessage());
        }
        return "redirect:/owner/tenants";
    }
}