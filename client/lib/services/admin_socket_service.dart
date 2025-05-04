import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class AdminSocketService {
  late IO.Socket socket;

  AdminSocketService() {
    socket = IO.io('http://192.168.6.224:3000');

    socket.connect();
    socket.onConnect((_) {
      socket.emit('check', "Helloooooo");
      log('Connected to socket server');
    });

    socket.onConnectError((error) {
      log('Connection error: $error');
    });

    socket.onDisconnect((_) {
      log('Disconnected from socket server');
    });
  }

  void sendOrder({
    required String uuid,
    required String address,
    required String description,
  }) {
    var data = {
      "uuid": uuid,
      "address": address,
      "description": description,
      "status": "waiting",
    };
    log("Sending order data: ${data.toString()}");
    socket.emit('orders', data);
  }

  void viewOrders(Function(dynamic data) callback) {
    log("Setting up orders listener");
    socket.on("orders", callback);
  }

  void disconnect() {
    socket.disconnect();
  }
}
