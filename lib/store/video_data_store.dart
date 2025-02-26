import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobx/mobx.dart';

part 'video_data_store.g.dart';

class VideoDataStore = _VideoDataStore with _$VideoDataStore;

abstract class _VideoDataStore with Store {

  /// 初始化加载缓存的用户账号
  @observable
  bool initLoadUser = false;

  @action
  void updateInitLoadUser(bool newInitLoadUser) {
    initLoadUser = newInitLoadUser;
  }

  @observable
  bool signed = false;

  @action
  void updateSigned(bool newSigned) {
    signed = newSigned;
  }

  @observable
  bool showLoginLoading = false;

  @action
  void updateShowLoginLoading(bool newShowLoginLoading) {
    showLoginLoading = newShowLoginLoading;
  }

  @observable
  String currentUserAccount = "";

  @action
  void updateCurrentUserAccount(String newCurrentUserAccount) {
    currentUserAccount = newCurrentUserAccount;
  }

  @observable
  String userAccount = "";

  @action
  void updateUserAccount(String newUserAccount) {
    userAccount = newUserAccount;
  }

  @observable
  String userPassword = "";

  @action
  void updateUserPassword(String newUserPassword) {
    userPassword = newUserPassword;
  }

  @observable
  List<Widget> userItemList = [];

  @action
  void updateUserItemList(List<Widget> newUserItemList) {
    userItemList = newUserItemList;
  }

  /// 密码是否可见, 默认不可见
  @observable
  bool isObscure = true;

  @action
  void updateIsObscure(bool newIsObscure) {
    isObscure = newIsObscure;
  }

  @observable
  GoogleSignInAccount? googleUser;

  @action
  void updateGoogleUser(GoogleSignInAccount? newGoogleUser) {
    googleUser = newGoogleUser;
  }

}