import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/services/database_service.dart';

import '../models/user.dart';

class AuthService extends ChangeNotifier {
  bool _login = false;
  bool get loginState => _login;

  // login
  Future login(String email, String password, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        });
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      _login = true;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text(
                  'Email is incorrect or doesn\'t exist',
                  style: TextStyle(fontSize: 16.0),
                ),
              );
            });
      } else if (e.code == 'wrong-password') {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text(
                  'Password incorrect',
                  style: TextStyle(fontSize: 16.0),
                ),
              );
            });
      }
    }
    FirebaseAuth.instance.authStateChanges().listen((event) async {
      if (event != null) {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      }
    });
  }

  // register
  Future register(String email, String password, BuildContext context,
      String id, String name, bool isTeacher) async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        });
    final check =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    if (!check.exists) {
      if (context.mounted) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          Navigator.pop(context);
          login(email, password, context);
          UserModel newUser = UserModel(
              classAndGroup: {},
              name: name,
              email: email,
              id: int.parse(id),
              isTeacher: isTeacher);
          DatabaseService().saveUser(newUser);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            if (context.mounted) {
              Navigator.pop(context);
              showDialog(
                  context: context,
                  builder: (context) {
                    return const AlertDialog(
                      title: Text(
                        'The password provided is too weak.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    );
                  });
            }
          } else if (e.code == 'email-already-in-use') {
            if (context.mounted) {
              Navigator.pop(context);
              showDialog(
                  context: context,
                  builder: (context) {
                    return const AlertDialog(
                      title: Text(
                        'The account already exists for that email.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    );
                  });
            }
          } else {
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (context) {
                  return const AlertDialog(
                    title: Text(
                      'Unexpected Error.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  );
                });
          }
        }
      }
    } else {
      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text(
                  'The account with that ID is already exists.',
                  style: TextStyle(fontSize: 16.0),
                ),
              );
            });
      }
    }
  }

  // logout
  Future logout() async {
    await FirebaseAuth.instance.signOut();
    _login = false;
    notifyListeners();
  }
}
