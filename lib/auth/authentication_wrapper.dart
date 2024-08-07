// ignore_for_file: prefer_const_constructors



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locator/google_maps_page.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'Login.dart';



class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
 
  @override
  void initState() {
   
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
        HydratedBloc.storage.read("status") == null ? Login() : GoogleMapPage();
  }
}