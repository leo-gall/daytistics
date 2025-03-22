import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAnalytics extends Fake implements Analytics {
  List<String> capturedEvents = [];

  @override
  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    capturedEvents.add(eventName);
  }
}
