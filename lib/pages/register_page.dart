import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_work_grading_web_based/models/user.dart';
import 'package:study_work_grading_web_based/services/database_service.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _idController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isTeacher = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            height: 525,
            width: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      'Enter your information here',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Full Name',
                        ),
                        validator: (value) {
                          if (value == '') {
                            return "Please enter your Name";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          hintText: 'ID',
                        ),
                        validator: (value) {
                          if (RegExp(r'(\d{8})').hasMatch(value!)) {
                            return null;
                          } else {
                            return "ID is incorrect";
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                        ),
                        validator: (value) {
                          if (value == '') {
                            return 'Email can\'t be empty';
                          } else if (RegExp(
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                              .hasMatch(value!)) {
                            return null;
                          } else {
                            return 'Email is not correct';
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        obscureText: true,
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                        ),
                        validator: (value) {
                          if (value!.length < 6) {
                            return "Password must be at least 6 characters";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        obscureText: true,
                        controller: _passwordConfirmController,
                        decoration: const InputDecoration(
                          hintText: 'Confirm Password',
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return "Confirm Password doesn't match";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 200,
                      child: CheckboxListTile(
                          title: const Text('I am a teacher'),
                          checkboxShape: const CircleBorder(),
                          value: isTeacher,
                          onChanged: (value) {
                            setState(() {
                              isTeacher = value!;
                            });
                          }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Already have account? Login here!',
                              style: TextStyle(
                                color: Color.fromARGB(192, 235, 83, 72),
                              ),
                            )),
                        OutlinedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() == true) {
                              context.read<AuthService>().register(
                                    _emailController.text,
                                    _passwordController.text,
                                    context,
                                    _idController.text,
                                    _nameController.text,
                                    isTeacher,
                                  );
                            }
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: Color.fromARGB(192, 235, 83, 72),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
