import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/models/class.dart';
import 'package:study_work_grading_web_based/services/database_service.dart';

class NewClassDialog extends StatefulWidget {
  const NewClassDialog({Key? key}) : super(key: key);

  @override
  _NewClassDialogState createState() => _NewClassDialogState();
}

class _NewClassDialogState extends State<NewClassDialog> {
  final _subjectNameController = TextEditingController();
  final _classIDController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _subjectNameController.dispose();
    _classIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size.width * 0.25,

              // 'subject's name' line
              child: TextFormField(
                controller: _subjectNameController,
                decoration: InputDecoration(
                  hintText: 'Subject\'s Name',
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
                  if (value.toString() == '') {
                    return 'Class Name must not be empty';
                  } else {
                    return null;
                  }
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),

            // classID line
            SizedBox(
              width: size.width * 0.25,
              child: TextFormField(
                controller: _classIDController,
                decoration: InputDecoration(
                  hintText: 'Class ID',
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
                    return "Class ID must be 6 number character";
                  }
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 'add class' button
                TextButton.icon(
                  onPressed: () {
                    final teacherEmail =
                        FirebaseAuth.instance.currentUser!.email;
                    if (_formKey.currentState!.validate() == true) {
                      Class currentClass = Class(
                          _subjectNameController.text,
                          int.parse(_classIDController.text),
                          teacherEmail!, []);
                      DatabaseService().saveClass(currentClass, context);
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  style: TextButton.styleFrom(backgroundColor: Colors.green),
                  label: const Text(
                    'Create',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
