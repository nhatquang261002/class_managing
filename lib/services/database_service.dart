import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/models/user.dart';

import '../models/class.dart';

class DatabaseService {
  Future saveUser(UserModel user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.email).set(
          user.toMap(),
        );
  }

  Future saveClass(Class currentClass, BuildContext context) async {
    final checkClass = await FirebaseFirestore.instance
        .collection('classes')
        .doc(currentClass.classID.toString())
        .get();
    if (!checkClass.exists) {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(currentClass.classID.toString())
          .set(currentClass.toMap());
    } else {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text(
                  'The class with that ID is already exists.',
                  style: TextStyle(fontSize: 16.0),
                ),
              );
            });
      }
    }
  }

  Future addStudent(String studentID, int classID, BuildContext context) async {
    final checkStudent = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: double.parse(studentID))
        .get();
    final checkClass = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .get();
    List students = checkClass.data()!['classStudents'];
    if (checkStudent.docs.isNotEmpty) {
      final userEmail = checkStudent.docs.first.data()['email'];
      if (!students.contains(userEmail)) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .update({
          'classGroups': FieldValue.arrayUnion([classID])
        });

        await FirebaseFirestore.instance
            .collection('classes')
            .doc(classID.toString())
            .update({
          'classStudents': FieldValue.arrayUnion([userEmail]),
        });
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text(
                    'The student with that ID is already in the class.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                );
              });
        }
      }
    } else {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text(
                  'The student with that ID doesn\'t exist.',
                  style: TextStyle(fontSize: 16.0),
                ),
              );
            });
      }
    }
  }

  Future deleteStudent(int classID, String userEmail) async {
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .update({
      'classStudents': FieldValue.arrayRemove([userEmail]),
    });
  }
}
