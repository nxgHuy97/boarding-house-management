import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class OwnerContractListScreen extends StatefulWidget {
  const OwnerContractListScreen({super.key});

  @override
  State<OwnerContractListScreen> createState() =>
      _OwnerContractListScreenState();
}

class _OwnerContractListScreenState extends State<OwnerContractListScreen> {
  String _generateContractCode() {
    return 'HDONG${(MockData.contracts.length + 1).toString().padLeft(3, '0')}';
  }

  List<String> get _tenantNames {
    return MockData.tenants
        .map((tenant) => tenant['name'] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  List<String> get _roomNames {
    return MockData.rooms
        .map((room) => room['name'] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  void _syncRoomAndTenant({
    required String tenantName,
    required String roomName,
    required String status,
  }) {
    if (status != 'Còn hiệu lực') return;

    final roomIndex = MockData.rooms.indexWhere(
      (room) => room['name'] == roomName,
    );

    if (roomIndex != -1) {
      MockData.rooms[roomIndex]['tenant'] = tenantName;
      MockData.rooms[roomIndex]['status'] = 'Đang thuê';
    }

    final tenantIndex = MockData.tenants.indexWhere(
      (tenant) => tenant['name'] == tenantName,
    );

    if (tenantIndex != -1) {
      MockData.tenants[tenantIndex]['room'] = roomName;
      MockData.tenants[tenantIndex]['status'] = 'Đang thuê';
    }
  }

  void _viewContract(Map<String, String> contract) {
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

  void _addContract() {
    final startController = TextEditingController();
    final endController = TextEditingController();

    String selectedTenant =
        _tenantNames.isNotEmpty ? _tenantNames.first : 'Chưa có người thuê';
    String selectedRoom =
        _roomNames.isNotEmpty ? _roomNames.first : 'Chưa có phòng';
    String selectedStatus = 'Còn hiệu lực';

    final code = _generateContractCode();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Thêm hợp đồng'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Mã hợp đồng',
                          hintText: code,
                          prefixIcon: const Icon(Icons.description),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedTenant,
                        decoration: const InputDecoration(
                          labelText: 'Người thuê',
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _tenantNames.map((tenant) {
                          return DropdownMenuItem(
                            value: tenant,
                            child: Text(tenant),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() {
                            selectedTenant = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedRoom,
                        decoration: const InputDecoration(
                          labelText: 'Phòng',
                          prefixIcon: Icon(Icons.meeting_room),
                        ),
                        items: _roomNames.map((room) {
                          return DropdownMenuItem(
                            value: room,
                            child: Text(room),
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
                        controller: startController,
                        decoration: const InputDecoration(
                          labelText: 'Ngày bắt đầu',
                          hintText: 'Ví dụ: 01/06/2026',
                          prefixIcon: Icon(Icons.calendar_month),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: endController,
                        decoration: const InputDecoration(
                          labelText: 'Ngày kết thúc',
                          hintText: 'Ví dụ: 01/06/2027',
                          prefixIcon: Icon(Icons.event),
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
                            value: 'Còn hiệu lực',
                            child: Text('Còn hiệu lực'),
                          ),
                          DropdownMenuItem(
                            value: 'Hết hạn',
                            child: Text('Hết hạn'),
                          ),
                          DropdownMenuItem(
                            value: 'Đã hủy',
                            child: Text('Đã hủy'),
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
                    final start = startController.text.trim();
                    final end = endController.text.trim();

                    if (start.isEmpty || end.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập ngày bắt đầu và kết thúc'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      MockData.contracts.add({
                        'code': code,
                        'tenant': selectedTenant,
                        'room': selectedRoom,
                        'start': start,
                        'end': end,
                        'status': selectedStatus,
                      });

                      _syncRoomAndTenant(
                        tenantName: selectedTenant,
                        roomName: selectedRoom,
                        status: selectedStatus,
                      );
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã thêm hợp đồng'),
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

  void _editContract(int index) {
    final contract = MockData.contracts[index];

    final startController = TextEditingController(text: contract['start']);
    final endController = TextEditingController(text: contract['end']);

    String selectedTenant = contract['tenant'] ?? _tenantNames.first;
    String selectedRoom = contract['room'] ?? _roomNames.first;
    String selectedStatus = contract['status'] ?? 'Còn hiệu lực';

    if (!_tenantNames.contains(selectedTenant)) {
      selectedTenant = _tenantNames.isNotEmpty ? _tenantNames.first : '';
    }

    if (!_roomNames.contains(selectedRoom)) {
      selectedRoom = _roomNames.isNotEmpty ? _roomNames.first : '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Sửa hợp đồng'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Mã hợp đồng',
                          hintText: contract['code'],
                          prefixIcon: const Icon(Icons.description),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedTenant,
                        decoration: const InputDecoration(
                          labelText: 'Người thuê',
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _tenantNames.map((tenant) {
                          return DropdownMenuItem(
                            value: tenant,
                            child: Text(tenant),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() {
                            selectedTenant = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedRoom,
                        decoration: const InputDecoration(
                          labelText: 'Phòng',
                          prefixIcon: Icon(Icons.meeting_room),
                        ),
                        items: _roomNames.map((room) {
                          return DropdownMenuItem(
                            value: room,
                            child: Text(room),
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
                        controller: startController,
                        decoration: const InputDecoration(
                          labelText: 'Ngày bắt đầu',
                          prefixIcon: Icon(Icons.calendar_month),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: endController,
                        decoration: const InputDecoration(
                          labelText: 'Ngày kết thúc',
                          prefixIcon: Icon(Icons.event),
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
                            value: 'Còn hiệu lực',
                            child: Text('Còn hiệu lực'),
                          ),
                          DropdownMenuItem(
                            value: 'Hết hạn',
                            child: Text('Hết hạn'),
                          ),
                          DropdownMenuItem(
                            value: 'Đã hủy',
                            child: Text('Đã hủy'),
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
                    final start = startController.text.trim();
                    final end = endController.text.trim();

                    if (start.isEmpty || end.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập đủ thông tin'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      MockData.contracts[index] = {
                        'code': contract['code'] ?? '',
                        'tenant': selectedTenant,
                        'room': selectedRoom,
                        'start': start,
                        'end': end,
                        'status': selectedStatus,
                      };

                      _syncRoomAndTenant(
                        tenantName: selectedTenant,
                        roomName: selectedRoom,
                        status: selectedStatus,
                      );
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật hợp đồng'),
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

  void _deleteContract(int index) {
    final contract = MockData.contracts[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa hợp đồng'),
          content: Text('Bạn có chắc muốn xóa ${contract['code']} không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  MockData.contracts.removeAt(index);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa hợp đồng'),
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

  Color _statusBg(String status) {
    if (status == 'Còn hiệu lực') return const Color(0xFFDCFCE7);
    if (status == 'Hết hạn') return const Color(0xFFFFEDD5);
    return const Color(0xFFFEE2E2);
  }

  Color _statusColor(String status) {
    if (status == 'Còn hiệu lực') return const Color(0xFF16A34A);
    if (status == 'Hết hạn') return const Color(0xFFF97316);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final contracts = MockData.contracts;

    return Scaffold(
      drawer: const AppDrawer(role: 'OWNER'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Quản lý hợp đồng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
        actions: [
          IconButton(
            onPressed: _addContract,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
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
                '${contract['code']} - ${contract['tenant']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${contract['room']} • ${contract['start']} → ${contract['end']}',
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
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'view') {
                        _viewContract(contract);
                      } else if (value == 'edit') {
                        _editContract(index);
                      } else if (value == 'delete') {
                        _deleteContract(index);
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