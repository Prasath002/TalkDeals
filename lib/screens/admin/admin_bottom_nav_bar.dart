// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:talkdeals/screens/admin/admin_profile.dart';
import 'package:talkdeals/screens/admin/call_logs.dart';
import 'package:talkdeals/screens/admin/customers/customer_list_screen.dart';
import 'package:talkdeals/theme/color_theme.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _index = 0;
  // final VoipCallManager _callManager =
  //     VoipCallManager(); // Create instance here

  late final List<Widget> _pages; // Declare as late final

  @override
  void initState() {
    super.initState();
    _pages = [
      const CustomersPage(),
      CallLogsScreen(
        // callManager: _callManager,
        // manager: VoipCallManager(),
      ), // Pass the manager instance
      const AdminProfilePage(),
    ];
  }

  @override
  void dispose() {
    // _callManager.dispose(); // Clean up resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people), label: 'Customers'),
          NavigationDestination(icon: Icon(Icons.call), label: 'Call Logs'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        indicatorColor: AppColors.primary.withOpacity(.15),
      ),
    );
  }
}
