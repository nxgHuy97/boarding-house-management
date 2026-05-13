package com.example.DACN.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "utilities")
@Data
public class Utility {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;

    private String icon; // Lưu class icon của Bootstrap (VD: bi-wifi)
}