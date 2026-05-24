import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  final List<String> accountRoles = const [
    'ADMIN',
    'OWNER',
  ];

  final List<String> statuses = const [
    'Hoạt động',
    'Chờ duyệt',
    'Đã khóa',
  ];

  String _roleCode(Map<String, String> user) {
    final role = user['role'] ?? '';

    if (role == 'ADMIN') return 'ADMIN';
    if (role == 'OWNER' || role.contains('CHỦ TRỌ') || role.contains('KHÁCH HÀNG')) {
      return 'OWNER';
    }
    if (role == 'TENANT' || role.contains('NGƯỜI THUÊ')) {
      return 'TENANT';
    }

    return role;
  }

  String _roleText(String role) {
    if (role == 'ADMIN') return 'Quản trị viên';
    if (role == 'OWNER') return 'Khách hàng / Chủ trọ';
    if (role == 'TENANT') return 'Người thuê';
    return role;
  }

  bool _isAdmin(Map<String, String> user) => _roleCode(user) == 'ADMIN';

  bool _isOwner(Map<String, String> user) => _roleCode(user) == 'OWNER';

  bool _isTenant(Map<String, String> user) => _roleCode(user) == 'TENANT';

  String _generateUserId(String role) {
    final prefix = role == 'ADMIN'
        ? 'A'
        : role == 'OWNER'
            ? 'O'
            : 'T';

    return '$prefix${(MockData.users.length + 1).toString().padLeft(3, '0')}';
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

  void _viewUser(Map<String, String> user) {
    final role = _roleCode(user);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chi tiết tài khoản'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoLine(label: 'ID', value: user['id'] ?? ''),
              _InfoLine(label: 'Username', value: user['username'] ?? ''),
              _InfoLine(label: 'Tên', value: user['name'] ?? ''),
              _InfoLine(label: 'Email', value: user['email'] ?? ''),
              _InfoLine(label: 'Vai trò', value: _roleText(role)),
              _InfoLine(label: 'Trạng thái', value: user['status'] ?? ''),
              _InfoLine(
                label: 'Mật khẩu',
                value: user['password'] ?? '123456',
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

  void _addUser() {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController(text: '123456');

    String selectedRole = 'OWNER';
    String selectedStatus = 'Chờ duyệt';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (selectedRole == 'ADMIN' && selectedStatus == 'Chờ duyệt') {
              selectedStatus = 'Hoạt động';
            }

            return AlertDialog(
              title: const Text('Thêm tài khoản'),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'Admin chỉ thêm tài khoản hệ thống hoặc Chủ trọ. Người thuê sẽ do Chủ trọ tạo.',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ tên',
                          prefixIcon: Icon(Icons.person),
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
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: Icon(Icons.lock_reset),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Vai trò',
                          prefixIcon: Icon(Icons.badge),
                        ),
                        items: accountRoles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(_roleText(role)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setDialogState(() {
                            selectedRole = value;
                            selectedStatus =
                                selectedRole == 'OWNER' ? 'Chờ duyệt' : 'Hoạt động';
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          prefixIcon: Icon(Icons.info),
                        ),
                        items: statuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
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
                    final username = usernameController.text.trim();
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();

                    if (name.isEmpty ||
                        username.isEmpty ||
                        email.isEmpty ||
                        password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập đầy đủ thông tin'),
                        ),
                      );
                      return;
                    }

                    if (_usernameExists(username)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Username đã tồn tại'),
                        ),
                      );
                      return;
                    }

                    if (_emailExists(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email đã tồn tại'),
                        ),
                      );
                      return;
                    }

                    final newUser = {
                      'id': _generateUserId(selectedRole),
                      'username': username,
                      'password': password,
                      'name': name,
                      'email': email,
                      'role': selectedRole,
                      'status': selectedStatus,
                    };

                    setState(() {
                      MockData.users.add(newUser);
                      _syncRelatedData(newUser);
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã thêm tài khoản'),
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

  void _editUser(int index) {
    final user = MockData.users[index];
    final oldEmail = user['email'] ?? '';
    final oldUsername = user['username'] ?? '';
    final oldRole = _roleCode(user);

    final nameController = TextEditingController(text: user['name']);
    final usernameController = TextEditingController(text: oldUsername);
    final emailController = TextEditingController(text: oldEmail);

    String selectedStatus = user['status'] ?? 'Hoạt động';

    if (!statuses.contains(selectedStatus)) {
      selectedStatus = 'Hoạt động';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Sửa tài khoản'),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ tên',
                          prefixIcon: Icon(Icons.person),
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
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Vai trò',
                          prefixIcon: const Icon(Icons.badge),
                          hintText: _roleText(oldRole),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          prefixIcon: Icon(Icons.info),
                        ),
                        items: statuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
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
                    final username = usernameController.text.trim();
                    final email = emailController.text.trim();

                    if (name.isEmpty || username.isEmpty || email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập đầy đủ thông tin'),
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
                          content: Text('Email đã được tài khoản khác sử dụng'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _removeRelatedDataByEmail(oldEmail);

                      MockData.users[index] = {
                        ...user,
                        'username': username,
                        'name': name,
                        'email': email,
                        'role': oldRole,
                        'status': selectedStatus,
                      };

                      _syncRelatedData(MockData.users[index]);
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật tài khoản'),
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
    final user = MockData.users[index];
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
                  'Reset mật khẩu cho: ${user['name']}',
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
                  MockData.users[index]['password'] = newPassword;
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã reset mật khẩu của ${user['name']} thành: $newPassword',
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

  void _approveOwner(int index) {
    final user = MockData.users[index];

    if (!_isOwner(user)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin chỉ phê duyệt tài khoản Chủ trọ'),
        ),
      );
      return;
    }

    setState(() {
      MockData.users[index]['status'] = 'Hoạt động';
      _syncRelatedData(MockData.users[index]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã phê duyệt tài khoản Chủ trọ'),
      ),
    );
  }

  void _lockUser(int index) {
    setState(() {
      MockData.users[index]['status'] = 'Đã khóa';
      _syncRelatedData(MockData.users[index]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã khóa tài khoản'),
      ),
    );
  }

  void _unlockUser(int index) {
    setState(() {
      MockData.users[index]['status'] = 'Hoạt động';
      _syncRelatedData(MockData.users[index]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã mở khóa tài khoản'),
      ),
    );
  }

  void _deleteUser(int index) {
    final user = MockData.users[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa tài khoản'),
          content: Text('Bạn có chắc muốn xóa ${user['name']} không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _removeRelatedDataByEmail(user['email'] ?? '');
                  MockData.users.removeAt(index);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa tài khoản'),
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

  void _syncRelatedData(Map<String, String> user) {
    final role = _roleCode(user);
    final id = user['id'] ?? '';
    final name = user['name'] ?? '';
    final email = user['email'] ?? '';
    final status = user['status'] ?? '';

    if (email.isEmpty) return;

    if (role == 'OWNER') {
      final ownerIndex = MockData.owners.indexWhere(
        (owner) => owner['email'] == email,
      );

      final ownerData = {
        'id': id,
        'name': name,
        'email': email,
        'phone': user['phone'] ?? '',
        'status': status,
        'roomCount': '0',
        'bankName': user['bankName'] ?? '',
        'bankAccount': user['bankAccount'] ?? '',
        'bankOwner': user['bankOwner'] ?? '',
        'bankQr': user['bankQr'] ?? '',
      };

      if (ownerIndex == -1) {
        MockData.owners.add(ownerData);
      } else {
        MockData.owners[ownerIndex] = {
          ...MockData.owners[ownerIndex],
          ...ownerData,
        };
      }
    }

    if (role == 'TENANT') {
      final tenantIndex = MockData.tenants.indexWhere(
        (tenant) => tenant['email'] == email,
      );

      if (tenantIndex != -1) {
        MockData.tenants[tenantIndex]['name'] = name;
        MockData.tenants[tenantIndex]['email'] = email;
        MockData.tenants[tenantIndex]['status'] = status;
      }
    }
  }

  void _removeRelatedDataByEmail(String email) {
    if (email.isEmpty) return;

    MockData.owners.removeWhere(
      (owner) => owner['email'] == email,
    );

    // Không xóa tenant ở đây để tránh mất dữ liệu nghiệp vụ/phòng/hợp đồng.
    // Tenant do Owner tạo và quản lý nghiệp vụ.
  }

  Color _statusBg(String status) {
    if (status == 'Hoạt động') return const Color(0xFFDCFCE7);
    if (status == 'Chờ duyệt') return const Color(0xFFFFEDD5);
    return const Color(0xFFFEE2E2);
  }

  Color _statusColor(String status) {
    if (status == 'Hoạt động') return const Color(0xFF16A34A);
    if (status == 'Chờ duyệt') return const Color(0xFFF97316);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final admins = MockData.users.where(_isAdmin).toList();
    final owners = MockData.users.where(_isOwner).toList();
    final tenants = MockData.users.where(_isTenant).toList();

    return Scaffold(
      drawer: const AppDrawer(role: 'ADMIN'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Quản lý tài khoản',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
        actions: [
          IconButton(
            onPressed: _addUser,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _UserSection(
              title: 'Admin',
              subtitle: 'Tài khoản quản trị hệ thống',
              users: admins,
              getOriginalIndex: (user) => MockData.users.indexOf(user),
              onView: _viewUser,
              onEdit: _editUser,
              onResetPassword: _resetPassword,
              onDelete: _deleteUser,
              onApprove: _approveOwner,
              onLock: _lockUser,
              onUnlock: _unlockUser,
              statusBg: _statusBg,
              statusColor: _statusColor,
            ),
            const SizedBox(height: 20),
            _UserSection(
              title: 'Owner / Chủ trọ',
              subtitle: 'Admin phê duyệt tài khoản Chủ trọ',
              users: owners,
              getOriginalIndex: (user) => MockData.users.indexOf(user),
              onView: _viewUser,
              onEdit: _editUser,
              onResetPassword: _resetPassword,
              onDelete: _deleteUser,
              onApprove: _approveOwner,
              onLock: _lockUser,
              onUnlock: _unlockUser,
              statusBg: _statusBg,
              statusColor: _statusColor,
            ),
            const SizedBox(height: 20),
            _UserSection(
              title: 'Tenant / Người thuê',
              subtitle: 'Người thuê do Chủ trọ tạo, Admin không phê duyệt Tenant',
              users: tenants,
              getOriginalIndex: (user) => MockData.users.indexOf(user),
              onView: _viewUser,
              onEdit: _editUser,
              onResetPassword: _resetPassword,
              onDelete: _deleteUser,
              onApprove: _approveOwner,
              onLock: _lockUser,
              onUnlock: _unlockUser,
              statusBg: _statusBg,
              statusColor: _statusColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Map<String, String>> users;
  final int Function(Map<String, String> user) getOriginalIndex;
  final void Function(Map<String, String> user) onView;
  final void Function(int index) onEdit;
  final void Function(int index) onResetPassword;
  final void Function(int index) onDelete;
  final void Function(int index) onApprove;
  final void Function(int index) onLock;
  final void Function(int index) onUnlock;
  final Color Function(String status) statusBg;
  final Color Function(String status) statusColor;

  const _UserSection({
    required this.title,
    required this.subtitle,
    required this.users,
    required this.getOriginalIndex,
    required this.onView,
    required this.onEdit,
    required this.onResetPassword,
    required this.onDelete,
    required this.onApprove,
    required this.onLock,
    required this.onUnlock,
    required this.statusBg,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: title,
          subtitle: '$subtitle • ${users.length} tài khoản',
        ),
        const SizedBox(height: 12),
        if (users.isEmpty)
          const _EmptyBox(message: 'Chưa có tài khoản nào')
        else
          ...users.map((user) {
            final originalIndex = getOriginalIndex(user);

            return _UserCard(
              user: user,
              originalIndex: originalIndex,
              onView: onView,
              onEdit: onEdit,
              onResetPassword: onResetPassword,
              onDelete: onDelete,
              onApprove: onApprove,
              onLock: onLock,
              onUnlock: onUnlock,
              statusBg: statusBg,
              statusColor: statusColor,
            );
          }),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, String> user;
  final int originalIndex;
  final void Function(Map<String, String> user) onView;
  final void Function(int index) onEdit;
  final void Function(int index) onResetPassword;
  final void Function(int index) onDelete;
  final void Function(int index) onApprove;
  final void Function(int index) onLock;
  final void Function(int index) onUnlock;
  final Color Function(String status) statusBg;
  final Color Function(String status) statusColor;

  const _UserCard({
    required this.user,
    required this.originalIndex,
    required this.onView,
    required this.onEdit,
    required this.onResetPassword,
    required this.onDelete,
    required this.onApprove,
    required this.onLock,
    required this.onUnlock,
    required this.statusBg,
    required this.statusColor,
  });

  String _roleCode(String role) {
    if (role == 'ADMIN') return 'ADMIN';
    if (role == 'OWNER' || role.contains('CHỦ TRỌ') || role.contains('KHÁCH HÀNG')) {
      return 'OWNER';
    }
    if (role == 'TENANT' || role.contains('NGƯỜI THUÊ')) {
      return 'TENANT';
    }

    return role;
  }

  String _roleText(String role) {
    if (role == 'ADMIN') return 'Quản trị viên';
    if (role == 'OWNER') return 'Khách hàng / Chủ trọ';
    if (role == 'TENANT') return 'Người thuê';
    return role;
  }

  IconData _roleIcon(String role) {
    if (role == 'ADMIN') return Icons.admin_panel_settings;
    if (role == 'OWNER') return Icons.apartment;
    return Icons.person;
  }

  @override
  Widget build(BuildContext context) {
    final status = user['status'] ?? '';
    final role = _roleCode(user['role'] ?? '');
    final isOwnerAccount = role == 'OWNER';

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0E7FF),
          child: Icon(
            _roleIcon(role),
            color: const Color(0xFF1E3A8A),
          ),
        ),
        title: Text(
          user['name'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${user['username'] ?? ''} • ${user['email'] ?? ''} • ${_roleText(role)}',
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
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
                color: statusBg(status),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor(status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'view') {
                  onView(user);
                } else if (value == 'edit') {
                  onEdit(originalIndex);
                } else if (value == 'reset') {
                  onResetPassword(originalIndex);
                } else if (value == 'approve') {
                  onApprove(originalIndex);
                } else if (value == 'lock') {
                  onLock(originalIndex);
                } else if (value == 'unlock') {
                  onUnlock(originalIndex);
                } else if (value == 'delete') {
                  onDelete(originalIndex);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('Xem'),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Sửa tài khoản'),
                ),
                const PopupMenuItem(
                  value: 'reset',
                  child: Text('Reset mật khẩu'),
                ),
                if (status == 'Chờ duyệt' && isOwnerAccount)
                  const PopupMenuItem(
                    value: 'approve',
                    child: Text('Phê duyệt Chủ trọ'),
                  ),
                if (status != 'Đã khóa')
                  const PopupMenuItem(
                    value: 'lock',
                    child: Text('Khóa tài khoản'),
                  ),
                if (status == 'Đã khóa')
                  const PopupMenuItem(
                    value: 'unlock',
                    child: Text('Mở khóa tài khoản'),
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

class _EmptyBox extends StatelessWidget {
  final String message;

  const _EmptyBox({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}