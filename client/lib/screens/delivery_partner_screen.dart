import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:client/services/delivery_socket_service.dart';

class DeliveryPartnerScreen extends StatefulWidget {
  const DeliveryPartnerScreen({super.key});

  @override
  State<DeliveryPartnerScreen> createState() => _DeliveryPartnerScreenState();
}

class _DeliveryPartnerScreenState extends State<DeliveryPartnerScreen> {
  final _ordersStreamController = StreamController<List<dynamic>>.broadcast();
  late final DeliverySocketService _deliverySocket;
  List<dynamic> _availableOrders = [];
  List<dynamic> _acceptedOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDeliveryPartner();
  }

  Future<void> _initializeDeliveryPartner() async {
    // Get or generate a unique delivery partner ID
   
    
    setState(() {
      _isLoading = false;
    });
    
    _deliverySocket = DeliverySocketService();
    _deliverySocket.listenForOrders((data) {
      log("DeliveryPartner: Received order data: $data");
      _processOrders(data);
    });
  }

  void _processOrders(dynamic data) {
    // Handle both single order and list of orders
    List<dynamic> allOrders = [];
    
    if (data is List) {
      allOrders = List.from(data);
    } else if (data != null) {
      allOrders = [data];
    }
    
    // Filter orders into available and accepted categories
    _availableOrders = allOrders.where((order) => 
      order['status'] == 'waiting' || 
      (order['status'] == 'rejected' )
    ).toList();
    
    _acceptedOrders = allOrders.where((order) => 
      order['status'] == 'accepted'
    ).toList();
    
    // Update stream
    _ordersStreamController.add(_availableOrders);
  }

  void _acceptOrder(dynamic order) {
    _deliverySocket.acceptOrder(
      uuid: order['uuid'],
    );
  }

  void _rejectOrder(dynamic order) {
    _deliverySocket.rejectOrder(
      uuid: order['uuid'],
    );
  }

  @override
  void dispose() {
    _ordersStreamController.close();
    _deliverySocket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Delivery Partner'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Available Orders'),
              Tab(text: 'My Orders'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Available Orders Tab
                  StreamBuilder<List<dynamic>>(
                    stream: _ordersStreamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return ListView.builder(
                          itemCount: _availableOrders.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final order = _availableOrders[index];
                            return _buildOrderCard(
                              order,
                              showActionButtons: true,
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return _buildErrorState(snapshot.error.toString());
                      } else {
                        return _buildEmptyState('No available orders');
                      }
                    },
                  ),
                  
                  // My Orders Tab
                  Builder(
                    builder: (context) {
                      if (_acceptedOrders.isNotEmpty) {
                        return ListView.builder(
                          itemCount: _acceptedOrders.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final order = _acceptedOrders[index];
                            return _buildOrderCard(
                              order,
                              showActionButtons: false,
                            );
                          },
                        );
                      } else {
                        return _buildEmptyState('No accepted orders');
                      }
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order, {required bool showActionButtons}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order['uuid'] ?? ''}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text('Address: ${order['address'] ?? ''}'),
            const SizedBox(height: 4),
            Text('Description: ${order['description'] ?? ''}'),
            const SizedBox(height: 4),
            Text(
              'Status: ${order['status'] ?? 'Unknown'}',
              style: TextStyle(
                color: _getStatusColor(order['status']),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showActionButtons) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _rejectOrder(order),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _acceptOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'waiting':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $errorMessage',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}