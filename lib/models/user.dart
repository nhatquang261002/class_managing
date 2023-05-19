// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';

class UserModel {
  final String name;
  final String email;
  final bool isTeacher;
  final int id;
  Map<String, Map<String, bool>> classAndGroup;

  UserModel({
    required this.name,
    required this.email,
    required this.isTeacher,
    required this.id,
    required this.classAndGroup,
  });

  UserModel copyWith({
    String? name,
    String? email,
    bool? isTeacher,
    int? id,
    Map<String, Map<String, bool>>? classAndGroup,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      isTeacher: isTeacher ?? this.isTeacher,
      id: id ?? this.id,
      classAndGroup: classAndGroup ?? this.classAndGroup,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'isTeacher': isTeacher,
      'id': id,
      'classAndGroup': classAndGroup,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        name: map['name'] as String,
        email: map['email'] as String,
        isTeacher: map['isTeacher'] as bool,
        id: map['id'] as int,
        classAndGroup: Map<String, Map<String, bool>>.from(
          (map['classAndGroup'] as Map<String, Map<String, bool>>),
        ));
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, isTeacher: $isTeacher, id: $id, classAndGroup: $classAndGroup)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other.name == name &&
        other.email == email &&
        other.isTeacher == isTeacher &&
        other.id == id &&
        mapEquals(other.classAndGroup, classAndGroup);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        isTeacher.hashCode ^
        id.hashCode ^
        classAndGroup.hashCode;
  }
}
