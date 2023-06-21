import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_work_grading_web_based/widgets/scoring/scoring_form.dart';

class ScoringHome extends StatelessWidget {
  const ScoringHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> classAndGroup;
    Map<String, Map<String, bool>> classAndGroupNotScored = {};
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // scoring form line
          const Center(
            child: Text(
              'Scoring Form',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
            ),
          ),

          // get the groups where the user haven't scored yet
          SingleChildScrollView(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  classAndGroup = snapshot.data!.data()!['classAndGroup']
                      as Map<String, dynamic>;

                  classAndGroup.forEach((key, value) {
                    if (value.toString().contains('false')) {
                      classAndGroupNotScored[key] =
                          Map<String, bool>.from(value);
                    }
                    if (value.toString().contains('true')) {
                      if (classAndGroupNotScored.containsKey(key)) {
                        classAndGroupNotScored.remove(key);
                      }
                    }
                  });
                }
                return SizedBox(
                  height: size.height * 0.7,
                  width: size.width * 0.6,
                  child: ListView.builder(
                    itemCount: classAndGroupNotScored.length,
                    itemBuilder: (context, index) {
                      return ScoringForm(
                        classID: classAndGroupNotScored.keys.elementAt(index),
                        groupName: classAndGroupNotScored.values
                            .elementAt(index)
                            .keys
                            .elementAt(0),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
