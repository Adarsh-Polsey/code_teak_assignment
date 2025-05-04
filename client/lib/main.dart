import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: EchoScreen());
  }
}

class EchoScreen extends StatefulWidget {
  const EchoScreen({super.key});

  @override
  State<EchoScreen> createState() => _EchoScreenState();
}

class _EchoScreenState extends State<EchoScreen> {
  late IO.Socket socket;
  final TextEditingController _controller = TextEditingController();
  String _echo = '';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    socket = IO.io(
      'http://192.168.6.224:3000',
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.onConnect((_) {
      log('Connected');
      setState(() {
        _isConnected = true;
      });
    });

    socket.on('msg', (data) {
      setState(() {
        _echo = data;
      });
    });

    socket.onDisconnect((_) {
      setState(() {
        _isConnected = false;
      });
    });
  }

  void sendMessage(String msg) {
    if (msg.trim().isEmpty) return;
    socket.emit('msg', msg);
    _controller.clear();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket Echo'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Type something',
                    ),
                    onSubmitted: sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _isConnected ? () => sendMessage(_controller.text) : null,
                  child: const Text('Send'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_echo),
          ],
        ),
      ),
    );
  }
}
