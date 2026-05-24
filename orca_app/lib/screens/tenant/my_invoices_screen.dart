import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class MyInvoicesScreen extends StatefulWidget {
  const MyInvoicesScreen({super.key});

  @override
  State<MyInvoicesScreen> createState() => _MyInvoicesScreenState();
}

class _MyInvoicesScreenState extends State<MyInvoicesScreen> {
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

  List<Map<String, String>> get _myInvoices {
    final filtered = MockData.invoices.where((invoice) {
      return invoice['tenantId'] == _tenantId || invoice['tenant'] == _tenantName;
    }).toList();

    return filtered;
  }

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

  Map<String, String> _ownerOfInvoice(Map<String, String> invoice) {
    final ownerId = invoice['ownerId'] ?? '';

    final owner = MockData.owners.firstWhere(
      (item) => item['id'] == ownerId,
      orElse: () {
        return MockData.owners.isNotEmpty ? MockData.owners.first : {};
      },
    );

    return owner;
  }

  void _viewInvoice(Map<String, String> invoice) {
    final statusCode = _statusCodeOf(invoice);

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
                value: (invoice['paymentMethod'] ?? '').isNotEmpty
                    ? invoice['paymentMethod']!
                    : 'Chưa có',
              ),
              _InfoLine(
                label: 'Minh chứng',
                value: (invoice['proofImage'] ?? '').isNotEmpty
                    ? 'Đã gửi'
                    : 'Chưa có',
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

  void _openPaymentDialog(Map<String, String> invoice) {
    final statusCode = _statusCodeOf(invoice);

    if (statusCode == 'paid') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hóa đơn này đã thanh toán rồi'),
        ),
      );
      return;
    }

    if (statusCode == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hóa đơn đang chờ chủ trọ xác nhận'),
        ),
      );
      return;
    }

    String selectedMethod = 'Chuyển khoản';
    bool proofUploaded = false;

    showDialog(
      context: context,
      builder: (context) {
        final owner = _ownerOfInvoice(invoice);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isBankTransfer = selectedMethod == 'Chuyển khoản';

            return AlertDialog(
              title: const Text('Thanh toán hóa đơn'),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _InfoLine(label: 'Mã hóa đơn', value: invoice['code'] ?? ''),
                      _InfoLine(label: 'Phòng', value: invoice['room'] ?? ''),
                      _InfoLine(label: 'Tháng', value: invoice['month'] ?? ''),
                      _InfoLine(label: 'Tổng tiền', value: invoice['amount'] ?? ''),

                      const SizedBox(height: 14),

                      DropdownButtonFormField<String>(
                        value: selectedMethod,
                        decoration: const InputDecoration(
                          labelText: 'Hình thức thanh toán',
                          prefixIcon: Icon(Icons.payments),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Chuyển khoản',
                            child: Text('Chuyển khoản'),
                          ),
                          DropdownMenuItem(
                            value: 'Tiền mặt',
                            child: Text('Tiền mặt'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setDialogState(() {
                            selectedMethod = value;
                            proofUploaded = false;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      if (isBankTransfer)
                        _BankTransferBox(
                          owner: owner,
                          proofUploaded: proofUploaded,
                          onUploadProof: () {
                            setDialogState(() {
                              proofUploaded = true;
                            });
                          },
                        )
                      else
                        const _CashPaymentBox(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () {
                    if (selectedMethod == 'Tiền mặt') {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vui lòng đưa tiền trực tiếp cho chủ trọ. Chủ trọ sẽ xác nhận sau khi nhận tiền.',
                          ),
                        ),
                      );

                      return;
                    }

                    if (!proofUploaded) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng upload ảnh minh chứng chuyển khoản'),
                        ),
                      );
                      return;
                    }

                    _submitTransferPayment(invoice);

                    Navigator.pop(context);
                  },
                  child: Text(
                    isBankTransfer ? 'Gửi minh chứng' : 'Đã hiểu',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitTransferPayment(Map<String, String> invoice) {
    setState(() {
      final invoiceIndex = MockData.invoices.indexWhere(
        (item) => item['code'] == invoice['code'],
      );

      if (invoiceIndex != -1) {
        MockData.invoices[invoiceIndex]['status'] = 'Chờ xác nhận';
        MockData.invoices[invoiceIndex]['statusCode'] = 'pending';
        MockData.invoices[invoiceIndex]['paymentMethod'] = 'Chuyển khoản';
        MockData.invoices[invoiceIndex]['proofImage'] =
            'assets/images/proof_${invoice['code']}.png';
      }

      final paymentIndex = MockData.payments.indexWhere(
        (payment) => payment['invoice'] == invoice['code'],
      );

      final paymentData = {
        'code': paymentIndex == -1
            ? _generatePaymentCode()
            : MockData.payments[paymentIndex]['code'] ?? _generatePaymentCode(),
        'invoice': invoice['code'] ?? '',
        'tenantId': invoice['tenantId'] ?? _tenantId,
        'tenant': invoice['tenant'] ?? _tenantName,
        'room': invoice['room'] ?? '',
        'amount': invoice['amount'] ?? '0đ',
        'method': 'Chuyển khoản',
        'date': _today(),
        'proofImage': 'assets/images/proof_${invoice['code']}.png',
        'status': 'Chờ xác nhận',
        'statusCode': 'pending',
      };

      if (paymentIndex == -1) {
        MockData.payments.add(paymentData);
      } else {
        MockData.payments[paymentIndex] = paymentData;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã gửi minh chứng thanh toán, chờ chủ trọ xác nhận'),
      ),
    );
  }

  Color _statusBg(String statusCode) {
    if (statusCode == 'paid') return const Color(0xFFDCFCE7);
    if (statusCode == 'pending') return const Color(0xFFE0E7FF);
    return const Color(0xFFFFEDD5);
  }

  Color _statusColor(String statusCode) {
    if (statusCode == 'paid') return const Color(0xFF16A34A);
    if (statusCode == 'pending') return const Color(0xFF1E3A8A);
    return const Color(0xFFF97316);
  }

  @override
  Widget build(BuildContext context) {
    final invoices = _myInvoices;

    return Scaffold(
      drawer: const AppDrawer(role: 'TENANT'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Hóa đơn của tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
      ),
      body: invoices.isEmpty
          ? const Center(
              child: Text(
                'Bạn chưa có hóa đơn nào',
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
                final statusCode = _statusCodeOf(invoice);
                final statusText = _statusTextOf(statusCode);
                final canPay = statusCode == 'unpaid';

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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Tháng ${invoice['month']} • ${invoice['amount']}',
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
                        OutlinedButton(
                          onPressed: () => _viewInvoice(invoice),
                          child: const Text('Chi tiết'),
                        ),
                        if (canPay)
                          FilledButton(
                            onPressed: () => _openPaymentDialog(invoice),
                            child: const Text('Thanh toán'),
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

class _BankTransferBox extends StatelessWidget {
  final Map<String, String> owner;
  final bool proofUploaded;
  final VoidCallback onUploadProof;

  const _BankTransferBox({
    required this.owner,
    required this.proofUploaded,
    required this.onUploadProof,
  });

  @override
  Widget build(BuildContext context) {
    final bankName = owner['bankName'] ?? 'Chưa có';
    final bankAccount = owner['bankAccount'] ?? 'Chưa có';
    final bankOwner = owner['bankOwner'] ?? 'Chưa có';
    final bankQr = owner['bankQr'] ?? 'Chưa có';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin chuyển khoản',
            style: TextStyle(
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          _InfoLine(label: 'Ngân hàng', value: bankName),
          _InfoLine(label: 'Số tài khoản', value: bankAccount),
          _InfoLine(label: 'Chủ tài khoản', value: bankOwner),
          _InfoLine(label: 'QR demo', value: bankQr),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onUploadProof,
              icon: Icon(
                proofUploaded ? Icons.check_circle : Icons.upload_file,
              ),
              label: Text(
                proofUploaded
                    ? 'Đã upload ảnh minh chứng'
                    : 'Upload ảnh minh chứng chuyển khoản',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CashPaymentBox extends StatelessWidget {
  const _CashPaymentBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFED7AA),
        ),
      ),
      child: const Text(
        'Vui lòng thanh toán trực tiếp cho chủ trọ. Sau khi chủ trọ nhận tiền, chủ trọ sẽ xác nhận hóa đơn là đã thanh toán.',
        style: TextStyle(
          color: Color(0xFFC2410C),
          fontWeight: FontWeight.w600,
        ),
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