// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_work_grading_web_based/services/auth_service.dart';
import 'package:study_work_grading_web_based/widgets/classes/classes.dart';
import 'package:study_work_grading_web_based/widgets/scoring/scoring_home.dart';
import '../models/user.dart';
import '../widgets/personal_info/personal_info.dart';

class HomePage extends StatefulWidget {
  int selectedWidget;
  HomePage({
    Key? key,
    required this.selectedWidget,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Theme.of(context).primaryColor,
            pinned: true,
            floating: true,
            automaticallyImplyLeading: false,
            title: SizedBox(
              height: 50,
              width: 400,
              child: Image.asset(
                "assets/logo-english-3.png",
                fit: BoxFit.fill,
              ),
            ),
            actions: [
              // if loginState = true => LoginButton, else is Welcome 'User' + LogOutButton
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: context.watch<AuthService>().loginState == false

                    // Login State == true
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

                    // LoginState == false
                    : Row(children: [
                        // Fetch user name for the Welcome 'User'
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

                        // logOut Button
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

          // body of the mainPage
          // if loginState is false => HUST image, else => homePage
          SliverToBoxAdapter(
            child: context.watch<AuthService>().loginState == false

                // image from assets
                ? SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Image.asset(
                      "assets/hust_background.jpg",
                      fit: BoxFit.cover,
                    ),
                  )

                // homePage body
                : Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // The left red menu
                        // if the  screen width < 800 then it'll dissapear
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
                                      // The user name line
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

                                      // personal info button
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            widget.selectedWidget = 0;
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

                                      // classes button
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            widget.selectedWidget = 1;
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

                                      // scoring button
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            widget.selectedWidget = 2;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.arrow_right,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Scoring',
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

                        // the white right part
                        SizedBox(
                          height: size.height * 0.8,
                          width: size.width * 0.7,
                          child: Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(12.0),
                            child: Column(
                              children: [
                                // if personalInfo button is pressed, change the widget to PersonalInfo
                                Visibility(
                                  visible: widget.selectedWidget == 0,
                                  child: const PersonalInfo(),
                                ),

                                // if classes button is pressed, change the widget to Classes
                                Visibility(
                                  visible: widget.selectedWidget == 1,
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
                                ),

                                // if the scoring button is pressed, change the widget to scoring home
                                Visibility(
                                    visible: widget.selectedWidget == 2,
                                    child: const ScoringHome()),
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
