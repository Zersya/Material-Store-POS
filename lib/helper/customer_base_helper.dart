import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/models/customer.dart';
import 'package:harco_app/services/customer_base_service.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:rxdart/rxdart.dart';

class CustomerBaseHelper extends BaseReponseBloc<ViewState> {
  CustomerBaseService customerBaseService = GetIt.I<CustomerBaseService>();

  BehaviorSubject<List<Customer>> subjectListCustomer;

  List<Customer> customers = List();

  CustomerBaseHelper() {
    subjectListCustomer = BehaviorSubject<List<Customer>>();
  }
  ValueStream<List<Customer>> get customerListStream =>
      subjectListCustomer.stream;

  Future fetchCustomers() async {
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response =
        await customerBaseService.fetchCustomers();

    final listen = response.result.listen((list) {
      customers = List<Customer>.from(
          list.docs.map((val) => Customer.fromMap(val.data())).toList());

      this.subjectListCustomer.sink.add(customers);
      this.subjectResponse.sink.add(response);
      this.subjectState.sink.add(ViewState.IDLE);
    });
    listen.onDone(() => listen.cancel());
  }

  void dispose() {
    subjectListCustomer.close();
  }
}
