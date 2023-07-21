import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_sms/flutter_sms.dart';

class BackgroundService {
  static const MethodChannel _backgroundChannel =
      MethodChannel('com.example.myapp/background');

  static Future<void> sendBulkSMS(
      List<String> recipients, String message) async {
    try {
      await sendSMS(message: message, recipients: recipients);
    } on PlatformException catch (e) {
      print('Error sending bulk SMS: ${e.message}');
    }
  }

  static void start() {
    _backgroundChannel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'sendBulkSMS':
        final Map<dynamic, dynamic> arguments = call.arguments;
        final List<String> recipients =
            List<String>.from(arguments['recipients']);
        final String message = arguments['message'];
        await sendBulkSMS(recipients, message);
        break;
      default:
        throw MissingPluginException();
    }
  }
}
