import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class MyPaymentsScreen extends StatefulWidget {
  const MyPaymentsScreen({super.key});

  @override
  State<MyPaymentsScreen> createState() => _MyPaymentsScreenState();
}

class _MyPaymentsScreenState extends State<MyPaymentsScreen> {
  String get _tenantId {
    final current = MockData.currentUsername.trim();

    final user = MockData.users.firstWhere(
      (item) =>
          item['role'] == 'TENANT' &&
          (item['username'] == current || item['name'] == current),
      orElse: () => {},
    );

    if ((user['id'] ?? '').isNotEmpty) {
      return user['id']!;
    }

    return MockData.tenantProfile['id'] ?? 'T001';
  }

  String get _tenantName {
    final current = MockData.currentUsername.trim();

    final user = MockData.users.firstWhere(
      (item) =>
          item['role'] == 'TENANT' &&
          (item['username'] == current || item['name'] == current),
      orElse: () => {},
    );

    if ((user['name'] ?? '').isNotEmpty) {
      return user['name']!;
    }

    return MockData.tenantProfile['name'] ?? 'Nguyễn Văn A';
  }

  String _statusCodeOf(Map<String, String> invoice) {
    final statusCode = invoice['statusCode'];

    if (statusCode == 'unpaid' ||
        statusCode == 'pending' ||
        statusCode == 'paid') {
      return statusCode!;
    }

    final status = invoice['status'] ?? '';

    if (status == 'Đã thanh toán') return 'paid';
    if (status == 'Chờ xác nhận') return 'pending';

    return 'unpaid';
  }

  List<Map<String, String>> get _paidInvoices {
    return MockData.invoices.where((invoice) {
      final isMyInvoice =
          invoice['tenantId'] == _tenantId || invoice['tenant'] == _tenantName;

      final isPaid = _statusCodeOf(invoice) == 'paid';

      return isMyInvoice && isPaid;
    }).toList();
  }

  Map<String, String>? _findPaymentByInvoice(String invoiceCode) {
    try {
      return MockData.payments.firstWhere(
        (payment) =>
            payment['invoice'] == invoiceCode &&
            (payment['statusCode'] == 'paid' ||
                payment['status'] == 'Đã xác nhận' ||
                payment['status'] == 'Đã thanh toán'),
      );
    } catch (_) {
      return null;
    }
  }

  String _paymentDate(Map<String, String> invoice) {
    final invoicePaidDate = invoice['paidDate'] ?? '';

    if (invoicePaidDate.isNotEmpty) {
      return invoicePaidDate;
    }

    final payment = _findPaymentByInvoice(invoice['code'] ?? '');

    return payment?['date'] ?? 'Chưa có';
  }

  String _paymentMethod(Map<String, String> invoice) {
    final invoiceMethod = invoice['paymentMethod'] ?? '';

    if (invoiceMethod.isNotEmpty) {
      return invoiceMethod;
    }

    final payment = _findPaymentByInvoice(invoice['code'] ?? '');

    return payment?['method'] ?? 'Chưa có';
  }

  String _proofStatus(Map<String, String> invoice) {
    final invoiceProof = invoice['proofImage'] ?? '';
    final payment = _findPaymentByInvoice(invoice['code'] ?? '');
    final paymentProof = payment?['proofImage'] ?? '';

    if (invoiceProof.isNotEmpty || paymentProof.isNotEmpty) {
      return 'Có';
    }

    return 'Không';
  }

  void _viewPaymentHistory(Map<String, String> invoice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chi tiết lịch sử đóng tiền'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoLine(label: 'Mã hóa đơn', value: invoice['code'] ?? ''),
              _InfoLine(label: 'Phòng', value: invoice['room'] ?? ''),
              _InfoLine(label: 'Tháng', value: invoice['month'] ?? ''),
              _InfoLine(label: 'Người thuê', value: invoice['tenant'] ?? ''),
              _InfoLine(label: 'Tiền phòng', value: invoice['roomPrice'] ?? ''),
              _InfoLine(label: 'Tiền điện', value: invoice['electricMoney'] ?? ''),
              _InfoLine(label: 'Tiền nước', value: invoice['waterMoney'] ?? ''),
              _InfoLine(label: 'Tiền dịch vụ', value: invoice['serviceMoney'] ?? ''),
              _InfoLine(label: 'Tổng tiền', value: invoice['amount'] ?? ''),
              _InfoLine(
                label: 'Ngày thanh toán',
                value: _paymentDate(invoice),
              ),
              _InfoLine(
                label: 'Hình thức',
                value: _paymentMethod(invoice),
              ),
              _InfoLine(
                label: 'Minh chứng',
                value: _proofStatus(invoice),
              ),
              const _InfoLine(
                label: 'Trạng thái',
                value: 'Đã thanh toán',
              ),
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

  Color _statusBg() {
    return const Color(0xFFDCFCE7);
  }

  Color _statusColor() {
    return const Color(0xFF16A34A);
  }

  @override
  Widget build(BuildContext context) {
    final invoices = _paidInvoices;

    return Scaffold(
      drawer: const AppDrawer(role: 'TENANT'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Lịch sử đóng tiền',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
      ),
      body: invoices.isEmpty
          ? const Center(
              child: Text(
                'Bạn chưa có hóa đơn đã thanh toán nào',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];

                return Card(
                  elevation: 0,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE0E7FF),
                      child: Icon(
                        Icons.payments,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    title: Text(
                      '${invoice['code']} - ${invoice['room']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Tháng ${invoice['month']} • ${invoice['amount']}\n'
                        'Ngày thanh toán: ${_paymentDate(invoice)} • Hình thức: ${_paymentMethod(invoice)}',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBg(),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Đã thanh toán',
                            style: TextStyle(
                              color: _statusColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _viewPaymentHistory(invoice),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
            width: 125,
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