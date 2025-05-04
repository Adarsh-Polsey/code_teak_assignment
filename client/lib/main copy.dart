// import 'package:client/core/app_theme.dart';
// import 'package:client/screens/admin_screen.dart';
// import 'package:client/screens/home_screen.dart';
// import 'package:client/screens/delivery_partner_screen.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: AppTheme.darkTheme,
//       routes: {
//         '/': (context) => HomeScreen(),
//         '/admin': (context) => AdminScreen(),
//         '/deliveryPartner': (context) => DeliveryPartnerScreen(),
//       },
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/',
//     );
//   }
// }

import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as IO;

main() {
  // Dart client
  IO.Socket socket = IO.io('http://localhost:3000');
  socket.onConnect((_) {
    log('connect');
    socket.emit('msg', 'test');
  });
  socket.on('event', (data) => log(data));
  socket.onDisconnect((_) => log('disconnect'));
  socket.on('fromServer', (dat) => log(dat));
}