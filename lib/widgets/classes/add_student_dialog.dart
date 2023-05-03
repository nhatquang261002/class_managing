// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/models/user.dart';
import 'package:study_work_grading_web_based/services/database_service.dart';

class AddStudentDialog extends StatefulWidget {
  final int classID;
  const AddStudentDialog({
    Key? key,
    required this.classID,
  }) : super(key: key);

  @override
  _AddStudentDialogState createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _studentIDController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _studentIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                  controller: _studentIDController,
                  decoration: InputDecoration(
                    hintText: 'Student\'s ID',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(90.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        90.0,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (RegExp(r'(\d{6})').hasMatch(value!)) {
                      return null;
                    } else {
                      return 'Incorrect Student ID';
                    }
                  }),
            ),
            const SizedBox(
              height: 5,
            ),
            OutlinedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() == true) {
                  await DatabaseService().addStudent(
                      _studentIDController.text, widget.classID, context);
                }
              },
              child: const Text('Add Student'),
            ),
          ],
        ),
      ),
    );
  }
}
