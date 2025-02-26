import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobx/mobx.dart';
import 'package:vid_web/data/login_account_data.dart';

part 'login_page_store.g.dart';

class LoginPageStore = _LoginPageStore with _$LoginPageStore;

abstract class _LoginPageStore with Store {

  @observable
  LoginAccountData? currentAccount;

  @action
  void setCurrentAccount(LoginAccountData? currentAccount) {
    this.currentAccount = currentAccount;
  }

  @observable
  List<LoginAccountData> loginDataList = [];

  @action
  void setLoginDataList(List<LoginAccountData> loginDataList) {
    this.loginDataList = loginDataList;
  }

  @observable
  User? user;

  @action
  void setUser(User? user) {
    this.user = user;
  }

  @observable
  GoogleSignInAccount? googleUser;

  @action
  void setGoogleUser(GoogleSignInAccount? googleUser) {
    this.googleUser = googleUser;
  }
}