import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:harco_app/helper/customer_base_helper.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/models/customer.dart';
import 'package:harco_app/services/customer_service.dart';
import 'package:harco_app/utils/enum.dart';

class CustomerBloc extends CustomerBaseHelper {
  CustomerService _customerService = GetIt.I<CustomerService>();

  Future fetchCustomers() async {
    this.subjectState.sink.add(ViewState.LOADING);
    MyResponse<Stream<QuerySnapshot>> response =
        await this.customerBaseService.fetchCustomers();

    final listen = response.result.listen((list) {
      customers = List<Customer>.from(
          list.documents.map((val) => Customer.fromMap(val.data)).toList());

      this.subjectListCustomer.sink.add(customers);
      this.subjectResponse.sink.add(response);
      this.subjectState.sink.add(ViewState.IDLE);
    });
    listen.onDone(() => listen.cancel());
  }

  Future setCustomer(Customer customer) async {
    this.subjectState.sink.add(ViewState.LOADING);
    customer.createdBy = this.subjectUser.value;
    MyResponse response = await _customerService.setCustomer(customer);
    this.subjectResponse.sink.add(response);
    this.subjectState.sink.add(ViewState.IDLE);
  }
}
