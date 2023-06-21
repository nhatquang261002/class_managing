// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/services/database_service.dart';

class ImportDialog extends StatelessWidget {
  final int classID;
  const ImportDialog({
    Key? key,
    required this.classID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      "Pick a xls, xlsx file with a list of student-ID on column 1"),
                  const SizedBox(height: 20),
                  OutlinedButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            });
                        FilePickerResult? pickedFile =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['xlsx', 'xls'],
                          allowMultiple: false,
                        );

                        if (pickedFile != null) {
                          var bytes = pickedFile.files.single.bytes;
                          var excel = Excel.decodeBytes(bytes!);
                          for (var table in excel.tables.keys) {
                            for (var row in excel.tables[table]!.rows) {
                              if (context.mounted) {
                                DatabaseService().importStudentsToClass(
                                  row.first!.value,
                                  classID.toString(),
                                );
                              }
                            }
                          }
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Pick a file"))
                ],
              ),
            );
          },
        );
      },
      child: const Text(
        'Import list of students',
        style: TextStyle(fontSize: 10),
      ),
    );
  }
}
