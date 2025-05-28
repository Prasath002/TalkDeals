import 'package:flutter/material.dart';

class CallLogsScreen extends StatelessWidget {
  const CallLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call History')),
      body: const Center(child: Text('No calls yet')),
    );
  }
}
