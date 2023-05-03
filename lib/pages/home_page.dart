import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:study_work_grading_web_based/services/database_service.dart';
import 'package:study_work_grading_web_based/widgets/classes/classes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import '../widgets/home_page/personal_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedWidget = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).primaryColor,
            pinned: true,
            floating: true,
            automaticallyImplyLeading: false,
            title: SizedBox(
              height: 50,
              width: 400,
              child: Image.asset(
                'logo-english-3.png',
                fit: BoxFit.fill,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: context.watch<AuthService>().loginState == false
                    ? OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        icon: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ))
                    : Row(children: [
                        FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.email)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text(
                                  'Welcome',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                );
                              }

                              return Text(
                                'Welcome, ${snapshot.data!['name']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              );
                            }),
                        const SizedBox(
                          width: 5,
                        ),
                        OutlinedButton.icon(
                            onPressed: () {
                              context.read<AuthService>().logout();
                            },
                            icon: const Icon(
                              Icons.exit_to_app,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Log Out',
                              style: TextStyle(color: Colors.white),
                            )),
                      ]),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: context.watch<AuthService>().loginState == false
                ? Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: Image.asset(
                          'hust_background.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        size.width < 800
                            ? Container()
                            : SizedBox(
                                height: size.height * 0.8,
                                width: size.width * 0.2,
                                child: Material(
                                  elevation: 10,
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: FutureBuilder(
                                          future: FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.email)
                                              .get(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child: Text(
                                                  'Welcome',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              );
                                            }

                                            return Text(
                                              snapshot.data!['name'],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20.0),
                                            );
                                          },
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            selectedWidget = 0;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.arrow_right,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Personal Information',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Container(
                                          height: 2,
                                          width: size.width * 0.19,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            selectedWidget = 1;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.arrow_right,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Classes',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Container(
                                          height: 2,
                                          width: size.width * 0.19,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          height: size.height * 0.8,
                          width: size.width * 0.7,
                          child: Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(12.0),
                            child: Column(
                              children: [
                                Visibility(
                                  visible: selectedWidget == 0,
                                  child: const PersonalInfo(),
                                ),
                                Visibility(
                                  visible: selectedWidget == 1,
                                  child: FutureBuilder(
                                      future: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.email)
                                          .get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              backgroundColor: Color.fromARGB(
                                                  192, 235, 83, 72),
                                            ),
                                          );
                                        }
                                        return Classes(
                                          isTeacher:
                                              snapshot.data!['isTeacher'],
                                        );
                                      }),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
