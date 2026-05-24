import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class OwnerPaymentListScreen extends StatefulWidget {
  const OwnerPaymentListScreen({super.key});

  @override
  State<OwnerPaymentListScreen> createState() => _OwnerPaymentListScreenState();
}

class _OwnerPaymentListScreenState extends State<OwnerPaymentListScreen> {
  List<Map<String, String>> get _receipts {
    final receipts = <Map<String, String>>[];
    final addedInvoiceCodes = <String>{};

    for (final payment in MockData.payments) {
      final invoiceCode = payment['invoice'] ?? '';
      final invoice = _findInvoice(invoiceCode);

      final paymentIsPaid = payment['statusCode'] == 'paid' ||
          payment['status'] == 'Đã xác nhận' ||
          payment['status'] == 'Đã thanh toán';

      final invoiceIsPaid = invoice?['statusCode'] == 'paid' ||
          invoice?['status'] == 'Đã thanh toán';

      if (paymentIsPaid || invoiceIsPaid) {
        receipts.add({
          'code': payment['code'] ?? '',
          'invoice': invoiceCode,
          'room': payment['room'] ?? invoice?['room'] ?? '',
          'tenantId': payment['tenantId'] ?? invoice?['tenantId'] ?? '',
          'tenant': payment['tenant'] ?? invoice?['tenant'] ?? '',
          'month': invoice?['month'] ?? '',
          'amount': payment['amount'] ?? invoice?['amount'] ?? '0đ',
          'method': payment['method'] ?? invoice?['paymentMethod'] ?? '',
          'date': payment['date'] ?? invoice?['paidDate'] ?? '',
          'proofImage': payment['proofImage'] ?? invoice?['proofImage'] ?? '',
          'status': 'Đã thanh toán',
          'statusCode': 'paid',
        });

        if (invoiceCode.isNotEmpty) {
          addedInvoiceCodes.add(invoiceCode);
        }
      }
    }

    // Phòng trường hợp invoice đã paid nhưng chưa có record trong payments.
    for (final invoice in MockData.invoices) {
      final invoiceCode = invoice['code'] ?? '';

      final invoiceIsPaid = invoice['statusCode'] == 'paid' ||
          invoice['status'] == 'Đã thanh toán';

      if (invoiceIsPaid && !addedInvoiceCodes.contains(invoiceCode)) {
        receipts.add({
          'code': 'BL-$invoiceCode',
          'invoice': invoiceCode,
          'room': invoice['room'] ?? '',
          'tenantId': invoice['tenantId'] ?? '',
          'tenant': invoice['tenant'] ?? '',
          'month': invoice['month'] ?? '',
          'amount': invoice['amount'] ?? '0đ',
          'method': invoice['paymentMethod'] ?? '',
          'date': invoice['paidDate'] ?? '',
          'proofImage': invoice['proofImage'] ?? '',
          'status': 'Đã thanh toán',
          'statusCode': 'paid',
        });
      }
    }

    return receipts;
  }

  Map<String, String>? _findInvoice(String invoiceCode) {
    if (invoiceCode.isEmpty) return null;

    try {
      return MockData.invoices.firstWhere(
        (invoice) => invoice['code'] == invoiceCode,
      );
    } catch (_) {
      return null;
    }
  }

  String _displayValue(String? value, {String emptyText = 'Chưa có'}) {
    if (value == null || value.trim().isEmpty) {
      return emptyText;
    }

    return value;
  }

  void _viewReceipt(Map<String, String> receipt) {
    final proofImage = receipt['proofImage'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chi tiết biên lai'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoLine(
                label: 'Mã biên lai',
                value: _displayValue(receipt['code']),
              ),
              _InfoLine(
                label: 'Hóa đơn',
                value: _displayValue(receipt['invoice']),
              ),
              _InfoLine(
                label: 'Phòng',
                value: _displayValue(receipt['room']),
              ),
              _InfoLine(
                label: 'Người thuê',
                value: _displayValue(receipt['tenant']),
              ),
              _InfoLine(
                label: 'Tháng',
                value: _displayValue(receipt['month']),
              ),
              _InfoLine(
                label: 'Số tiền',
                value: _displayValue(receipt['amount'], emptyText: '0đ'),
              ),
              _InfoLine(
                label: 'Hình thức',
                value: _displayValue(receipt['method']),
              ),
              _InfoLine(
                label: 'Ngày thanh toán',
                value: _displayValue(receipt['date']),
              ),
              _InfoLine(
                label: 'Minh chứng',
                value: proofImage.isNotEmpty ? 'Đã có minh chứng' : 'Không có',
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
    final receipts = _receipts;

    return Scaffold(
      drawer: const AppDrawer(role: 'OWNER'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Biên lai / Lịch sử thanh toán',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
      ),
      body: receipts.isEmpty
          ? const Center(
              child: Text(
                'Chưa có biên lai nào',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: receipts.length,
              itemBuilder: (context, index) {
                final receipt = receipts[index];
                final proofImage = receipt['proofImage'] ?? '';
                final hasProof = proofImage.isNotEmpty;

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
                      '${receipt['code']} - ${receipt['tenant']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Hóa đơn: ${receipt['invoice']} • Phòng: ${receipt['room']} • Tháng ${receipt['month']}\n'
                        '${receipt['amount']} • ${receipt['method']} • ${receipt['date']} • Minh chứng: ${hasProof ? 'Có' : 'Không'}',
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
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'detail') {
                              _viewReceipt(receipt);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'detail',
                              child: Text('Chi tiết'),
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