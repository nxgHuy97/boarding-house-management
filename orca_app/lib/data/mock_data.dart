class MockData {
  static String currentUsername = 'Chủ trọ A';
  static String currentRole = 'OWNER';

  // =========================
  // USER / ACCOUNT DATA
  // =========================
  // Tenant không tự đăng ký nữa.
  // Tenant được Owner tạo tài khoản và giao username/password để đăng nhập.

  static final List<Map<String, String>> users = [
    {
      'id': 'U001',
      'username': 'admin',
      'password': '123456',
      'name': 'Admin',
      'email': 'admin@gmail.com',
      'role': 'ADMIN',
      'status': 'Hoạt động',
    },
    {
      'id': 'O001',
      'username': 'owner',
      'password': '123456',
      'name': 'Chủ trọ A',
      'email': 'owner@gmail.com',
      'role': 'OWNER',
      'status': 'Hoạt động',
    },
    {
      'id': 'O002',
      'username': 'owner2',
      'password': '123456',
      'name': 'Chủ trọ B',
      'email': 'owner2@gmail.com',
      'role': 'OWNER',
      'status': 'Chờ duyệt',
    },
    {
      'id': 'T001',
      'username': 'tenant',
      'password': '123456',
      'name': 'Nguyễn Văn A',
      'email': 'tenant@gmail.com',
      'role': 'TENANT',
      'status': 'Hoạt động',
      'createdByOwner': 'Chủ trọ A',
    },
    {
      'id': 'T002',
      'username': 'tenant2',
      'password': '123456',
      'name': 'Trần Thị B',
      'email': 'tenant2@gmail.com',
      'role': 'TENANT',
      'status': 'Hoạt động',
      'createdByOwner': 'Chủ trọ A',
    },
    {
      'id': 'T003',
      'username': 'tenant3',
      'password': '123456',
      'name': 'Lê Văn C',
      'email': 'tenant3@gmail.com',
      'role': 'TENANT',
      'status': 'Hoạt động',
      'createdByOwner': 'Chủ trọ A',
    },
  ];

  // Admin không quản lý loại phòng nữa.
  // Giữ list này để màn cũ chưa bị lỗi, sau sẽ bỏ khỏi menu.
  static final List<Map<String, String>> categories = [];

  // Admin không quản lý tiện ích nữa.
  // Owner sẽ tự quy định tiện ích trong từng phòng.
  static final List<Map<String, String>> utilities = [];

  // =========================
  // OWNER DATA
  // =========================

  static final List<Map<String, String>> owners = [
    {
      'id': 'O001',
      'name': 'Chủ trọ A',
      'email': 'owner@gmail.com',
      'phone': '0901111222',
      'status': 'Hoạt động',
      'roomCount': '3',
      'bankName': 'MB Bank',
      'bankAccount': '0901111222',
      'bankOwner': 'CHU TRO A',
      'bankQr': 'assets/images/qr_owner_a.png',
    },
    {
      'id': 'O002',
      'name': 'Chủ trọ B',
      'email': 'owner2@gmail.com',
      'phone': '0903333444',
      'status': 'Chờ duyệt',
      'roomCount': '1',
      'bankName': 'Vietcombank',
      'bankAccount': '0903333444',
      'bankOwner': 'CHU TRO B',
      'bankQr': 'assets/images/qr_owner_b.png',
    },
  ];

  // =========================
  // ROOM DATA
  // =========================

  static final List<Map<String, String>> rooms = [
    {
      'id': 'R001',
      'name': 'Phòng 101',
      'roomNumber': '101',
      'ownerId': 'O001',
      'owner': 'Chủ trọ A',
      'tenantId': 'T001',
      'tenant': 'Nguyễn Văn A',
      'price': '2.500.000đ',
      'rentPrice': '2500000',
      'status': 'Đang thuê',
      'area': '25m²',
      'roomType': 'Có gác',
      'hasAirConditioner': 'Có',
      'hasFurniture': 'Có',
      'wifiFee': '100000',
      'garbageFee': '30000',
      'parkingFee': '100000',
      'otherFee': '0',
      'serviceMoney': '230000',
    },
    {
      'id': 'R002',
      'name': 'Phòng 102',
      'roomNumber': '102',
      'ownerId': 'O001',
      'owner': 'Chủ trọ A',
      'tenantId': '',
      'tenant': 'Chưa có',
      'price': '2.200.000đ',
      'rentPrice': '2200000',
      'status': 'Trống',
      'area': '22m²',
      'roomType': 'Phòng trệt',
      'hasAirConditioner': 'Không',
      'hasFurniture': 'Không',
      'wifiFee': '100000',
      'garbageFee': '30000',
      'parkingFee': '0',
      'otherFee': '0',
      'serviceMoney': '130000',
    },
    {
      'id': 'R003',
      'name': 'Phòng 201',
      'roomNumber': '201',
      'ownerId': 'O001',
      'owner': 'Chủ trọ A',
      'tenantId': 'T002',
      'tenant': 'Trần Thị B',
      'price': '3.000.000đ',
      'rentPrice': '3000000',
      'status': 'Đang thuê',
      'area': '30m²',
      'roomType': 'Có gác',
      'hasAirConditioner': 'Có',
      'hasFurniture': 'Có',
      'wifiFee': '100000',
      'garbageFee': '30000',
      'parkingFee': '100000',
      'otherFee': '50000',
      'serviceMoney': '280000',
    },
    {
      'id': 'R004',
      'name': 'Phòng 202',
      'roomNumber': '202',
      'ownerId': 'O001',
      'owner': 'Chủ trọ A',
      'tenantId': 'T003',
      'tenant': 'Lê Văn C',
      'price': '2.500.000đ',
      'rentPrice': '2500000',
      'status': 'Đang thuê',
      'area': '24m²',
      'roomType': 'Phòng trệt',
      'hasAirConditioner': 'Không',
      'hasFurniture': 'Có',
      'wifiFee': '100000',
      'garbageFee': '30000',
      'parkingFee': '0',
      'otherFee': '0',
      'serviceMoney': '130000',
    },
  ];

  // =========================
  // TENANT DATA
  // =========================

  static final List<Map<String, String>> tenants = [
    {
      'id': 'T001',
      'username': 'tenant',
      'password': '123456',
      'name': 'Nguyễn Văn A',
      'phone': '0901234567',
      'email': 'nguyenvana@gmail.com',
      'cccd': '001201000001',
      'address': 'TP.HCM',
      'ownerId': 'O001',
      'owner': 'Chủ trọ A',
      'roomId': 'R001',
      'room': 'Phòng 101',
      'status': 'Đang thuê',
      'paymentRate': '100%',
      'avgDelayDays': '0',
      'tenantType': 'reliable',
    },
    {
      'id': 'T002',
      'username': 'tenant2',
      'password': '123456',
      'name': 'Trần Thị B',
      'phone': '0912345678',
      'email': 'tranthib@gmail.com',
      'cccd': '001201000002',
      'address': 'Bình Dương',
      'ownerId': 'O001',
      'owner': 'Chủ trọ A',
      'roomId': 'R003',
      'room': 'Phòng 201',
      'status': 'Đang thuê',
      'paymentRate': '60%',
      'avgDelayDays': '5',
      'tenantType': 'often_late',
    },
    {
      'id': 'T003',
      'username': 'tenant3',
      'password': '123456',
      'name': 'Lê Văn C',
      'phone': '0987654321',
      'email': 'levanc@gmail.com',
      'cccd': '001201000003',
      'address': 'Đồng Nai',
      'ownerId': 'O001',
      'owner': 'Chủ trọ A',
      'roomId': 'R004',
      'room': 'Phòng 202',
      'status': 'Đang thuê',
      'paymentRate': 'Chưa có',
      'avgDelayDays': '0',
      'tenantType': 'new',
    },
  ];

  // =========================
  // CONTRACT DATA
  // =========================

  static final List<Map<String, String>> contracts = [
    {
      'code': 'HDONG001',
      'tenantId': 'T001',
      'tenant': 'Nguyễn Văn A',
      'roomId': 'R001',
      'room': 'Phòng 101',
      'start': '01/05/2026',
      'end': '01/05/2027',
      'status': 'Còn hiệu lực',
    },
    {
      'code': 'HDONG002',
      'tenantId': 'T002',
      'tenant': 'Trần Thị B',
      'roomId': 'R003',
      'room': 'Phòng 201',
      'start': '10/05/2026',
      'end': '10/05/2027',
      'status': 'Còn hiệu lực',
    },
    {
      'code': 'HDONG003',
      'tenantId': 'T003',
      'tenant': 'Lê Văn C',
      'roomId': 'R004',
      'room': 'Phòng 202',
      'start': '01/10/2026',
      'end': '01/10/2027',
      'status': 'Còn hiệu lực',
    },
  ];

  // =========================
  // METER DATA
  // =========================

  static final List<Map<String, String>> meters = [
    {
      'roomId': 'R001',
      'room': 'Phòng 101',
      'month': '10/2026',
      'oldElectric': '100',
      'newElectric': '225',
      'electric': '125',
      'electricPrice': '4000',
      'electricMoney': '500000',
      'oldWater': '10',
      'newWater': '16',
      'water': '6',
      'waterPrice': '20000',
      'waterMoney': '120000',
    },
    {
      'roomId': 'R003',
      'room': 'Phòng 201',
      'month': '10/2026',
      'oldElectric': '120',
      'newElectric': '330',
      'electric': '210',
      'electricPrice': '4000',
      'electricMoney': '840000',
      'oldWater': '20',
      'newWater': '28',
      'water': '8',
      'waterPrice': '20000',
      'waterMoney': '160000',
    },
    {
      'roomId': 'R004',
      'room': 'Phòng 202',
      'month': '10/2026',
      'oldElectric': '0',
      'newElectric': '80',
      'electric': '80',
      'electricPrice': '4000',
      'electricMoney': '320000',
      'oldWater': '0',
      'newWater': '5',
      'water': '5',
      'waterPrice': '20000',
      'waterMoney': '100000',
    },
  ];

  // =========================
  // INVOICE DATA
  // statusCode:
  // unpaid  = chưa thanh toán
  // pending = tenant đã upload minh chứng, chờ owner xác nhận
  // paid    = đã thanh toán, chuyển sang biên lai
  // =========================

  static final List<Map<String, String>> invoices = [
    {
      'code': 'HD001',
      'ownerId': 'O001',
      'roomId': 'R001',
      'room': 'Phòng 101',
      'tenantId': 'T001',
      'tenant': 'Nguyễn Văn A',
      'month': '10/2026',
      'dueDate': '31/10/2026',
      'roomPrice': '2.500.000đ',
      'electricMoney': '500.000đ',
      'waterMoney': '120.000đ',
      'serviceMoney': '230.000đ',
      'amount': '3.350.000đ',
      'paymentMethod': '',
      'proofImage': '',
      'paidDate': '',
      'status': 'Chưa thanh toán',
      'statusCode': 'unpaid',
    },
    {
      'code': 'HD002',
      'ownerId': 'O001',
      'roomId': 'R003',
      'room': 'Phòng 201',
      'tenantId': 'T002',
      'tenant': 'Trần Thị B',
      'month': '10/2026',
      'dueDate': '31/10/2026',
      'roomPrice': '3.000.000đ',
      'electricMoney': '840.000đ',
      'waterMoney': '160.000đ',
      'serviceMoney': '280.000đ',
      'amount': '4.280.000đ',
      'paymentMethod': 'Chuyển khoản',
      'proofImage': 'assets/images/proof_hd002.png',
      'paidDate': '',
      'status': 'Chờ xác nhận',
      'statusCode': 'pending',
    },
    {
      'code': 'HD003',
      'ownerId': 'O001',
      'roomId': 'R004',
      'room': 'Phòng 202',
      'tenantId': 'T003',
      'tenant': 'Lê Văn C',
      'month': '10/2026',
      'dueDate': '31/10/2026',
      'roomPrice': '2.500.000đ',
      'electricMoney': '320.000đ',
      'waterMoney': '100.000đ',
      'serviceMoney': '130.000đ',
      'amount': '3.050.000đ',
      'paymentMethod': '',
      'proofImage': '',
      'paidDate': '',
      'status': 'Chưa thanh toán',
      'statusCode': 'unpaid',
    },
    {
      'code': 'HD004',
      'ownerId': 'O001',
      'roomId': 'R001',
      'room': 'Phòng 101',
      'tenantId': 'T001',
      'tenant': 'Nguyễn Văn A',
      'month': '09/2026',
      'dueDate': '30/09/2026',
      'roomPrice': '2.500.000đ',
      'electricMoney': '460.000đ',
      'waterMoney': '100.000đ',
      'serviceMoney': '230.000đ',
      'amount': '3.290.000đ',
      'paymentMethod': 'Chuyển khoản',
      'proofImage': 'assets/images/proof_hd004.png',
      'paidDate': '28/09/2026',
      'status': 'Đã thanh toán',
      'statusCode': 'paid',
    },
  ];

  // =========================
  // PAYMENT / RECEIPT DATA
  // Chỉ lưu hóa đơn đã thanh toán hoặc đang chờ xác nhận.
  // =========================

  static final List<Map<String, String>> payments = [
    {
      'code': 'TT001',
      'invoice': 'HD002',
      'tenantId': 'T002',
      'tenant': 'Trần Thị B',
      'room': 'Phòng 201',
      'amount': '4.280.000đ',
      'method': 'Chuyển khoản',
      'date': '31/10/2026',
      'proofImage': 'assets/images/proof_hd002.png',
      'status': 'Chờ xác nhận',
      'statusCode': 'pending',
    },
    {
      'code': 'TT002',
      'invoice': 'HD004',
      'tenantId': 'T001',
      'tenant': 'Nguyễn Văn A',
      'room': 'Phòng 101',
      'amount': '3.290.000đ',
      'method': 'Chuyển khoản',
      'date': '28/09/2026',
      'proofImage': 'assets/images/proof_hd004.png',
      'status': 'Đã xác nhận',
      'statusCode': 'paid',
    },
  ];

  // =========================
  // PAYMENT HISTORY FOR AI
  // =========================

  static final List<Map<String, String>> paymentHistories = [
    {
      'tenantId': 'T001',
      'tenant': 'Nguyễn Văn A',
      'totalInvoices': '5',
      'onTimeInvoices': '5',
      'lateInvoices': '0',
      'onTimeRate': '100',
      'avgDelayDays': '0',
      'riskLevel': 'Thấp',
      'note': 'Luôn thanh toán đúng hạn',
    },
    {
      'tenantId': 'T002',
      'tenant': 'Trần Thị B',
      'totalInvoices': '5',
      'onTimeInvoices': '3',
      'lateInvoices': '2',
      'onTimeRate': '60',
      'avgDelayDays': '5',
      'riskLevel': 'Trung bình',
      'note': 'Thường thanh toán trễ khoảng 5 ngày',
    },
    {
      'tenantId': 'T003',
      'tenant': 'Lê Văn C',
      'totalInvoices': '0',
      'onTimeInvoices': '0',
      'lateInvoices': '0',
      'onTimeRate': '0',
      'avgDelayDays': '0',
      'riskLevel': 'Chưa đánh giá',
      'note': 'Người thuê mới, chưa có lịch sử thanh toán',
    },
  ];

  // =========================
  // AI NOTIFICATION MOCK DATA
  // =========================

  static final List<Map<String, String>> aiNotifications = [
    {
      'id': 'AI001',
      'tenantId': 'T001',
      'tenant': 'Nguyễn Văn A',
      'invoiceCode': 'HD001',
      'messageType': 'AI',
      'message':
          'Chào Nguyễn Văn A, hóa đơn tháng 10/2026 của bạn là 3.350.000đ, hạn thanh toán ngày 31/10/2026. Cảm ơn bạn vì luôn thanh toán đúng hạn. 🙏',
      'sentAt': '25/10/2026',
      'opened': 'Có',
      'paymentTime': 'Trước hạn',
      'satisfaction': '5',
    },
    {
      'id': 'AI002',
      'tenantId': 'T002',
      'tenant': 'Trần Thị B',
      'invoiceCode': 'HD002',
      'messageType': 'AI',
      'message':
          'Chào Trần Thị B, hóa đơn tháng 10/2026 của bạn là 4.280.000đ, hạn thanh toán ngày 31/10/2026. Dựa trên lịch sử, bạn thường thanh toán trễ khoảng 5 ngày. Bạn nên đặt lời nhắc để tránh phát sinh phí trễ hạn nhé. 💡',
      'sentAt': '25/10/2026',
      'opened': 'Có',
      'paymentTime': 'Đúng hạn',
      'satisfaction': '4',
    },
    {
      'id': 'AI003',
      'tenantId': 'T003',
      'tenant': 'Lê Văn C',
      'invoiceCode': 'HD003',
      'messageType': 'AI',
      'message':
          'Chào Lê Văn C, hóa đơn tháng 10/2026 của bạn là 3.050.000đ, hạn thanh toán ngày 31/10/2026. Đây là tháng đầu tiên của bạn. Bạn có thể thanh toán bằng chuyển khoản hoặc tiền mặt. Nếu có thắc mắc, hãy liên hệ chủ trọ nhé. 👋',
      'sentAt': '25/10/2026',
      'opened': 'Chưa',
      'paymentTime': 'Chưa thanh toán',
      'satisfaction': '0',
    },
  ];

  // =========================
  // A/B TEST MOCK DATA
  // =========================

  static final List<Map<String, String>> abTestReports = [
    {
      'type': 'Template message',
      'sentCount': '20',
      'openRate': '65%',
      'avgPaymentTime': '4.2 ngày',
      'satisfaction': '3.8/5',
    },
    {
      'type': 'AI message',
      'sentCount': '20',
      'openRate': '82%',
      'avgPaymentTime': '2.1 ngày',
      'satisfaction': '4.5/5',
    },
  ];

  // =========================
  // TENANT PROFILE DATA
  // =========================

  static final Map<String, String> tenantProfile = {
    'id': 'T001',
    'username': 'tenant',
    'name': 'Nguyễn Văn A',
    'email': 'tenant@gmail.com',
    'phone': '0901234567',
    'cccd': '001201000001',
    'address': 'TP.HCM',
    'room': 'Phòng 101',
    'status': 'Đang thuê',
  };
}