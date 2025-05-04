import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DeliverySocketService {
  late IO.Socket socket;
  
  DeliverySocketService() {
    socket = IO.io(
      'http://192.168.1.10:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    
    socket.connect();
    socket.onConnect((_) {
      log('DeliveryPartner: Connected to socket server');
    });
    
    socket.onConnectError((error) {
      log('DeliveryPartner: Connection error: $error');
    });
    
    socket.onDisconnect((_) {
      log('DeliveryPartner: Disconnected from socket server');
    });
  }
  
  void listenForOrders(Function(dynamic data) callback) {
    log("DeliveryPartner: Setting up orders listener");
    socket.on("orders", callback);
  }
  
  void updateOrderStatus({
    required String uuid,
    required String status,
  }) {
    var data = {
      "uuid": uuid,
      "status": status,
      "updatedAt": DateTime.now().toIso8601String(),
    };
    log("DeliveryPartner: Updating order status: ${data.toString()}");
    socket.emit('orderStatusUpdate', data);
  }
  
  void acceptOrder({
    required String uuid,
  }) {
    updateOrderStatus(
      uuid: uuid,
      status: "accepted",
      
    );
  }
  
  void rejectOrder({
    required String uuid,
  }) {
    updateOrderStatus(
      uuid: uuid,
      status: "rejected",
      
    );
  }
  
  void disconnect() {
    socket.disconnect();
  }
}