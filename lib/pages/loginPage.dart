import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.currentColors});

  final Map<String, Color> currentColors;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.currentColors['bg'],
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "lib/images/Logo.png",
                width: 200,
              ),
              SizedBox(height: 10),
              Text(
                "ORCA/NET",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: widget.currentColors['text'],
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Log in and find yourself a pod!",
                style: TextStyle(
                  fontSize: 25,
                  color: widget.currentColors['text'],
                ),
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: widget.currentColors['container'],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  cursorColor: widget.currentColors['text']!.withAlpha(200),
                  style: TextStyle(
                    color: widget.currentColors['text'],
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                  controller: emailController,
                  decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                        color: widget.currentColors['text'],
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: widget.currentColors['bar']!.withAlpha(170), width: 3)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: widget.currentColors['bar']!.withAlpha(170), width: 3))),
                ),
              ),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: widget.currentColors['container'],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  cursorColor: widget.currentColors['text']!.withAlpha(1200),
                  style: TextStyle(
                    color: widget.currentColors['text'],
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                     ),
                  controller: passwordController,
                  decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                        color: widget.currentColors['text'],
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: widget.currentColors['bar']!.withAlpha(170), width: 3)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: widget.currentColors['bar']!.withAlpha(170), width: 3))),
                ),
              ),
              SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await logIn(
                        email: emailController.text,
                        password: passwordController.text);
                    String? fcmToken =
                        await FirebaseMessaging.instance.getToken();
                    createAndSaveUser(fcmToken: fcmToken ?? "");
                    if (context.mounted && FirebaseAuth.instance.currentUser != null) {
                      Utilityclass().navigator(context, MyHomePage());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: widget.currentColors['text'],
                      backgroundColor: widget.currentColors['acc2'],
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: widget.currentColors['acc2border']!,
                            width: 3.5
                          )
                        )
                      ),
                  child: Text(
                    "Login",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              SizedBox(height: 5),
              SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await signInWithGoogle();
                    String? fcmToken =
                        await FirebaseMessaging.instance.getToken();
                    createAndSaveUser(fcmToken: fcmToken ?? "");
                    if (context.mounted) {
                      Utilityclass().navigator(context, MyHomePage());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: widget.currentColors['text'],
                      backgroundColor: widget.currentColors['acc2'],
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: widget.currentColors['acc2border']!,
                          width: 3.5
                        ),
                        borderRadius: BorderRadius.circular(15)
                        )
                      ),
                  child: Text(
                    "Google",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: widget.currentColors['text'],
                    ),
                  ),
                  TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => signUpPage(
                              currentColors: widget.currentColors,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color.fromRGBO(66, 162, 61, 1.0),
                        ),
                      )
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
  }
