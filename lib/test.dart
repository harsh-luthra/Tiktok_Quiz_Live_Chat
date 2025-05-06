import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8081'), // replace with your server IP if needed
    );

    channel.stream.listen((message) {
      final data = jsonDecode(message);
      print('💬 ${data['username']} -- ${data['profileName']} (${data['userId']}): ${data['message']}');

      // You can now implement answer checking logic here
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
