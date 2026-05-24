import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class TenantRoomInfoScreen extends StatelessWidget {
  const TenantRoomInfoScreen({super.key});

  Map<String, String> _findCurrentTenant() {
    final current = MockData.currentUsername.trim();

    final tenant = MockData.tenants.firstWhere(
      (item) {
        return item['username'] == current || item['name'] == current;
      },
      orElse: () => {},
    );

    if (tenant.isNotEmpty) {
      return tenant;
    }

    return MockData.tenantProfile;
  }

  Map<String, String> _findRoom(Map<String, String> tenant) {
    final roomId = tenant['roomId'] ?? '';
    final roomName = tenant['room'] ?? '';

    return MockData.rooms.firstWhere(
      (room) {
        return room['id'] == roomId || room['name'] == roomName;
      },
      orElse: () => {},
    );
  }

  String _formatMoney(String? value) {
    if (value == null || value.isEmpty) return '0đ';

    final number = int.tryParse(
          value
              .replaceAll('.', '')
              .replaceAll(',', '')
              .replaceAll('đ', '')
              .replaceAll(' ', ''),
        ) ??
        0;

    final text = number.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');

    return '${text.replaceAllMapped(reg, (match) => '.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    final tenant = _findCurrentTenant();
    final room = _findRoom(tenant);

    final roomName = room['name'] ?? tenant['room'] ?? 'Chưa có';
    final owner = room['owner'] ?? tenant['owner'] ?? 'Chưa có';
    final area = room['area'] ?? 'Chưa có';
    final price = room['price'] ?? 'Chưa có';
    final roomType = room['roomType'] ?? 'Chưa có';
    final airConditioner = room['hasAirConditioner'] ?? 'Không';
    final furniture = room['hasFurniture'] ?? 'Không';
    final status = room['status'] ?? 'Chưa có';

    final wifiFee = _formatMoney(room['wifiFee']);
    final garbageFee = _formatMoney(room['garbageFee']);
    final parkingFee = _formatMoney(room['parkingFee']);
    final otherFee = _formatMoney(room['otherFee']);
    final serviceMoney = _formatMoney(room['serviceMoney']);

    return Scaffold(
      drawer: const AppDrawer(role: 'TENANT'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Thông tin phòng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
      ),
      body: Center(
        child: Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            width: 560,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 38,
                    backgroundColor: Color(0xFFE0E7FF),
                    child: Icon(
                      Icons.meeting_room_rounded,
                      color: Color(0xFF1E3A8A),
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    roomName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Chủ trọ: $owner',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _RoomInfoLine(
                    icon: Icons.square_foot,
                    label: 'Diện tích',
                    value: area,
                  ),

                  const SizedBox(height: 14),

                  _RoomInfoLine(
                    icon: Icons.attach_money,
                    label: 'Giá thuê',
                    value: price,
                  ),

                  const SizedBox(height: 14),

                  _RoomInfoLine(
                    icon: Icons.home_work,
                    label: 'Loại phòng',
                    value: roomType,
                  ),

                  const SizedBox(height: 14),

                  _RoomInfoLine(
                    icon: Icons.ac_unit,
                    label: 'Điều hòa',
                    value: airConditioner,
                  ),

                  const SizedBox(height: 14),

                  _RoomInfoLine(
                    icon: Icons.chair,
                    label: 'Nội thất',
                    value: furniture,
                  ),

                  const SizedBox(height: 14),

                  _RoomInfoLine(
                    icon: Icons.info,
                    label: 'Trạng thái phòng',
                    value: status,
                  ),

                  const SizedBox(height: 22),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tiện ích / Dịch vụ hằng tháng',
                          style: TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _ServiceLine(label: 'Wifi', value: wifiFee),
                        _ServiceLine(label: 'Rác', value: garbageFee),
                        _ServiceLine(label: 'Tiền xe', value: parkingFee),
                        _ServiceLine(label: 'Dịch vụ khác', value: otherFee),

                        const Divider(height: 22),

                        _ServiceLine(
                          label: 'Tổng dịch vụ',
                          value: serviceMoney,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomInfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RoomInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFE0E7FF),
          child: Icon(
            icon,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _ServiceLine({
    required this.label,
    required this.value,
    this.isBold = false,
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
              style: TextStyle(
                color: const Color(0xFF374151),
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isBold ? const Color(0xFF1E3A8A) : const Color(0xFF111827),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}