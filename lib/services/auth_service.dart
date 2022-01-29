import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/services.dart';
import 'package:harco_app/models/user.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/helper/responseHelper.dart';

import 'dart:io';

class AuthService {
  fa.FirebaseAuth auth;
  FirebaseFirestore firestore;

  AuthService(this.firestore, this.auth);

  Future<MyResponse> loginUser(User user) async {
    try {
      fa.UserCredential res = await auth.signInWithEmailAndPassword(
          email: user.email, password: user.password);
      user = User(res.user.email, id: res.user.uid);

      return MyResponse<User>(ResponseState.SUCCESS, user, message: null);
    } on SocketException {
      return MyResponse(ResponseState.ERROR, null,
          message: 'Kesalahan jaringan');
    } on PlatformException catch (err) {
      return MyResponse(ResponseState.ERROR, null, message: err.message);
    } on Exception catch (err) {
      return MyResponse(ResponseState.ERROR, null, message: err.toString());
    }
  }
}
