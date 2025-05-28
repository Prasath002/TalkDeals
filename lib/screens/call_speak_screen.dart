import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallSpeakScreen extends StatefulWidget {
  const CallSpeakScreen({super.key});

  @override
  State<CallSpeakScreen> createState() => _CallSpeakScreenState();
}

class _CallSpeakScreenState extends State<CallSpeakScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: 1331437100, // your AppID,
      appSign:
          'ca8f1ada6a857cc839c2f3a2e86b62a38b00b31eb2b5689fbd323afd657b08c7',
      userID: currentUser!.email.toString(),
      userName: currentUser!.email.toString(),
      callID: '2411',
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}
