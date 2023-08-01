// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/services/database_service.dart';
import '../widgets/classes/add_group_dialog.dart';
import '../widgets/classes/add_student_to_class_dialog.dart';
import '../widgets/classes/class_detail_card.dart';
import '../widgets/classes/group_details_dialog.dart';
import '../widgets/classes/import_dialog.dart';

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

    // scaffold
    return Scaffold(
      // appbar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: SizedBox(
          height: 50,
          width: 400,
          child: GestureDetector(
            onTap: () => Navigator.popUntil(context, ModalRoute.withName('/')),
            child: Image.asset(
              "assets/logo-english-3.png",
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
      body: SizedBox(
        height: size.height * 0.9,
        width: size.width * 1,
        child: SingleChildScrollView(
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
                classStudents.sort();
                return Column(
                  children: [
                    // the upper class details card
                    ClassDetailCard(
                      isCreator: widget.isCreator,
                      subjectName: snapshot.data!['subjectName'],
                      classID: snapshot.data!['classID'],
                      numberOfStudents: classStudents.length,
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    // 2 lower columns
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // students column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.isCreator
                                ? ImportDialog(classID: widget.classID)
                                : Container(),
                            Card(
                              child: SingleChildScrollView(
                                child: SizedBox(
                                  height: size.height * 0.5,
                                  width: size.width * 0.4,
                                  child: classStudents.isEmpty
                                      ? const Center(
                                          child: Text(
                                              'This class has no student yet'),
                                        )
                                      : ListView.builder(
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
                                                return Column(
                                                  children: [
                                                    ListTile(
                                                      leading: const Icon(
                                                        Icons.person,
                                                      ),
                                                      title: Text(snapshot.data!
                                                          .data()!['name']),
                                                      subtitle: Text(snapshot
                                                          .data!
                                                          .data()!['id']
                                                          .toString()),

                                                      // if the user is the creator, the delete icon will comes up
                                                      trailing: widget.isCreator
                                                          ? IconButton(
                                                              onPressed: () {
                                                                DatabaseService()
                                                                    .deleteStudentFromClass(
                                                                  widget
                                                                      .classID,
                                                                  snapshot.data!
                                                                          .data()![
                                                                      'email'],
                                                                );
                                                              },
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            )
                                                          : null,
                                                    ),
                                                    const Divider(),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),

                            // if the current user is the creator, the add student to class will comes up
                            widget.isCreator
                                ? SizedBox(
                                    width: size.width * 0.4,
                                    child: Center(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AddStudentToClassDialog(
                                                classID: widget.classID,
                                              );
                                            },
                                          );
                                        },
                                        child: const Text(
                                            'Add a new student to class'),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),

                        // groups column
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widget.isCreator
                                ? const SizedBox(
                                    height: 30,
                                  )
                                : Container(),
                            Card(
                              child: SingleChildScrollView(
                                child: SizedBox(
                                  height: size.height * 0.5,
                                  width: size.width * 0.4,
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('classes')
                                        .doc(widget.classID.toString())
                                        .collection('classGroups')
                                        .orderBy(FieldPath.documentId)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container();
                                      } else if (snapshot.data!.docs.isEmpty) {
                                        return const Center(
                                          child: Text(
                                              'This class has no group yet'),
                                        );
                                      } else {
                                        final data = snapshot.data!.docs;
                                        return ListView.builder(
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            return Column(
                                              children: [
                                                InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    12,
                                                  ),
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          GroupDetailsDialog(
                                                        isCreator:
                                                            widget.isCreator,
                                                        groupName:
                                                            data[index].data()[
                                                                'groupName'],
                                                        classID: widget.classID,
                                                      ),
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: ListTile(
                                                      leading: const Icon(
                                                          Icons.groups),
                                                      title: Text(
                                                          'Group ${data[index].data()['groupName']}'),

                                                      // if the user is the creator, the delete icon will comes up
                                                      trailing: widget.isCreator
                                                          ? IconButton(
                                                              onPressed: () {
                                                                DatabaseService().deleteGroup(
                                                                    data[index]
                                                                            .data()[
                                                                        'groupName'],
                                                                    widget
                                                                        .classID);
                                                              },
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            )
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                                const Divider(),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),

                            // if the user is the creator, add group button will comes up
                            widget.isCreator
                                ? OutlinedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AddGroupDialog(
                                            classID: widget.classID,
                                          );
                                        },
                                      );
                                    },
                                    child:
                                        const Text('Add a new group to class'),
                                  )
                                : Container(),
                          ],
                        ),
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
