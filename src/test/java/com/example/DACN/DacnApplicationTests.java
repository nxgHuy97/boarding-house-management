package com.example.DACN;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootTest
class DacnApplicationTests {

	@Autowired
	private PasswordEncoder passwordEncoder;

	/**
	 * Test 1: Kiểm tra mật khẩu hiện tại trong Database có khớp với "123456" hay không
	 */
	@Test
	void checkPassword() {
		String rawPassword = "123456";

		// 1. Dán chuỗi băm của owner1 từ MySQL vào đây để kiểm tra
		String encodedInDb = "$2y$10$hKDVYxLefVhv/vtuMhuYp.29y.9S6NqH6s8Bf8tG4Y1A6oK9jF6S2";

		boolean isMatch = passwordEncoder.matches(rawPassword, encodedInDb);

		System.out.println("\n================ KẾT QUẢ KIỂM TRA ================");
		if (isMatch) {
			System.out.println(">>> TRẠNG THÁI: KHỚP! Bạn có thể dùng '123456' để đăng nhập.");
		} else {
			System.out.println(">>> TRẠNG THÁI: KHÔNG KHỚP! Mật khẩu trong DB không phải là 123456.");
		}
		System.out.println("==================================================\n");
	}

	/**
	 * Test 2: Tạo chuỗi băm mới và in sẵn câu lệnh SQL để cập nhật cho owner1
	 */
	@Test
	void generateNewPasswordForOwner() {
		String rawPassword = "123456";
		String newEncodedPassword = passwordEncoder.encode(rawPassword);

		System.out.println("\n================ CẬP NHẬT CHO OWNER1 ================");
		System.out.println("1. Chuỗi mã hóa mới:");
		System.out.println(newEncodedPassword);
		System.out.println("\n2. Câu lệnh SQL để chạy trong MySQL Workbench:");
		System.out.println("UPDATE users SET password = '" + newEncodedPassword + "' WHERE username = 'owner1';");
		System.out.println("====================================================\n");
	}
}