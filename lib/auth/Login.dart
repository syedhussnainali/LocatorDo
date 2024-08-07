// ignore_for_file: prefer_const_constructors, avoid_single_cascade_in_expression_statements, prefer_const_literals_to_create_immutables

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_locator/auth/signup.dart';
import 'package:flutter_locator/google_maps_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../bloc/Login/login_bloc.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late String password, email;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.sign_in,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,

                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.email,
                          labelStyle: TextStyle(color: Colors.grey),
                          icon: Icon(Icons.email_outlined, color: Colors.black),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          fillColor: Colors.black,
                        ),
                        style: TextStyle(color: Colors.black),
                        //controller: email,
                        validator: (val) => !val!.contains("@")
                            ? "Enter a valid email address"
                            : null,
                        onChanged: (value) {
                          email = value;
                        },
                        onSaved: (val) => email = val!,
                      ),
                      Padding(padding: EdgeInsets.all(20)),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,

                        decoration: InputDecoration(
                          labelText:AppLocalizations.of(context)!.password,
                          labelStyle: TextStyle(color: Colors.grey),
                          icon: Icon(Icons.lock, color: Colors.black),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          fillColor: Colors.black,
                        ),
                        style: TextStyle(color: Colors.black),
                        //controller: password,
                        validator: (val) =>
                            val!.length < 6 ? "Pasword too short" : null,
                        onChanged: (value) {
                          password = value;
                        },
                        onSaved: (val) => password = val!,
                        obscureText: true,
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                      ),
                      BlocConsumer<LoginBloc, LoginState>(
                        listener: (context, state) {
                          if (state.status == LoginStatus.success) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        GoogleMapPage()));
                          }

                          if (state.status == LoginStatus.failed) {
                            final snackBar = SnackBar(
                              content: Text(state.message),
                              backgroundColor: (Colors.red),
                              action: SnackBarAction(
                                label: '',
                                onPressed: () {},
                              ),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }

                          if (state.status == LoginStatus.error) {
                            final snackBar = SnackBar(
                              content: Text(
                                  "Login failed! Try again"),
                              backgroundColor: (Colors.red),
                              action: SnackBarAction(
                                label: '',
                                onPressed: () {},
                              ),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        builder: (context, state) {
                          return BlocBuilder<LoginBloc, LoginState>(
                            builder: (context, state) {
                              if (state.status == LoginStatus.loading) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              return ElevatedButton(
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  log(email + password);
                                  context.read<LoginBloc>().add(
                                        GetLogin(
                                          email: email.trim().toLowerCase(),
                                          password: password,
                                        ),
                                      );
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 30,
                                  width: 200,
                                  child: Text(
                                      AppLocalizations.of(context)!.log_in,
                                      
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Padding(padding: EdgeInsets.all(20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Text(
                          //   AppLocalizations.of(context)!.new_user_create_account,
                          //   style: Theme.of(context)
                          //       .textTheme
                          //       .bodyMedium!
                          //       .copyWith(fontSize: 17),
                          // ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SignUp()));
                            },
                            child: Text(
                              AppLocalizations.of(context)!.new_user_create_account,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      fontSize: 19,
                                      color: Theme.of(context).primaryColor),
                            ),
                         ),
                        ],
                      )
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
