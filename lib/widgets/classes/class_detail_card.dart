// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ClassDetailCard extends StatelessWidget {
  final String subjectName;
  final int classID;
  final int numberOfStudents;
  const ClassDetailCard({
    Key? key,
    required this.subjectName,
    required this.classID,
    required this.numberOfStudents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.2,
      width: size.width * 0.4,
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
            ],
          ),
        ),
      ),
    );
  }
}
