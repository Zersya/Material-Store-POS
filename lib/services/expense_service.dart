import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harco_app/helper/responseHelper.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/models/expense.dart';

class ExpenseService {
  final Firestore firestore;

  ExpenseService(this.firestore);
  
  Future<MyResponse> createExpense(
      Expense transaction) async {
    try {
      transaction.id =
          firestore.collection('expenses').document().documentID;

      await firestore
          .collection('expenses')
          .document(transaction.id)
          .setData(transaction.toMap())
          .catchError((err) {
        throw Exception(err);
      });

      return MyResponse(ResponseState.SUCCESS, transaction,
          message: 'Berhasil menambah pengeluaran');
    } on SocketException {
      return MyResponse(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on Exception catch (err) {
      return MyResponse(ResponseState.ERROR, null, message: err.toString());
    }
  }

  Future<MyResponse> fetchExpenseToday() async {
    try {
      DateTime now = DateTime.now();

      Stream<QuerySnapshot> snapshot = firestore
          .collection('expenses')
          .where('createdAt',
              isGreaterThan:
                  new DateTime(now.year, now.month, now.day - 1, 6, 30)
                      .millisecondsSinceEpoch)
          .snapshots();

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

  Future<MyResponse> fetchExpenseAll() async {
    try {
      Stream<QuerySnapshot> snapshot =
          firestore.collection('expenses').snapshots();

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
}
