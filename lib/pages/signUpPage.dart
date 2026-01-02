import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';
import '../encryption/sodium_singleton.dart';

class signUpPage extends StatefulWidget {
  const signUpPage({super.key, required this.currentColors});

  final Map<String, Color> currentColors;

  @override
  _signUpPageState createState() => _signUpPageState();
}

class _signUpPageState extends State<signUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final storage = const FlutterSecureStorage();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // 1️⃣ Create Firebase Auth user
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? currentUser = cred.user;
      if (currentUser == null) return;

      // 2️⃣ Generate sodium keypair
      final keyPair = sodium.crypto.box.keyPair();

      // extract private key bytes
      final privateKeyBytes = keyPair.secretKey.extractBytes();
      final publicKeyBytes = keyPair.publicKey;

      // 3️⃣ Store private key securely on device
      await storage.write(
        key: "${currentUser.uid}_privateKey",
        value: base64Encode(privateKeyBytes),
      );

      // 4️⃣ Store public key in Firestore
      await FirebaseFirestore.instance.collection("users").doc(currentUser.uid).set({
        "uid": currentUser.uid,
        "email": _emailController.text,
        "publicKey": base64Encode(publicKeyBytes),
      }, SetOptions(merge: true));

      // 5️⃣ Update display name (nickname)
      await currentUser.updateDisplayName(_nicknameController.text);
      await currentUser.reload();

      // 6️⃣ Your existing custom user creation logic
      createAndSaveUser(
          fcmToken: await FirebaseMessaging.instance.getToken() ?? "");

      DocumentReference profRef = FirebaseFirestore.instance
          .collection('profile')
          .doc(currentUser.uid);

      await profRef.set({
        'email': currentUser.email,
        'nickname': _nicknameController.text,
        'userName': _usernameController.text
      }, SetOptions(merge: true));

      // 7️⃣ Navigate to home screen
      if (mounted) {
        Utilityclass().navigator(context, MyHomePage());
      }
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
                style: TextStyle(
                  color: widget.currentColors['text'],
                  fontSize: 20,
                  fontWeight: FontWeight.normal
                  ),
                cursorColor: widget.currentColors['text'],
                controller: _emailController,
                decoration: InputDecoration(
                    icon: Icon(
                      Icons.mail,
                      size: 30,
                    ),
                    hintText: 'Your email address',
                    labelText: 'Email *',
                    hintStyle:
                      TextStyle(color: widget.currentColors['hintText'],
                      fontWeight: FontWeight.w500,
                      fontSize: 17
                      ),
                    labelStyle: 
                      TextStyle(color: widget.currentColors['text'],
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                      ),
                    iconColor: widget.currentColors['text'],
                    
                    focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.currentColors['bar']!,
                      width: 3
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.currentColors['bar']!,
                      width: 3
                      ),
                    ),
                  ),
                validator: (value) {
                  return (value != null && EmailValidator.validate(value))
                      ? null
                      : "Please provide a valid email";
                },
              ),

              SizedBox(height: 10,),

              TextFormField(
                style: TextStyle(
                  color: widget.currentColors['text'],
                  fontSize: 20,
                  fontWeight: FontWeight.normal
                  ),
                cursorColor: widget.currentColors['text'],
                controller: _usernameController,
                decoration: InputDecoration(
                    icon: Icon(
                      Icons.alternate_email,
                      size: 30,
                      ),
                    hintText: 'Please select a unique username.',
                    labelText: 'Username',
                    hintStyle:
                        TextStyle(
                          color: widget.currentColors['hintText'],
                          fontSize: 17,
                          fontWeight: FontWeight.w500
                          ),
                    labelStyle: TextStyle(
                      color: widget.currentColors['text'],
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                      ),
                    iconColor: widget.currentColors['text'],
                    
                    focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.currentColors['bar']!,
                      width: 3
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.currentColors['bar']!,
                      width: 3
                      ),
                    ),

                    ),
                validator: (value) {
                  return (value != null && value.contains('@'))
                      ? 'Do not use the @ char.'
                      : null;
                },
              ),

              SizedBox(height: 10,),

              TextFormField(
                style: TextStyle(
                  color: widget.currentColors['text'],
                  fontSize: 20,
                  fontWeight: FontWeight.normal
                  ),
                cursorColor: widget.currentColors['text'],
                controller: _nicknameController,
                decoration: InputDecoration(
                    icon: Icon(
                      Icons.person,
                      size: 30,
                      ),
                    hintText: 'What should people call you?',
                    labelText: 'Nick Name',
                    hintStyle:
                        TextStyle(
                        color: widget.currentColors['hintText'],
                        fontWeight: FontWeight.w500,
                        fontSize: 17
                        ),
                    labelStyle: TextStyle(
                      color: widget.currentColors['text'],
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                      ),
                    iconColor: widget.currentColors['text'],
                    
                    focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.currentColors['bar']!,
                      width: 3
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.currentColors['bar']!,
                      width: 3
                      ),
                    ),

                    ),
                validator: (value) {
                  return (value != null && value.contains('@'))
                      ? 'Do not use the @ char.'
                      : null;
                },
              ),

              const SizedBox(height: 10),

              TextFormField(
                style: TextStyle(
                  color: widget.currentColors['text'],
                  fontSize: 20,
                  fontWeight: FontWeight.normal
                  ),
                cursorColor: widget.currentColors['text'],
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Password*",
                    icon: Icon(
                      Icons.password,
                      size: 30,
                      ),
                    hintStyle:
                        TextStyle(color: widget.currentColors['hintText'],
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                        ),
                    labelStyle: TextStyle(
                      color: widget.currentColors['text'],
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                      ),
                    iconColor: widget.currentColors['text'],
                    
                    focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.currentColors['bar']!,
                      width: 3
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.currentColors['bar']!,
                      width: 3
                      ),
                    ),
                  ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a password';
                  }
                  if (value.length < 6) {
                    return 'At least 6 characters required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              TextFormField(
                style: TextStyle(
                  color: widget.currentColors['text'],
                  fontSize: 20,
                  fontWeight: FontWeight.normal
                  ),
                cursorColor: widget.currentColors['text'],
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Confirm Password*",
                    icon: Icon(
                      Icons.password_outlined,
                      size: 30,
                      ),
                    hintStyle:
                        TextStyle(
                          color: widget.currentColors['hintText'],
                          fontWeight: FontWeight.w500,
                          fontSize: 20
                          ),
                    labelStyle: TextStyle(
                      color: widget.currentColors['text'],
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                      ),
                    iconColor: widget.currentColors['text'],
                    focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.currentColors['bar']!,
                      width: 3
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.currentColors['bar']!,
                      width: 3
                      ),
                    ),

                    ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  foregroundColor: widget.currentColors['text'],
                      backgroundColor: widget.currentColors['acc1'],
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: widget.currentColors['acc1border']!,
                            width: 3.5
                        )
                    )
                ),
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
