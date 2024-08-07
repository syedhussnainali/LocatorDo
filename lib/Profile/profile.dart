    // ignore_for_file: public_member_api_docs, sort_constructors_first
    // ignore_for_file: prefer_const_constructors

    import 'dart:async';
    import 'dart:developer';
    import 'dart:io';

    import 'package:firebase_storage/firebase_storage.dart';
    import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_locator/bloc/Devices/devices_bloc.dart';
import 'package:flutter_locator/bloc/Login/login_bloc.dart';
    import 'package:flutter_locator/helper/shared_pref.dart';
    import 'package:flutter_locator/models/language/app_language.dart';
    import 'package:flutter_locator/provider/app_locale.dart';
    import 'package:hydrated_bloc/hydrated_bloc.dart';
    import 'package:flutter_gen/gen_l10n/app_localizations.dart';

    import 'package:flutter_locator/Profile/AccountDetails.dart';
    import 'package:flutter_locator/auth/Login.dart';
    import 'package:flutter_locator/functions/constants.dart';
    import 'package:image_cropper/image_cropper.dart';
    import 'package:image_picker/image_picker.dart';
    import 'package:provider/provider.dart';

import '../functions/app_functions.dart';

    class Profile extends StatefulWidget {

      Timer? timer;
      @override
      State<Profile> createState() => _ProfileState();

      Profile( this.timer );
}

    class _ProfileState extends State<Profile> {
      String password = "";
      var dropdownValue =  null;
  
      var imageFile;
      var profileBloc;

      var imageUrl;
      String dummyProfile = "https://firebasestorage.googleapis.com/v0/b/dietx-cbb19.appspot.com/o/mainfood%2Fpasta%26beef.jpeg?alt=media&token=f1b36807-0d06-454e-81b8-0e4210085780";
        

      String firstname = HydratedBloc.storage.read("firstname");
      String email = HydratedBloc.storage.read("email");
      String id = HydratedBloc.storage.read("id");
      String middleName = HydratedBloc.storage.read("middlename");
      String phonenumber = HydratedBloc.storage.read("phonenumber");
      String  profile_photo = HydratedBloc.storage.read("profile_photo") ?? "https://firebasestorage.googleapis.com/v0/b/dietx-cbb19.appspot.com/o/mainfood%2Fpasta%26beef.jpeg?alt=media&token=f1b36807-0d06-454e-81b8-0e4210085780";
      
      late String currentDefaultSystemLocale;
      int selectedLangIndex = 0;



      _pickImage( String imagename, ImageSource source) async {
        var pictureFile =
        await ImagePicker.platform.getImageFromSource(source: source);

        final firebasestorage = FirebaseStorage.instance;

        if (pictureFile!.path.isNotEmpty) {
          showDialog(
              context: context,
              builder: (context) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              });
          var croppedImage = await ImageCropper.platform.cropImage(
            sourcePath: pictureFile.path,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            uiSettings: [
              AndroidUiSettings(
                  toolbarColor: Colors.teal,
                  toolbarWidgetColor: Colors.white,
                  initAspectRatio: CropAspectRatioPreset.original,
                  lockAspectRatio: false)
            ],
            compressQuality: 100,
            maxHeight: 700,
            maxWidth: 700,
            compressFormat: ImageCompressFormat.jpg,
          );
          setState(() {
            imageFile = File(croppedImage!.path);
          });
          //Upload to Firebase
          var snapshot = await firebasestorage
              .ref()
              .child('images/{$imagename}')
              .putFile(imageFile);
          var downloadUrl = await snapshot.ref.getDownloadURL();
          setState(() {
            imageUrl = downloadUrl;
          });

          profileBloc.add(updateProfile(id: id, email: email, first_name: firstname, middle_name: middleName, phone_number: phonenumber, password: password, profile_photo: imageUrl ));
   

          Navigator.pop(context);
        } else {
          print('No Image Path Received');
        }
      }

      Future imagepickerdialogue(BuildContext context, String imageName) {
        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Choose the image source"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pop(_pickImage(imageName, ImageSource.gallery));
                      },
                      child: Text("Gallery"),
                    ),
                    Padding(padding: EdgeInsets.all(8)),
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pop(_pickImage(imageName, ImageSource.camera));
                      },
                      child: Text("Camera"),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }

      Widget displayImage(String profileUrl) {
        return CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage:
          NetworkImage(profileUrl),
          radius: 80, //Image.file(imageFile),
          //radius: 70,
        );
      }

      Widget profilepictureview(String url) {
        return Image.network(url);
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text( AppLocalizations.of(context)!.profile),
            centerTitle: true,
          ),
          body:


                              Padding(
                                        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                                        child: Provider(
                              create: (context) => AppLocale(),
                              child: BlocProvider(
                      create: (context) => LoginBloc(),
                      child: SingleChildScrollView(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.grey[600],
                                      content: profilepictureview(
                                      profile_photo),
                                    );
                                  });
                            },
                            child: BlocBuilder<LoginBloc, LoginState>(
                                  builder: (context, state) {
                                
                                    profileBloc = BlocProvider.of<LoginBloc>(context);
                                  firstname = HydratedBloc.storage.read("firstname");
                                    email = HydratedBloc.storage.read("email");
                                   id = HydratedBloc.storage.read("id");
                                   middleName = HydratedBloc.storage.read("middlename");
                                   phonenumber = HydratedBloc.storage.read("phonenumber");
                                  profile_photo = HydratedBloc.storage.read("profile_photo") ?? "https://www.pngitem.com/pimgs/m/30-307416_profile-icon-png-image-free-download-searchpng-employee.png";
                                
                                    return Stack(
                              children: [
                                displayImage(profile_photo),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width * 0.28,
                                      top:
                                      MediaQuery.of(context).size.height * 0.125),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.teal,
                                    radius: 25,
                                    child: InkWell(
                                      onTap: () {
                                        imagepickerdialogue(
                                            context, email);
                                      },
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );  },),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "$firstname $middleName",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(email),
                          SizedBox(
                            height: 20,
                          ),
                          Divider(),
                          Text(
                            AppLocalizations.of(context)!.account_information,
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<AppLanguage>(
                            hint: Text("-- change language -- ", style: TextStyle(fontSize: 15),),
                            value: dropdownValue,
                            iconSize: 40,
                            style: TextStyle(fontSize: 25),
                            onChanged: (AppLanguage? language) {
                              dropdownValue = language!;
                              context.read<AppLocale>().changeLocale(Locale(language.languageCode));
                             // _appLocale.changeLocale(Locale(language.languageCode));
                              setLocale(language.languageCode);
                            },
                            items: AppLanguage.languages()
                                .map<DropdownMenuItem<AppLanguage>>(
                                  (e) => DropdownMenuItem<AppLanguage>(
                                      value: e,
                                      child: Text(
                                        e.name,
                                        style: TextStyle(color: Colors.black),
                                      )),
                                )
                                .toList(),
                          ),
                          AccountDetails(
                          title:  AppLocalizations.of(context)!.email,
                            subtitle: email,
                          ),
                          AccountDetails(title:  AppLocalizations.of(context)!.name, subtitle: "$firstname $middleName"),
                          AccountDetails(title:  AppLocalizations.of(context)!.phone_number, subtitle: phonenumber),
                          !is_user_admin ?
                          BlocProvider(
                                create: (context) => DevicesBloc(),
                                child: BlocConsumer<DevicesBloc, DevicesState>(
                              listener: (context, state) {
                                if(state.status == DevicesStatus.loaded){
                                  AppFunctions().snackbar(context, state.message, Colors.green);

                                }else if(state.status == DevicesStatus.error){
                                  AppFunctions().snackbar(context, state.message, Colors.red);

                                }
                              },
                              builder: (context, state) {
                            
                                  if(state.status == DevicesStatus.loading){
                                    return Center(child: CircularProgressIndicator.adaptive(),);
                                  }

                                  return ElevatedButton(onPressed: (){
                                    context.read<DevicesBloc>().add(RequestAdminPermission());
                                  }, child: Text("Request to be admin"));
                              },
                            ),
                          )
                              
                              : Container(),
                          SizedBox(
                            height: 20,
                          ),
                          ListTile(
                            leading: Icon(Icons.settings_power),
                            title: Text(  AppLocalizations.of(context)!.log_out),
                            onTap: () {
                              AppConstants().alertDialog(
                                  context: context,
                                  content: Text( AppLocalizations.of(context)!.do_you_want_to_logout),
                                  title:  AppLocalizations.of(context)!.log_out,
                                  onpress: () async {
                                  if(widget.timer != null){
                                    widget.timer!.cancel();
                                  }

                                    HydratedBloc.storage.clear();
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) => Login()),
                                        (Route<dynamic> route) => false);
                                  });
                            },
                          )
                        ],
                    ),
                      ),),),
                  ),
        );
      }
    }
