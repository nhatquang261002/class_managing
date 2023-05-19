// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_work_grading_web_based/services/database_service.dart';

class ScoringForm extends StatefulWidget {
  final String classID;
  final String groupName;
  const ScoringForm({
    Key? key,
    required this.classID,
    required this.groupName,
  }) : super(key: key);

  @override
  State<ScoringForm> createState() => _ScoringFormState();
}

class _ScoringFormState extends State<ScoringForm> {
  late List<String> studentsName = [];
  List<String> studentsEmail = [];
  List<int> _score = [];

  // getStudents from the group function
  void getStudents() async {
    final doc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classID)
        .collection('classGroups')
        .doc(widget.groupName)
        .get();
    final listEmail = doc.data()!['students'] as Map<String, dynamic>;

    for (int i = 0; i < listEmail.length; i++) {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(listEmail.keys.elementAt(i))
          .get();
      var name = snap.data()!['name'];

      setState(() {
        studentsName.add(name);
        studentsEmail.add(listEmail.keys.elementAt(i));
        _score = List.filled(studentsName.length, 3);
      });
    }

    setState(() {
      studentsName.sort();
    });
  }

  @override
  void initState() {
    super.initState();
    getStudents();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: size.height * 0.275,
        width: size.width * 0.6,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  child: Text(
                      'Class ${widget.classID} - Group ${widget.groupName}'),
                ),

                studentsName.isEmpty

                    // if the user is the only one in the group, appear the text
                    ? const Center(
                        child: Text(
                            'You are the only student in this  group for now, please wait until the teacher add more students to the group'),
                      )

                    // else appear the scoring form
                    : SingleChildScrollView(
                        child: SizedBox(
                          height: size.height * 0.15,
                          width: size.width * 0.6,
                          child: ListView.builder(
                            itemCount: studentsName.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                height: 25,
                                width: size.width * 0.6,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // group's member's name
                                    SizedBox(
                                      width: size.width * 0.15,
                                      child: Center(
                                        child: Text(studentsName[index]),
                                      ),
                                    ),

                                    // the scoring radio
                                    SizedBox(
                                      width: size.width * 0.4,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Flexible(
                                            fit: FlexFit.tight,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('1'),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Radio<int>(
                                                  value: 1,
                                                  groupValue: _score[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _score[index] = value!;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Flexible(
                                            fit: FlexFit.tight,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('2'),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Radio<int>(
                                                  value: 2,
                                                  groupValue: _score[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _score[index] = value!;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Flexible(
                                            fit: FlexFit.tight,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('3'),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Radio<int>(
                                                  value: 3,
                                                  groupValue: _score[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _score[index] = value!;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Flexible(
                                            fit: FlexFit.tight,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('4'),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Radio<int>(
                                                  value: 4,
                                                  groupValue: _score[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _score[index] = value!;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Flexible(
                                            fit: FlexFit.tight,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('5'),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Radio<int>(
                                                  value: 5,
                                                  groupValue: _score[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _score[index] = value!;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                // submit button
                OutlinedButton(
                  onPressed: () {
                    Map<String, int> scores = {};
                    for (int i = 0; i < studentsName.length; i++) {
                      scores[studentsEmail[i]] = _score[i];
                    }
                    DatabaseService().submitScore(
                        FirebaseAuth.instance.currentUser!.email!,
                        widget.classID,
                        widget.groupName,
                        scores);
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
