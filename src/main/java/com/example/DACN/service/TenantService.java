package com.example.DACN.service;

import com.example.DACN.entity.Tenant;
import com.example.DACN.entity.User;
import com.example.DACN.repository.TenantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class TenantService {

    @Autowired
    private TenantRepository tenantRepository;

    public List<Tenant> getAllTenants() {
        return tenantRepository.findAll();
    }

    public Tenant getTenantById(Long id) {
        return tenantRepository.findById(id).orElse(null);
    }

    /**
     * Lấy thông tin Tenant theo User.
     * * @param user Đối tượng User cần tìm.
     * @return Tenant tương ứng hoặc null nếu không tìm thấy.
     */
    public Tenant getTenantByUser(User user) {
        if (user == null || user.getId() == null) {
            return null;
        }
        return tenantRepository.findAll().stream()
                .filter(t -> t.getUser() != null && t.getUser().getId().equals(user.getId()))
                .findFirst()
                .orElse(null);
    }

    public void saveTenant(Tenant tenant) {
        tenantRepository.save(tenant);
    }

    public void deleteTenant(Long id) {
        tenantRepository.deleteById(id);
    }
}