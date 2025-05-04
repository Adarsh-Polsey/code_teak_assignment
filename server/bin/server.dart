// import 'package:socket_io/socket_io.dart';

// void main() {
//   var io = Server();

//   io.on('connection', (client) {
//     print('Client connected: ${client.id}');
//     client.on('check', (data) {
//       io.emit('check', "$data  Connection successful");
//     });

//     client.on('orders', (data) {
//       print('Order from admin: $data');
//       io.emit('order_received', data); // send to partner
//     });

//     client.on('order_response', (data) {
//       print('Response from partner: $data');
//       io.emit('status_update', data); // send to admin
//     });

//     client.on('disconnect', (_) {
//       print('Client disconnected: ${client.id}');
//     });
//   });

//   io.listen(3000);
//   print('Socket server listening on port 3000');
// }


import 'package:socket_io/socket_io.dart';

void main() {
  final io = Server();

  io.on('connection', (client) {
    print('Client connected: ${client.id}');
    
    client.on('msg', (data) {
      print('Received: $data');
      client.emit('msg', 'Echo: $data');
    });

    client.on('disconnect', (_) {
      print('Client disconnected: ${client.id}');
    });
  });

  io.listen(3000);
  print('Server running on port 3000');
}