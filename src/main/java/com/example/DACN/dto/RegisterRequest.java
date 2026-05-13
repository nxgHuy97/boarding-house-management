package com.example.DACN.dto;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter // Dùng cái này cho gọn, không cần viết tay Getter/Setter nữa em nhé
public class RegisterRequest {
    private String username;
    private String password;
    private String email;
    private String phone;
    private String fullName; // Thêm dòng này để hết lỗi đỏ ở AuthController!
    private Long roleId;     // Dùng ID để nhận giá trị từ thẻ <select> trong HTML
}