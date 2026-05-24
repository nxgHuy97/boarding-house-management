import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/form_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _roleCode(String role) {
    if (role == 'ADMIN') return 'ADMIN';
    if (role == 'OWNER' ||
        role.contains('CHỦ TRỌ') ||
        role.contains('KHÁCH HÀNG')) {
      return 'OWNER';
    }
    if (role == 'TENANT' || role.contains('NGƯỜI THUÊ')) {
      return 'TENANT';
    }

    return role;
  }

  String _routeByRole(String role) {
    final roleCode = _roleCode(role);

    if (roleCode == 'ADMIN') return '/admin/dashboard';
    if (roleCode == 'OWNER') return '/owner/dashboard';
    if (roleCode == 'TENANT') return '/tenant/dashboard';

    return '/login';
  }

  void _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên đăng nhập và mật khẩu'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 350));

    final user = MockData.users.firstWhere(
      (item) {
        final itemUsername = item['username'] ?? '';
        final itemPassword = item['password'] ?? '';

        return itemUsername == username && itemPassword == password;
      },
      orElse: () => {},
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (user.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tên đăng nhập hoặc mật khẩu không đúng'),
        ),
      );
      return;
    }

    final status = user['status'] ?? 'Hoạt động';

    if (status == 'Đã khóa') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tài khoản đã bị khóa. Vui lòng liên hệ quản trị viên.'),
        ),
      );
      return;
    }

    if (status == 'Chờ duyệt') {
      MockData.currentUsername = user['username'] ?? username;

      Navigator.pushReplacementNamed(context, '/pending');
      return;
    }

    final role = user['role'] ?? '';
    final route = _routeByRole(role);

    MockData.currentUsername = user['username'] ?? username;

    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 980,
            constraints: const BoxConstraints(minHeight: 560),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 22),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 560,
                    padding: const EdgeInsets.all(38),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1E3A8A),
                          Color(0xFF2563EB),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        bottomLeft: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.apartment_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          'Orca',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Hệ thống quản lý phòng trọ dành cho chủ trọ và người thuê.',
                          style: TextStyle(
                            color: Color(0xFFE0E7FF),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const Spacer(),

                        const _FeatureItem(
                          icon: Icons.meeting_room_rounded,
                          title: 'Quản lý phòng trọ',
                          subtitle: 'Theo dõi phòng, người thuê và hợp đồng',
                        ),

                        SizedBox(height: 18),

                        const _FeatureItem(
                          icon: Icons.receipt_long_rounded,
                          title: 'Theo dõi hóa đơn',
                          subtitle: 'Tự động tính tiền phòng, điện nước',
                        ),

                        SizedBox(height: 18),

                        const _FeatureItem(
                          icon: Icons.auto_awesome_rounded,
                          title: 'AI nhắc thanh toán',
                          subtitle: 'Cá nhân hóa thông báo cho từng người thuê',
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 46,
                      vertical: 42,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Nhập tài khoản để tiếp tục sử dụng hệ thống',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 34),

                        FormInput(
                          label: 'Tên đăng nhập',
                          icon: Icons.person_outline_rounded,
                          controller: usernameController,
                        ),

                        const SizedBox(height: 16),

                        FormInput(
                          label: 'Mật khẩu',
                          icon: Icons.lock_outline_rounded,
                          controller: passwordController,
                          obscureText: true,
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFBFDBFE),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF1E3A8A),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Hệ thống sẽ tự nhận diện vai trò từ tài khoản đăng nhập.',
                                  style: TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton(
                            onPressed: isLoading ? null : _login,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Chưa có tài khoản?',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text('Đăng ký Owner'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        const Center(
                          child: Text(
                            'Người thuê không tự đăng ký. Tài khoản người thuê do chủ trọ tạo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFFDCE7FF),
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}