// import 'package:flutter/material.dart';
// import 'voip_call_manager.dart';

// class CallScreen extends StatefulWidget {
//   final String contactId;
//   final String contactName;
//   final bool isIncoming;

//   const CallScreen({
//     super.key,
//     required this.contactId,
//     required this.contactName,
//     this.isIncoming = false,
//   });

//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }

// class _CallScreenState extends State<CallScreen> {
//   late final VoipCallManager _callManager;

//   bool _showControls = true;
//   String _status = 'Calling…';
//   bool _isMuted = false;
//   bool _isSpeakerOn = false;
//   late DateTime _callStart;

//   @override
//   void initState() {
//     super.initState();
//     _callManager = VoipCallManager();
//     _status = widget.isIncoming ? 'Incoming call' : 'Calling…';
//     _init();
//   }

//   Future<void> _init() async {
//     await _callManager.initWebRTC();
//     if (widget.isIncoming) {
//       await _callManager.receiveCall(widget.contactId);
//     } else {
//       await _callManager.startCall(widget.contactId);
//     }
//     _callStart = DateTime.now();
//     setState(() => _status = 'In call…');
//     _callManager.addListener(_refresh);
//   }

//   void _refresh() {
//     setState(() {
//       _isMuted = _callManager.isMuted;
//       _isSpeakerOn = _callManager.isSpeakerOn;
//     });
//   }

//   @override
//   void dispose() {
//     _callManager.removeListener(_refresh);
//     _callManager.endCall(widget.contactId, widget.isIncoming, _callStart);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: GestureDetector(
//         onTap: () => setState(() => _showControls = !_showControls),
//         child: Stack(
//           children: [
//             // ---------- centre name & status -----------
//             Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircleAvatar(
//                     radius: 60,
//                     backgroundColor: Colors.blueGrey.shade700,
//                     child: Text(
//                       widget.contactName.isNotEmpty
//                           ? widget.contactName[0].toUpperCase()
//                           : '?',
//                       style: const TextStyle(
//                         fontSize: 48,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     widget.contactName,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(_status, style: const TextStyle(color: Colors.white70)),
//                 ],
//               ),
//             ),

//             // ---------- controls -----------
//             AnimatedPositioned(
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeOut,
//               left: 0,
//               right: 0,
//               bottom: _showControls ? 40 : -250,
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _CtlBtn(
//                         icon: _isMuted ? Icons.mic_off : Icons.mic,
//                         label: 'Mute',
//                         active: _isMuted,
//                         onTap: _callManager.toggleMute,
//                       ),
//                       _CtlBtn(
//                         icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
//                         label: 'Speaker',
//                         active: _isSpeakerOn,
//                         onTap: _callManager.toggleSpeaker,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       width: 72,
//                       height: 72,
//                       decoration: const BoxDecoration(
//                         color: Colors.red,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.call_end,
//                         color: Colors.white,
//                         size: 38,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // Small round control button
// // ---------------------------------------------------------------------------
// class _CtlBtn extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool active;
//   final VoidCallback onTap;

//   const _CtlBtn({
//     required this.icon,
//     required this.label,
//     required this.active,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: onTap,
//           child: Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: active ? Colors.blue : Colors.grey.withOpacity(0.35),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: Colors.white, size: 28),
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(label, style: const TextStyle(color: Colors.white70)),
//       ],
//     );
//   }
// }
