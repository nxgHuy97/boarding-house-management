package com.example.DACN.controller;

import com.example.DACN.entity.Meter;
import com.example.DACN.entity.Room;
import com.example.DACN.entity.User;
import com.example.DACN.repository.RoomRepository;
import com.example.DACN.repository.UserRepository;
import com.example.DACN.service.MeterService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Objects;

@Controller
@RequiredArgsConstructor
public class MeterController {

    private final MeterService meterService;
    private final RoomRepository roomRepository;
    private final UserRepository userRepository;

    @GetMapping("/owner/meters")
    public String listMeters(Authentication authentication, Model model) {
        User owner = getCurrentUser(authentication);

        List<Meter> meters = meterService.findByOwner(owner);

        model.addAttribute("meters", meters);

        return "owner/meters/list";
    }

    @GetMapping("/owner/meters/add")
    public String addMeterForm(Authentication authentication, Model model) {
        User owner = getCurrentUser(authentication);

        List<Room> rooms = roomRepository.findByOwner(owner);

        model.addAttribute("rooms", rooms);

        return "owner/meters/add";
    }

    @PostMapping("/owner/meters/add")
    public String addMeter(
            Authentication authentication,
            @RequestParam Long roomId,
            @RequestParam Integer month,
            @RequestParam Integer year,
            @RequestParam Double oldElectricity,
            @RequestParam Double newElectricity,
            @RequestParam Double electricityUnitPrice,
            @RequestParam Double oldWater,
            @RequestParam Double newWater,
            @RequestParam Double waterUnitPrice,
            @RequestParam(required = false) String note,
            RedirectAttributes redirectAttributes
    ) {
        User owner = getCurrentUser(authentication);

        try {
            Room room = roomRepository.findById(roomId)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy phòng"));

            if (room.getOwner() == null || !Objects.equals(room.getOwner().getId(), owner.getId())) {
                throw new RuntimeException("Bạn không có quyền thêm chỉ số cho phòng này");
            }

            meterService.createMeter(
                    room,
                    owner,
                    month,
                    year,
                    oldElectricity,
                    newElectricity,
                    electricityUnitPrice,
                    oldWater,
                    newWater,
                    waterUnitPrice,
                    note
            );

            redirectAttributes.addFlashAttribute("success", "Thêm chỉ số điện nước thành công");

            return "redirect:/owner/meters";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/owner/meters/add";
        }
    }

    @GetMapping("/owner/meters/{id}/history")
    public String meterHistory(
            Authentication authentication,
            @PathVariable Long id,
            Model model
    ) {
        User owner = getCurrentUser(authentication);

        Meter meter = meterService.findById(id);

        if (meter.getOwner() == null || !Objects.equals(meter.getOwner().getId(), owner.getId())) {
            throw new RuntimeException("Bạn không có quyền xem chỉ số này");
        }

        model.addAttribute("meter", meter);

        return "owner/meters/history";
    }

    @GetMapping("/owner/meters/{id}/edit")
    public String editMeterForm(
            Authentication authentication,
            @PathVariable Long id,
            Model model
    ) {
        User owner = getCurrentUser(authentication);

        Meter meter = meterService.findById(id);

        if (meter.getOwner() == null || !Objects.equals(meter.getOwner().getId(), owner.getId())) {
            throw new RuntimeException("Bạn không có quyền sửa chỉ số này");
        }

        model.addAttribute("meter", meter);

        return "owner/meters/edit";
    }

    @PostMapping("/owner/meters/{id}/edit")
    public String editMeter(
            Authentication authentication,
            @PathVariable Long id,
            @RequestParam Double oldElectricity,
            @RequestParam Double newElectricity,
            @RequestParam Double electricityUnitPrice,
            @RequestParam Double oldWater,
            @RequestParam Double newWater,
            @RequestParam Double waterUnitPrice,
            @RequestParam(required = false) String note,
            RedirectAttributes redirectAttributes
    ) {
        User owner = getCurrentUser(authentication);

        try {
            Meter meter = meterService.findById(id);

            if (meter.getOwner() == null || !Objects.equals(meter.getOwner().getId(), owner.getId())) {
                throw new RuntimeException("Bạn không có quyền sửa chỉ số này");
            }

            meterService.updateMeter(
                    id,
                    oldElectricity,
                    newElectricity,
                    electricityUnitPrice,
                    oldWater,
                    newWater,
                    waterUnitPrice,
                    note
            );

            redirectAttributes.addFlashAttribute("success", "Cập nhật chỉ số điện nước thành công");

            return "redirect:/owner/meters";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/owner/meters/" + id + "/edit";
        }
    }

    private User getCurrentUser(Authentication authentication) {
        String username = authentication.getName();

        return userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng đang đăng nhập"));
    }
}