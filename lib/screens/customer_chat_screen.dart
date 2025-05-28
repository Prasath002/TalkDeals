// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unnecessary_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:intl/intl.dart';
import 'package:talkdeals/screens/admin/customers/customer.dart';
import 'package:talkdeals/screens/call_speak_screen.dart';
import 'package:talkdeals/theme/color_theme.dart';

class CustomerChatScreen extends StatefulWidget {
  final Customer customer;

  const CustomerChatScreen({super.key, required this.customer});

  @override
  State<CustomerChatScreen> createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _ensureIndexExists();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _ensureIndexExists() async {
    try {
      // Try a test query
      await _firestore
          .collection('customer_chats')
          .where('customerId', isEqualTo: widget.customer.id)
          .orderBy('timestamp', descending: false)
          .limit(1)
          .get();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Setting up database... Please wait a moment.'),
            action: SnackBarAction(
              label: 'Create Index',
              onPressed: () {
                final regex = RegExp(
                  r'https://console.firebase.google.com[^\s]+',
                );
                final match = regex.firstMatch(e.message!);
                if (match != null) {
                  // You could use url_launcher package to open the URL
                  debugPrint('Index creation URL: ${match.group(0)}');
                }
              },
            ),
          ),
        );
        // Wait a few seconds for index to potentially be created
        await Future.delayed(const Duration(seconds: 10));
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await _firestore.collection('customer_chats').add({
        'customerId': widget.customer.id,
        'text': _messageController.text.trim(),
        'sender': 'admin',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              widget.customer.name.isNotEmpty
                  ? widget.customer.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.customer.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.customer.isActive
                          ? Colors.green
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.customer.isActive ? 'Online' : 'Offline',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        // ZegoSendCallInvitationButton(
        //   isVideoCall: true,
        //   resourceID: "zegouikit_call",
        //   invitees: [ZegoUIKitUser(id: 'target_user_id', name: 'Target User')],
        // ),
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            Get.to(() => CallSpeakScreen());
          },
        ),
      ],
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }

  // Future<void> _initiateCall() async {
  //   try {
  //     // Show loading indicator
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => const Center(child: CircularProgressIndicator()),
  //     );

  //     // Start the call
  //     await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => CallScreen(
  //           contactId: widget.customer.id,
  //           contactName: widget.customer.name,
  //           isIncoming: false,
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     // Close loading indicator if still showing
  //     if (Navigator.of(context).canPop()) {
  //       Navigator.of(context).pop();
  //     }

  //     // Show error message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to start call: ${e.toString()}'),
  //         duration: const Duration(seconds: 3),
  //       ),
  //     );
  //   } finally {
  //     // Ensure loading indicator is closed
  //     if (Navigator.of(context).canPop()) {
  //       Navigator.of(context).pop();
  //     }
  //   }
  // }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('customer_chats')
          .where('customerId', isEqualTo: widget.customer.id)
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading messages',
              style: TextStyle(color: AppColors.error),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data?.docs ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Start the conversation',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data() as Map<String, dynamic>;
            final isMe = message['sender'] == 'admin';
            final isSameSenderAsPrevious =
                index > 0 &&
                (messages[index - 1].data()
                        as Map<String, dynamic>)['sender'] ==
                    message['sender'];

            if (isSameSenderAsPrevious) {
              return Padding(
                padding: EdgeInsets.only(
                  left: isMe ? 64.0 : 16.0,
                  right: isMe ? 16.0 : 64.0,
                  bottom: 4,
                ),
                child: _buildMessageBubble(message, isMe, false),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        widget.customer.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  _buildMessageBubble(message, isMe, true),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
    bool isMe,
    bool showTail,
  ) {
    final text = message['text'] ?? '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe
                ? const Radius.circular(16)
                : showTail
                ? const Radius.circular(4)
                : const Radius.circular(16),
            bottomRight: isMe
                ? showTail
                      ? const Radius.circular(4)
                      : const Radius.circular(16)
                : const Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? AppColors.primary : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTimestamp(message['timestamp']),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? AppColors.primary.withOpacity(0.6)
                        : Colors.grey,
                  ),
                ),
                if (isMe && (message['read'] ?? false))
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.done_all, size: 12, color: Colors.blue),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      maxLines: 4,
                      minLines: 1,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.darkBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      return 'Just now';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDay == today) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }
}
