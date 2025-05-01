// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:openpanel_flutter/openpanel_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics.g.dart';

class Analytics {
  final http.Client httpClient = http.Client();

  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    Openpanel.instance.event(name: eventName, properties: properties ?? {});
  }
}

@riverpod
Analytics analyticsDependency(Ref ref) => Analytics();
