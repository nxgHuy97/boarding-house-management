import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class OwnerInvoiceListScreen extends StatefulWidget {
  const OwnerInvoiceListScreen({super.key});

  @override
  State<OwnerInvoiceListScreen> createState() => _OwnerInvoiceListScreenState();
}

class _OwnerInvoiceListScreenState extends State<OwnerInvoiceListScreen> {
  String _generatePaymentCode() {
    return 'TT${(MockData.payments.length + 1).toString().padLeft(3, '0')}';
  }

  String _today() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
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

  String _statusTextOf(String statusCode) {
    if (statusCode == 'paid') return 'Đã thanh toán';
    if (statusCode == 'pending') return 'Chờ xác nhận';
    return 'Chưa thanh toán';
  }

  List<int> get _visibleInvoiceIndexes {
    final result = <int>[];

    for (int i = 0; i < MockData.invoices.length; i++) {
      final statusCode = _statusCodeOf(MockData.invoices[i]);

      if (statusCode == 'unpaid' || statusCode == 'pending') {
        result.add(i);
      }
    }

    return result;
  }

  void _viewInvoice(Map<String, String> invoice) {
    final statusCode = _statusCodeOf(invoice);
    final proofImage = invoice['proofImage'] ?? '';
    final paymentMethod = invoice['paymentMethod'] ?? '';

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
              _InfoLine(label: 'Người thuê', value: invoice['tenant'] ?? ''),
              _InfoLine(label: 'Tháng', value: invoice['month'] ?? ''),
              _InfoLine(label: 'Hạn thanh toán', value: invoice['dueDate'] ?? ''),
              _InfoLine(label: 'Tiền phòng', value: invoice['roomPrice'] ?? ''),
              _InfoLine(label: 'Tiền điện', value: invoice['electricMoney'] ?? ''),
              _InfoLine(label: 'Tiền nước', value: invoice['waterMoney'] ?? ''),
              _InfoLine(label: 'Tiền dịch vụ', value: invoice['serviceMoney'] ?? ''),
              _InfoLine(label: 'Tổng tiền', value: invoice['amount'] ?? ''),
              _InfoLine(
                label: 'Hình thức',
                value: paymentMethod.isNotEmpty ? paymentMethod : 'Chưa có',
              ),
              _InfoLine(
                label: 'Minh chứng',
                value: proofImage.isNotEmpty ? 'Đã gửi' : 'Chưa có',
              ),
              _InfoLine(label: 'Trạng thái', value: _statusTextOf(statusCode)),
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

  void _confirmPayment(int originalIndex) {
    final invoice = MockData.invoices[originalIndex];
    final statusCode = _statusCodeOf(invoice);

    if (statusCode == 'paid') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hóa đơn này đã thanh toán rồi'),
        ),
      );
      return;
    }

    final paymentMethod = statusCode == 'pending'
        ? ((invoice['paymentMethod'] ?? '').isNotEmpty
            ? invoice['paymentMethod']!
            : 'Chuyển khoản')
        : 'Tiền mặt';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận thanh toán'),
          content: Text(
            'Xác nhận ${invoice['code']} đã thanh toán bằng $paymentMethod?\n\nSau khi xác nhận, hóa đơn sẽ chuyển sang trang Biên lai.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  MockData.invoices[originalIndex]['status'] = 'Đã thanh toán';
                  MockData.invoices[originalIndex]['statusCode'] = 'paid';
                  MockData.invoices[originalIndex]['paidDate'] = _today();
                  MockData.invoices[originalIndex]['paymentMethod'] =
                      paymentMethod;

                  final paymentIndex = MockData.payments.indexWhere(
                    (payment) => payment['invoice'] == invoice['code'],
                  );

                  final paymentData = {
                    'code': paymentIndex == -1
                        ? _generatePaymentCode()
                        : MockData.payments[paymentIndex]['code'] ??
                            _generatePaymentCode(),
                    'invoice': invoice['code'] ?? '',
                    'tenantId': invoice['tenantId'] ?? '',
                    'tenant': invoice['tenant'] ?? '',
                    'room': invoice['room'] ?? '',
                    'amount': invoice['amount'] ?? '0đ',
                    'method': paymentMethod,
                    'date': _today(),
                    'proofImage': invoice['proofImage'] ?? '',
                    'status': 'Đã xác nhận',
                    'statusCode': 'paid',
                  };

                  if (paymentIndex == -1) {
                    MockData.payments.add(paymentData);
                  } else {
                    MockData.payments[paymentIndex] = paymentData;
                  }
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Đã xác nhận thanh toán và chuyển sang Biên lai',
                    ),
                  ),
                );
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _rejectProof(int originalIndex) {
    final invoice = MockData.invoices[originalIndex];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Từ chối minh chứng'),
          content: Text(
            'Từ chối minh chứng thanh toán của ${invoice['code']}?\nHóa đơn sẽ quay về trạng thái chưa thanh toán.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  MockData.invoices[originalIndex]['status'] =
                      'Chưa thanh toán';
                  MockData.invoices[originalIndex]['statusCode'] = 'unpaid';
                  MockData.invoices[originalIndex]['paymentMethod'] = '';
                  MockData.invoices[originalIndex]['proofImage'] = '';
                  MockData.invoices[originalIndex]['paidDate'] = '';

                  MockData.payments.removeWhere(
                    (payment) => payment['invoice'] == invoice['code'],
                  );
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã từ chối minh chứng thanh toán'),
                  ),
                );
              },
              child: const Text('Từ chối'),
            ),
          ],
        );
      },
    );
  }

  Color _statusBg(String statusCode) {
    if (statusCode == 'pending') return const Color(0xFFE0E7FF);
    return const Color(0xFFFFEDD5);
  }

  Color _statusColor(String statusCode) {
    if (statusCode == 'pending') return const Color(0xFF1E3A8A);
    return const Color(0xFFF97316);
  }

  @override
  Widget build(BuildContext context) {
    final invoiceIndexes = _visibleInvoiceIndexes;

    return Scaffold(
      drawer: const AppDrawer(role: 'OWNER'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Quản lý hóa đơn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/owner/invoices/create');
              setState(() {});
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: invoiceIndexes.isEmpty
          ? const Center(
              child: Text(
                'Không có hóa đơn chưa thanh toán hoặc chờ xác nhận',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: invoiceIndexes.length,
              itemBuilder: (context, index) {
                final originalIndex = invoiceIndexes[index];
                final invoice = MockData.invoices[originalIndex];
                final statusCode = _statusCodeOf(invoice);
                final statusText = _statusTextOf(statusCode);

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
                        Icons.receipt_long,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    title: Text(
                      '${invoice['code']} - ${invoice['room']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Người thuê: ${invoice['tenant']} • Tháng ${invoice['month']} • ${invoice['amount']}',
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
                            color: _statusBg(statusCode),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: _statusColor(statusCode),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'detail') {
                              _viewInvoice(invoice);
                            } else if (value == 'confirm') {
                              _confirmPayment(originalIndex);
                            } else if (value == 'reject') {
                              _rejectProof(originalIndex);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'detail',
                              child: Text('Xem chi tiết'),
                            ),
                            const PopupMenuItem(
                              value: 'confirm',
                              child: Text('Xác nhận thanh toán'),
                            ),
                            if (statusCode == 'pending')
                              const PopupMenuItem(
                                value: 'reject',
                                child: Text('Từ chối minh chứng'),
                              ),
                          ],
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