import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../services/export_excel.dart';

import '../models/class.dart';

class DatabaseService {
  // save user to database
  Future saveUser(UserModel user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.email).set(
          user.toMap(),
        );
  }

  // save class to database
  Future saveClass(Class currentClass, BuildContext context) async {
    // check if the class is already exist
    final checkClass = await FirebaseFirestore.instance
        .collection('classes')
        .doc(currentClass.classID.toString())
        .get();
    // if not, save the classID to the db
    if (!checkClass.exists) {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(currentClass.classID.toString())
          .set(currentClass.toMap());

      // else pop the dialog
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

  // delete class from database
  Future deleteClass(int classID) async {
    // get all the students from the class
    final getStudents = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .get();
    final students = getStudents.data()!['classStudents'];

    // get all the groups from the class
    final getGroups = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .collection('classGroups')
        .get();

    // if there are students in the class, delete the class info in the student table
    if (students.isNotEmpty) {
      for (int i = 0; i < students.length; i++) {
        final getClassAndGroup = await FirebaseFirestore.instance
            .collection('users')
            .doc(students[i])
            .get();
        var classAndGroup =
            getClassAndGroup.data()!['classAndGroup'] as Map<String, dynamic>;
        classAndGroup.remove(classID.toString());
        await FirebaseFirestore.instance
            .collection('users')
            .doc(students[i])
            .update({'classAndGroup': classAndGroup});
      }
    }

    // if there are groups in the class, delete the groups
    if (getGroups.docs.isNotEmpty) {
      for (int i = 0; i < getGroups.size; i++) {
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(classID.toString())
            .collection('classGroups')
            .doc(getGroups.docs.elementAt(i).data()['groupName'])
            .delete();
      }
    }

    // delete the class
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .delete();
  }

  // add student to class
  Future addStudentToClass(
      String studentID, int classID, BuildContext context) async {
    // check if there are student with the correct studentID provided
    final checkStudent = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: double.parse(studentID))
        .get();

    // get the students list from the class
    final checkClass = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .get();
    List students = checkClass.data()!['classStudents'];

    // if there are a student with that studentID
    if (checkStudent.docs.isNotEmpty) {
      final userEmail = checkStudent.docs.first.data()['email'];
      // if the class doesn't have the student with that studentID, save the student to the class table and save the class to the student table
      if (!students.contains(userEmail)) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .set({
          'classAndGroup': {classID.toString(): {}}
        }, SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection('classes')
            .doc(classID.toString())
            .update({
          'classStudents': FieldValue.arrayUnion([userEmail]),
        });
        if (context.mounted) {
          Navigator.pop(context);
        }
        // if the student with the ID is already in the class, pop the dialog
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

      // if there are no student with that studentID, pop the dialog
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

  // delete student from class
  Future deleteStudentFromClass(int classID, String studentEmail) async {
    // delete the studentEmail from the class table
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .update({
      'classStudents': FieldValue.arrayRemove([studentEmail])
    });

    // the the student's classes and groups
    final getClassAndGroup = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentEmail)
        .get();
    var classAndGroup =
        getClassAndGroup.data()!['classAndGroup'] as Map<String, dynamic>;
    var group = Map<String, bool>.from(classAndGroup[classID.toString()]);
    // if there are classes and groups, delete them in the classes and classGroups table
    if (group.isNotEmpty) {
      var studentsInGroup = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classID.toString())
          .collection('classGroups')
          .doc(group.keys.first)
          .get();
      var studentsInGroupMap =
          studentsInGroup.data()!['students'] as Map<String, dynamic>;
      studentsInGroupMap.remove(studentEmail);
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classID.toString())
          .collection('classGroups')
          .doc(group.keys.first)
          .update({'students': studentsInGroupMap});
    }

    // delete the class info from the user table
    classAndGroup.remove(classID.toString());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(studentEmail)
        .update({'classAndGroup': classAndGroup});
  }

  // add group to database
  Future addGroup(int classID, String groupName, BuildContext context) async {
    // check if the group with  that groupName is already exist
    final checkGroup = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .collection('classGroups')
        .doc(groupName)
        .get();
    if (!checkGroup.exists) {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classID.toString())
          .collection('classGroups')
          .doc(groupName)
          .set(Group(groupName, {}).toMap());
      if (context.mounted) {
        Navigator.pop(context);
      }

      // if already exists, pop the dialog
    } else {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text(
                  'The group with that name is already exist.',
                  style: TextStyle(fontSize: 16.0),
                ),
              );
            });
      }
    }
  }

  // delete group from database
  Future deleteGroup(String groupName, int classID) async {
    // get the studentsEmail from the group table
    final getStudents = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .collection('classGroups')
        .doc(groupName)
        .get();
    var students = getStudents.data()!['students'] as Map<String, dynamic>;
    List<String> studentsEmail = students.keys.toList();
    // if there are students in the group, delete student
    if (studentsEmail.isNotEmpty) {
      for (int i = 0; i < studentsEmail.length; i++) {
        await deleteStudentFromGroup(
            studentsEmail[i], classID.toString(), groupName);
      }
    }
    // delete the group from the class table
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .collection('classGroups')
        .doc(groupName)
        .delete();
  }

  // add student to a group
  Future addStudentToGroup(String studentID, String groupName, int classID,
      BuildContext context) async {
    // check if the student with that id is exists
    final checkStudentExist = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: double.parse(studentID))
        .get();

    List<int> scoring = [];
    // if the student exists
    if (checkStudentExist.docs.isNotEmpty) {
      final studentEmail = checkStudentExist.docs.first.data()['email'];
      final studentClassAndGroup = checkStudentExist.docs.first
          .data()['classAndGroup'] as Map<String, dynamic>;
      // if the student is not in the class yet, add the student to the group and the class
      if (!studentClassAndGroup.containsKey(classID.toString())) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(studentEmail)
            .set({
          'classAndGroup': {
            classID.toString(): {groupName: false}
          }
        }, SetOptions(merge: true));
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(classID.toString())
            .update({
          'classStudents': FieldValue.arrayUnion([studentEmail])
        });
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(classID.toString())
            .collection('classGroups')
            .doc(groupName)
            .set({
          'students': {studentEmail: scoring}
        }, SetOptions(merge: true));
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        Map<String, bool> group = {};
        group =
            Map<String, bool>.from(studentClassAndGroup[classID.toString()]);
        // if the student is already in the class but not in the group, add the student to the group only
        if (group.isEmpty) {
          await FirebaseFirestore.instance
              .collection('classes')
              .doc(classID.toString())
              .collection('classGroups')
              .doc(groupName)
              .set({
            'students': {studentEmail: scoring}
          }, SetOptions(merge: true));
          await FirebaseFirestore.instance
              .collection('users')
              .doc(studentEmail)
              .set({
            'classAndGroup': {
              classID.toString(): {groupName: false}
            }
          }, SetOptions(merge: true));
          if (context.mounted) {
            Navigator.pop(context);
          }

          // if the student is already in the group, pop the dialog
        } else if (group.keys.first == groupName) {
          if (context.mounted) {
            showDialog(
                context: context,
                builder: (context) {
                  return const AlertDialog(
                    title: Text(
                      'The student with that ID is already in this group.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  );
                });
          }

          // if the student is already in another group, pop the dialog
        } else {
          if (context.mounted) {
            showDialog(
                context: context,
                builder: (context) {
                  return const AlertDialog(
                    title: Text(
                      'The student with that ID is already in another group.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  );
                });
          }
        }
      }

      // if the student doesn't exist, pop the dialog
    } else {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text(
                  'The student with that ID doesn\'t exists.',
                  style: TextStyle(fontSize: 16.0),
                ),
              );
            });
      }
    }
  }

  // delete student from group
  Future deleteStudentFromGroup(
      String studentEmail, String classID, String groupName) async {
    // get the students in the goup
    final getGroup = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .collection('classGroups')
        .doc(groupName)
        .get();
    var students = getGroup.data()!['students'] as Map<String, dynamic>;
    students.remove(studentEmail);
    // delete the student wanted to delete
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .collection('classGroups')
        .doc(groupName)
        .update({'students': students});
    // delete the group info in the student's user table
    final getClassAndGroup = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentEmail)
        .get();
    var classAndGroup =
        getClassAndGroup.data()!['classAndGroup'] as Map<String, dynamic>;
    classAndGroup[classID.toString()] = {};
    await FirebaseFirestore.instance
        .collection('users')
        .doc(studentEmail)
        .update({'classAndGroup': classAndGroup});
  }

  // submit score
  Future submitScore(String submitStudentEmail, String classID,
      String groupName, Map<String, int> scores) async {
    // get the student scores status and set it to true (student submitted the scoring from)
    final studentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(submitStudentEmail)
        .get();
    Map<String, dynamic> studentClassAndGroup =
        studentSnapshot.data()!['classAndGroup'] as Map<String, dynamic>;
    studentClassAndGroup[classID.toString()] = {groupName: true};
    await FirebaseFirestore.instance
        .collection('users')
        .doc(submitStudentEmail)
        .update({
      'classAndGroup': studentClassAndGroup,
    });

    // save the scores student submitted to the group table
    final getStudentsScore = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .collection('classGroups')
        .doc(groupName)
        .get();
    Map<String, List<dynamic>> studentsScore =
        Map<String, List<dynamic>>.from(getStudentsScore.data()!['students']);
    for (int i = 0; i < scores.length; i++) {
      studentsScore[scores.keys.elementAt(i)]!.add(scores.values.elementAt(i));
    }
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .collection('classGroups')
        .doc(groupName)
        .update({'students': studentsScore});
  }

  // import student to class
  Future importStudentsToClass(
    int studentID,
    String classID,
  ) async {
    var query = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: studentID)
        .get();

    String studentEmail = query.docs.first.data()['email'];

    // get the students list from the class
    final checkClass = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .get();
    List students = checkClass.data()!['classStudents'];

    // if the class doesn't have the student with that studentID, save the student to the class table and save the class to the student table
    if (!students.contains(studentEmail)) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentEmail)
          .set({
        'classAndGroup': {classID.toString(): {}}
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classID.toString())
          .update({
        'classStudents': FieldValue.arrayUnion([studentEmail]),
      });
    }
  }

  // query the data and export to excel
  Future getClassExcelFile(String classID, context) async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        });
    final classSnapshot = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID)
        .get();
    Class classData = Class(
        classSnapshot.data()!['subjectName'],
        classSnapshot.data()!['classID'],
        classSnapshot.data()!['classTeacherEmail'],
        List<String>.from(classSnapshot.data()!['classStudents']));

    saveExcel(classData);
    Navigator.pop(context);
  }
}
