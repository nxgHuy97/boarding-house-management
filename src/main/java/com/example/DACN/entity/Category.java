package com.example.DACN.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List; // QUAN TRỌNG: Cần import cái này để hết lỗi đỏ ở List

@Entity
@Table(name = "categories")
@Data // Tự động tạo Getter, Setter, toString...
@NoArgsConstructor
@AllArgsConstructor
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @ManyToMany
    @JoinTable(
            name = "category_utilities",
            joinColumns = @JoinColumn(name = "category_id"),
            inverseJoinColumns = @JoinColumn(name = "utility_id")
    )
    private List<Utility> utilities;

    // Thêm các trường quy định nhanh (Boolean)
    private boolean hasMezzanine; // Có gác lửng
    private boolean allowPets;    // Cho nuôi thú cưng
    private boolean hasAirConditioner; // Có máy lạnh (Ví dụ thêm)
    private boolean hasBalcony;        // Có ban công (Ví dụ thêm)
}