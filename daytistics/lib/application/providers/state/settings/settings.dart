import 'package:daytistics/application/models/user_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  UserSettings? build() {
    return null;
  }

  // ignore: use_setters_to_change_properties
  void update(UserSettings userSettings) {
    state = userSettings;
  }
}
