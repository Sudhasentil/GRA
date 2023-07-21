import 'dart:async';
import 'package:flutter/material.dart';
import 'background_service.dart';

class SendSMS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SMS Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final List<String> _recipients = ['9500293181', '9944172415'];
  final String _message = 'Hello from Flutter!';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter SMS Demo'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            BackgroundService.sendBulkSMS(_recipients, _message);
          },
          child: Text('Send Bulk SMS'),
        ),
      ),
    );
  }
}
