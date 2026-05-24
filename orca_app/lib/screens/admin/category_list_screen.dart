import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(role: 'ADMIN'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Danh mục phòng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
      ),
      body: Center(
        child: Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFFE0E7FF),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF1E3A8A),
                    size: 38,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Chức năng này đã được thay đổi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Admin không còn quản lý loại phòng hoặc danh mục phòng. '
                  'Loại phòng, giá thuê, nội thất, điều hòa và tiện ích sẽ do Chủ trọ cấu hình trực tiếp khi thêm hoặc sửa phòng.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin/dashboard',
                      );
                    },
                    icon: const Icon(Icons.dashboard_rounded),
                    label: const Text('Quay về Dashboard'),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin/users',
                      );
                    },
                    icon: const Icon(Icons.people_alt_rounded),
                    label: const Text('Quản lý tài khoản'),
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