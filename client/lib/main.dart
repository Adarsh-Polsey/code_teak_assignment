import 'package:client/features/screens/admin_screen.dart';
import 'package:client/features/screens/home_screen.dart';
import 'package:client/features/screens/delivery_partner_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => HomeScreen(),
        '/admin': (context) => AdminScreen(),
        '/deliveryPartner': (context) => DeliveryPartnerScreen(),
      },
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
    );
  }
}
