import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:harco_app/helper/routerHelper.dart';
import 'package:harco_app/models/user.dart';
import 'package:harco_app/utils/enum.dart' as Enum;

import 'login_bloc.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FocusNode _emailFN = FocusNode();
  FocusNode _passwordFN = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  LoginBloc _loginBloc = LoginBloc();

  @override
  void initState() {
    super.initState();
    _loginBloc.subjectResponse.listen((val) {
      if (val.responseState == Enum.ResponseState.SUCCESS) {
        Navigator.of(context).pushReplacementNamed(RouterHelper.kRouteHome);
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(val.message),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double radiusInputField = 10.0;

    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                'Masuk Harco POS',
                style: Theme.of(context).textTheme.headline,
              ),
              Divider(
                height: 62,
              ),
              StreamBuilder<Enum.FormState>(
                  stream: _loginBloc.stateStream,
                  initialData: Enum.FormState.IDLE,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    Enum.FormState state = snapshot.data;
                    if (state == Enum.FormState.ERROR) {
                      return Container(child: Center(child: Text('Error')));
                    }

                    if (state == Enum.FormState.LOADING) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (state == Enum.FormState.IDLE) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            margin: EdgeInsets.all(16.0),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 32.0, horizontal: 16.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Material(
                                      elevation: 2,
                                      borderRadius:
                                          BorderRadius.circular(radiusInputField),
                                      shadowColor: Theme.of(context)
                                          .colorScheme
                                          .primaryVariant,
                                      child: TextFormField(
                                        controller: _emailController,
                                        focusNode: _emailFN,
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          hintText: 'Email',
                                          prefixIcon: Icon(Icons.email),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(
                                                  radiusInputField)),
                                        ),
                                        onFieldSubmitted: (val) {
                                          FocusScope.of(context)
                                              .requestFocus(_passwordFN);
                                        },
                                        validator: (val) {
                                          if (val.isEmpty) {
                                            return 'Email tidak boleh kosong';
                                          } else if (!EmailValidator.validate(
                                              val)) {
                                            return 'Email tidak benar';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: 48.0,
                                      // child: GestureDetector(
                                      //   onTap: () {},
                                      //   child: Padding(
                                      //     padding: EdgeInsets.symmetric(vertical: 8.0),
                                      //     child: Align(
                                      //       alignment: Alignment.centerRight,
                                      //       child: Text(loc.auth.forgotPassword),
                                      //     ),
                                      //   ),
                                      // ),
                                    ),
                                    StreamBuilder<bool>(
                                        stream: _loginBloc.isVisibleStream,
                                        initialData: true,
                                        builder: (context, snapshot) {
                                          bool isVisible = snapshot.data;
                                          return Material(
                                            elevation: 2,
                                            borderRadius: BorderRadius.circular(
                                                radiusInputField),
                                            shadowColor: Theme.of(context)
                                                .colorScheme
                                                .primaryVariant,
                                            child: TextFormField(
                                              controller: _passwordController,
                                              focusNode: _passwordFN,
                                              obscureText: isVisible,
                                              textInputAction:
                                                  TextInputAction.done,
                                              decoration: InputDecoration(
                                                hintText: 'Password',
                                                suffixIcon: GestureDetector(
                                                    onTap: () {
                                                      _loginBloc.setVisibility(
                                                          !isVisible);
                                                    },
                                                    child: Icon(isVisible
                                                        ? Icons.visibility_off
                                                        : Icons.visibility)),
                                                prefixIcon: Icon(Icons.lock),
                                              ),
                                              onFieldSubmitted: (val) {
                                                _submitLogin();
                                              },
                                              validator: (val) {
                                                if (val.isEmpty) {
                                                  return 'Password tidak boleh kosong';
                                                } else if (val.length < 6) {
                                                  return 'Password terlalu pendek';
                                                }
                                                return null;
                                              },
                                            ),
                                          );
                                        }),
                                    SizedBox(
                                      height: 32,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: RaisedButton(
                                        elevation: 2,
                                        child: Text('Masuk',
                                            style: Theme.of(context).textTheme.button),
                                        onPressed: () {
                                          _submitLogin();
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else
                      return Container();
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void _submitLogin() {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      User user =
          User(_emailController.text, password: _passwordController.text);
      _loginBloc.loginUser(user);
    }
  }
}
