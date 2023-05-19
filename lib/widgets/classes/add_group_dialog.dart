// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/models/user.dart';
import 'package:study_work_grading_web_based/services/database_service.dart';

class AddGroupDialog extends StatefulWidget {
  final int classID;
  const AddGroupDialog({
    Key? key,
    required this.classID,
  }) : super(key: key);

  @override
  _AddGroupDialogState createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends State<AddGroupDialog> {
  final _groupNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // the dialog
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,

              // group name line
              child: TextFormField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    hintText: 'Group\'s name',
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
                    if (value.toString() != '') {
                      return null;
                    } else {
                      return 'Group\'s name cannot empty';
                    }
                  }),
            ),
            const SizedBox(
              height: 5,
            ),

            // 'add group' button
            OutlinedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() == true) {
                  await DatabaseService().addGroup(
                      widget.classID, _groupNameController.text, context);
                }
              },
              child: const Text('Add Group'),
            ),
          ],
        ),
      ),
    );
  }
}
