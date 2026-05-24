import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/pending_screen.dart';

import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/all_users_screen.dart';
import 'screens/admin/room_list_screen.dart';

import 'screens/owner/owner_dashboard_screen.dart';
import 'screens/owner/owner_room_list_screen.dart';
import 'screens/owner/add_room_screen.dart';
import 'screens/owner/tenant_list_screen.dart';
import 'screens/owner/add_tenant_screen.dart';
import 'screens/owner/contract_list_screen.dart';
import 'screens/owner/invoice_list_screen.dart';
import 'screens/owner/create_invoice_screen.dart';
import 'screens/owner/payment_list_screen.dart';
import 'screens/owner/meter_list_screen.dart';
import 'screens/owner/add_meter_screen.dart';
import 'screens/owner/ai_notification_screen.dart';

import 'screens/tenant/tenant_dashboard_screen.dart';
import 'screens/tenant/room_info_screen.dart';
import 'screens/tenant/my_invoices_screen.dart';
import 'screens/tenant/my_payments_screen.dart';
import 'screens/tenant/my_contracts_screen.dart';
import 'screens/tenant/profile_screen.dart';

void main() {
  runApp(const OrcaApp());
}

class OrcaApp extends StatelessWidget {
  const OrcaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orca',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1E3A8A),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      initialRoute: '/login',
      routes: {
        // Auth
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/pending': (_) => const PendingScreen(),

        // Admin
        '/admin/dashboard': (_) => const AdminDashboardScreen(),
        '/admin/users': (_) => const AllUsersScreen(),
        '/admin/rooms': (_) => const AdminRoomListScreen(),

        // Owner
        '/owner/dashboard': (_) => const OwnerDashboardScreen(),

        '/owner/rooms': (_) => const OwnerRoomListScreen(),
        '/owner/rooms/add': (_) => const AddRoomScreen(),

        '/owner/tenants': (_) => const OwnerTenantListScreen(),
        '/owner/tenants/add': (_) => const AddTenantScreen(),

        '/owner/contracts': (_) => const OwnerContractListScreen(),

        '/owner/meters': (_) => const OwnerMeterListScreen(),
        '/owner/meters/add': (_) => const AddMeterScreen(),

        '/owner/invoices': (_) => const OwnerInvoiceListScreen(),
        '/owner/invoices/create': (_) => const CreateInvoiceScreen(),

        '/owner/payments': (_) => const OwnerPaymentListScreen(),

        '/owner/ai-notifications': (_) => const OwnerAiNotificationScreen(),

        // Tenant
        '/tenant/dashboard': (_) => const TenantDashboardScreen(),
        '/tenant/room-info': (_) => const TenantRoomInfoScreen(),
        '/tenant/invoices': (_) => const MyInvoicesScreen(),
        '/tenant/payments': (_) => const MyPaymentsScreen(),
        '/tenant/contracts': (_) => const MyContractsScreen(),
        '/tenant/profile': (_) => const ProfileScreen(),
      },
    );
  }
}