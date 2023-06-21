import 'package:flutter/material.dart';
import 'package:study_work_grading_web_based/services/auth_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              "assets/logo-english-3.png",
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),

      // the Form at the center
      body: Center(
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            height: 325,
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
                    SizedBox(
                      height: 50,
                      width: 37,
                      child: Image.asset(
                        "assets/694px-Logo_Hust.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      'Enter your information here',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    // email line
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
                            return 'Email is incorrect';
                          }
                        },
                      ),
                    ),

                    // password line
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
                    const SizedBox(
                      height: 20,
                    ),

                    // register line button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              'Dont have account? Register now!',
                              style: TextStyle(
                                color: Color.fromARGB(192, 235, 83, 72),
                              ),
                            )),

                        // login button
                        OutlinedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() == true) {
                              context.read<AuthService>().login(
                                  _emailController.text,
                                  _passwordController.text,
                                  context);
                            }
                          },
                          child: const Text(
                            'Login',
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
