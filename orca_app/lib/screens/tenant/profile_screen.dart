import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/form_input.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _userIndexByTenant(Map<String, String> tenant) {
    final tenantId = tenant['id'] ?? '';
    final username = tenant['username'] ?? '';
    final email = tenant['email'] ?? '';
    final name = tenant['name'] ?? '';

    return MockData.users.indexWhere((user) {
      return user['role'] == 'TENANT' &&
          ((tenantId.isNotEmpty && user['id'] == tenantId) ||
              (username.isNotEmpty && user['username'] == username) ||
              (email.isNotEmpty && user['email'] == email) ||
              (name.isNotEmpty && user['name'] == name));
    });
  }

  int _tenantIndex() {
    final current = MockData.currentUsername.trim();

    final userIndex = MockData.users.indexWhere((user) {
      return user['role'] == 'TENANT' &&
          (user['username'] == current || user['name'] == current);
    });

    if (userIndex != -1) {
      final user = MockData.users[userIndex];

      final tenantIndex = MockData.tenants.indexWhere((tenant) {
        return tenant['id'] == user['id'] ||
            tenant['username'] == user['username'] ||
            tenant['email'] == user['email'] ||
            tenant['name'] == user['name'];
      });

      if (tenantIndex != -1) {
        return tenantIndex;
      }
    }

    final profileId = MockData.tenantProfile['id'];
    final profileName = MockData.tenantProfile['name'];

    final byProfile = MockData.tenants.indexWhere((tenant) {
      return tenant['id'] == profileId || tenant['name'] == profileName;
    });

    return byProfile;
  }

  Map<String, String> get _tenant {
    final index = _tenantIndex();

    if (index != -1) {
      return MockData.tenants[index];
    }

    return MockData.tenantProfile;
  }

  String _usernameOf(Map<String, String> tenant) {
    final username = tenant['username'] ?? '';

    if (username.isNotEmpty) {
      return username;
    }

    final userIndex = _userIndexByTenant(tenant);

    if (userIndex != -1) {
      return MockData.users[userIndex]['username'] ?? '';
    }

    return MockData.tenantProfile['username'] ?? '';
  }

  String _accountStatusOf(Map<String, String> tenant) {
    final userIndex = _userIndexByTenant(tenant);

    if (userIndex != -1) {
      return MockData.users[userIndex]['status'] ?? 'Hoạt động';
    }

    return tenant['accountStatus'] ?? 'Hoạt động';
  }

  void _updateLinkedData({
    required String oldName,
    required String newName,
    required String newEmail,
    required String newPhone,
    required String newCccd,
    required String newAddress,
  }) {
    for (final invoice in MockData.invoices) {
      if (invoice['tenant'] == oldName) {
        invoice['tenant'] = newName;
      }
    }

    for (final payment in MockData.payments) {
      if (payment['tenant'] == oldName) {
        payment['tenant'] = newName;
      }
    }

    for (final contract in MockData.contracts) {
      if (contract['tenant'] == oldName) {
        contract['tenant'] = newName;
      }
    }

    for (final room in MockData.rooms) {
      if (room['tenant'] == oldName) {
        room['tenant'] = newName;
      }
    }

    MockData.tenantProfile['name'] = newName;
    MockData.tenantProfile['email'] = newEmail;
    MockData.tenantProfile['phone'] = newPhone;
    MockData.tenantProfile['cccd'] = newCccd;
    MockData.tenantProfile['address'] = newAddress;
  }

  void _editProfile() {
    final tenant = _tenant;
    final oldName = tenant['name'] ?? '';

    final nameController = TextEditingController(text: tenant['name']);
    final phoneController = TextEditingController(text: tenant['phone']);
    final emailController = TextEditingController(text: tenant['email']);
    final cccdController = TextEditingController(text: tenant['cccd']);
    final addressController = TextEditingController(text: tenant['address']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cập nhật hồ sơ cá nhân'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FormInput(
                    label: 'Họ và tên',
                    icon: Icons.person,
                    controller: nameController,
                  ),
                  const SizedBox(height: 14),
                  FormInput(
                    label: 'Số điện thoại',
                    icon: Icons.phone,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  FormInput(
                    label: 'Email',
                    icon: Icons.email,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  FormInput(
                    label: 'CCCD',
                    icon: Icons.badge,
                    controller: cccdController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  FormInput(
                    label: 'Địa chỉ',
                    icon: Icons.location_on,
                    controller: addressController,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Username, vai trò, phòng đang thuê và trạng thái tài khoản không thể chỉnh sửa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
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
                final newName = nameController.text.trim();
                final newPhone = phoneController.text.trim();
                final newEmail = emailController.text.trim();
                final newCccd = cccdController.text.trim();
                final newAddress = addressController.text.trim();

                if (newName.isEmpty ||
                    newPhone.isEmpty ||
                    newEmail.isEmpty ||
                    newCccd.isEmpty ||
                    newAddress.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập đầy đủ thông tin'),
                    ),
                  );
                  return;
                }

                setState(() {
                  final tenantIndex = _tenantIndex();

                  if (tenantIndex != -1) {
                    MockData.tenants[tenantIndex]['name'] = newName;
                    MockData.tenants[tenantIndex]['phone'] = newPhone;
                    MockData.tenants[tenantIndex]['email'] = newEmail;
                    MockData.tenants[tenantIndex]['cccd'] = newCccd;
                    MockData.tenants[tenantIndex]['address'] = newAddress;

                    final userIndex = _userIndexByTenant(
                      MockData.tenants[tenantIndex],
                    );

                    if (userIndex != -1) {
                      MockData.users[userIndex]['name'] = newName;
                      MockData.users[userIndex]['email'] = newEmail;
                    }
                  }

                  _updateLinkedData(
                    oldName: oldName,
                    newName: newName,
                    newEmail: newEmail,
                    newPhone: newPhone,
                    newCccd: newCccd,
                    newAddress: newAddress,
                  );

                  if (MockData.currentUsername == oldName) {
                    MockData.currentUsername = newName;
                  }
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật hồ sơ cá nhân'),
                  ),
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Color _statusColor(String status) {
    if (status == 'Hoạt động' || status == 'Đang thuê') {
      return const Color(0xFF16A34A);
    }

    if (status == 'Chờ duyệt') {
      return const Color(0xFFF97316);
    }

    return const Color(0xFFDC2626);
  }

  Color _statusBg(String status) {
    if (status == 'Hoạt động' || status == 'Đang thuê') {
      return const Color(0xFFDCFCE7);
    }

    if (status == 'Chờ duyệt') {
      return const Color(0xFFFFEDD5);
    }

    return const Color(0xFFFEE2E2);
  }

  @override
  Widget build(BuildContext context) {
    final tenant = _tenant;

    final name = tenant['name'] ?? 'Người thuê';
    final username = _usernameOf(tenant);
    final email = tenant['email'] ?? '';
    final phone = tenant['phone'] ?? '';
    final cccd = tenant['cccd'] ?? 'Chưa có';
    final address = tenant['address'] ?? 'Chưa có';
    final room = tenant['room'] ?? 'Chưa gán phòng';
    final rentStatus = tenant['status'] ?? 'Đang thuê';
    final accountStatus = _accountStatusOf(tenant);

    return Scaffold(
      drawer: const AppDrawer(role: 'TENANT'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Hồ sơ cá nhân',
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
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: 560,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: Color(0xFFE0E7FF),
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF1E3A8A),
                      size: 44,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _StatusChip(
                        label: rentStatus,
                        bgColor: _statusBg(rentStatus),
                        textColor: _statusColor(rentStatus),
                      ),
                      _StatusChip(
                        label: 'TK: $accountStatus',
                        bgColor: _statusBg(accountStatus),
                        textColor: _statusColor(accountStatus),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  _ProfileLine(
                    icon: Icons.account_circle,
                    label: 'Username',
                    value: username,
                    readOnly: true,
                  ),

                  const SizedBox(height: 16),

                  const _ProfileLine(
                    icon: Icons.badge,
                    label: 'Vai trò',
                    value: 'Người thuê',
                    readOnly: true,
                  ),

                  const SizedBox(height: 16),

                  _ProfileLine(
                    icon: Icons.email,
                    label: 'Email',
                    value: email,
                  ),

                  const SizedBox(height: 16),

                  _ProfileLine(
                    icon: Icons.phone,
                    label: 'Số điện thoại',
                    value: phone,
                  ),

                  const SizedBox(height: 16),

                  _ProfileLine(
                    icon: Icons.credit_card,
                    label: 'CCCD',
                    value: cccd,
                  ),

                  const SizedBox(height: 16),

                  _ProfileLine(
                    icon: Icons.location_on,
                    label: 'Địa chỉ',
                    value: address,
                  ),

                  const SizedBox(height: 16),

                  _ProfileLine(
                    icon: Icons.meeting_room,
                    label: 'Phòng đang thuê',
                    value: room,
                    readOnly: true,
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _editProfile,
                      icon: const Icon(Icons.edit),
                      label: const Text('Cập nhật hồ sơ'),
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

class _StatusChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _StatusChip({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ProfileLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool readOnly;

  const _ProfileLine({
    required this.icon,
    required this.label,
    required this.value,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor:
              readOnly ? const Color(0xFFF3F4F6) : const Color(0xFFE0E7FF),
          child: Icon(
            icon,
            color: readOnly ? const Color(0xFF6B7280) : const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                  if (readOnly) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ],
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