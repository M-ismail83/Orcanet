import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/pageIndex.dart';
import 'package:orcanet/serviceIndex.dart';

class signUpPage extends StatefulWidget {
  const signUpPage({super.key, required this.currentColors});

  final Map<String, Color> currentColors;

  @override
  _signUpPageState createState() => _signUpPageState();
}

class _signUpPageState extends State<signUpPage> {
  // 1. identify the Form
  final _formKey = GlobalKey<FormState>();

  // 2. controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    //free up memory
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      User? currentUser = await createUserWithEmailAndPassword(_emailController.text, _passwordController.text);
      await currentUser!.updateDisplayName(_nicknameController.text);
      await currentUser.reload();
      createAndSaveUser(fcmToken: await FirebaseMessaging.instance.getToken() ?? "");

      DocumentReference profRef = FirebaseFirestore.instance
        .collection('profile')
        .doc(currentUser.uid);

      await profRef.set({
        'email': currentUser.email,
        'nickname': _nicknameController.text,
        'userName': _usernameController.text
      }, SetOptions(merge: true));

      if (mounted) Utilityclass().navigator(context, MyHomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Let's Sign You Up! ")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                // --- email---
                controller: _emailController,
                decoration: InputDecoration(
                    icon: Icon(Icons.mail),
                    hintText: 'Your email address',
                    labelText: 'Email *',
                    hintStyle:
                        TextStyle(color: widget.currentColors['hintText']),
                    labelStyle: TextStyle(color: widget.currentColors['text']),
                    iconColor: widget.currentColors['text']),
                onSaved: (String? value) {
                  // This optional block of code can be used to run
                  // code when the user saves the form.
                },
                validator: (String? value) {
                  return (value != null && EmailValidator.validate(value))
                      ? null
                      : "Please provide a valid email";
                },
              ),

              TextFormField(
                //--- username ---
                controller: _usernameController,
                decoration: InputDecoration(
                    icon: Icon(Icons.alternate_email),
                    hintText: 'Please select a unique username.',
                    labelText: 'Username *',
                    hintStyle:
                        TextStyle(color: widget.currentColors['hintText']),
                    labelStyle: TextStyle(color: widget.currentColors['text']),
                    iconColor: widget.currentColors['text']),
                onSaved: (String? value) {
                  // This optional block of code can be used to run
                  // code when the user saves the form.
                },
                validator: (String? value) {
                  return (value != null && value.contains('@'))
                      ? 'Do not use the @ char.'
                      : null;
                },
              ),

              TextFormField(
                // --- nickname ----
                controller: _nicknameController,
                decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'What should people call you?',
                    labelText: 'Nick Name *',
                    hintStyle:
                        TextStyle(color: widget.currentColors['hintText']),
                    labelStyle: TextStyle(color: widget.currentColors['text']),
                    iconColor: widget.currentColors['text']),
                onSaved: (String? value) {
                  // This optional block of code can be used to run
                  // code when the user saves the form.
                },
                validator: (String? value) {
                  return (value != null && value.contains('@'))
                      ? 'Do not use the @ char.'
                      : null;
                },
              ),

              SizedBox(height: 20),

              // --- Password Field ---
              TextFormField(
                controller: _passwordController, // Assign the controller
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Password",
                    icon: Icon(Icons.password),
                    hintStyle:
                        TextStyle(color: widget.currentColors['hintText']),
                    labelStyle: TextStyle(color: widget.currentColors['text']),
                    iconColor: widget.currentColors['text']),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // --- Confirm Password Field ---
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Confirm Password",
                    icon: Icon(Icons.password_outlined),
                    hintStyle:
                        TextStyle(color: widget.currentColors['hintText']),
                    labelStyle: TextStyle(color: widget.currentColors['text']),
                    iconColor: widget.currentColors['text']),
                // The Magic happens here in the validator
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  // compare user input (value) vs the first controller
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              SizedBox(height: 40),

              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
