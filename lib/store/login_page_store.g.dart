// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_page_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LoginPageStore on _LoginPageStore, Store {
  late final _$currentAccountAtom =
      Atom(name: '_LoginPageStore.currentAccount', context: context);

  @override
  LoginAccountData? get currentAccount {
    _$currentAccountAtom.reportRead();
    return super.currentAccount;
  }

  @override
  set currentAccount(LoginAccountData? value) {
    _$currentAccountAtom.reportWrite(value, super.currentAccount, () {
      super.currentAccount = value;
    });
  }

  late final _$loginDataListAtom =
      Atom(name: '_LoginPageStore.loginDataList', context: context);

  @override
  List<LoginAccountData> get loginDataList {
    _$loginDataListAtom.reportRead();
    return super.loginDataList;
  }

  @override
  set loginDataList(List<LoginAccountData> value) {
    _$loginDataListAtom.reportWrite(value, super.loginDataList, () {
      super.loginDataList = value;
    });
  }

  late final _$_LoginPageStoreActionController =
      ActionController(name: '_LoginPageStore', context: context);

  @override
  void setCurrentAccount(LoginAccountData? currentAccount) {
    final _$actionInfo = _$_LoginPageStoreActionController.startAction(
        name: '_LoginPageStore.setCurrentAccount');
    try {
      return super.setCurrentAccount(currentAccount);
    } finally {
      _$_LoginPageStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoginDataList(List<LoginAccountData> loginDataList) {
    final _$actionInfo = _$_LoginPageStoreActionController.startAction(
        name: '_LoginPageStore.setLoginDataList');
    try {
      return super.setLoginDataList(loginDataList);
    } finally {
      _$_LoginPageStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentAccount: ${currentAccount},
loginDataList: ${loginDataList}
    ''';
  }
}
