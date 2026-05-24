import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/form_input.dart';

class AddTenantScreen extends StatefulWidget {
  const AddTenantScreen({super.key});

  @override
  State<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends State<AddTenantScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final cccdController = TextEditingController();
  final addressController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController(text: '123456');

  String? selectedRoom;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    cccdController.dispose();
    addressController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _availableRooms {
    return MockData.rooms.where((room) => room['status'] == 'Trống').toList();
  }

  String _generateTenantId() {
    return 'T${(MockData.tenants.length + 1).toString().padLeft(3, '0')}';
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

  bool _usernameExists(String username) {
    return MockData.users.any(
      (user) => user['username']?.toLowerCase() == username.toLowerCase(),
    );
  }

  void _saveTenant() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final cccd = cccdController.text.trim();
    final address = addressController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        cccd.isEmpty ||
        username.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin người thuê'),
        ),
      );
      return;
    }

    if (selectedRoom == null || selectedRoom!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn phòng trống để gán cho người thuê'),
        ),
      );
      return;
    }

    if (_usernameExists(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username đã tồn tại, vui lòng chọn username khác'),
        ),
      );
      return;
    }

    final tenantId = _generateTenantId();

    final roomIndex = MockData.rooms.indexWhere(
      (room) => room['name'] == selectedRoom,
    );

    if (roomIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy phòng đã chọn'),
        ),
      );
      return;
    }

    final room = MockData.rooms[roomIndex];
    final roomId = room['id'] ?? '';

    MockData.users.add({
      'id': tenantId,
      'username': username,
      'password': password,
      'name': name,
      'email': email,
      'role': 'TENANT',
      'status': 'Hoạt động',
      'createdByOwner': 'Chủ trọ A',
    });

    MockData.tenants.add({
      'id': tenantId,
      'username': username,
      'password': password,
      'name': name,
      'phone': phone,
      'email': email,
      'cccd': cccd,
      'address': address,
      'ownerId': 'O001',
      'owner': 'Chủ trọ A',
      'roomId': roomId,
      'room': selectedRoom!,
      'status': 'Đang thuê',
      'paymentRate': 'Chưa có',
      'avgDelayDays': '0',
      'tenantType': 'new',
    });

    MockData.rooms[roomIndex]['tenantId'] = tenantId;
    MockData.rooms[roomIndex]['tenant'] = name;
    MockData.rooms[roomIndex]['status'] = 'Đang thuê';

    MockData.contracts.add({
      'code': _generateContractCode(),
      'tenantId': tenantId,
      'tenant': name,
      'roomId': roomId,
      'room': selectedRoom!,
      'start': _today(),
      'end': _nextYear(),
      'status': 'Còn hiệu lực',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã tạo tài khoản cho $name. Username: $username, mật khẩu: $password',
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final availableRooms = _availableRooms;

    if (selectedRoom == null && availableRooms.isNotEmpty) {
      selectedRoom = availableRooms.first['name'];
    }

    final hasAvailableRoom = availableRooms.isNotEmpty;

    return Scaffold(
      drawer: const AppDrawer(role: 'OWNER'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Thêm người thuê',
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
                      Icons.person_add,
                      color: Color(0xFF1E3A8A),
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Tạo tài khoản người thuê',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Chủ trọ tạo tài khoản và gán người thuê vào phòng trống',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 24),

                  FormInput(
                    label: 'Họ và tên',
                    icon: Icons.person,
                    controller: nameController,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Số điện thoại',
                    icon: Icons.phone,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Email',
                    icon: Icons.email,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'CCCD',
                    icon: Icons.badge,
                    controller: cccdController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Địa chỉ',
                    icon: Icons.location_on,
                    controller: addressController,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Username đăng nhập',
                    icon: Icons.account_circle,
                    controller: usernameController,
                  ),

                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Mật khẩu mặc định',
                    icon: Icons.lock,
                    controller: passwordController,
                    obscureText: true,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: hasAvailableRoom ? selectedRoom : null,
                    decoration: InputDecoration(
                      labelText: 'Gán vào phòng trống',
                      prefixIcon: const Icon(Icons.meeting_room),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: availableRooms.map((room) {
                      final roomName = room['name'] ?? '';
                      final price = room['price'] ?? '';

                      return DropdownMenuItem(
                        value: roomName,
                        child: Text('$roomName - $price'),
                      );
                    }).toList(),
                    onChanged: hasAvailableRoom
                        ? (value) {
                            if (value == null) return;
                            setState(() {
                              selectedRoom = value;
                            });
                          }
                        : null,
                  ),

                  if (!hasAvailableRoom) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFED7AA),
                        ),
                      ),
                      child: const Text(
                        'Hiện chưa có phòng trống. Vui lòng thêm phòng hoặc đổi trạng thái phòng trước.',
                        style: TextStyle(
                          color: Color(0xFFC2410C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: hasAvailableRoom ? _saveTenant : null,
                          child: const Text('Tạo tài khoản'),
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