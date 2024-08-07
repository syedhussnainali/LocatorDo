// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
      final String? id;
      final String? email; 
      final String? firstName; 
      final String? middleName; 
      final String? phoneNumber;
      final String? profile_photo;
      final bool?  isAdmin;

  User({
    this.id,
    this.email,
    this.firstName,
    this.middleName,
    this.phoneNumber,
    this.profile_photo,
    this.isAdmin,
  });

  

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: map['id'] = map['id'] .toString() ,
      email: map['email'] = map['email'] .toString() ,
      firstName: map['firstName'] = map['first_name'] .toString() ,
      middleName: map['middleName'] = map['middle_name'] .toString() ,
      phoneNumber: map['phoneNumber'] = map['phone_number'] .toString() ,
      profile_photo: map['profile_photo'] = map['profile_photo'] .toString() ,
      isAdmin: map['isAdmin'] = map['is_admin'],
    );
  }

 
}
