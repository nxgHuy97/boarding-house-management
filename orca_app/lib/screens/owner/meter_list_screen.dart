import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class OwnerMeterListScreen extends StatefulWidget {
  const OwnerMeterListScreen({super.key});

  @override
  State<OwnerMeterListScreen> createState() => _OwnerMeterListScreenState();
}

class _OwnerMeterListScreenState extends State<OwnerMeterListScreen> {
  static const int defaultElectricPrice = 4000;
  static const int defaultWaterPrice = 20000;

  int _toNumber(String? value) {
    if (value == null) return 0;

    return int.tryParse(
          value
              .replaceAll('.', '')
              .replaceAll(',', '')
              .replaceAll('đ', '')
              .replaceAll(' ', '')
              .trim(),
        ) ??
        0;
  }

  String _formatMoney(int value) {
    final text = value.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return '${text.replaceAllMapped(reg, (match) => '.')}đ';
  }

  String _findRoomId(String roomName) {
    final room = MockData.rooms.firstWhere(
      (room) => room['name'] == roomName,
      orElse: () => {'id': ''},
    );

    return room['id'] ?? '';
  }

  int _electricPrice(Map<String, String> meter) {
    final price = _toNumber(meter['electricPrice']);
    return price > 0 ? price : defaultElectricPrice;
  }

  int _waterPrice(Map<String, String> meter) {
    final price = _toNumber(meter['waterPrice']);
    return price > 0 ? price : defaultWaterPrice;
  }

  int _electricMoney(Map<String, String> meter) {
    final savedMoney = _toNumber(meter['electricMoney']);

    if (savedMoney > 0) {
      return savedMoney;
    }

    return _toNumber(meter['electric']) * _electricPrice(meter);
  }

  int _waterMoney(Map<String, String> meter) {
    final savedMoney = _toNumber(meter['waterMoney']);

    if (savedMoney > 0) {
      return savedMoney;
    }

    return _toNumber(meter['water']) * _waterPrice(meter);
  }

  void _viewMeter(Map<String, String> meter) {
    final electricPrice = _electricPrice(meter);
    final waterPrice = _waterPrice(meter);
    final electricMoney = _electricMoney(meter);
    final waterMoney = _waterMoney(meter);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chi tiết điện nước'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoLine(label: 'Phòng', value: meter['room'] ?? ''),
              _InfoLine(label: 'Tháng', value: meter['month'] ?? ''),
              _InfoLine(label: 'Điện cũ', value: meter['oldElectric'] ?? ''),
              _InfoLine(label: 'Điện mới', value: meter['newElectric'] ?? ''),
              _InfoLine(label: 'Điện dùng', value: '${meter['electric']} kWh'),
              _InfoLine(label: 'Đơn giá điện', value: _formatMoney(electricPrice)),
              _InfoLine(label: 'Tiền điện', value: _formatMoney(electricMoney)),
              _InfoLine(label: 'Nước cũ', value: meter['oldWater'] ?? ''),
              _InfoLine(label: 'Nước mới', value: meter['newWater'] ?? ''),
              _InfoLine(label: 'Nước dùng', value: '${meter['water']} m³'),
              _InfoLine(label: 'Đơn giá nước', value: _formatMoney(waterPrice)),
              _InfoLine(label: 'Tiền nước', value: _formatMoney(waterMoney)),
              _InfoLine(
                label: 'Tổng tiền',
                value: _formatMoney(electricMoney + waterMoney),
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

  void _editMeter(int index) {
    final meter = MockData.meters[index];

    final monthController = TextEditingController(text: meter['month']);
    final oldElectricController =
        TextEditingController(text: meter['oldElectric']);
    final newElectricController =
        TextEditingController(text: meter['newElectric']);
    final oldWaterController = TextEditingController(text: meter['oldWater']);
    final newWaterController = TextEditingController(text: meter['newWater']);

    final roomNames = MockData.rooms
        .map((room) => room['name'] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    String? selectedRoom = meter['room'];

    if (selectedRoom == null || !roomNames.contains(selectedRoom)) {
      selectedRoom = roomNames.isNotEmpty ? roomNames.first : null;
    }

    int previewElectricUsed() {
      final used =
          _toNumber(newElectricController.text) - _toNumber(oldElectricController.text);
      return used < 0 ? 0 : used;
    }

    int previewWaterUsed() {
      final used = _toNumber(newWaterController.text) - _toNumber(oldWaterController.text);
      return used < 0 ? 0 : used;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final electricUsed = previewElectricUsed();
            final waterUsed = previewWaterUsed();
            final electricMoney = electricUsed * defaultElectricPrice;
            final waterMoney = waterUsed * defaultWaterPrice;

            return AlertDialog(
              title: const Text('Sửa chỉ số điện nước'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedRoom,
                        decoration: const InputDecoration(
                          labelText: 'Phòng',
                          prefixIcon: Icon(Icons.meeting_room),
                        ),
                        items: roomNames.map((roomName) {
                          return DropdownMenuItem(
                            value: roomName,
                            child: Text(roomName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setDialogState(() {
                            selectedRoom = value;
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: monthController,
                        decoration: const InputDecoration(
                          labelText: 'Tháng',
                          hintText: 'Ví dụ: 05/2026',
                          prefixIcon: Icon(Icons.calendar_month),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: oldElectricController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Chỉ số điện cũ',
                          prefixIcon: Icon(Icons.bolt),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: newElectricController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Chỉ số điện mới',
                          prefixIcon: Icon(Icons.bolt),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: oldWaterController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Chỉ số nước cũ',
                          prefixIcon: Icon(Icons.water_drop),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: newWaterController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Chỉ số nước mới',
                          prefixIcon: Icon(Icons.water_drop),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),

                      const SizedBox(height: 16),

                      Container(
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
                              'Tiền điện nước tạm tính',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _PreviewLine(
                              label: 'Tiền điện',
                              value:
                                  '$electricUsed kWh x ${_formatMoney(defaultElectricPrice)} = ${_formatMoney(electricMoney)}',
                            ),
                            _PreviewLine(
                              label: 'Tiền nước',
                              value:
                                  '$waterUsed m³ x ${_formatMoney(defaultWaterPrice)} = ${_formatMoney(waterMoney)}',
                            ),
                            const Divider(),
                            _PreviewLine(
                              label: 'Tổng',
                              value: _formatMoney(electricMoney + waterMoney),
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
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
                    final room = selectedRoom;
                    final month = monthController.text.trim();
                    final oldElectric = oldElectricController.text.trim();
                    final newElectric = newElectricController.text.trim();
                    final oldWater = oldWaterController.text.trim();
                    final newWater = newWaterController.text.trim();

                    if (room == null ||
                        room.isEmpty ||
                        month.isEmpty ||
                        oldElectric.isEmpty ||
                        newElectric.isEmpty ||
                        oldWater.isEmpty ||
                        newWater.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập đầy đủ thông tin'),
                        ),
                      );
                      return;
                    }

                    final electricUsed =
                        _toNumber(newElectric) - _toNumber(oldElectric);
                    final waterUsed = _toNumber(newWater) - _toNumber(oldWater);

                    if (electricUsed < 0 || waterUsed < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chỉ số mới không được nhỏ hơn chỉ số cũ'),
                        ),
                      );
                      return;
                    }

                    final electricMoney = electricUsed * defaultElectricPrice;
                    final waterMoney = waterUsed * defaultWaterPrice;

                    setState(() {
                      MockData.meters[index] = {
                        'roomId': _findRoomId(room),
                        'room': room,
                        'month': month,

                        'oldElectric': oldElectric,
                        'newElectric': newElectric,
                        'electric': electricUsed.toString(),
                        'electricPrice': defaultElectricPrice.toString(),
                        'electricMoney': electricMoney.toString(),

                        'oldWater': oldWater,
                        'newWater': newWater,
                        'water': waterUsed.toString(),
                        'waterPrice': defaultWaterPrice.toString(),
                        'waterMoney': waterMoney.toString(),
                      };
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật chỉ số điện nước'),
                      ),
                    );
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteMeter(int index) {
    final meter = MockData.meters[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa chỉ số điện nước'),
          content: Text(
            'Bạn có chắc muốn xóa chỉ số của ${meter['room']} - Tháng ${meter['month']} không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  MockData.meters.removeAt(index);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa chỉ số điện nước'),
                  ),
                );
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final meters = MockData.meters;

    return Scaffold(
      drawer: const AppDrawer(role: 'OWNER'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Quản lý điện nước',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/owner/meters/add');
              setState(() {});
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: meters.isEmpty
          ? const Center(
              child: Text(
                'Chưa có chỉ số điện nước nào',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meters.length,
              itemBuilder: (context, index) {
                final meter = meters[index];

                final electricMoney = _electricMoney(meter);
                final waterMoney = _waterMoney(meter);

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
                        Icons.speed,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    title: Text(
                      '${meter['room']} - Tháng ${meter['month']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Điện: ${meter['oldElectric']} → ${meter['newElectric']} = ${meter['electric']} kWh • ${_formatMoney(electricMoney)}\n'
                        'Nước: ${meter['oldWater']} → ${meter['newWater']} = ${meter['water']} m³ • ${_formatMoney(waterMoney)}',
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'view') {
                          _viewMeter(meter);
                        } else if (value == 'edit') {
                          _editMeter(index);
                        } else if (value == 'delete') {
                          _deleteMeter(index);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'view',
                          child: Text('Xem'),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Sửa'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Xóa'),
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
            width: 120,
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

class _PreviewLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _PreviewLine({
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