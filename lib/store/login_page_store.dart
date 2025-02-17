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
}