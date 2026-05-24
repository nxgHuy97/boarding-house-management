import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class AdminRoomListScreen extends StatelessWidget {
  const AdminRoomListScreen({super.key});

  void _viewRoomDetail(BuildContext context, Map<String, String> room) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chi tiết phòng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoLine(label: 'Tên phòng', value: room['name'] ?? ''),
              _InfoLine(label: 'Chủ trọ', value: room['owner'] ?? 'Chưa xác định'),
              _InfoLine(label: 'Người thuê', value: room['tenant'] ?? 'Chưa có'),
              _InfoLine(label: 'Diện tích', value: room['area'] ?? ''),
              _InfoLine(label: 'Giá thuê', value: room['price'] ?? ''),
              _InfoLine(label: 'Trạng thái', value: room['status'] ?? ''),
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
    if (status == 'Trống') return const Color(0xFFDCFCE7);
    if (status == 'Bảo trì') return const Color(0xFFFEE2E2);
    return const Color(0xFFE0E7FF);
  }

  Color _statusColor(String status) {
    if (status == 'Trống') return const Color(0xFF16A34A);
    if (status == 'Bảo trì') return const Color(0xFFDC2626);
    return const Color(0xFF1E3A8A);
  }

  @override
  Widget build(BuildContext context) {
    final rooms = MockData.rooms;

    return Scaffold(
      drawer: const AppDrawer(role: 'ADMIN'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Danh sách phòng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
      ),
      body: rooms.isEmpty
          ? const Center(
              child: Text(
                'Chưa có phòng nào',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                final status = room['status'] ?? 'Trống';

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
                        Icons.meeting_room,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    title: Text(
                      room['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chủ trọ: ${room['owner'] ?? 'Chưa xác định'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${room['area']} • ${room['price']} • Người thuê: ${room['tenant'] ?? 'Chưa có'}',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
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
                        IconButton(
                          onPressed: () {
                            _viewRoomDetail(context, room);
                          },
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
            width: 95,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}