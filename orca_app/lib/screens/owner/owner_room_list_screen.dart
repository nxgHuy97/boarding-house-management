import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class OwnerRoomListScreen extends StatefulWidget {
  const OwnerRoomListScreen({super.key});

  @override
  State<OwnerRoomListScreen> createState() => _OwnerRoomListScreenState();
}

class _OwnerRoomListScreenState extends State<OwnerRoomListScreen> {
  String _onlyNumber(String value) {
    return value
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll('đ', '')
        .replaceAll(' ', '')
        .trim();
  }

  int _toNumber(String? value) {
    if (value == null) return 0;
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

  String _moneyInput(String? value) {
    return value
            ?.replaceAll('.', '')
            .replaceAll('đ', '')
            .replaceAll(',', '')
            .trim() ??
        '';
  }

  String _displayMoneyFromRaw(String? value) {
    final number = _toNumber(value);
    return _formatMoney(number);
  }

  int _serviceTotal(Map<String, String> room) {
    final savedServiceMoney = _toNumber(room['serviceMoney']);

    if (savedServiceMoney > 0) {
      return savedServiceMoney;
    }

    return _toNumber(room['wifiFee']) +
        _toNumber(room['garbageFee']) +
        _toNumber(room['parkingFee']) +
        _toNumber(room['otherFee']);
  }

  void _deleteRoom(int index) {
    final room = MockData.rooms[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa phòng'),
          content: Text('Bạn có chắc muốn xóa ${room['name']} không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  MockData.rooms.removeAt(index);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa phòng'),
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

  void _viewRoom(Map<String, String> room) {
    final serviceTotal = _serviceTotal(room);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chi tiết phòng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoLine(label: 'Phòng', value: room['name'] ?? ''),
              _InfoLine(label: 'Diện tích', value: room['area'] ?? ''),
              _InfoLine(label: 'Giá thuê', value: room['price'] ?? ''),
              _InfoLine(label: 'Loại phòng', value: room['roomType'] ?? 'Phòng trệt'),
              _InfoLine(label: 'Điều hòa', value: room['hasAirConditioner'] ?? 'Không'),
              _InfoLine(label: 'Nội thất', value: room['hasFurniture'] ?? 'Không'),
              _InfoLine(label: 'Wifi', value: _displayMoneyFromRaw(room['wifiFee'])),
              _InfoLine(label: 'Rác', value: _displayMoneyFromRaw(room['garbageFee'])),
              _InfoLine(label: 'Tiền xe', value: _displayMoneyFromRaw(room['parkingFee'])),
              _InfoLine(label: 'Dịch vụ khác', value: _displayMoneyFromRaw(room['otherFee'])),
              _InfoLine(label: 'Tổng dịch vụ', value: _formatMoney(serviceTotal)),
              _InfoLine(label: 'Người thuê', value: room['tenant'] ?? 'Chưa có'),
              _InfoLine(label: 'Trạng thái', value: room['status'] ?? 'Trống'),
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

  void _editRoom(int index) {
    final room = MockData.rooms[index];

    final nameController = TextEditingController(text: room['name']);
    final areaController = TextEditingController(
      text: room['area']?.replaceAll('m²', '').trim(),
    );
    final priceController = TextEditingController(
      text: _moneyInput(room['price'] ?? room['rentPrice']),
    );

    final wifiFeeController = TextEditingController(
      text: _moneyInput(room['wifiFee'] ?? '0'),
    );
    final garbageFeeController = TextEditingController(
      text: _moneyInput(room['garbageFee'] ?? '0'),
    );
    final parkingFeeController = TextEditingController(
      text: _moneyInput(room['parkingFee'] ?? '0'),
    );
    final otherFeeController = TextEditingController(
      text: _moneyInput(room['otherFee'] ?? '0'),
    );

    String selectedStatus = room['status'] ?? 'Trống';
    String selectedRoomType = room['roomType'] ?? 'Phòng trệt';
    String selectedAirConditioner = room['hasAirConditioner'] ?? 'Không';
    String selectedFurniture = room['hasFurniture'] ?? 'Không';

    if (!['Trống', 'Đang thuê', 'Bảo trì'].contains(selectedStatus)) {
      selectedStatus = 'Trống';
    }

    if (!['Phòng trệt', 'Có gác'].contains(selectedRoomType)) {
      selectedRoomType = 'Phòng trệt';
    }

    if (!['Có', 'Không'].contains(selectedAirConditioner)) {
      selectedAirConditioner = 'Không';
    }

    if (!['Có', 'Không'].contains(selectedFurniture)) {
      selectedFurniture = 'Không';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Sửa phòng'),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên phòng',
                          prefixIcon: Icon(Icons.meeting_room),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: areaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Diện tích',
                          prefixIcon: Icon(Icons.square_foot),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá thuê',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedRoomType,
                        decoration: const InputDecoration(
                          labelText: 'Loại phòng',
                          prefixIcon: Icon(Icons.home_work),
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

                          setDialogState(() {
                            selectedRoomType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedAirConditioner,
                        decoration: const InputDecoration(
                          labelText: 'Điều hòa',
                          prefixIcon: Icon(Icons.ac_unit),
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

                          setDialogState(() {
                            selectedAirConditioner = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedFurniture,
                        decoration: const InputDecoration(
                          labelText: 'Nội thất',
                          prefixIcon: Icon(Icons.chair),
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

                          setDialogState(() {
                            selectedFurniture = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: wifiFeeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tiền wifi',
                          prefixIcon: Icon(Icons.wifi),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: garbageFeeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tiền rác',
                          prefixIcon: Icon(Icons.delete),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: parkingFeeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tiền xe',
                          prefixIcon: Icon(Icons.directions_bike),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: otherFeeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Dịch vụ khác',
                          prefixIcon: Icon(Icons.add_business),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          prefixIcon: Icon(Icons.info),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Trống',
                            child: Text('Trống'),
                          ),
                          DropdownMenuItem(
                            value: 'Đang thuê',
                            child: Text('Đang thuê'),
                          ),
                          DropdownMenuItem(
                            value: 'Bảo trì',
                            child: Text('Bảo trì'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setDialogState(() {
                            selectedStatus = value;
                          });
                        },
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
                    final name = nameController.text.trim();
                    final area = areaController.text.trim();
                    final price = priceController.text.trim();

                    final wifiFee = _toNumber(wifiFeeController.text);
                    final garbageFee = _toNumber(garbageFeeController.text);
                    final parkingFee = _toNumber(parkingFeeController.text);
                    final otherFee = _toNumber(otherFeeController.text);
                    final serviceMoney =
                        wifiFee + garbageFee + parkingFee + otherFee;

                    if (name.isEmpty || area.isEmpty || price.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập đủ thông tin phòng'),
                        ),
                      );
                      return;
                    }

                    final formattedName = _formatRoomName(name);
                    final rentPrice = _toNumber(price);

                    setState(() {
                      MockData.rooms[index] = {
                        ...room,
                        'name': formattedName,
                        'roomNumber': _getRoomNumber(formattedName),
                        'area': _formatArea(area),
                        'price': _formatMoney(rentPrice),
                        'rentPrice': rentPrice.toString(),
                        'status': selectedStatus,
                        'ownerId': room['ownerId'] ?? 'O001',
                        'owner': room['owner'] ?? 'Chủ trọ A',
                        'tenantId': selectedStatus == 'Trống'
                            ? ''
                            : room['tenantId'] ?? '',
                        'tenant': selectedStatus == 'Trống'
                            ? 'Chưa có'
                            : room['tenant'] ?? 'Chưa có',
                        'roomType': selectedRoomType,
                        'hasAirConditioner': selectedAirConditioner,
                        'hasFurniture': selectedFurniture,
                        'wifiFee': wifiFee.toString(),
                        'garbageFee': garbageFee.toString(),
                        'parkingFee': parkingFee.toString(),
                        'otherFee': otherFee.toString(),
                        'serviceMoney': serviceMoney.toString(),
                      };
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật phòng'),
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

  Color _statusBgColor(String status) {
    if (status == 'Trống') return const Color(0xFFDCFCE7);
    if (status == 'Bảo trì') return const Color(0xFFFEE2E2);
    return const Color(0xFFE0E7FF);
  }

  Color _statusTextColor(String status) {
    if (status == 'Trống') return const Color(0xFF16A34A);
    if (status == 'Bảo trì') return const Color(0xFFDC2626);
    return const Color(0xFF1E3A8A);
  }

  @override
  Widget build(BuildContext context) {
    final rooms = MockData.rooms;

    return Scaffold(
      drawer: const AppDrawer(role: 'OWNER'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Quản lý phòng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/owner/rooms/add');
              setState(() {});
            },
            icon: const Icon(Icons.add),
          ),
        ],
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
                final roomType = room['roomType'] ?? 'Phòng trệt';
                final ac = room['hasAirConditioner'] ?? 'Không';
                final furniture = room['hasFurniture'] ?? 'Không';
                final serviceTotal = _serviceTotal(room);

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
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${room['area']} • ${room['price']} • $roomType\n'
                        'Điều hòa: $ac • Nội thất: $furniture • Dịch vụ: ${_formatMoney(serviceTotal)}\n'
                        'Người thuê: ${room['tenant'] ?? 'Chưa có'}',
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
                            color: _statusBgColor(status),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _statusTextColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'view') {
                              _viewRoom(room);
                            } else if (value == 'assign') {
                              Navigator.pushNamed(
                                context,
                                '/owner/tenants/add',
                              ).then((_) {
                                setState(() {});
                              });
                            } else if (value == 'edit') {
                              _editRoom(index);
                            } else if (value == 'delete') {
                              _deleteRoom(index);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Text('Chi tiết'),
                            ),
                            if (status == 'Trống')
                              const PopupMenuItem(
                                value: 'assign',
                                child: Text('Gán người thuê'),
                              ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Sửa'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Xóa'),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
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