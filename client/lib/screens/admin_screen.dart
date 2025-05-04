import 'dart:async';
import 'dart:developer';

import 'package:client/services/admin_socket_service.dart';
import 'package:client/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:uuid/v4.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final _statusStream = StreamController<List<dynamic>>.broadcast();
  late final AdminSocketService adminSocket;
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    adminSocket = AdminSocketService();
    adminSocket.viewOrders((data) {
      log("Received order data: $data");
      if (data is List) {
        orders = data;
      } else if (data != null) {
        orders.add(data);
      }
      _statusStream.add(orders);
    });
  }

  @override
  void dispose() {
    addressController.dispose();
    descriptionController.dispose();
    _statusStream.close();
    super.dispose();
  }

  void _showAddOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Order Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            icon: Icons.send,
            label: "Send Order",
            onPressed: () {
              final String uuid = UuidV4().generate();
              adminSocket.sendOrder(
                uuid: uuid,
                address: addressController.text,
                description: descriptionController.text,
              );
              addressController.clear();
              descriptionController.clear();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _statusStream.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final ordersList = snapshot.data!;
            return ListView.builder(
              itemCount: ordersList.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final order = ordersList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('Order #${order['uuid'] ?? ''}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address: ${order['address'] ?? ''}'),
                        Text('Description: ${order['description'] ?? ''}'),
                        Text('Status: ${order['status'] ?? 'Unknown'}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Error occurred: ${snapshot.error}"),
                ],
              ),
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No pending orders", style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOrderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}