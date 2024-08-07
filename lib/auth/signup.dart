// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_locator/functions/constants.dart';
import 'package:flutter_locator/google_maps_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../bloc/Login/login_bloc.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String password = "";
  String email = "";
  String middleName = "";
  String firstName = "";
  String lastName = "";
  String phoneNumber = "";

  String confirm_password = "";

  final formKey = GlobalKey<FormState>();
  bool _isChecked = false;

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: BlocProvider(
          create: (context) => LoginBloc(),
          child: Center(
            child: Form(
              key: formKey,
              child: ListView(children: [
                Padding(padding: EdgeInsets.all(30)),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.signn_up,
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                Padding(padding: EdgeInsets.all(20)),
                //email
                textForm(
                    AppLocalizations.of(context)!.email, TextInputType.emailAddress, Icons.email_outlined),
                textForm(
                    AppLocalizations.of(context)!.first_name, TextInputType.text, Icons.person_outline),

                textForm(
                    AppLocalizations.of(context)!.middle_name, TextInputType.text, Icons.person_outline),
                textForm(AppLocalizations.of(context)!.phone_number, TextInputType.number, Icons.phone),

                //password
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: _obscureText == true
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off)),
                    isDense: true,
                    labelText: AppLocalizations.of(context)!.enter_password,
                    labelStyle: TextStyle(color: Colors.grey),
                    icon: Icon(Icons.lock, color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    fillColor: Colors.black,
                  ),
                  style: TextStyle(color: Colors.black),
                  validator: (val) =>
                      val!.length < 6 ? "Pasword too short" : null,
                  onChanged: (value) {
                    password = value;
                  },
                  onSaved: (val) => password = val!,
                  obscureText: _obscureText,
                ),
                Padding(padding: EdgeInsets.all(10)),
                //confirm password
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: _obscureText == true
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off)),
                    isDense: true,
                    labelText: AppLocalizations.of(context)!.confirm_password,
                    labelStyle: TextStyle(color: Colors.grey),
                    icon: Icon(Icons.lock, color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    fillColor: Colors.black,
                  ),
                  style: TextStyle(color: Colors.black),
                  validator: (val) =>
                      val! != password ? "Passwords do not match" : null,
                  onChanged: (value) {
                    confirm_password = value;
                  },
                  onSaved: (val) => confirm_password = val!,
                  obscureText: _obscureText,
                ),

              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      },
                    ),
                    Text(
                      'I accept the',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),

                    ),
                    MaterialButton(onPressed: ()async{
                      final file = await AppConstants().loadNetwork();
                      AppConstants().openPDF(context, file);
                    }, child:  Text("terms and conditions", style: TextStyle(
                      fontSize: 16.0,color: Colors.teal
                    ),),)
                  ],
                ),
              ),
                Padding(padding: EdgeInsets.all(10)),

                BlocConsumer<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state.status == LoginStatus.success) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => GoogleMapPage()));
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
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }

                    if (state.status == LoginStatus.error) {
                      final snackBar = SnackBar(
                        content: Text(
                            "Signup failed! Check your internet and try again"),
                        backgroundColor: (Colors.red),
                        action: SnackBarAction(
                          label: '',
                          onPressed: () {},
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  builder: (context, state) {
                    return BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        if (state.status == LoginStatus.loading) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ElevatedButton(
                            onPressed: () async {
                              print(_isChecked);
                              if (!formKey.currentState!.validate() || !_isChecked ){
                                return;
                              } else {
                                context.read<LoginBloc>().add(Signup(
                                    password: password,
                                    email: email,
                                    middleName: middleName,
                                    firstName: firstName,
                                    phoneNumber: phoneNumber));
                              }
                            },
                            child: Container(
                                alignment: Alignment.center,
                                height: 30,
                                width: 200,
                                child: Text(
                                    AppLocalizations.of(context)!.signn_up,

                                  style: TextStyle(fontSize: 18),
                                )));
                      },
                    );
                  },
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget textForm(
      String label_text, TextInputType keyboard_type, IconData icon) {
    return Column(
      children: [
        TextFormField(
          keyboardType: keyboard_type,
          decoration: InputDecoration(
            labelText: label_text,
            isDense: true,
            labelStyle: TextStyle(color: Colors.grey),
            icon: Icon(icon, color: Colors.black),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
            fillColor: Colors.black,
          ),
          style: TextStyle(color: Colors.black),
          validator: (val) {
            String? returnValue;
            if (label_text.contains(AppLocalizations.of(context)!.email)) {
              returnValue = !val!.contains("@") ? "Enter a valid Email" : null;
            } else if (label_text.contains(AppLocalizations.of(context)!.first_name)) {
              returnValue = val!.length < 2 ? "Enter a valid name" : null;
            } else if (label_text.contains(AppLocalizations.of(context)!.middle_name)) {
              returnValue = val!.length < 2 ? "Enter a valid name" : null;
            } else if (label_text.contains(AppLocalizations.of(context)!.phone_number)) {
              returnValue =
                  val!.length != 10 ? "Enter a valid Phone Number" : null;
            }

            return returnValue;
          },
          onChanged: (value) {
            if (label_text.contains(AppLocalizations.of(context)!.email)) {
              email = value;
            } else if (label_text.contains(AppLocalizations.of(context)!.first_name)) {
              firstName = value;
            } else if (label_text.contains(AppLocalizations.of(context)!.middle_name)) {
              middleName = value;
            }  else if (label_text.contains(AppLocalizations.of(context)!.phone_number)) {
              phoneNumber = value;
            }
          },
          onSaved: (val) => email = val!,
        ),
        Padding(padding: EdgeInsets.all(10)),
      ],
    );
  }
}
