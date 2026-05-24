import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Future<void> _goAndRefresh(String route) async {
    await Navigator.pushNamed(context, route);

    if (!mounted) return;

    setState(() {});
  }

  bool _isOwner(Map<String, String> user) {
    final role = user['role'] ?? '';
    return role == 'OWNER' ||
        role.contains('CHỦ TRỌ') ||
        role.contains('KHÁCH HÀNG');
  }

  bool _isTenant(Map<String, String> user) {
    final role = user['role'] ?? '';
    return role == 'TENANT' || role.contains('NGƯỜI THUÊ');
  }

  bool _isPaidReceipt(Map<String, String> payment) {
    if (payment['statusCode'] == 'paid') return true;
    if (payment['status'] == 'Đã xác nhận') return true;
    if (payment['status'] == 'Đã thanh toán') return true;

    final invoiceCode = payment['invoice'];

    final invoice = MockData.invoices.firstWhere(
      (item) => item['code'] == invoiceCode,
      orElse: () => {},
    );

    return invoice['statusCode'] == 'paid' ||
        invoice['status'] == 'Đã thanh toán';
  }

  @override
  Widget build(BuildContext context) {
    final users = MockData.users;
    final rooms = MockData.rooms;
    final invoices = MockData.invoices;
    final payments = MockData.payments;

    final totalOwners = users.where(_isOwner).length;
    final pendingOwners = users.where((user) {
      return _isOwner(user) && user['status'] == 'Chờ duyệt';
    }).length;

    final totalTenants = users.where(_isTenant).length;
    final totalRooms = rooms.length;
    final totalInvoices = invoices.length;
    final totalReceipts = payments.where(_isPaidReceipt).length;

    return Scaffold(
      drawer: const AppDrawer(role: 'ADMIN'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Tổng quan quản trị',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeHeader(
              name: MockData.currentUsername,
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(
                  title: 'Tổng Owner',
                  value: totalOwners.toString(),
                  icon: Icons.apartment_rounded,
                  color: const Color(0xFF16A34A),
                  onTap: () {
                    _goAndRefresh('/admin/users');
                  },
                ),
                _StatCard(
                  title: 'Owner chờ duyệt',
                  value: pendingOwners.toString(),
                  icon: Icons.pending_actions_rounded,
                  color: const Color(0xFFF97316),
                  onTap: () {
                    _goAndRefresh('/admin/users');
                  },
                ),
                _StatCard(
                  title: 'Tổng Tenant',
                  value: totalTenants.toString(),
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: () {
                    _goAndRefresh('/admin/users');
                  },
                ),
                _StatCard(
                  title: 'Tổng phòng',
                  value: totalRooms.toString(),
                  icon: Icons.meeting_room_rounded,
                  color: const Color(0xFF7C3AED),
                  onTap: () {
                    _goAndRefresh('/admin/rooms');
                  },
                ),
                _StatCard(
                  title: 'Tổng hóa đơn',
                  value: totalInvoices.toString(),
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF0EA5E9),
                ),
                _StatCard(
                  title: 'Tổng biên lai',
                  value: totalReceipts.toString(),
                  icon: Icons.payments_rounded,
                  color: const Color(0xFF059669),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const _SectionTitle(
              title: 'Thao tác nhanh',
              subtitle: 'Admin quản lý tài khoản và theo dõi dữ liệu hệ thống',
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _QuickAction(
                  icon: Icons.people_alt_rounded,
                  title: 'Quản lý tài khoản',
                  onTap: () {
                    _goAndRefresh('/admin/users');
                  },
                ),
                _QuickAction(
                  icon: Icons.apartment_rounded,
                  title: 'Phê duyệt Owner',
                  onTap: () {
                    _goAndRefresh('/admin/users');
                  },
                ),
                _QuickAction(
                  icon: Icons.meeting_room_rounded,
                  title: 'Xem danh sách phòng',
                  onTap: () {
                    _goAndRefresh('/admin/rooms');
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            const _SectionTitle(
              title: 'Tài khoản gần đây',
              subtitle: 'Theo dõi tài khoản trong hệ thống',
            ),

            const SizedBox(height: 12),

            if (users.isEmpty)
              const _EmptyBox(message: 'Chưa có tài khoản nào')
            else
              ...users.take(3).map((user) {
                return _UserCard(user: user);
              }),

            const SizedBox(height: 28),

            const _SectionTitle(
              title: 'Phòng trong hệ thống',
              subtitle: 'Admin chỉ xem thông tin phòng, không chỉnh sửa nghiệp vụ',
            ),

            const SizedBox(height: 12),

            if (rooms.isEmpty)
              const _EmptyBox(message: 'Chưa có phòng nào')
            else
              ...rooms.take(3).map((room) {
                return _RoomCard(room: room);
              }),

            const SizedBox(height: 28),

            const _SectionTitle(
              title: 'Hóa đơn gần đây',
              subtitle: 'Theo dõi nhanh hóa đơn và trạng thái thanh toán',
            ),

            const SizedBox(height: 12),

            if (invoices.isEmpty)
              const _EmptyBox(message: 'Chưa có hóa đơn nào')
            else
              ...invoices.take(3).map((invoice) {
                return _InvoiceCard(invoice: invoice);
              }),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String name;

  const _WelcomeHeader({
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'Quản trị viên' : name;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xin chào,',
                  style: TextStyle(
                    color: Color(0xFFDCE7FF),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Quản lý tài khoản, phê duyệt Owner và theo dõi dữ liệu tổng quan của hệ thống.',
                  style: TextStyle(
                    color: Color(0xFFE0E7FF),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 118,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9CA3AF),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 110,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE0E7FF),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
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

class _UserCard extends StatelessWidget {
  final Map<String, String> user;

  const _UserCard({
    required this.user,
  });

  String _roleText(String role) {
    if (role == 'ADMIN') return 'Quản trị viên';
    if (role == 'OWNER' || role.contains('CHỦ TRỌ') || role.contains('KHÁCH HÀNG')) {
      return 'Chủ trọ';
    }
    if (role == 'TENANT' || role.contains('NGƯỜI THUÊ')) {
      return 'Người thuê';
    }

    return role;
  }

  @override
  Widget build(BuildContext context) {
    final status = user['status'] ?? '';
    final isPending = status == 'Chờ duyệt';
    final isLocked = status == 'Đã khóa';

    Color bgColor;
    Color textColor;

    if (isPending) {
      bgColor = const Color(0xFFFFEDD5);
      textColor = const Color(0xFFF97316);
    } else if (isLocked) {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
    } else {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF16A34A);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFE0E7FF),
            child: Icon(
              Icons.person_rounded,
              color: Color(0xFF1E3A8A),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user['email']} • ${_roleText(user['role'] ?? '')}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Map<String, String> room;

  const _RoomCard({
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    final status = room['status'] ?? 'Trống';

    Color bgColor;
    Color textColor;

    if (status == 'Trống') {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF16A34A);
    } else if (status == 'Bảo trì') {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
    } else {
      bgColor = const Color(0xFFE0E7FF);
      textColor = const Color(0xFF1E3A8A);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFE0E7FF),
            child: Icon(
              Icons.meeting_room_rounded,
              color: Color(0xFF1E3A8A),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${room['area']} • ${room['price']} • ${room['owner']}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Map<String, String> invoice;

  const _InvoiceCard({
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final status = invoice['status'] ?? 'Chưa thanh toán';
    final statusCode = invoice['statusCode'] ?? '';

    Color bgColor;
    Color textColor;

    if (statusCode == 'paid' || status == 'Đã thanh toán') {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF16A34A);
    } else if (statusCode == 'pending' || status == 'Chờ xác nhận') {
      bgColor = const Color(0xFFE0E7FF);
      textColor = const Color(0xFF1E3A8A);
    } else {
      bgColor = const Color(0xFFFFEDD5);
      textColor = const Color(0xFFF97316);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFE0E7FF),
            child: Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF1E3A8A),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${invoice['code']} - ${invoice['room']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${invoice['tenant']} • Tháng ${invoice['month']} • ${invoice['amount']}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String message;

  const _EmptyBox({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}