import 'package:flutter_test/flutter_test.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class FakePosthog extends Fake implements Posthog {
  List<String> capturedEvents = [];

  @override
  Future<void> identify({
    required String userId,
    Map<String, Object>? userProperties,
    Map<String, Object>? userPropertiesSetOnce,
  }) async {
    // Do nothing.
  }

  @override
  Future<void> capture({
    required String eventName,
    Map<String, Object>? properties,
  }) async {
    capturedEvents.add(eventName);
  }
}
