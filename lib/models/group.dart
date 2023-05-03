// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:study_work_grading_web_based/models/class.dart';
import 'package:study_work_grading_web_based/models/user.dart';

class Group {
  final int groupID;
  final Class groupClass;
  List<String> groupUsers = [];
  Group({
    required this.groupID,
    required this.groupClass,
    required this.groupUsers,
  });

  Group copyWith({
    int? groupID,
    Class? groupClass,
    List<String>? groupUsers,
  }) {
    return Group(
      groupID: groupID ?? this.groupID,
      groupClass: groupClass ?? this.groupClass,
      groupUsers: groupUsers ?? this.groupUsers,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'groupID': groupID,
      'groupClass': groupClass.toMap(),
      'groupUsers': groupUsers,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
        groupID: map['groupID'] as int,
        groupClass: Class.fromMap(map['groupClass'] as Map<String, dynamic>),
        groupUsers: List<String>.from(
          (map['groupUsers'] as List<String>),
        ));
  }

  String toJson() => json.encode(toMap());

  factory Group.fromJson(String source) =>
      Group.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Group(groupID: $groupID, groupClass: $groupClass, groupUsers: $groupUsers)';

  @override
  bool operator ==(covariant Group other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.groupID == groupID &&
        other.groupClass == groupClass &&
        listEquals(other.groupUsers, groupUsers);
  }

  @override
  int get hashCode =>
      groupID.hashCode ^ groupClass.hashCode ^ groupUsers.hashCode;
}
