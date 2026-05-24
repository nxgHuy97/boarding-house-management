import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  Future<void> _goAndRefresh(String route) async {
    await Navigator.pushNamed(context, route);

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final rooms = MockData.rooms;
    final tenants = MockData.tenants;
    final invoices = MockData.invoices;
    final payments = MockData.payments;

    final waitingPayments = payments
        .where((payment) => payment['status'] == 'Chờ xác nhận')
        .length;

    return Scaffold(
      drawer: const AppDrawer(role: 'OWNER'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Tổng quan chủ trọ',
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
                  title: 'Tổng số phòng',
                  value: rooms.length.toString(),
                  icon: Icons.meeting_room_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: () {
                    _goAndRefresh('/owner/rooms');
                  },
                ),
                _StatCard(
                  title: 'Người thuê',
                  value: tenants.length.toString(),
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF16A34A),
                  onTap: () {
                    _goAndRefresh('/owner/tenants');
                  },
                ),
                _StatCard(
                  title: 'Hóa đơn',
                  value: invoices.length.toString(),
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFFF97316),
                  onTap: () {
                    _goAndRefresh('/owner/invoices');
                  },
                ),
                _StatCard(
                  title: 'Chờ xác nhận',
                  value: waitingPayments.toString(),
                  icon: Icons.payments_rounded,
                  color: const Color(0xFF7C3AED),
                  onTap: () {
                    _goAndRefresh('/owner/payments');
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            const _SectionTitle(
              title: 'Thao tác nhanh',
              subtitle: 'Các chức năng chủ trọ thường dùng',
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _QuickAction(
                  icon: Icons.add_home_rounded,
                  title: 'Thêm phòng',
                  onTap: () {
                    _goAndRefresh('/owner/rooms/add');
                  },
                ),
                _QuickAction(
                  icon: Icons.person_add_rounded,
                  title: 'Thêm người thuê',
                  onTap: () {
                    _goAndRefresh('/owner/tenants/add');
                  },
                ),
                _QuickAction(
                  icon: Icons.receipt_long_rounded,
                  title: 'Tạo hóa đơn',
                  onTap: () {
                    _goAndRefresh('/owner/invoices/create');
                  },
                ),
                _QuickAction(
                  icon: Icons.speed_rounded,
                  title: 'Nhập điện nước',
                  onTap: () {
                    _goAndRefresh('/owner/meters/add');
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            const _SectionTitle(
              title: 'Phòng gần đây',
              subtitle: 'Tình trạng các phòng trong hệ thống',
            ),

            const SizedBox(height: 12),

            if (rooms.isEmpty)
              const _EmptyBox(message: 'Chưa có phòng nào')
            else
              ...rooms.take(4).map((room) {
                return _RoomCard(room: room);
              }),

            const SizedBox(height: 28),

            const _SectionTitle(
              title: 'Hóa đơn gần đây',
              subtitle: 'Theo dõi trạng thái hóa đơn',
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
    final displayName = name.trim().isEmpty ? 'Khách hàng / Chủ trọ' : name;

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
              Icons.apartment_rounded,
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
                  'Quản lý phòng, người thuê, hóa đơn và thanh toán tại một nơi.',
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
                  'Đang hoạt động',
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
        Column(
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
                  '${room['area']} • ${room['price']} • ${room['tenant']}',
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
    final isPaid = status == 'Đã thanh toán';

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
          CircleAvatar(
            radius: 28,
            backgroundColor: isPaid
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFFFEDD5),
            child: Icon(
              isPaid ? Icons.check_circle_rounded : Icons.warning_rounded,
              color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFF97316),
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
              color: isPaid
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFF97316),
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