import 'package:flutter/material.dart';

class DashboardButton extends StatelessWidget {
  final String role;

  const DashboardButton({
    super.key,
    required this.role,
  });

  String get _dashboardRoute {
    if (role == 'ADMIN') return '/admin/dashboard';
    if (role == 'OWNER') return '/owner/dashboard';
    if (role == 'TENANT') return '/tenant/dashboard';

    return '/login';
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == _dashboardRoute) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: 'Quay về Dashboard',
      icon: const Icon(Icons.dashboard_rounded),
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          _dashboardRoute,
          (route) => false,
        );
      },
    );
  }
}