import 'package:harco_app/models/user.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyResponse<T> {
  final ResponseState responseState;
  final String message;
  final T result;

  MyResponse(this.responseState, this.result, {this.message});
}

class BaseReponseBloc<T> {
  BehaviorSubject<T> subjectState;
  BehaviorSubject<MyResponse> subjectResponse;
  BehaviorSubject<User> subjectUser;

  BaseReponseBloc() {
    subjectResponse = BehaviorSubject<MyResponse>();
    subjectState = BehaviorSubject<T>();
    subjectUser = BehaviorSubject<User>();

    SharedPreferences.getInstance().then((val) {
      final uid = val.getString('UID');
      final email = val.getString('EMAIL');
      final name = val.getString('NAME');

      subjectUser.sink.add(User(email, id: uid, name: name));
    });
  }

  ValueStream<MyResponse> get responseStream => subjectResponse.stream;
  ValueStream<T> get stateStream => subjectState.stream;
  ValueStream<User> get userStream => subjectUser.stream;

  void dispose() {
    subjectResponse.close();
    subjectState.close();
    subjectUser.close();
  }
}
