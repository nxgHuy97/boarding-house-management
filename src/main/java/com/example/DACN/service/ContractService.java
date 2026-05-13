package com.example.DACN.service;

import com.example.DACN.entity.Contract;
import com.example.DACN.repository.ContractRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class ContractService {

    @Autowired
    private ContractRepository contractRepository;

    public List<Contract> getContractsByOwnerId(Long ownerId) {
        return contractRepository.findByRoom_Owner_Id(ownerId);
    }

    public void saveContract(Contract contract) {
        // Tự động tạo mã hợp đồng nếu chưa có hoặc để trống
        if (contract.getContractNumber() == null || contract.getContractNumber().isEmpty()) {
            contract.setContractNumber(generateContractNumber());
        }
        contractRepository.save(contract);
    }

    public Contract getContractById(Long id) {
        return contractRepository.findById(id).orElse(null);
    }

    public void deleteContract(Long id) {
        contractRepository.deleteById(id);
    }

    public String generateContractNumber() {
        // Tạo mã hợp đồng tự động, ví dụ: HD_xxxxxx (6 ký tự ngẫu nhiên)
        return "HD_" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();
    }
}