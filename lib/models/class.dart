// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:study_work_grading_web_based/models/group.dart';

class Class {
  final String subjectName;
  final int classID;
  final String classTeacherEmail;
  List<String> classStudents;

  Class(
    this.subjectName,
    this.classID,
    this.classTeacherEmail,
    this.classStudents,
  );

  Class copyWith({
    String? subjectName,
    int? classID,
    String? classTeacherEmail,
    List<String>? classStudents,
  }) {
    return Class(
      subjectName ?? this.subjectName,
      classID ?? this.classID,
      classTeacherEmail ?? this.classTeacherEmail,
      classStudents ?? this.classStudents,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'subjectName': subjectName,
      'classID': classID,
      'classTeacherEmail': classTeacherEmail,
      'classStudents': classStudents,
    };
  }

  factory Class.fromMap(Map<String, dynamic> map) {
    return Class(
        map['subjectName'] as String,
        map['classID'] as int,
        map['classTeacherEmail'] as String,
        List<String>.from(
          (map['classStudents'] as List<String>),
        ));
  }

  String toJson() => json.encode(toMap());

  factory Class.fromJson(String source) =>
      Class.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Class(subjectName: $subjectName, classID: $classID, classTeacherEmail: $classTeacherEmail, classStudents: $classStudents)';
  }

  @override
  bool operator ==(covariant Class other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.subjectName == subjectName &&
        other.classID == classID &&
        other.classTeacherEmail == classTeacherEmail &&
        listEquals(other.classStudents, classStudents);
  }

  @override
  int get hashCode {
    return subjectName.hashCode ^
        classID.hashCode ^
        classTeacherEmail.hashCode ^
        classStudents.hashCode;
  }
}
