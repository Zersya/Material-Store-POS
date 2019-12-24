import 'package:harco_app/utils/enum.dart';
import 'package:rxdart/rxdart.dart';

class MyResponse<T> {
  final ResponseState responseState;
  final String message;
  final T result;

  MyResponse(this.responseState, this.result, {this.message});
}

class BaseReponseBloc<T> {
  BehaviorSubject<T> subjectState;
  BehaviorSubject<MyResponse> subjectResponse;


  BaseReponseBloc() {
    subjectResponse = BehaviorSubject<MyResponse>();
    subjectState = BehaviorSubject<T>();
  }

  ValueStream<MyResponse> get responseStream => subjectResponse.stream;
  ValueStream<T> get stateStream => subjectState.stream;


  void dispose() {
    subjectResponse.close();
    subjectState.close();
  }
}
