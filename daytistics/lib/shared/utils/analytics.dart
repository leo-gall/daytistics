// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> trackEvent({
  required String eventName,
  Map<String, dynamic>? properties,
  http.Client? httpClient,
}) async {
  try {
    httpClient ??= http.Client();

    final Map<String, dynamic> deviceInfo = {
      'platform': Platform.operatingSystem,
      'platform_version': Platform.operatingSystemVersion,
      'device': Platform.localHostname,
    };

    final response = await httpClient.post(
      Uri.parse('${const String.fromEnvironment('OPENPANEL_URL')}/track'),
      headers: {
        'Content-Type': 'application/json',
        'user-agent': jsonEncode(deviceInfo),
        'openpanel-client-id':
            const String.fromEnvironment('OPENPANEL_CLIENT_ID'),
        'openpanel-client-secret':
            const String.fromEnvironment('OPENPANEL_CLIENT_SECRET'),
      },
      body: jsonEncode({
        'type': 'track',
        'payload': {
          'name': eventName,
          'properties': properties,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to track event');
    }
  } on SocketException catch (e) {
    throw Exception(e.message);
  }
}
