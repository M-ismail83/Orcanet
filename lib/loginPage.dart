import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(60, 49, 43, 1.0),
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color.fromRGBO(240, 232, 230, 1.0),),
              ),
              SizedBox(height: 5),
              Text(
                "Log inn and find yourself a pod!!",
                style: TextStyle(fontSize: 18, color: Color.fromRGBO(240, 232, 230, 1.0),),
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(92, 81, 68, 1.0),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Color.fromRGBO(240, 232, 230, 1.0),),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color.fromRGBO(145, 118, 104, 1.0), width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color.fromRGBO(145, 118, 104, 1.0), width: 1))),
                ),
              ),

              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(92, 81, 68, 1.0),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Color.fromRGBO(240, 232, 230, 1.0),),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color.fromRGBO(145, 118, 104, 1.0), width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color.fromRGBO(145, 118, 104, 1.0), width: 1))),
                ),
              ),

              SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromRGBO(17, 123, 77, 1.0),
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: Text(
                    "Login",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              SizedBox(height: 5),
              Divider(color: Color.fromRGBO(145, 118, 104, 1.0), ),
              SizedBox(height: 5),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromRGBO(17, 123, 77, 1.0),
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: Text(
                    "Google",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color.fromRGBO(240, 232, 230, 1.0),),
                  ),
                  Text(
                    " Sign Up",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color.fromRGBO(17, 123, 77, 1.0)),
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