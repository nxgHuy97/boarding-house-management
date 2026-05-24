import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/form_input.dart';

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final roomNameController = TextEditingController();
  final areaController = TextEditingController();
  final priceController = TextEditingController();

  final wifiFeeController = TextEditingController(text: '100000');
  final garbageFeeController = TextEditingController(text: '30000');
  final parkingFeeController = TextEditingController(text: '0');
  final otherFeeController = TextEditingController(text: '0');

  String selectedStatus = 'Trống';
  String selectedRoomType = 'Phòng trệt';
  String selectedAirConditioner = 'Không';
  String selectedFurniture = 'Không';

  @override
  void dispose() {
    roomNameController.dispose();
    areaController.dispose();
    priceController.dispose();
    wifiFeeController.dispose();
    garbageFeeController.dispose();
    parkingFeeController.dispose();
    otherFeeController.dispose();
    super.dispose();
  }

  String _generateRoomId() {
    return 'R${(MockData.rooms.length + 1).toString().padLeft(3, '0')}';
  }

  String _onlyNumber(String value) {
    return value
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll('đ', '')
        .replaceAll(' ', '')
        .trim();
  }

  int _toNumber(String value) {
    return int.tryParse(_onlyNumber(value)) ?? 0;
  }

  String _formatMoney(int value) {
    final text = value.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return '${text.replaceAllMapped(reg, (match) => '.')}đ';
  }

  String _formatArea(String value) {
    final text = value.trim();
    if (text.endsWith('m²')) return text;
    return '$text m²';
  }

  String _formatRoomName(String value) {
    final text = value.trim();
    if (text.toLowerCase().startsWith('phòng')) return text;
    return 'Phòng $text';
  }

  String _getRoomNumber(String roomName) {
    return roomName
        .replaceAll('Phòng', '')
        .replaceAll('phòng', '')
        .trim();
  }

  void _saveRoom() {
    final inputRoomName = roomNameController.text.trim();
    final area = areaController.text.trim();
    final price = priceController.text.trim();

    final wifiFee = _toNumber(wifiFeeController.text);
    final garbageFee = _toNumber(garbageFeeController.text);
    final parkingFee = _toNumber(parkingFeeController.text);
    final otherFee = _toNumber(otherFeeController.text);

    if (inputRoomName.isEmpty || area.isEmpty || price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ tên phòng, diện tích và giá thuê'),
        ),
      );
      return;
    }

    final roomName = _formatRoomName(inputRoomName);
    final rentPrice = _toNumber(price);
    final serviceMoney = wifiFee + garbageFee + parkingFee + otherFee;

    MockData.rooms.add({
      'id': _generateRoomId(),
      'name': roomName,
      'roomNumber': _getRoomNumber(roomName),
      'ownerId': 'O001',
      'owner': 'Chủ trọ A',
      'tenantId': '',
      'tenant': 'Chưa có',

      'price': _formatMoney(rentPrice),
      'rentPrice': rentPrice.toString(),
      'status': selectedStatus,
      'area': _formatArea(area),

      'roomType': selectedRoomType,
      'hasAirConditioner': selectedAirConditioner,
      'hasFurniture': selectedFurniture,

      'wifiFee': wifiFee.toString(),
      'garbageFee': garbageFee.toString(),
      'parkingFee': parkingFee.toString(),
      'otherFee': otherFee.toString(),
      'serviceMoney': serviceMoney.toString(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm phòng thành công'),
      ),
    );

    Navigator.pushReplacementNamed(context, '/owner/rooms');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(role: 'OWNER'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Thêm phòng'),
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
                  const Text(
                    'Thông tin phòng',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Chủ trọ tự quy định loại phòng, giá thuê và các khoản tiện ích',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 24),

                  FormInput(
                    label: 'Tên phòng',
                    icon: Icons.meeting_room,
                    controller: roomNameController,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Diện tích',
                    icon: Icons.square_foot,
                    controller: areaController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Giá thuê',
                    icon: Icons.attach_money,
                    controller: priceController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedRoomType,
                    decoration: InputDecoration(
                      labelText: 'Loại phòng',
                      prefixIcon: const Icon(Icons.home_work),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Phòng trệt',
                        child: Text('Phòng trệt'),
                      ),
                      DropdownMenuItem(
                        value: 'Có gác',
                        child: Text('Có gác'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedRoomType = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedAirConditioner,
                    decoration: InputDecoration(
                      labelText: 'Điều hòa',
                      prefixIcon: const Icon(Icons.ac_unit),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Không',
                        child: Text('Không có điều hòa'),
                      ),
                      DropdownMenuItem(
                        value: 'Có',
                        child: Text('Có điều hòa'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedAirConditioner = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedFurniture,
                    decoration: InputDecoration(
                      labelText: 'Nội thất',
                      prefixIcon: const Icon(Icons.chair),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Không',
                        child: Text('Không có nội thất'),
                      ),
                      DropdownMenuItem(
                        value: 'Có',
                        child: Text('Có nội thất'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedFurniture = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Tiền wifi',
                    icon: Icons.wifi,
                    controller: wifiFeeController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Tiền rác',
                    icon: Icons.delete,
                    controller: garbageFeeController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Tiền xe',
                    icon: Icons.directions_bike,
                    controller: parkingFeeController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Dịch vụ khác',
                    icon: Icons.add_business,
                    controller: otherFeeController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Trạng thái',
                      prefixIcon: const Icon(Icons.info),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Trống',
                        child: Text('Trống'),
                      ),
                      DropdownMenuItem(
                        value: 'Bảo trì',
                        child: Text('Bảo trì'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _saveRoom,
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