import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/services/customer_base_service.dart';
import 'package:harco_app/utils/enum.dart';

class CustomerService extends CustomerBaseService{
  final FirebaseFirestore firestore;

  CustomerService(this.firestore) : super(firestore);

  Future<MyResponse> deleteCustomer(String id) async {
    try {
      firestore.collection('customers').doc(id).delete();
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.SUCCESS, null,
          message: 'Sukses menghapus pelanggan');
    } on SocketException {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Terjadi kesalahan');
    }
  }

}