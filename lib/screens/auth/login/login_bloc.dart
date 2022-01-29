import 'package:get_it/get_it.dart';
import 'package:harco_app/models/user.dart';
import 'package:harco_app/services/auth_service.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginBloc extends BaseReponseBloc<FormState> {
  AuthService _authService;
  BehaviorSubject<bool> _isVisible;

  LoginBloc() {
    _authService = GetIt.I<AuthService>();
    _isVisible = BehaviorSubject<bool>();
  }

  @override
  ValueStream<MyResponse> get responseStream => super.responseStream;
  ValueStream<bool> get isVisibleStream => _isVisible.stream;

  void setVisibility(bool data) {
    _isVisible.sink.add(data);
  }

  Future loginUser(User user) async {
    this.subjectState.sink.add(FormState.LOADING);

    MyResponse response = await _authService.loginUser(user);
    if (response.responseState == ResponseState.SUCCESS) {
      SharedPreferences pref = await SharedPreferences.getInstance();

      pref.setString('UID', response.result.id);
      pref.setString('EMAIL', response.result.email);
      // pref.setString('NAME', response.result.name);
    }
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(FormState.IDLE);
  }

  @override
  void dispose() {
    super.dispose();

    _isVisible.close();
  }
}
