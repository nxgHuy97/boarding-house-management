import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/form_input.dart';

class AddMeterScreen extends StatefulWidget {
  const AddMeterScreen({super.key});

  @override
  State<AddMeterScreen> createState() => _AddMeterScreenState();
}

class _AddMeterScreenState extends State<AddMeterScreen> {
  final monthController = TextEditingController();
  final oldElectricController = TextEditingController();
  final newElectricController = TextEditingController();
  final oldWaterController = TextEditingController();
  final newWaterController = TextEditingController();

  String? selectedRoom;

  static const int electricPrice = 4000;
  static const int waterPrice = 20000;

  @override
  void initState() {
    super.initState();

    if (MockData.rooms.isNotEmpty) {
      selectedRoom = MockData.rooms.first['name'];
    }

    oldElectricController.addListener(_refreshPreview);
    newElectricController.addListener(_refreshPreview);
    oldWaterController.addListener(_refreshPreview);
    newWaterController.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    oldElectricController.removeListener(_refreshPreview);
    newElectricController.removeListener(_refreshPreview);
    oldWaterController.removeListener(_refreshPreview);
    newWaterController.removeListener(_refreshPreview);

    monthController.dispose();
    oldElectricController.dispose();
    newElectricController.dispose();
    oldWaterController.dispose();
    newWaterController.dispose();
    super.dispose();
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  int _toNumber(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  String _formatMoney(int value) {
    final text = value.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return '${text.replaceAllMapped(reg, (match) => '.')}đ';
  }

  Map<String, String> _selectedRoomData() {
    return MockData.rooms.firstWhere(
      (room) => room['name'] == selectedRoom,
      orElse: () => {},
    );
  }

  int get electricUsed {
    final used =
        _toNumber(newElectricController.text) - _toNumber(oldElectricController.text);
    return used < 0 ? 0 : used;
  }

  int get waterUsed {
    final used = _toNumber(newWaterController.text) - _toNumber(oldWaterController.text);
    return used < 0 ? 0 : used;
  }

  int get electricMoney {
    return electricUsed * electricPrice;
  }

  int get waterMoney {
    return waterUsed * waterPrice;
  }

  void _goToMeterList() {
    Navigator.pushReplacementNamed(context, '/owner/meters');
  }

  void _saveMeter() {
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
          content: Text('Vui lòng nhập đầy đủ thông tin điện nước'),
        ),
      );
      return;
    }

    final electricUsedValue = _toNumber(newElectric) - _toNumber(oldElectric);
    final waterUsedValue = _toNumber(newWater) - _toNumber(oldWater);

    if (electricUsedValue < 0 || waterUsedValue < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ số mới không được nhỏ hơn chỉ số cũ'),
        ),
      );
      return;
    }

    final roomData = _selectedRoomData();
    final roomId = roomData['id'] ?? '';

    final existedIndex = MockData.meters.indexWhere(
      (meter) => meter['room'] == room && meter['month'] == month,
    );

    final newMeter = {
      'roomId': roomId,
      'room': room,
      'month': month,

      'oldElectric': oldElectric,
      'newElectric': newElectric,
      'electric': electricUsedValue.toString(),
      'electricPrice': electricPrice.toString(),
      'electricMoney': electricMoney.toString(),

      'oldWater': oldWater,
      'newWater': newWater,
      'water': waterUsedValue.toString(),
      'waterPrice': waterPrice.toString(),
      'waterMoney': waterMoney.toString(),
    };

    setState(() {
      if (existedIndex != -1) {
        MockData.meters[existedIndex] = newMeter;
      } else {
        MockData.meters.add(newMeter);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existedIndex != -1
              ? 'Đã cập nhật chỉ số điện nước'
              : 'Đã thêm chỉ số điện nước',
        ),
      ),
    );

    _goToMeterList();
  }

  @override
  Widget build(BuildContext context) {
    final rooms = MockData.rooms;

    return Scaffold(
      drawer: const AppDrawer(role: 'OWNER'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Nhập chỉ số điện nước',
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
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: Color(0xFFE0E7FF),
                    child: Icon(
                      Icons.speed,
                      color: Color(0xFF1E3A8A),
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Chỉ số điện nước',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Nhập chỉ số cũ và mới, hệ thống sẽ tự tính lượng sử dụng và tiền điện nước',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 24),

                  DropdownButtonFormField<String>(
                    value: selectedRoom,
                    decoration: InputDecoration(
                      labelText: 'Phòng',
                      prefixIcon: const Icon(Icons.meeting_room),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: rooms.map((room) {
                      final roomName = room['name'] ?? '';
                      final tenant = room['tenant'] ?? 'Chưa có';

                      return DropdownMenuItem(
                        value: roomName,
                        child: Text('$roomName - $tenant'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedRoom = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Tháng',
                    icon: Icons.calendar_month,
                    controller: monthController,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Chỉ số điện cũ',
                    icon: Icons.bolt,
                    controller: oldElectricController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Chỉ số điện mới',
                    icon: Icons.bolt,
                    controller: newElectricController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Chỉ số nước cũ',
                    icon: Icons.water_drop,
                    controller: oldWaterController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Chỉ số nước mới',
                    icon: Icons.water_drop,
                    controller: newWaterController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 20),

                  _PreviewBox(
                    electricUsed: electricUsed,
                    waterUsed: waterUsed,
                    electricPrice: electricPrice,
                    waterPrice: waterPrice,
                    electricMoney: electricMoney,
                    waterMoney: waterMoney,
                    formatMoney: _formatMoney,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _goToMeterList,
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _saveMeter,
                          child: const Text('Lưu'),
                        ),
                      ),
                    ],
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

class _PreviewBox extends StatelessWidget {
  final int electricUsed;
  final int waterUsed;
  final int electricPrice;
  final int waterPrice;
  final int electricMoney;
  final int waterMoney;
  final String Function(int value) formatMoney;

  const _PreviewBox({
    required this.electricUsed,
    required this.waterUsed,
    required this.electricPrice,
    required this.waterPrice,
    required this.electricMoney,
    required this.waterMoney,
    required this.formatMoney,
  });

  @override
  Widget build(BuildContext context) {
    final total = electricMoney + waterMoney;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
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
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 12),

          _PreviewLine(
            label: 'Điện sử dụng',
            value: '$electricUsed kWh x ${formatMoney(electricPrice)}',
          ),
          _PreviewLine(
            label: 'Tiền điện',
            value: formatMoney(electricMoney),
          ),
          _PreviewLine(
            label: 'Nước sử dụng',
            value: '$waterUsed m³ x ${formatMoney(waterPrice)}',
          ),
          _PreviewLine(
            label: 'Tiền nước',
            value: formatMoney(waterMoney),
          ),

          const Divider(height: 22),

          _PreviewLine(
            label: 'Tổng điện nước',
            value: formatMoney(total),
            isBold: true,
          ),
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