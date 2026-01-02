import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orcanet/index/serviceIndex.dart';
import 'package:orcanet/services/firebase_options.dart';

class createPodPage extends StatefulWidget {
  const createPodPage({super.key, required this.currentColors});
  final Map<String, Color> currentColors;

  @override
  State<createPodPage> createState() => _createPodPageState();
}

class _createPodPageState extends State<createPodPage> {
  final TextEditingController _podNameController = TextEditingController();
  final TextEditingController _podDescController = TextEditingController();
  final TextEditingController _userController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;

  // List to keep track of added users
  final List<String> _addedUsers = [];
  final List<String> _allTags = [
    'Flutter',
    'Dart',
    'Widgets',
    'Design',
    'Mobile',
    'Backend',
  ];

  Set<String> _selectedTags = {};

  bool _isSelected(String tag) {
    return _selectedTags.contains(tag);
  }

  // loading the state
  bool _isLoading = false;

  @override
  void dispose() {
    _podNameController.dispose();
    _userController.dispose();
    super.dispose();
  }

  // Firebase Logic to handle the create button press
  Future<void> _createChatroom() async {
    if (_podNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Please enter a chatroom name', style: TextStyle(color: widget.currentColors['text']),)),
      );
      return;
    }

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
        "createdAt": FieldValue.serverTimestamp(),
        "createrId": auth.currentUser!.uid,
        "members": _addedUsers,
        "podId": Utilityclass().getChatId(auth.currentUser!.uid, []),
        "podName": _podNameController.text.trim(),
        "podDesc": _podDescController.text.trim(),
        "tags": _selectedTags.toList()
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
            content: Text(
                'Chatroom created successfully!', style: TextStyle(color: widget.currentColors['text']))), ///////// go back to pods page after?
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
        title:  Text("New Pod", style: TextStyle(color: widget.currentColors['text'])),
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
                     Text("Pod Details:",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: widget.currentColors['text'])),
                    const SizedBox(height: 10),
                    TextField(

                      cursorColor: widget.currentColors['text'],
                      cursorWidth: 1.7,
                      style: TextStyle(
                        color: widget.currentColors['text'], fontSize: 18, fontWeight: FontWeight.w500
                        ),
                      controller: _podNameController,
                      decoration:  InputDecoration(
                        labelText: "Pod Name",
                        hintText: "A Pod is a group for your project teammates",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: widget.currentColors['text']!, width: 2),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: widget.currentColors['text']!, width: 2),
                        ),
                        prefixIcon: Icon(Icons.group_add, color: widget.currentColors['text'], fontWeight: FontWeight.bold),
                        labelStyle: TextStyle(color: widget.currentColors['text'], fontSize: 19, fontWeight: FontWeight.bold),
                        hintStyle: TextStyle(color: widget.currentColors['hintText'], fontWeight: FontWeight.w500, fontSize: 19),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    TextField(
                      cursorColor: widget.currentColors['text'],
                      cursorWidth: 1.7,
                      style: TextStyle(
                        color: widget.currentColors['text'], fontSize: 18, fontWeight: FontWeight.w500
                      ),
                      controller: _podDescController,
                      decoration:  InputDecoration(
                        labelText: "Pod Description",
                        hintText: "Describe your pod.",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: widget.currentColors['text']!, width: 2),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: widget.currentColors['text']!, width: 2),
                        ),
                        prefixIcon: Icon(Icons.anchor_sharp, color: widget.currentColors['text'], fontWeight: FontWeight.bold),
                        labelStyle: TextStyle(color: widget.currentColors['text'], fontSize: 19, fontWeight: FontWeight.bold),
                        hintStyle: TextStyle(color: widget.currentColors['hintText'], fontWeight: FontWeight.w500, fontSize: 19),
                      ),
                    ),
                    const SizedBox(height: 24),
                    //user field
                     Text(
                      "Add Tags:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.currentColors['text']),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Wrap(
                                  spacing: 8.0,
                                  children: _allTags.map((tag) {
                                    final isSelected = _isSelected(tag);

                                    return FilterChip(
                                      showCheckmark: false,
                                      label: Text(tag, style: TextStyle(color: widget.currentColors['text'])),
                                      selected: isSelected,
                                      selectedColor:
                                          widget.currentColors['acc1'],
                                      backgroundColor:
                                          widget.currentColors['bg'],
                                      shape: StadiumBorder(
                                        side: BorderSide(
                                          color: widget.currentColors['acc1border']!,
                                          width: 3.0,
                                        ),
                                      ),
                                      labelStyle: TextStyle(
                                        color: widget.currentColors['text']!,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      onSelected: (bool selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedTags.add(tag);
                                          } else {
                                            _selectedTags.remove(tag);
                                          }
                                        });
                                      },
                                    );
                                  }).toList()),
                            )
                    
          ]),
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
                    backgroundColor: widget.currentColors['acc1'],
                    foregroundColor: widget.currentColors['text'],
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: widget.currentColors['acc1border']!,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "CREATE YOUR POD!",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
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