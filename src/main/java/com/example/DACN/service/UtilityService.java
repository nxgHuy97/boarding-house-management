package com.example.DACN.service;

import com.example.DACN.entity.Utility;
import com.example.DACN.repository.UtilityRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class UtilityService {
    @Autowired
    private UtilityRepository utilityRepository;

    public List<Utility> getAll() { return utilityRepository.findAll(); }
    public void save(Utility utility) { utilityRepository.save(utility); }
    public void delete(Long id) { utilityRepository.deleteById(id); }
}