import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/utilityClass.dart';

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // If form is valid, sign up
      print("Passwords match and are valid! // Signed Up Successfully! ");
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
                      ? "Please provide a valid email"
                      : null;
                },
              ),

              TextFormField(
                //--- username ---
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
