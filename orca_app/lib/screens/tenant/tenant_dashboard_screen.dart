import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class TenantDashboardScreen extends StatefulWidget {
  const TenantDashboardScreen({super.key});

  @override
  State<TenantDashboardScreen> createState() => _TenantDashboardScreenState();
}

class _TenantDashboardScreenState extends State<TenantDashboardScreen> {
  Future<void> _goAndRefresh(String route) async {
    await Navigator.pushNamed(context, route);

    if (!mounted) return;

    setState(() {});
  }

  Map<String, String> get _tenant {
    final currentName = MockData.currentUsername.trim();

    final tenantIndex = MockData.tenants.indexWhere(
      (tenant) => tenant['name'] == currentName,
    );

    if (tenantIndex != -1) {
      return MockData.tenants[tenantIndex];
    }

    final defaultName = MockData.tenantProfile['name'];

    final defaultTenantIndex = MockData.tenants.indexWhere(
      (tenant) => tenant['name'] == defaultName,
    );

    if (defaultTenantIndex != -1) {
      return MockData.tenants[defaultTenantIndex];
    }

    return MockData.tenantProfile;
  }

  String get _tenantName {
    return _tenant['name'] ?? 'Người thuê';
  }

  String get _tenantRoom {
    return _tenant['room'] ?? 'Chưa gán phòng';
  }

  List<Map<String, String>> get _myInvoices {
    return MockData.invoices.where((invoice) {
      return invoice['tenant'] == _tenantName;
    }).toList();
  }

  List<Map<String, String>> get _myPayments {
    return MockData.payments.where((payment) {
      return payment['tenant'] == _tenantName;
    }).toList();
  }

  List<Map<String, String>> get _myContracts {
    return MockData.contracts.where((contract) {
      return contract['tenant'] == _tenantName;
    }).toList();
  }

  String _roomNumber(String room) {
    return room.replaceAll('Phòng', '').trim();
  }

  int get _unpaidInvoiceCount {
    return _myInvoices.where((invoice) {
      final status = invoice['status'] ?? '';
      return status != 'Đã thanh toán';
    }).length;
  }

  int get _sentPaymentCount {
    return _myPayments.length;
  }

  int get _contractCount {
    return _myContracts.length;
  }

  void _viewInvoice(Map<String, String> invoice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chi tiết hóa đơn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoLine(label: 'Mã hóa đơn', value: invoice['code'] ?? ''),
              _InfoLine(label: 'Phòng', value: invoice['room'] ?? ''),
              _InfoLine(label: 'Tháng', value: invoice['month'] ?? ''),
              _InfoLine(label: 'Tiền phòng', value: invoice['roomPrice'] ?? ''),
              _InfoLine(label: 'Tiền điện', value: invoice['electricMoney'] ?? ''),
              _InfoLine(label: 'Tiền nước', value: invoice['waterMoney'] ?? ''),
              _InfoLine(label: 'Tiền dịch vụ', value: invoice['serviceMoney'] ?? ''),
              _InfoLine(label: 'Tổng tiền', value: invoice['amount'] ?? ''),
              _InfoLine(label: 'Trạng thái', value: invoice['status'] ?? ''),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Color _statusBg(String status) {
    if (status == 'Đã thanh toán') return const Color(0xFFDCFCE7);
    if (status == 'Chờ xác nhận') return const Color(0xFFE0E7FF);
    return const Color(0xFFFFEDD5);
  }

  Color _statusColor(String status) {
    if (status == 'Đã thanh toán') return const Color(0xFF16A34A);
    if (status == 'Chờ xác nhận') return const Color(0xFF1E3A8A);
    return const Color(0xFFF97316);
  }

  @override
  Widget build(BuildContext context) {
    final invoices = _myInvoices;
    final room = _tenantRoom;

    return Scaffold(
      drawer: const AppDrawer(role: 'TENANT'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Tổng quan',
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
              name: _tenantName,
              room: room,
              status: _tenant['status'] ?? 'Đang thuê',
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(
                  title: 'Phòng hiện tại',
                  value: room == 'Chưa gán phòng' ? '-' : _roomNumber(room),
                  icon: Icons.meeting_room_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: () {
                    _goAndRefresh('/tenant/profile');
                  },
                ),
                _StatCard(
                  title: 'Hóa đơn chưa trả',
                  value: _unpaidInvoiceCount.toString(),
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFFF97316),
                  onTap: () {
                    _goAndRefresh('/tenant/invoices');
                  },
                ),
                _StatCard(
                  title: 'Thanh toán đã gửi',
                  value: _sentPaymentCount.toString(),
                  icon: Icons.payments_rounded,
                  color: const Color(0xFF16A34A),
                  onTap: () {
                    _goAndRefresh('/tenant/payments');
                  },
                ),
                _StatCard(
                  title: 'Hợp đồng',
                  value: _contractCount.toString(),
                  icon: Icons.description_rounded,
                  color: const Color(0xFF7C3AED),
                  onTap: () {
                    _goAndRefresh('/tenant/contracts');
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            const _SectionTitle(
              title: 'Thao tác nhanh',
              subtitle: 'Các chức năng người thuê thường dùng',
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _QuickAction(
                  icon: Icons.receipt_long_rounded,
                  title: 'Xem hóa đơn',
                  onTap: () {
                    _goAndRefresh('/tenant/invoices');
                  },
                ),
                _QuickAction(
                  icon: Icons.payments_rounded,
                  title: 'Thanh toán',
                  onTap: () {
                    _goAndRefresh('/tenant/invoices');
                  },
                ),
                _QuickAction(
                  icon: Icons.description_rounded,
                  title: 'Hợp đồng',
                  onTap: () {
                    _goAndRefresh('/tenant/contracts');
                  },
                ),
                _QuickAction(
                  icon: Icons.person_rounded,
                  title: 'Hồ sơ',
                  onTap: () {
                    _goAndRefresh('/tenant/profile');
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            const _SectionTitle(
              title: 'Hóa đơn gần đây',
              subtitle: 'Theo dõi hóa đơn và trạng thái thanh toán',
            ),

            const SizedBox(height: 12),

            if (invoices.isEmpty)
              const _EmptyBox(message: 'Bạn chưa có hóa đơn nào')
            else
              ...invoices.take(4).map((invoice) {
                return _InvoiceCard(
                  invoice: invoice,
                  statusBg: _statusBg,
                  statusColor: _statusColor,
                  onView: () {
                    _viewInvoice(invoice);
                  },
                  onPay: () {
                    _goAndRefresh('/tenant/invoices');
                  },
                );
              }),

            const SizedBox(height: 28),

            const _SectionTitle(
              title: 'Thanh toán gần đây',
              subtitle: 'Các thanh toán bạn đã gửi',
            ),

            const SizedBox(height: 12),

            if (_myPayments.isEmpty)
              const _EmptyBox(message: 'Bạn chưa gửi thanh toán nào')
            else
              ..._myPayments.take(3).map((payment) {
                return _PaymentCard(payment: payment);
              }),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String name;
  final String room;
  final String status;

  const _WelcomeHeader({
    required this.name,
    required this.room,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isRenting = status == 'Đang thuê';

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
              Icons.person_rounded,
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
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  room == 'Chưa gán phòng'
                      ? 'Bạn chưa được gán phòng'
                      : 'Bạn đang thuê $room',
                  style: const TextStyle(
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
            child: Row(
              children: [
                Icon(
                  isRenting
                      ? Icons.verified_rounded
                      : Icons.pending_actions_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: const TextStyle(
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
            borderRadius: BorderRadius.circular(99),
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
                  color: Color(0xFF111827),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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

class _InvoiceCard extends StatelessWidget {
  final Map<String, String> invoice;
  final Color Function(String status) statusBg;
  final Color Function(String status) statusColor;
  final VoidCallback onView;
  final VoidCallback onPay;

  const _InvoiceCard({
    required this.invoice,
    required this.statusBg,
    required this.statusColor,
    required this.onView,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final status = invoice['status'] ?? 'Chưa thanh toán';
    final canPay = status != 'Đã thanh toán' && status != 'Chờ xác nhận';

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
                  'Tháng ${invoice['month']} • ${invoice['amount']}',
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
              color: statusBg(status),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor(status),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(width: 8),

          OutlinedButton(
            onPressed: onView,
            child: const Text('Chi tiết'),
          ),

          const SizedBox(width: 8),

          FilledButton(
            onPressed: canPay ? onPay : null,
            child: Text(
              status == 'Đã thanh toán'
                  ? 'Đã trả'
                  : status == 'Chờ xác nhận'
                      ? 'Đang chờ'
                      : 'Thanh toán',
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Map<String, String> payment;

  const _PaymentCard({
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    final status = payment['status'] ?? 'Chờ xác nhận';

    Color bgColor;
    Color textColor;

    if (status == 'Đã xác nhận') {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF16A34A);
    } else if (status == 'Từ chối') {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
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
              Icons.payments_rounded,
              color: Color(0xFF1E3A8A),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${payment['code']} - ${payment['invoice']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${payment['amount']} • ${payment['method']} • ${payment['date']}',
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

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
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