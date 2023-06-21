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
    } on FirebaseAuthException catch (e) {
      final code = parseFirebaseAuthExceptionMessage(input: e.message);
      if (code == 'user-not-found') {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text(
                  "Email is incorrect or doesn't exist",
                  style: TextStyle(fontSize: 16.0),
                ),
              );
            });
      } else if (code == 'wrong-password') {
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
    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      FirebaseAuth.instance.authStateChanges().listen((event) async {
        _login = true;
        notifyListeners();
        if (event != null) {
          Navigator.popUntil(context, ModalRoute.withName('/'));
        }
      });
    } else if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text(
                      "This email is not verified, please check your email for verification."),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () async {
                            UserCredential user = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email, password: password);

                            user.user!.sendEmailVerification();
                            if (context.mounted) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const AlertDialog(
                                      title: Text(
                                        'Email verification sent.',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    );
                                  });
                            }
                          },
                          child: const Text("Resend email.")),
                      TextButton(
                          onPressed: () async {
                            UserCredential user = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email, password: password);
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(email)
                                .delete();
                            user.user!.delete();
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text("Register again.")),
                    ],
                  )
                ]),
              );
            });
      }
      logout();
    }
  }

  String parseFirebaseAuthExceptionMessage(
      {String plugin = "auth", required String? input}) {
    if (input == null) {
      return "unknown";
    }

    // https://regexr.com/7en3h
    String regexPattern = r'(?<=\(' + plugin + r'/)(.*?)(?=\)\.)';
    RegExp regExp = RegExp(regexPattern);
    Match? match = regExp.firstMatch(input);
    if (match != null) {
      return match.group(0)!;
    }

    return "unknown";
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
          UserCredential user = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);

          user.user!.sendEmailVerification().then((value) {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                        'Email verification sent.\nPlease check your email for signing up completion.'),
                  ],
                ),
              ),
            );
          });

          UserModel newUser = UserModel(
              classAndGroup: {},
              name: name,
              email: email,
              id: int.parse(id),
              isTeacher: isTeacher);
          DatabaseService().saveUser(newUser);
        } on FirebaseAuthException catch (e) {
          var code = parseFirebaseAuthExceptionMessage(input: e.code);
          if (code == 'weak-password') {
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
          } else {
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
