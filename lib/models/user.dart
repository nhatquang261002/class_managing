// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';

class UserModel {
  final String name;
  final String email;
  final bool isTeacher;
  final int id;
  List<String> classGroups = [];

  UserModel({
    required this.name,
    required this.email,
    required this.isTeacher,
    required this.classGroups,
    required this.id,
  });

  UserModel copyWith({
    String? name,
    String? email,
    bool? isTeacher,
    int? id,
    List<String>? classGroups,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      isTeacher: isTeacher ?? this.isTeacher,
      id: id ?? this.id,
      classGroups: classGroups ?? this.classGroups,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'isTeacher': isTeacher,
      'classGroups': classGroups,
      'id': id,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        name: map['name'] as String,
        email: map['email'] as String,
        isTeacher: map['isTeacher'] as bool,
        id: map['id'] as int,
        classGroups: List<String>.from(
          (map['classGroups'] as List<String>),
        ));
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, isTeacher: $isTeacher, classGroups: $classGroups, id: $id)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.name == name &&
        other.email == email &&
        other.isTeacher == isTeacher &&
        listEquals(other.classGroups, classGroups) &&
        other.id == id;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        isTeacher.hashCode ^
        classGroups.hashCode ^
        id.hashCode;
  }
}
