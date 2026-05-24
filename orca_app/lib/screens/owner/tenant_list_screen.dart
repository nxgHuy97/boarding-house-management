import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class OwnerTenantListScreen extends StatefulWidget {
  const OwnerTenantListScreen({super.key});

  @override
  State<OwnerTenantListScreen> createState() => _OwnerTenantListScreenState();
}

class _OwnerTenantListScreenState extends State<OwnerTenantListScreen> {
  List<int> get _ownerTenantIndexes {
    final result = <int>[];

    for (int i = 0; i < MockData.tenants.length; i++) {
      final tenant = MockData.tenants[i];

      final ownerId = tenant['ownerId'] ?? '';
      final owner = tenant['owner'] ?? '';

      if (ownerId == 'O001' || owner == 'Chủ trọ A' || ownerId.isEmpty) {
        result.add(i);
      }
    }

    return result;
  }

  List<String> _availableRoomsForTenant(String currentRoom) {
    final rooms = MockData.rooms
        .where((room) {
          final roomName = room['name'] ?? '';
          final status = room['status'] ?? '';

          return status == 'Trống' || roomName == currentRoom;
        })
        .map((room) => room['name'] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    return [
      'Chưa gán phòng',
      ...rooms,
    ];
  }

  String _generateContractCode() {
    return 'HDONG${(MockData.contracts.length + 1).toString().padLeft(3, '0')}';
  }

  String _today() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _nextYear() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year + 1}';
  }

  int _findUserIndexByTenant(Map<String, String> tenant) {
    final tenantId = tenant['id'] ?? '';
    final username = tenant['username'] ?? '';
    final email = tenant['email'] ?? '';

    return MockData.users.indexWhere((user) {
      return (tenantId.isNotEmpty && user['id'] == tenantId) ||
          (username.isNotEmpty && user['username'] == username) ||
          (email.isNotEmpty && user['email'] == email);
    });
  }

  String _accountStatus(Map<String, String> tenant) {
    final userIndex = _findUserIndexByTenant(tenant);

    if (userIndex == -1) {
      return tenant['accountStatus'] ?? 'Hoạt động';
    }

    return MockData.users[userIndex]['status'] ?? 'Hoạt động';
  }

  String _accountPassword(Map<String, String> tenant) {
    final userIndex = _findUserIndexByTenant(tenant);

    if (userIndex == -1) {
      return tenant['password'] ?? '123456';
    }

    return MockData.users[userIndex]['password'] ?? '123456';
  }

  bool _usernameExists(String username, {String? oldUsername}) {
    return MockData.users.any((user) {
      final currentUsername = user['username'] ?? '';

      return currentUsername.toLowerCase() == username.toLowerCase() &&
          currentUsername != oldUsername;
    });
  }

  bool _emailExists(String email, {String? oldEmail}) {
    return MockData.users.any((user) {
      final currentEmail = user['email'] ?? '';

      return currentEmail.toLowerCase() == email.toLowerCase() &&
          currentEmail != oldEmail;
    });
  }

  void _viewTenant(Map<String, String> tenant) {
    final accountStatus = _accountStatus(tenant);
    final password = _accountPassword(tenant);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chi tiết người thuê'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoLine(label: 'Họ tên', value: tenant['name'] ?? ''),
              _InfoLine(label: 'Username', value: tenant['username'] ?? ''),
              _InfoLine(label: 'Mật khẩu', value: password),
              _InfoLine(label: 'SĐT', value: tenant['phone'] ?? ''),
              _InfoLine(label: 'Email', value: tenant['email'] ?? ''),
              _InfoLine(label: 'CCCD', value: tenant['cccd'] ?? ''),
              _InfoLine(label: 'Địa chỉ', value: tenant['address'] ?? ''),
              _InfoLine(label: 'Phòng', value: tenant['room'] ?? ''),
              _InfoLine(label: 'Trạng thái thuê', value: tenant['status'] ?? ''),
              _InfoLine(label: 'Trạng thái TK', value: accountStatus),
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

  void _viewPaymentHistory(Map<String, String> tenant) {
    final tenantId = tenant['id'] ?? '';
    final tenantName = tenant['name'] ?? '';

    final invoices = MockData.invoices.where((invoice) {
      return invoice['tenantId'] == tenantId || invoice['tenant'] == tenantName;
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Lịch sử thanh toán - $tenantName'),
          content: SizedBox(
            width: 520,
            child: invoices.isEmpty
                ? const Text('Người thuê này chưa có hóa đơn/thanh toán nào.')
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: invoices.map((invoice) {
                        final status = invoice['status'] ?? '';
                        final isPaid = invoice['statusCode'] == 'paid' ||
                            status == 'Đã thanh toán';

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${invoice['code']} - Tháng ${invoice['month']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('Phòng: ${invoice['room']}'),
                              Text('Tổng tiền: ${invoice['amount']}'),
                              Text('Hạn thanh toán: ${invoice['dueDate'] ?? ''}'),
                              Text(
                                'Ngày thanh toán: ${invoice['paidDate']?.isNotEmpty == true ? invoice['paidDate'] : 'Chưa có'}',
                              ),
                              Text(
                                'Hình thức: ${invoice['paymentMethod']?.isNotEmpty == true ? invoice['paymentMethod'] : 'Chưa có'}',
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFFEDD5),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: isPaid
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFF97316),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
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

  void _editTenant(int index) {
    final oldTenant = MockData.tenants[index];

    final oldName = oldTenant['name'] ?? '';
    final oldEmail = oldTenant['email'] ?? '';
    final oldUsername = oldTenant['username'] ?? '';
    final oldRoom = oldTenant['room'] ?? 'Chưa gán phòng';

    final nameController = TextEditingController(text: oldTenant['name']);
    final phoneController = TextEditingController(text: oldTenant['phone']);
    final emailController = TextEditingController(text: oldTenant['email']);
    final cccdController = TextEditingController(text: oldTenant['cccd']);
    final addressController = TextEditingController(text: oldTenant['address']);
    final usernameController = TextEditingController(text: oldUsername);

    String selectedRoom = oldRoom;
    String selectedStatus = oldTenant['status'] ?? 'Đang thuê';

    final roomNames = _availableRoomsForTenant(oldRoom);

    if (!roomNames.contains(selectedRoom)) {
      selectedRoom = 'Chưa gán phòng';
    }

    final validStatuses = [
      'Đang thuê',
      'Đã rời đi',
    ];

    if (!validStatuses.contains(selectedStatus)) {
      selectedStatus = 'Đang thuê';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Sửa người thuê'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: cccdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'CCCD',
                          prefixIcon: Icon(Icons.badge),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.account_circle),
                        ),
                      ),
                      const SizedBox(height: 14),
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

                            if (selectedRoom != 'Chưa gán phòng') {
                              selectedStatus = 'Đang thuê';
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái thuê',
                          prefixIcon: Icon(Icons.info),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Đang thuê',
                            child: Text('Đang thuê'),
                          ),
                          DropdownMenuItem(
                            value: 'Đã rời đi',
                            child: Text('Đã rời đi'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setDialogState(() {
                            selectedStatus = value;

                            if (selectedStatus == 'Đã rời đi') {
                              selectedRoom = 'Chưa gán phòng';
                            }
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
                    final newName = nameController.text.trim();
                    final phone = phoneController.text.trim();
                    final email = emailController.text.trim();
                    final cccd = cccdController.text.trim();
                    final address = addressController.text.trim();
                    final username = usernameController.text.trim();

                    if (newName.isEmpty ||
                        phone.isEmpty ||
                        email.isEmpty ||
                        cccd.isEmpty ||
                        username.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập đầy đủ thông tin'),
                        ),
                      );
                      return;
                    }

                    if (selectedStatus == 'Đang thuê' &&
                        selectedRoom == 'Chưa gán phòng') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Người thuê đang thuê thì phải chọn phòng'),
                        ),
                      );
                      return;
                    }

                    if (_usernameExists(username, oldUsername: oldUsername)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Username đã tồn tại'),
                        ),
                      );
                      return;
                    }

                    if (_emailExists(email, oldEmail: oldEmail)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email đã tồn tại'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _clearOldRoomAndContracts(oldName);

                      final tenantId = oldTenant['id'] ?? '';
                      final roomId = _findRoomId(selectedRoom);

                      MockData.tenants[index] = {
                        ...oldTenant,
                        'name': newName,
                        'phone': phone,
                        'email': email,
                        'cccd': cccd,
                        'address': address,
                        'username': username,
                        'ownerId': oldTenant['ownerId'] ?? 'O001',
                        'owner': oldTenant['owner'] ?? 'Chủ trọ A',
                        'roomId': selectedRoom == 'Chưa gán phòng' ? '' : roomId,
                        'room': selectedRoom,
                        'status': selectedStatus,
                      };

                      final userIndex = _findUserIndexByTenant(oldTenant);

                      if (userIndex != -1) {
                        MockData.users[userIndex]['name'] = newName;
                        MockData.users[userIndex]['email'] = email;
                        MockData.users[userIndex]['username'] = username;
                        MockData.users[userIndex]['role'] = 'TENANT';
                      }

                      if (selectedStatus == 'Đang thuê' &&
                          selectedRoom != 'Chưa gán phòng') {
                        _assignRoomToTenant(
                          tenantId: tenantId,
                          tenantName: newName,
                          roomName: selectedRoom,
                        );

                        _createContractIfNotExists(
                          tenantId: tenantId,
                          tenantName: newName,
                          roomId: roomId,
                          roomName: selectedRoom,
                        );
                      }
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật người thuê'),
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

  void _resetPassword(int index) {
    final tenant = MockData.tenants[index];
    final passwordController = TextEditingController(text: '123456');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset mật khẩu'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reset mật khẩu cho: ${tenant['name']}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu mới',
                    prefixIcon: Icon(Icons.lock_reset),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                final newPassword = passwordController.text.trim();

                if (newPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập mật khẩu mới'),
                    ),
                  );
                  return;
                }

                setState(() {
                  MockData.tenants[index]['password'] = newPassword;

                  final userIndex = _findUserIndexByTenant(tenant);

                  if (userIndex != -1) {
                    MockData.users[userIndex]['password'] = newPassword;
                  }
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã reset mật khẩu của ${tenant['name']} thành: $newPassword',
                    ),
                  ),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _lockAccount(int index) {
    final tenant = MockData.tenants[index];

    setState(() {
      final userIndex = _findUserIndexByTenant(tenant);

      if (userIndex != -1) {
        MockData.users[userIndex]['status'] = 'Đã khóa';
      }

      MockData.tenants[index]['accountStatus'] = 'Đã khóa';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã khóa tài khoản người thuê'),
      ),
    );
  }

  void _unlockAccount(int index) {
    final tenant = MockData.tenants[index];

    setState(() {
      final userIndex = _findUserIndexByTenant(tenant);

      if (userIndex != -1) {
        MockData.users[userIndex]['status'] = 'Hoạt động';
      }

      MockData.tenants[index]['accountStatus'] = 'Hoạt động';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã mở khóa tài khoản người thuê'),
      ),
    );
  }

  void _deleteTenant(int index) {
    final tenant = MockData.tenants[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa người thuê'),
          content: Text('Bạn có chắc muốn xóa ${tenant['name']} không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  final tenantName = tenant['name'] ?? '';
                  final userIndex = _findUserIndexByTenant(tenant);

                  _clearOldRoomAndContracts(tenantName);

                  if (userIndex != -1) {
                    MockData.users.removeAt(userIndex);
                  }

                  MockData.tenants.removeAt(index);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa người thuê'),
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

  String _findRoomId(String roomName) {
    final room = MockData.rooms.firstWhere(
      (room) => room['name'] == roomName,
      orElse: () => {'id': ''},
    );

    return room['id'] ?? '';
  }

  void _clearOldRoomAndContracts(String tenantName) {
    for (final room in MockData.rooms) {
      if (room['tenant'] == tenantName) {
        room['tenant'] = 'Chưa có';
        room['tenantId'] = '';
        room['status'] = 'Trống';
      }
    }

    MockData.contracts.removeWhere(
      (contract) => contract['tenant'] == tenantName,
    );
  }

  void _assignRoomToTenant({
    required String tenantId,
    required String tenantName,
    required String roomName,
  }) {
    final roomIndex = MockData.rooms.indexWhere(
      (room) => room['name'] == roomName,
    );

    if (roomIndex != -1) {
      MockData.rooms[roomIndex]['tenantId'] = tenantId;
      MockData.rooms[roomIndex]['tenant'] = tenantName;
      MockData.rooms[roomIndex]['status'] = 'Đang thuê';
    }
  }

  void _createContractIfNotExists({
    required String tenantId,
    required String tenantName,
    required String roomId,
    required String roomName,
  }) {
    final exists = MockData.contracts.any(
      (contract) =>
          contract['tenant'] == tenantName &&
          contract['room'] == roomName &&
          contract['status'] == 'Còn hiệu lực',
    );

    if (exists) return;

    MockData.contracts.add({
      'code': _generateContractCode(),
      'tenantId': tenantId,
      'tenant': tenantName,
      'roomId': roomId,
      'room': roomName,
      'start': _today(),
      'end': _nextYear(),
      'status': 'Còn hiệu lực',
    });
  }

  Color _tenantStatusBg(String status) {
    if (status == 'Đang thuê') return const Color(0xFFDCFCE7);
    if (status == 'Đã rời đi') return const Color(0xFFFEE2E2);
    return const Color(0xFFE0E7FF);
  }

  Color _tenantStatusColor(String status) {
    if (status == 'Đang thuê') return const Color(0xFF16A34A);
    if (status == 'Đã rời đi') return const Color(0xFFDC2626);
    return const Color(0xFF1E3A8A);
  }

  Color _accountStatusBg(String status) {
    if (status == 'Đã khóa') return const Color(0xFFFEE2E2);
    return const Color(0xFFDCFCE7);
  }

  Color _accountStatusColor(String status) {
    if (status == 'Đã khóa') return const Color(0xFFDC2626);
    return const Color(0xFF16A34A);
  }

  @override
  Widget build(BuildContext context) {
    final tenantIndexes = _ownerTenantIndexes;

    return Scaffold(
      drawer: const AppDrawer(role: 'OWNER'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Quản lý người thuê',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/owner/tenants/add',
              );

              if (result == true) {
                setState(() {});
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: tenantIndexes.isEmpty
          ? const Center(
              child: Text(
                'Chưa có người thuê nào',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tenantIndexes.length,
              itemBuilder: (context, index) {
                final originalIndex = tenantIndexes[index];
                final tenant = MockData.tenants[originalIndex];

                final tenantStatus = tenant['status'] ?? 'Đang thuê';
                final accountStatus = _accountStatus(tenant);
                final isLocked = accountStatus == 'Đã khóa';

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
                        Icons.person,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    title: Text(
                      tenant['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${tenant['phone']} • ${tenant['email']}\nPhòng: ${tenant['room'] ?? 'Chưa gán phòng'}',
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
                            color: _tenantStatusBg(tenantStatus),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tenantStatus,
                            style: TextStyle(
                              color: _tenantStatusColor(tenantStatus),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _accountStatusBg(accountStatus),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            accountStatus,
                            style: TextStyle(
                              color: _accountStatusColor(accountStatus),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'view') {
                              _viewTenant(tenant);
                            } else if (value == 'history') {
                              _viewPaymentHistory(tenant);
                            } else if (value == 'reset') {
                              _resetPassword(originalIndex);
                            } else if (value == 'lock') {
                              _lockAccount(originalIndex);
                            } else if (value == 'unlock') {
                              _unlockAccount(originalIndex);
                            } else if (value == 'edit') {
                              _editTenant(originalIndex);
                            } else if (value == 'delete') {
                              _deleteTenant(originalIndex);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Text('Xem chi tiết'),
                            ),
                            const PopupMenuItem(
                              value: 'history',
                              child: Text('Lịch sử thanh toán'),
                            ),
                            const PopupMenuItem(
                              value: 'reset',
                              child: Text('Reset mật khẩu'),
                            ),
                            if (!isLocked)
                              const PopupMenuItem(
                                value: 'lock',
                                child: Text('Khóa tài khoản'),
                              ),
                            if (isLocked)
                              const PopupMenuItem(
                                value: 'unlock',
                                child: Text('Mở khóa tài khoản'),
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