import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> checkNetworkConnection() async {
  final connectivityResults = await Connectivity().checkConnectivity();
  return !connectivityResults.contains(ConnectivityResult.none);
}

Future<bool> checkSupabaseConnection() async {
  try {
    final request = await HttpClient().getUrl(
      Uri.parse('${SupabaseSettings.url}/auth/v1/health'),
    );

    final response = await request.close();

    return response.statusCode == 200;
  } on SocketException catch (_) {
    return false;
  }
}

Future<bool> maybeRedirectToConnectionErrorView(BuildContext context) async {
  final isNetworkConnected = await checkNetworkConnection();
  final isSupabaseConnected = await checkSupabaseConnection();

  if ((!isNetworkConnected || !isSupabaseConnected) && context.mounted) {
    await Navigator.of(context).pushNamed('/');
    return true;
  }

  return false;
}

Future<void> openUrl(String url) async {
  final Uri parsedUrl = Uri.parse(url);

  await launchUrl(parsedUrl);
}
