// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/pages/class_detail_page.dart';
import 'package:study_work_grading_web_based/widgets/classes/new_class_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Classes extends StatefulWidget {
  final bool isTeacher;
  const Classes({
    Key? key,
    required this.isTeacher,
  }) : super(key: key);

  @override
  State<Classes> createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  final _searchController = TextEditingController();
  bool isCreator = false;

  // check if the user is the creator
  Future checkCreator(int classID) async {
    final doc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classID.toString())
        .get();

    if (doc.data()!['classTeacherEmail'] ==
        FirebaseAuth.instance.currentUser!.email) {
      setState(() {
        isCreator = true;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size.width * 0.4,
                height: 50,

                // the search bar
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(90.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(90.0),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        hintText: 'Class ID'),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),

              // if the user is a teacher, appear the create new class button
              widget.isTeacher && size.width > 800
                  ? SizedBox(
                      width: size.width * 0.15,
                      height: 50,
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const NewClassDialog();
                                });
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Create new class',
                            style: TextStyle(color: Colors.white),
                          )),
                    )
                  : Container(),
            ],
          ),
          const SizedBox(
            height: 10,
          ),

          // the classes table
          SingleChildScrollView(
            child: SizedBox(
              height: size.height * 0.5,
              width: size.width * 0.6,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('classes')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(192, 235, 83, 72),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final data = snapshot.data!.docs[index];
                        if (_searchController.text == '') {
                          return Card(
                            elevation: 1,
                            child: ListTile(
                              onTap: () async {
                                await checkCreator(data['classID']);
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ClassDetailPage(
                                              isCreator: isCreator,
                                              classID: data['classID'],
                                            )),
                                  );
                                }
                              },
                              tileColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              title: Text(
                                  "Class: ${snapshot.data!.docs[index]['subjectName']}"),
                              subtitle: Text(
                                  "Class ID: ${snapshot.data!.docs[index]['classID']}"),
                            ),
                          );
                        } else if (data['classID']
                            .toString()
                            .contains(_searchController.text)) {
                          return Card(
                            elevation: 1,
                            child: ListTile(
                              onTap: () {
                                Navigator.pushNamed(context, '/classDetail');
                              },
                              tileColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              title: Text(
                                  "Class: ${snapshot.data!.docs[index]['subjectName']}"),
                              subtitle: Text(
                                  "Class ID: ${snapshot.data!.docs[index]['classID']}"),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ),
          size.width > 800
              ? Container()
              : ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const NewClassDialog();
                        });
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Create new class',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
        ],
      ),
    );
  }
}
