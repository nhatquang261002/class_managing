// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/services/database_service.dart';

class ClassDetailCard extends StatelessWidget {
  final String subjectName;
  final int classID;
  final bool isCreator;
  final int numberOfStudents;
  const ClassDetailCard({
    Key? key,
    required this.subjectName,
    required this.classID,
    required this.isCreator,
    required this.numberOfStudents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.2,
      width: size.width * 0.3,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  subjectName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text('Class ID: $classID'),
              const SizedBox(
                height: 10,
              ),
              Text('Number of students: $numberOfStudents'),
              const SizedBox(
                height: 10,
              ),

              // if the user is the creator, appear the 'delete class' button
              isCreator
                  ? Center(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor),
                        onPressed: () {
                          Navigator.pop(context);
                          DatabaseService().deleteClass(classID);
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Delete class',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
