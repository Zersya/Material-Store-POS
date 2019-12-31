import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/models/customer.dart';
import 'package:harco_app/utils/enum.dart';

class CustomerBaseService {
  final Firestore firestore;

  CustomerBaseService(this.firestore);

  Future<MyResponse> fetchCustomers() async {
    try {
      Stream<QuerySnapshot> snapshot =
          firestore.collection('customers').snapshots();
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.SUCCESS, snapshot,
          message: null);
    } on SocketException {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception {
      return MyResponse<Stream<QuerySnapshot>>(ResponseState.ERROR, null,
          message: 'Terjadi kesalahan');
    }
  }

  Future<MyResponse> createCustomer(Customer customer) async {
    try {
      final id = firestore.collection('customers').document().documentID;
      customer.id = id;
      
      await firestore
          .collection('customers')
          .document(id)
          .setData(customer.toMap()).catchError((err) {
        throw Exception(err);
      });

      return MyResponse(ResponseState.SUCCESS, null,
          message: 'Berhasil menambah customer');
    } on SocketException {
      return MyResponse(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception catch (err) {
      return MyResponse(ResponseState.ERROR, null, message: err.toString());
    }
  }

  Future<MyResponse> updateCustomer(Customer customer) async {
    try {

      await firestore
          .collection('customers')
          .document(customer.id)
          .setData(customer.toMap()).catchError((err) {
        throw Exception(err);
      });

      return MyResponse(ResponseState.SUCCESS, null,
          message: 'Berhasil menambah customer');
    } on SocketException {
      return MyResponse(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception catch (err) {
      return MyResponse(ResponseState.ERROR, null, message: err.toString());
    }
  }
}
