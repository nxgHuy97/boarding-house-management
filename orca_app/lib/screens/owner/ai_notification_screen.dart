import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class OwnerAiNotificationScreen extends StatefulWidget {
  const OwnerAiNotificationScreen({super.key});

  @override
  State<OwnerAiNotificationScreen> createState() =>
      _OwnerAiNotificationScreenState();
}

class _OwnerAiNotificationScreenState
    extends State<OwnerAiNotificationScreen> {
  String _generateNotificationId() {
    return 'AI${(MockData.aiNotifications.length + 1).toString().padLeft(3, '0')}';
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

  Map<String, String>? _latestInvoiceOfTenant(Map<String, String> history) {
    final tenantId = history['tenantId'] ?? '';
    final tenantName = history['tenant'] ?? '';

    final invoices = MockData.invoices.where((invoice) {
      return invoice['tenantId'] == tenantId || invoice['tenant'] == tenantName;
    }).toList();

    if (invoices.isEmpty) return null;

    final unpaidInvoices = invoices.where((invoice) {
      return _statusCodeOf(invoice) == 'unpaid';
    }).toList();

    if (unpaidInvoices.isNotEmpty) {
      return unpaidInvoices.first;
    }

    return invoices.first;
  }

  String _tenantType(Map<String, String> history) {
    final totalInvoices = int.tryParse(history['totalInvoices'] ?? '0') ?? 0;
    final onTimeRate = int.tryParse(history['onTimeRate'] ?? '0') ?? 0;
    final avgDelayDays = int.tryParse(history['avgDelayDays'] ?? '0') ?? 0;

    if (totalInvoices == 0) return 'Người thuê mới';
    if (onTimeRate >= 90) return 'Thanh toán tốt';
    if (onTimeRate < 70 || avgDelayDays >= 5) return 'Có nguy cơ trả trễ';

    return 'Bình thường';
  }

  String _riskLevel(Map<String, String> history) {
    final totalInvoices = int.tryParse(history['totalInvoices'] ?? '0') ?? 0;
    final onTimeRate = int.tryParse(history['onTimeRate'] ?? '0') ?? 0;
    final avgDelayDays = int.tryParse(history['avgDelayDays'] ?? '0') ?? 0;

    if (totalInvoices == 0) return 'Chưa đánh giá';
    if (onTimeRate >= 90) return 'Thấp';
    if (onTimeRate >= 60 && avgDelayDays <= 5) return 'Trung bình';

    return 'Cao';
  }

  String _generateTemplateMessage(Map<String, String> history) {
    final invoice = _latestInvoiceOfTenant(history);

    final tenantName = history['tenant'] ?? 'bạn';
    final month = invoice?['month'] ?? 'tháng này';
    final amount = invoice?['amount'] ?? 'hóa đơn';
    final dueDate = invoice?['dueDate'] ?? 'cuối tháng';

    return 'Chào $tenantName, hóa đơn $month của bạn là $amount, hạn thanh toán ngày $dueDate. Vui lòng thanh toán đúng hạn.';
  }

  String _generateAiMessage(Map<String, String> history) {
    final invoice = _latestInvoiceOfTenant(history);

    final tenantName = history['tenant'] ?? 'bạn';
    final month = invoice?['month'] ?? 'tháng này';
    final amount = invoice?['amount'] ?? 'hóa đơn';
    final dueDate = invoice?['dueDate'] ?? 'cuối tháng';

    final totalInvoices = int.tryParse(history['totalInvoices'] ?? '0') ?? 0;
    final onTimeRate = int.tryParse(history['onTimeRate'] ?? '0') ?? 0;
    final avgDelayDays = int.tryParse(history['avgDelayDays'] ?? '0') ?? 0;

    if (totalInvoices == 0) {
      return 'Chào $tenantName, hóa đơn $month của bạn là $amount, hạn thanh toán ngày $dueDate. Đây là tháng đầu tiên của bạn. Bạn có thể thanh toán bằng chuyển khoản hoặc tiền mặt. Nếu có thắc mắc, hãy liên hệ chủ trọ nhé. 👋';
    }

    if (onTimeRate >= 90) {
      return 'Chào $tenantName, hóa đơn $month của bạn là $amount, hạn thanh toán ngày $dueDate. Cảm ơn bạn vì luôn thanh toán đúng hạn. Chủ trọ rất trân trọng sự uy tín của bạn. 🙏';
    }

    if (onTimeRate < 70 || avgDelayDays >= 5) {
      return 'Chào $tenantName, hóa đơn $month của bạn là $amount, hạn thanh toán ngày $dueDate. Dựa trên lịch sử thanh toán, bạn thường thanh toán trễ khoảng $avgDelayDays ngày. Bạn nên đặt lời nhắc để tránh phát sinh phí trễ hạn nhé. 💡';
    }

    return 'Chào $tenantName, hóa đơn $month của bạn là $amount, hạn thanh toán ngày $dueDate. Bạn vui lòng kiểm tra và thanh toán đúng hạn để việc thuê phòng được thuận tiện hơn nhé.';
  }

  void _showMessageDialog({
    required Map<String, String> history,
    required String messageType,
  }) {
    final message = messageType == 'AI'
        ? _generateAiMessage(history)
        : _generateTemplateMessage(history);

    final invoice = _latestInvoiceOfTenant(history);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            messageType == 'AI'
                ? 'Tin nhắn AI cá nhân hóa'
                : 'Tin nhắn mẫu',
          ),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _InfoLine(
                  label: 'Người thuê',
                  value: history['tenant'] ?? '',
                ),
                _InfoLine(
                  label: 'Phân loại',
                  value: _tenantType(history),
                ),
                _InfoLine(
                  label: 'Rủi ro',
                  value: _riskLevel(history),
                ),
                _InfoLine(
                  label: 'Hóa đơn',
                  value: invoice?['code'] ?? 'Chưa có hóa đơn',
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      height: 1.45,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            FilledButton.icon(
              onPressed: () {
                _sendNotification(
                  history: history,
                  messageType: messageType,
                  message: message,
                );

                Navigator.pop(context);
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('Gửi thông báo'),
            ),
          ],
        );
      },
    );
  }

  void _sendNotification({
    required Map<String, String> history,
    required String messageType,
    required String message,
  }) {
    final invoice = _latestInvoiceOfTenant(history);

    setState(() {
      MockData.aiNotifications.add({
        'id': _generateNotificationId(),
        'tenantId': history['tenantId'] ?? '',
        'tenant': history['tenant'] ?? '',
        'invoiceCode': invoice?['code'] ?? '',
        'messageType': messageType,
        'message': message,
        'sentAt': _today(),
        'opened': 'Chưa',
        'paymentTime': 'Chưa thanh toán',
        'satisfaction': '0',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã gửi ${messageType == 'AI' ? 'tin nhắn AI' : 'tin nhắn mẫu'} cho ${history['tenant']}',
        ),
      ),
    );
  }

  Color _riskBg(String risk) {
    if (risk == 'Thấp') return const Color(0xFFDCFCE7);
    if (risk == 'Trung bình') return const Color(0xFFFFEDD5);
    if (risk == 'Cao') return const Color(0xFFFEE2E2);

    return const Color(0xFFE0E7FF);
  }

  Color _riskColor(String risk) {
    if (risk == 'Thấp') return const Color(0xFF16A34A);
    if (risk == 'Trung bình') return const Color(0xFFF97316);
    if (risk == 'Cao') return const Color(0xFFDC2626);

    return const Color(0xFF1E3A8A);
  }

  @override
  Widget build(BuildContext context) {
    final histories = MockData.paymentHistories;
    final notifications = MockData.aiNotifications;
    final reports = MockData.abTestReports;

    return Scaffold(
      drawer: const AppDrawer(role: 'OWNER'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'AI nhắc thanh toán',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const _HeaderBox(),

            const SizedBox(height: 20),

            const _SectionTitle(
              title: 'Phân loại người thuê',
              subtitle:
                  'Hệ thống phân tích lịch sử thanh toán để gợi ý cách nhắc phù hợp',
            ),

            const SizedBox(height: 12),

            if (histories.isEmpty)
              const _EmptyBox(message: 'Chưa có dữ liệu lịch sử thanh toán')
            else
              ...histories.map((history) {
                final risk = _riskLevel(history);
                final tenantType = _tenantType(history);
                final invoice = _latestInvoiceOfTenant(history);

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
                        Icons.person_search_rounded,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    title: Text(
                      history['tenant'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$tenantType • Đúng hạn: ${history['onTimeRate']}% • Trễ TB: ${history['avgDelayDays']} ngày\n'
                        'Hóa đơn gần nhất: ${invoice?['code'] ?? 'Chưa có'} • ${invoice?['amount'] ?? ''}',
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
                            color: _riskBg(risk),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Rủi ro: $risk',
                            style: TextStyle(
                              color: _riskColor(risk),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'template') {
                              _showMessageDialog(
                                history: history,
                                messageType: 'Template',
                              );
                            } else if (value == 'ai') {
                              _showMessageDialog(
                                history: history,
                                messageType: 'AI',
                              );
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'template',
                              child: Text('Tạo tin nhắn mẫu'),
                            ),
                            PopupMenuItem(
                              value: 'ai',
                              child: Text('Tạo tin nhắn AI'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 24),

            const _SectionTitle(
              title: 'A/B Test: Template vs AI',
              subtitle:
                  'So sánh hiệu quả giữa tin nhắn mẫu và tin nhắn AI cá nhân hóa',
            ),

            const SizedBox(height: 12),

            if (reports.isEmpty)
              const _EmptyBox(message: 'Chưa có dữ liệu A/B test')
            else
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: reports.map((report) {
                  return _ABTestCard(report: report);
                }).toList(),
              ),

            const SizedBox(height: 24),

            const _SectionTitle(
              title: 'Lịch sử thông báo đã gửi',
              subtitle: 'Theo dõi các tin nhắn đã gửi cho người thuê',
            ),

            const SizedBox(height: 12),

            if (notifications.isEmpty)
              const _EmptyBox(message: 'Chưa có thông báo nào được gửi')
            else
              ...notifications.reversed.take(8).map((notification) {
                final isAi = notification['messageType'] == 'AI';

                return Card(
                  elevation: 0,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor:
                          isAi ? const Color(0xFFE0E7FF) : const Color(0xFFF3F4F6),
                      child: Icon(
                        isAi
                            ? Icons.auto_awesome_rounded
                            : Icons.chat_bubble_outline_rounded,
                        color: isAi
                            ? const Color(0xFF1E3A8A)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    title: Text(
                      '${notification['tenant']} - ${notification['messageType']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${notification['message']}\nGửi lúc: ${notification['sentAt']} • Open: ${notification['opened']} • Payment: ${notification['paymentTime']}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _HeaderBox extends StatelessWidget {
  const _HeaderBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Tenant Communication',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tự động phân tích lịch sử thanh toán và tạo tin nhắn nhắc tiền cá nhân hóa cho từng người thuê.',
                  style: TextStyle(
                    color: Color(0xFFE0E7FF),
                    height: 1.4,
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

class _ABTestCard extends StatelessWidget {
  final Map<String, String> report;

  const _ABTestCard({
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final isAi = report['type'] == 'AI message';

    return SizedBox(
      width: 260,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor:
                    isAi ? const Color(0xFFE0E7FF) : const Color(0xFFF3F4F6),
                child: Icon(
                  isAi
                      ? Icons.auto_awesome_rounded
                      : Icons.chat_bubble_outline_rounded,
                  color: isAi
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                report['type'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 10),
              _SmallLine(label: 'Số tin gửi', value: report['sentCount'] ?? ''),
              _SmallLine(label: 'Open rate', value: report['openRate'] ?? ''),
              _SmallLine(
                label: 'TG thanh toán',
                value: report['avgPaymentTime'] ?? '',
              ),
              _SmallLine(
                label: 'Hài lòng',
                value: report['satisfaction'] ?? '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallLine extends StatelessWidget {
  final String label;
  final String value;

  const _SmallLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
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
        borderRadius: BorderRadius.circular(18),
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