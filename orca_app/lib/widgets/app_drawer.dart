import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String role;

  const AppDrawer({
    super.key,
    required this.role,
  });

  String get _roleTitle {
    if (role == 'ADMIN') return 'Quản trị viên';
    if (role == 'OWNER') return 'Khách hàng / Chủ trọ';
    if (role == 'TENANT') return 'Người thuê';
    return 'Người dùng';
  }

  IconData get _roleIcon {
    if (role == 'ADMIN') return Icons.admin_panel_settings_rounded;
    if (role == 'OWNER') return Icons.apartment_rounded;
    if (role == 'TENANT') return Icons.person_rounded;
    return Icons.account_circle_rounded;
  }

  List<_DrawerItem> get _items {
    if (role == 'ADMIN') {
      return [
        _DrawerItem(
          title: 'Dashboard',
          icon: Icons.dashboard_rounded,
          route: '/admin/dashboard',
        ),
        _DrawerItem(
          title: 'Quản lý tài khoản',
          icon: Icons.people_alt_rounded,
          route: '/admin/users',
        ),
        _DrawerItem(
          title: 'Phê duyệt Owner',
          icon: Icons.verified_user_rounded,
          route: '/admin/users',
        ),
      ];
    }

    if (role == 'OWNER') {
      return [
        _DrawerItem(
          title: 'Dashboard',
          icon: Icons.dashboard_rounded,
          route: '/owner/dashboard',
        ),
        _DrawerItem(
          title: 'Quản lý phòng',
          icon: Icons.meeting_room_rounded,
          route: '/owner/rooms',
        ),
        _DrawerItem(
          title: 'Thêm người thuê',
          icon: Icons.person_add_alt_1_rounded,
          route: '/owner/tenants/add',
        ),
        _DrawerItem(
          title: 'Quản lý người thuê',
          icon: Icons.people_alt_rounded,
          route: '/owner/tenants',
        ),
        _DrawerItem(
          title: 'Điện nước',
          icon: Icons.speed_rounded,
          route: '/owner/meters',
        ),
        _DrawerItem(
          title: 'Tạo hóa đơn',
          icon: Icons.add_card_rounded,
          route: '/owner/invoices/create',
        ),
        _DrawerItem(
          title: 'Hóa đơn',
          icon: Icons.receipt_long_rounded,
          route: '/owner/invoices',
        ),
        _DrawerItem(
          title: 'Biên lai',
          icon: Icons.payments_rounded,
          route: '/owner/payments',
        ),
        _DrawerItem(
          title: 'AI nhắc thanh toán',
          icon: Icons.auto_awesome_rounded,
          route: '/owner/ai-notifications',
        ),
      ];
    }

    return [
      _DrawerItem(
        title: 'Dashboard',
        icon: Icons.dashboard_rounded,
        route: '/tenant/dashboard',
      ),
      _DrawerItem(
        title: 'Thông tin phòng',
        icon: Icons.meeting_room_rounded,
        route: '/tenant/room-info',
      ),
      _DrawerItem(
        title: 'Hóa đơn của tôi',
        icon: Icons.receipt_long_rounded,
        route: '/tenant/invoices',
      ),
      _DrawerItem(
        title: 'Lịch sử đóng tiền',
        icon: Icons.payments_rounded,
        route: '/tenant/payments',
      ),
      _DrawerItem(
        title: 'Hợp đồng',
        icon: Icons.description_rounded,
        route: '/tenant/contracts',
      ),
      _DrawerItem(
        title: 'Profile',
        icon: Icons.person_rounded,
        route: '/tenant/profile',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      width: 304,
      backgroundColor: const Color(0xFFF8FAFC),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF2563EB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      _roleIcon,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Orca',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _roleTitle,
                    style: const TextStyle(
                      color: Color(0xFFE0E7FF),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  ..._items.map((item) {
                    final isActive = currentRoute == item.route;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: isActive
                            ? const Color(0xFFE0E7FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.pop(context);

                            if (currentRoute != item.route) {
                              Navigator.pushReplacementNamed(
                                context,
                                item.route,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item.icon,
                                  color: isActive
                                      ? const Color(0xFF1E3A8A)
                                      : const Color(0xFF4B5563),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      color: isActive
                                          ? const Color(0xFF1E3A8A)
                                          : const Color(0xFF374151),
                                      fontWeight: isActive
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                if (isActive)
                                  Container(
                                    width: 5,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E3A8A),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Đăng xuất'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  final String title;
  final IconData icon;
  final String route;

  const _DrawerItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}