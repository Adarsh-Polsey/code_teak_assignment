import 'package:client/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Choose your role",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 48),
                CustomButton(
                  icon: Icons.admin_panel_settings,
                  label: "Admin",
                  onPressed: () => Navigator.pushNamed(context, '/admin'),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  icon: Icons.delivery_dining,
                  label: "Delivery Partner",
                  onPressed:
                      () => Navigator.pushNamed(context, '/deliveryPartner'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
