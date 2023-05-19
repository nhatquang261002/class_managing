import 'package:flutter/material.dart';

import '../../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({Key? key}) : super(key: key);

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
            child: Text(
          'Personal Information',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
        )),
        const SizedBox(
          height: 10.0,
        ),

        // get the personal info
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.email)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(192, 235, 83, 72),
                  ),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Full Name: ${snapshot.data!['name']}'),
                    const SizedBox(
                      height: 5,
                    ),
                    Text('ID: ${snapshot.data!['id']}'),
                    const SizedBox(
                      height: 5,
                    ),
                    Text('Email: ${snapshot.data!['email']}'),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
