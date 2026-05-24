import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/form_input.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final monthController = TextEditingController();

  String? selectedRoom;

  @override
  void initState() {
    super.initState();

    final rooms = _rentedRooms;

    if (rooms.isNotEmpty) {
      selectedRoom = rooms.first['name'];
    }

    monthController.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    monthController.removeListener(_refreshPreview);
    monthController.dispose();
    super.dispose();
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  List<Map<String, String>> get _rentedRooms {
    return MockData.rooms.where((room) {
      final status = room['status'] ?? '';
      final tenant = room['tenant'] ?? '';

      return status == 'Đang thuê' &&
          tenant.isNotEmpty &&
          tenant != 'Chưa có' &&
          tenant != 'Chưa gán người thuê';
    }).toList();
  }

  String _generateInvoiceCode() {
    return 'HD${(MockData.invoices.length + 1).toString().padLeft(3, '0')}';
  }

  String _today() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _dueDateFromMonth(String month) {
    final parts = month.split('/');

    if (parts.length != 2) {
      return '';
    }

    final monthNumber = int.tryParse(parts[0]);
    final yearNumber = int.tryParse(parts[1]);

    if (monthNumber == null || yearNumber == null) {
      return '';
    }

    final lastDay = DateTime(yearNumber, monthNumber + 1, 0).day;

    return '${lastDay.toString().padLeft(2, '0')}/${monthNumber.toString().padLeft(2, '0')}/$yearNumber';
  }

  int _toNumber(String? value) {
    if (value == null) return 0;

    return int.tryParse(
          value
              .replaceAll('.', '')
              .replaceAll(',', '')
              .replaceAll('đ', '')
              .replaceAll('/kWh', '')
              .replaceAll('/m³', '')
              .replaceAll('/tháng', '')
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

  Map<String, String>? _findRoom(String roomName) {
    try {
      return MockData.rooms.firstWhere(
        (room) => room['name'] == roomName,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, String>? _findMeter({
    required String roomName,
    required String month,
  }) {
    try {
      return MockData.meters.firstWhere((meter) {
        final sameRoom = meter['room'] == roomName;
        final sameMonth = meter['month'] == month;

        return sameRoom && sameMonth;
      });
    } catch (_) {
      return null;
    }
  }

  Map<String, String>? get _selectedRoomData {
    final roomName = selectedRoom;

    if (roomName == null || roomName.isEmpty) {
      return null;
    }

    return _findRoom(roomName);
  }

  Map<String, String>? get _selectedMeterData {
    final roomName = selectedRoom;
    final month = monthController.text.trim();

    if (roomName == null || roomName.isEmpty || month.isEmpty) {
      return null;
    }

    return _findMeter(
      roomName: roomName,
      month: month,
    );
  }

  int get _roomPrice {
    final room = _selectedRoomData;

    if (room == null) return 0;

    final rentPrice = _toNumber(room['rentPrice']);

    if (rentPrice > 0) {
      return rentPrice;
    }

    return _toNumber(room['price']);
  }

  int get _wifiFee {
    return _toNumber(_selectedRoomData?['wifiFee']);
  }

  int get _garbageFee {
    return _toNumber(_selectedRoomData?['garbageFee']);
  }

  int get _parkingFee {
    return _toNumber(_selectedRoomData?['parkingFee']);
  }

  int get _otherFee {
    return _toNumber(_selectedRoomData?['otherFee']);
  }

  int get _serviceMoney {
    final room = _selectedRoomData;

    if (room == null) return 0;

    final savedServiceMoney = _toNumber(room['serviceMoney']);

    if (savedServiceMoney > 0) {
      return savedServiceMoney;
    }

    return _wifiFee + _garbageFee + _parkingFee + _otherFee;
  }

  int get _electricMoney {
    final meter = _selectedMeterData;

    if (meter == null) return 0;

    final savedMoney = _toNumber(meter['electricMoney']);

    if (savedMoney > 0) {
      return savedMoney;
    }

    final electric = _toNumber(meter['electric']);
    final electricPrice = _toNumber(meter['electricPrice']) > 0
        ? _toNumber(meter['electricPrice'])
        : 4000;

    return electric * electricPrice;
  }

  int get _waterMoney {
    final meter = _selectedMeterData;

    if (meter == null) return 0;

    final savedMoney = _toNumber(meter['waterMoney']);

    if (savedMoney > 0) {
      return savedMoney;
    }

    final water = _toNumber(meter['water']);
    final waterPrice = _toNumber(meter['waterPrice']) > 0
        ? _toNumber(meter['waterPrice'])
        : 20000;

    return water * waterPrice;
  }

  int get _totalAmount {
    return _roomPrice + _serviceMoney + _electricMoney + _waterMoney;
  }

  String get _tenantName {
    final room = _selectedRoomData;

    if (room == null) return 'Chưa có';

    return room['tenant'] ?? 'Chưa có';
  }

  String get _tenantId {
    final room = _selectedRoomData;

    if (room == null) return '';

    return room['tenantId'] ?? '';
  }

  String get _roomId {
    final room = _selectedRoomData;

    if (room == null) return '';

    return room['id'] ?? '';
  }

  bool _invoiceExists(String roomName, String month) {
    return MockData.invoices.any((invoice) {
      return invoice['room'] == roomName && invoice['month'] == month;
    });
  }

  void _createInvoice() {
    final roomName = selectedRoom;
    final month = monthController.text.trim();

    if (roomName == null || roomName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn phòng'),
        ),
      );
      return;
    }

    if (month.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tháng lập hóa đơn'),
        ),
      );
      return;
    }

    if (_tenantName == 'Chưa có' || _tenantName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phòng này chưa có người thuê, không thể tạo hóa đơn'),
        ),
      );
      return;
    }

    if (_selectedMeterData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Chưa có chỉ số điện nước của phòng trong tháng này. Vui lòng nhập điện nước trước.',
          ),
        ),
      );
      return;
    }

    if (_invoiceExists(roomName, month)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hóa đơn của phòng này trong tháng đã tồn tại'),
        ),
      );
      return;
    }

    final dueDate = _dueDateFromMonth(month);

    MockData.invoices.add({
      'code': _generateInvoiceCode(),
      'ownerId': 'O001',
      'roomId': _roomId,
      'room': roomName,
      'tenantId': _tenantId,
      'tenant': _tenantName,
      'month': month,
      'createdDate': _today(),
      'dueDate': dueDate,
      'roomPrice': _formatMoney(_roomPrice),
      'electricMoney': _formatMoney(_electricMoney),
      'waterMoney': _formatMoney(_waterMoney),
      'serviceMoney': _formatMoney(_serviceMoney),
      'amount': _formatMoney(_totalAmount),
      'paymentMethod': '',
      'proofImage': '',
      'paidDate': '',
      'status': 'Chưa thanh toán',
      'statusCode': 'unpaid',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã tạo hóa đơn thành công'),
      ),
    );

    Navigator.pushReplacementNamed(context, '/owner/invoices');
  }

  @override
  Widget build(BuildContext context) {
    final rooms = _rentedRooms;
    final month = monthController.text.trim();
    final meter = _selectedMeterData;
    final room = _selectedRoomData;

    return Scaffold(
      drawer: const AppDrawer(role: 'OWNER'),
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Tạo hóa đơn',
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
            width: 600,
            padding: const EdgeInsets.all(24),
            child: rooms.isEmpty
                ? const _EmptyState()
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 34,
                          backgroundColor: Color(0xFFE0E7FF),
                          child: Icon(
                            Icons.receipt_long,
                            color: Color(0xFF1E3A8A),
                            size: 34,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Tạo hóa đơn tự động',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Chỉ cần chọn phòng và tháng, hệ thống tự lấy tiền phòng, dịch vụ, điện nước và người thuê.',
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
                          label: 'Tháng lập hóa đơn',
                          icon: Icons.calendar_month,
                          controller: monthController,
                        ),

                        const SizedBox(height: 20),

                        _InvoicePreviewBox(
                          room: room,
                          meter: meter,
                          month: month,
                          tenantName: _tenantName,
                          roomPrice: _roomPrice,
                          wifiFee: _wifiFee,
                          garbageFee: _garbageFee,
                          parkingFee: _parkingFee,
                          otherFee: _otherFee,
                          serviceMoney: _serviceMoney,
                          electricMoney: _electricMoney,
                          waterMoney: _waterMoney,
                          totalAmount: _totalAmount,
                          formatMoney: _formatMoney,
                        ),

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
                                onPressed: _createInvoice,
                                child: const Text('Tạo hóa đơn'),
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

class _InvoicePreviewBox extends StatelessWidget {
  final Map<String, String>? room;
  final Map<String, String>? meter;
  final String month;
  final String tenantName;
  final int roomPrice;
  final int wifiFee;
  final int garbageFee;
  final int parkingFee;
  final int otherFee;
  final int serviceMoney;
  final int electricMoney;
  final int waterMoney;
  final int totalAmount;
  final String Function(int value) formatMoney;

  const _InvoicePreviewBox({
    required this.room,
    required this.meter,
    required this.month,
    required this.tenantName,
    required this.roomPrice,
    required this.wifiFee,
    required this.garbageFee,
    required this.parkingFee,
    required this.otherFee,
    required this.serviceMoney,
    required this.electricMoney,
    required this.waterMoney,
    required this.totalAmount,
    required this.formatMoney,
  });

  @override
  Widget build(BuildContext context) {
    final hasMonth = month.isNotEmpty;
    final hasMeter = meter != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin hệ thống tự lấy',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              fontSize: 17,
            ),
          ),

          const SizedBox(height: 12),

          _PreviewLine(
            label: 'Người thuê',
            value: tenantName,
          ),
          _PreviewLine(
            label: 'Loại phòng',
            value: room?['roomType'] ?? 'Chưa có',
          ),
          _PreviewLine(
            label: 'Tiền phòng',
            value: formatMoney(roomPrice),
          ),

          const Divider(height: 22),

          _PreviewLine(
            label: 'Wifi',
            value: formatMoney(wifiFee),
          ),
          _PreviewLine(
            label: 'Rác',
            value: formatMoney(garbageFee),
          ),
          _PreviewLine(
            label: 'Tiền xe',
            value: formatMoney(parkingFee),
          ),
          _PreviewLine(
            label: 'Dịch vụ khác',
            value: formatMoney(otherFee),
          ),
          _PreviewLine(
            label: 'Tổng dịch vụ',
            value: formatMoney(serviceMoney),
            isBold: true,
          ),

          const Divider(height: 22),

          if (!hasMonth)
            const _WarningBox(
              text: 'Vui lòng nhập tháng để hệ thống lấy tiền điện nước.',
            )
          else if (!hasMeter)
            const _WarningBox(
              text:
                  'Chưa có chỉ số điện nước tháng này. Hãy nhập điện nước trước khi tạo hóa đơn.',
            )
          else ...[
            _PreviewLine(
              label: 'Điện',
              value:
                  '${meter?['oldElectric']} → ${meter?['newElectric']} = ${meter?['electric']} kWh',
            ),
            _PreviewLine(
              label: 'Tiền điện',
              value: formatMoney(electricMoney),
            ),
            _PreviewLine(
              label: 'Nước',
              value:
                  '${meter?['oldWater']} → ${meter?['newWater']} = ${meter?['water']} m³',
            ),
            _PreviewLine(
              label: 'Tiền nước',
              value: formatMoney(waterMoney),
            ),
          ],

          const Divider(height: 22),

          _PreviewLine(
            label: 'Tổng hóa đơn',
            value: formatMoney(totalAmount),
            isBold: true,
            isTotal: true,
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
  final bool isTotal;

  const _PreviewLine({
    required this.label,
    required this.value,
    this.isBold = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF374151),
                fontWeight: isBold || isTotal ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? const Color(0xFF1E3A8A) : const Color(0xFF111827),
              fontWeight: isBold || isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  final String text;

  const _WarningBox({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFED7AA),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFC2410C),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: Color(0xFFFFEDD5),
          child: Icon(
            Icons.info_outline,
            color: Color(0xFFF97316),
            size: 34,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Chưa có phòng đang thuê',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Bạn cần có phòng đã gán người thuê trước khi tạo hóa đơn.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}