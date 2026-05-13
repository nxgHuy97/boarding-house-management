package com.example.DACN.service;

import com.example.DACN.entity.Category;
import com.example.DACN.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class CategoryService {
    @Autowired
    private CategoryRepository categoryRepository;

    public List<Category> getAll() { return categoryRepository.findAll(); }

    public void save(Category category) { categoryRepository.save(category); }

    public void delete(Long id) { categoryRepository.deleteById(id); }
}