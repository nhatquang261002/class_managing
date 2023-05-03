// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/models/group.dart';
import 'package:study_work_grading_web_based/services/database_service.dart';
import 'package:study_work_grading_web_based/widgets/classes/add_student_dialog.dart';
import 'package:study_work_grading_web_based/widgets/classes/class_detail_card.dart';

class ClassDetailPage extends StatefulWidget {
  final bool isCreator;
  final int classID;
  const ClassDetailPage({
    Key? key,
    required this.isCreator,
    required this.classID,
  }) : super(key: key);

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> {
  final _studentController = TextEditingController();
  final _groupController = TextEditingController();

  @override
  void dispose() {
    _studentController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: SizedBox(
          height: 50,
          width: 400,
          child: GestureDetector(
            onTap: () => Navigator.popUntil(context, ModalRoute.withName('/')),
            child: Image.asset(
              'logo-english-3.png',
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SizedBox(
          height: size.height * 0.9,
          width: size.width * 0.9,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('classes')
                .doc(widget.classID.toString())
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(192, 235, 83, 72),
                  ),
                );
              } else {
                List classStudents = snapshot.data!['classStudents'];
                return Column(
                  children: [
                    ClassDetailCard(
                      subjectName: snapshot.data!['subjectName'],
                      classID: snapshot.data!['classID'],
                      numberOfStudents: classStudents.length,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SingleChildScrollView(
                              child: SizedBox(
                                height: size.height * 0.5,
                                width: size.width * 0.4,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: classStudents.length,
                                  itemBuilder: (context, index) {
                                    return FutureBuilder(
                                      future: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(classStudents[index])
                                          .get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Container();
                                        }
                                        return ListTile(
                                          leading: Icon(
                                            Icons.person,
                                            color: Colors.grey[600],
                                          ),
                                          title: Text(
                                              snapshot.data!.data()!['name']),
                                          subtitle: Text(snapshot.data!
                                              .data()!['id']
                                              .toString()),
                                          trailing: widget.isCreator
                                              ? IconButton(
                                                  onPressed: () {
                                                    DatabaseService()
                                                        .deleteStudent(
                                                            widget.classID,
                                                            snapshot.data!
                                                                    .data()![
                                                                'email']);
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ))
                                              : null,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            widget.isCreator
                                ? OutlinedButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AddStudentDialog(
                                              classID: widget.classID,
                                            );
                                          });
                                    },
                                    child: const Text(
                                        'Add a new student to class'),
                                  )
                                : Container(),
                          ],
                        ),
                        Container(),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
