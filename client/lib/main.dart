import 'package:client/core/app_theme.dart';
import 'package:client/screens/admin_screen.dart';
import 'package:client/screens/home_screen.dart';
import 'package:client/screens/delivery_partner_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
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
