// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/services/database_service.dart';
import 'package:study_work_grading_web_based/widgets/classes/add_student_to_group_dialog.dart';

class GroupDetailsDialog extends StatelessWidget {
  final String groupName;
  final int classID;
  final bool isCreator;
  const GroupDetailsDialog({
    Key? key,
    required this.groupName,
    required this.classID,
    required this.isCreator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // dialog
    return AlertDialog(
        content: SizedBox(
      height: size.height * 0.5,
      width: size.width * 0.5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('classes')
                .doc(classID.toString())
                .collection('classGroups')
                .doc(groupName)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final map =
                    snapshot.data!.data()!['students'] as Map<String, dynamic>;
                final students = map.keys.toList();
                students.sort();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // group info lines
                    Center(
                      child: Text(
                        'Group ${snapshot.data!.data()!['groupName']}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text('    Class: ${classID.toString()}'),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: size.height * 0.325,
                      width: size.width * 0.48,

                      // students info list
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            List<dynamic> studentScores =
                                map.values.elementAt(index);
                            double avgScore = 0;
                            if (studentScores.isNotEmpty) {
                              for (int i = 0; i < studentScores.length; i++) {
                                avgScore += studentScores[i];
                              }
                              avgScore /= studentScores.length;
                            }
                            return Column(
                              children: [
                                ListTile(
                                  title: FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(students[index])
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text('Student: ...');
                                      } else {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Student: ${snapshot.data!.data()!['name']}',
                                              style: const TextStyle(
                                                  fontSize: 14.0),
                                            ),
                                            Text(
                                              'Student ID: ${snapshot.data!.data()!['id']}',
                                              style: const TextStyle(
                                                  fontSize: 14.0),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),

                                  // if the student have score, appear it
                                  subtitle: studentScores.isNotEmpty
                                      ? Text('Score: $avgScore')
                                      : null,
                                  trailing: isCreator
                                      ? IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                          onPressed: () {
                                            DatabaseService()
                                                .deleteStudentFromGroup(
                                                    students[index],
                                                    classID.toString(),
                                                    groupName);
                                          },
                                        )
                                      : null,
                                ),
                                const Divider(),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    // if the user is the creator, appear the add student to group button
                    Center(
                      child: isCreator
                          ? OutlinedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AddStudentToGroupDialog(
                                    classID: classID,
                                    groupName: groupName,
                                  ),
                                );
                              },
                              child: const Text('Add a student to the group'),
                            )
                          : null,
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    ));
  }
}
