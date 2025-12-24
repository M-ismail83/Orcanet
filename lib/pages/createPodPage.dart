import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orcanet/index/serviceIndex.dart';

class createPodPage extends StatefulWidget {
  const createPodPage({super.key});

  @override
  State<createPodPage> createState() => _createPodPageState();
}

class _createPodPageState extends State<createPodPage> {
  final TextEditingController _podNameController = TextEditingController();
  final TextEditingController _userController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;

  // List to keep track of added users
  final List<String> _addedUsers = [];

  // loading the state
  bool _isLoading = false;

  @override
  void dispose() {
    _podNameController.dispose();
    _userController.dispose();
    super.dispose();
  }

  // Logic to add a user to the list
  void _addUser() {
    final String user = _userController.text.trim();
    if (user.isNotEmpty && !_addedUsers.contains(user)) {
      setState(() {
        _addedUsers.add(user);
        _userController.clear(); // Clear input after adding
      });
    } else if (_addedUsers.contains(user)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User already added!')),
      );
    }
  }

  // Logic to remove a user from the list
  void _removeUser(String user) {
    setState(() {
      _addedUsers.remove(user);
    });
  }

  // Firebase Logic to handle the create button press
  Future<void> _createChatroom() async {
    if (_podNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a chatroom name')),
      );
      return;
    }

    // TODO: Add your backend logic here (e.g., Firebase, API call)

    setState(() {
      _isLoading = true;
    });

    try {
      _addedUsers.add(auth.currentUser!.uid);
      // 2. Add document to 'chatrooms' collection
      await FirebaseFirestore.instance.collection('chats').add({
        'chatId': Utilityclass().getChatId(auth.currentUser!.uid, []),
        'chatName': _podNameController.text.trim(),
        'participants': _addedUsers,
        'lastMessage': '',
        'lastMessageId': 0,
        'type': "Pods",
        'created_by': auth.currentUser!.uid,
      });

      await FirebaseFirestore.instance.collection('pods').add({
        'podId': Utilityclass().getChatId(auth.currentUser!.uid, []),
        'chatName': _podNameController.text.trim(),
        'lastMessage': '', ///////////////////////////////////////////////////
        'lastMessageId': 0,
        'type': "Pods",
        'created_by': auth.currentUser!.uid,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Chatroom created successfully!')), ///////// go back to pods page after?
      );

      // Optional: Navigate back or clear form
      setState(() {
        _podNameController.clear();
        _addedUsers.clear();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating room: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }

    print("Creating Room: ${_podNameController.text}");
    print("With Users: $_addedUsers");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chatroom Created!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Pod"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // pod name field
                    const Text("Pod Details",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _podNameController,
                      decoration: const InputDecoration(
                        labelText: "Pod Name",
                        hintText: "A Pod is a group for your project teammates",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                    ),
                    const SizedBox(height: 24),
                    //user field
                    const Text(
                      "Add Members",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _userController,
                            decoration: const InputDecoration(
                              labelText: "Username or Email",
                              hintText: "Enter user identifier",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_add),
                            ),
                            //
                            onSubmitted: (_) => _addUser(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filled(
                          onPressed: _addUser,
                          icon: const Icon(Icons.add),
                          iconSize: 28,
                          style: IconButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size(56, 56)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // users list
                    if (_addedUsers.isNotEmpty) ...[
                      const Text("Participants:",
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _addedUsers.map((user) {
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundColor: Colors.deepPurple.shade100,
                              radius: 12,
                              child: Text(user[0].toUpperCase()),
                            ),
                            label: Text(user),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => _removeUser(user),
                          );
                        }).toList(),
                      ),
                    ] else
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Center(
                            child: Text("No users added yet",
                                style: TextStyle(color: Colors.grey))),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _createChatroom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "CREATE",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}