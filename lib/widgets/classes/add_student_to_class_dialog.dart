// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/services/database_service.dart';

class AddStudentToClassDialog extends StatefulWidget {
  final int classID;
  const AddStudentToClassDialog({
    Key? key,
    required this.classID,
  }) : super(key: key);

  @override
  _AddStudentToClassDialogState createState() =>
      _AddStudentToClassDialogState();
}

class _AddStudentToClassDialogState extends State<AddStudentToClassDialog> {
  final _studentIDController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _studentIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // dialog
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,

              // studentID line
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
                  await DatabaseService().addStudentToClass(
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
