import 'package:preferences_service/preferences_service.dart';

/// In-memory [PreferencesService]: the editor only reads [current].
class FakePreferencesService implements PreferencesService {
  FakePreferencesService([this.current = const Preferences()]);

  @override
  Preferences current;

  @override
  Stream<Preferences> get stream => const Stream.empty();

  @override
  Future<void> update(Preferences Function(Preferences) transform) async {
    current = transform(current);
  }
}
