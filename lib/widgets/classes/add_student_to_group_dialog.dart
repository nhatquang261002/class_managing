// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/models/user.dart';
import 'package:study_work_grading_web_based/services/database_service.dart';

class AddStudentToGroupDialog extends StatefulWidget {
  final int classID;
  final String groupName;
  const AddStudentToGroupDialog({
    Key? key,
    required this.classID,
    required this.groupName,
  }) : super(key: key);

  @override
  _AddStudentToGroupDialogState createState() =>
      _AddStudentToGroupDialogState();
}

class _AddStudentToGroupDialogState extends State<AddStudentToGroupDialog> {
  final _studentIDController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _studentIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //dialog
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(

                  // studentID line
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
                    if (RegExp(r'(\d{8})').hasMatch(value!)) {
                      return null;
                    } else {
                      return "ID is incorrect";
                    }
                  }),
            ),
            const SizedBox(
              height: 5,
            ),

            // 'add student' button
            OutlinedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() == true) {
                  await DatabaseService().addStudentToGroup(
                      _studentIDController.text,
                      widget.groupName,
                      widget.classID,
                      context);
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
