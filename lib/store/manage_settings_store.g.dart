// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manage_settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ManageSettingsStore on _ManageSettingsStore, Store {
  late final _$autoAvailableAtom =
      Atom(name: '_ManageSettingsStore.autoAvailable', context: context);

  @override
  bool get autoAvailable {
    _$autoAvailableAtom.reportRead();
    return super.autoAvailable;
  }

  @override
  set autoAvailable(bool value) {
    _$autoAvailableAtom.reportWrite(value, super.autoAvailable, () {
      super.autoAvailable = value;
    });
  }

  late final _$_ManageSettingsStoreActionController =
      ActionController(name: '_ManageSettingsStore', context: context);

  @override
  void updateAutoAvailable(bool newAutoAvailable) {
    final _$actionInfo = _$_ManageSettingsStoreActionController.startAction(
        name: '_ManageSettingsStore.updateAutoAvailable');
    try {
      return super.updateAutoAvailable(newAutoAvailable);
    } finally {
      _$_ManageSettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
autoAvailable: ${autoAvailable}
    ''';
  }
}
