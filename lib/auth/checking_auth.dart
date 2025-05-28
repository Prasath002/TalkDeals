// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talkdeals/auth/sign_up_screen.dart';
import 'package:talkdeals/screens/admin/admin_bottom_nav_bar.dart';
import 'package:talkdeals/screens/agent_home_screen.dart';
import 'package:talkdeals/screens/customer_home_screen.dart';

class CheckingAuth extends StatefulWidget {
  const CheckingAuth({super.key});

  @override
  State<CheckingAuth> createState() => _CheckingAuthState();
}

class _CheckingAuthState extends State<CheckingAuth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .where('email', isEqualTo: snapshot.data!.email)
                  .limit(1)
                  .get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
                    Map<String, dynamic> userData =
                        snapshot.data!.docs.first.data()
                            as Map<String, dynamic>;
                    String role = userData['user_type'];

                    if (role == 'Admin') {
                      return const AdminMainScreen();
                    } else if (role == 'Agent') {
                      return AgentHomeScreen();
                    } else if (role == 'User') {
                      return const CustomerHomeScreen();
                    } else {
                      return const SignupScreen();
                    }
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  return const Center(child: SignupScreen());
                }
                // Always return a widget for other connection states
                return const Center(child: SignupScreen());
              },
            );
          } else {
            return const SignupScreen();
          }
        },
      ),
    );
  }
}
