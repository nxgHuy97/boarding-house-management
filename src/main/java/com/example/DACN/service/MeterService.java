package com.example.DACN.service;

import com.example.DACN.entity.Meter;
import com.example.DACN.entity.Room;
import com.example.DACN.entity.User;
import com.example.DACN.repository.MeterRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MeterService {

    private final MeterRepository meterRepository;

    public List<Meter> findAll() {
        return meterRepository.findAll();
    }

    public Meter findById(Long id) {
        return meterRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy chỉ số điện nước"));
    }

    public List<Meter> findByOwner(User owner) {
        return meterRepository.findByOwner(owner);
    }

    public List<Meter> findByRoom(Room room) {
        return meterRepository.findByRoom(room);
    }

    public List<Meter> findByMonthAndYear(Integer month, Integer year) {
        return meterRepository.findByMonthAndYear(month, year);
    }

    public Meter findByRoomAndMonthAndYear(Room room, Integer month, Integer year) {
        return meterRepository.findByRoomAndMonthAndYear(room, month, year)
                .orElse(null);
    }

    public Meter createMeter(
            Room room,
            User owner,
            Integer month,
            Integer year,
            Double oldElectricity,
            Double newElectricity,
            Double electricityUnitPrice,
            Double oldWater,
            Double newWater,
            Double waterUnitPrice,
            String note
    ) {
        boolean exists = meterRepository
                .findByRoomAndMonthAndYear(room, month, year)
                .isPresent();

        if (exists) {
            throw new RuntimeException("Phòng này đã có chỉ số điện nước tháng " + month + "/" + year);
        }

        Meter meter = new Meter();
        meter.setRoom(room);
        meter.setOwner(owner);
        meter.setMonth(month);
        meter.setYear(year);
        meter.setOldElectricity(oldElectricity);
        meter.setNewElectricity(newElectricity);
        meter.setElectricityUnitPrice(electricityUnitPrice);
        meter.setOldWater(oldWater);
        meter.setNewWater(newWater);
        meter.setWaterUnitPrice(waterUnitPrice);
        meter.setNote(note);

        meter.calculateAmount();

        return meterRepository.save(meter);
    }

    public Meter updateMeter(
            Long meterId,
            Double oldElectricity,
            Double newElectricity,
            Double electricityUnitPrice,
            Double oldWater,
            Double newWater,
            Double waterUnitPrice,
            String note
    ) {
        Meter meter = findById(meterId);

        meter.setOldElectricity(oldElectricity);
        meter.setNewElectricity(newElectricity);
        meter.setElectricityUnitPrice(electricityUnitPrice);
        meter.setOldWater(oldWater);
        meter.setNewWater(newWater);
        meter.setWaterUnitPrice(waterUnitPrice);
        meter.setNote(note);

        meter.calculateAmount();

        return meterRepository.save(meter);
    }

    public void deleteMeter(Long id) {
        Meter meter = findById(id);
        meterRepository.delete(meter);
    }
}