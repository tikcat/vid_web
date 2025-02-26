import 'package:mobx/mobx.dart';

part 'manage_settings_store.g.dart';

class ManageSettingsStore = _ManageSettingsStore with _$ManageSettingsStore;

abstract class _ManageSettingsStore with Store {

  @observable
  bool autoAvailable = false;

  @action
  void updateAutoAvailable(bool newAutoAvailable) {
    autoAvailable = newAutoAvailable;
  }

}