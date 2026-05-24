import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class MyContractsScreen extends StatelessWidget {
  const MyContractsScreen({super.key});

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

  List<Map<String, String>> get _myContracts {
    return MockData.contracts.where((contract) {
      return contract['tenantId'] == _tenantId ||
          contract['tenant'] == _tenantName;
    }).toList();
  }

  void _viewContract(
    BuildContext context,
    Map<String, String> contract,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chi tiết hợp đồng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoLine(label: 'Mã hợp đồng', value: contract['code'] ?? ''),
              _InfoLine(label: 'Người thuê', value: contract['tenant'] ?? ''),
              _InfoLine(label: 'Phòng', value: contract['room'] ?? ''),
              _InfoLine(label: 'Ngày bắt đầu', value: contract['start'] ?? ''),
              _InfoLine(label: 'Ngày kết thúc', value: contract['end'] ?? ''),
              _InfoLine(label: 'Trạng thái', value: contract['status'] ?? ''),
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
    if (status == 'Còn hiệu lực') {
      return const Color(0xFFDCFCE7);
    }

    if (status == 'Sắp hết hạn') {
      return const Color(0xFFFFEDD5);
    }

    return const Color(0xFFFEE2E2);
  }

  Color _statusColor(String status) {
    if (status == 'Còn hiệu lực') {
      return const Color(0xFF16A34A);
    }

    if (status == 'Sắp hết hạn') {
      return const Color(0xFFF97316);
    }

    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final contracts = _myContracts;

    return Scaffold(
      drawer: const AppDrawer(role: 'TENANT'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Hợp đồng của tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
      ),
      body: contracts.isEmpty
          ? const Center(
              child: Text(
                'Bạn chưa có hợp đồng nào',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contracts.length,
              itemBuilder: (context, index) {
                final contract = contracts[index];
                final status = contract['status'] ?? 'Còn hiệu lực';

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
                        Icons.description,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    title: Text(
                      '${contract['code']} - ${contract['room']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Người thuê: ${contract['tenant']} • ${contract['start']} → ${contract['end']}',
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
                            color: _statusBg(status),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            _viewContract(context, contract);
                          },
                          child: const Text('Xem chi tiết'),
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