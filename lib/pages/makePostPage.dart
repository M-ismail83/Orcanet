import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class makePostPage extends StatefulWidget {
  const makePostPage(
      {super.key, required this.currentColors, required this.onPost});

  final Map<String, Color> currentColors;
  final VoidCallback onPost;

  @override
  State<StatefulWidget> createState() =>
      _makePostPageState(); //what is this ughhhhhhhhhhh im so tireddd
}

class _makePostPageState extends State<makePostPage> {
  //Widget
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

  String? selectedPodName;
    bool isUploading = false;
    final List<String> pods = ['Orcas', 'Dolphins', 'Whales', 'Students'];

    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

  Future<void> makePost(
      String title, String subtitle, String? senderName, String senderUid, String podName) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    await posts.add({
      'title': title,
      'subTitle': subtitle,
      'tags': _selectedTags.toList(),
      'senderUid': senderUid,
      'senderName': senderName,
      'podName': podName
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: isUploading
              ? null
              : () async {
                  final title = titleController.text.trim();
                  final content = contentController.text.trim();
                  final pod = selectedPodName;

                  if (pod == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please select a Pod first!")));
                    return;
                  }

                  if (title.isEmpty || content.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Title and Content cannot be empty!")));
                    return;
                  }

                  setState(() {
                    isUploading = true;
                  });

                  try {
                    final currentUser = FirebaseAuth.instance.currentUser;

                    if (currentUser != null) {
                      await makePost(title, content, currentUser.displayName, currentUser.uid, pod);

                      if (mounted) {
                        widget.onPost();
                      }
                    }
                  } catch (e) {
                    print('Error: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Upload failed: $e")));
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        isUploading = false;
                      });
                    }
                  }
                },
          backgroundColor: widget.currentColors['container'],
          child: Icon(
            Icons.plus_one,
            color: widget.currentColors['text'],
          ),
        ),
        backgroundColor: widget.currentColors['bg'],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(
                    16.0), // This is the "padding on the outside"
                child: Column(children: [
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent)),
                      padding: const EdgeInsets.all(5.0),
                      width: double.infinity,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButtonFormField<String>(
                              dropdownColor: widget.currentColors['selected'],
                              decoration: InputDecoration(
                                labelText: 'Select Pod',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.group_work),

                              ),
                              initialValue: selectedPodName, // Connects to your variable

                              // The List of Options
                              items: pods.map((String pod) {
                                return DropdownMenuItem(
                                  value: pod,
                                  child: Text(pod, style: TextStyle(color: widget.currentColors['text'])),
                                );
                              }).toList(),

                              // Update State when picked
                              onChanged: (value) {
                                setState(() {
                                  selectedPodName = value!;
                                });
                              },

                              // AUTOMATIC VALIDATION!
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a pod'; // Turns box red
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            Divider(
                              thickness: 1.0,
                              color: Colors.grey,
                            ),
                            Text(
                              'Tags:',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: widget.currentColors['text']),
                            ),
                            SizedBox(height: 4),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Wrap(
                                  spacing: 8.0,
                                  children: _allTags.map((tag) {
                                    final isSelected = _isSelected(tag);

                                    return FilterChip(
                                      showCheckmark: false,
                                      label: Text(tag),
                                      selected: isSelected,
                                      selectedColor:
                                          widget.currentColors['acc1'],
                                      backgroundColor:
                                          widget.currentColors['bg'],
                                      shape: StadiumBorder(
                                        side: BorderSide(
                                          color: widget.currentColors['acc1']!,
                                          width: 1.0,
                                        ),
                                      ),
                                      labelStyle: TextStyle(
                                        color: widget.currentColors['text']!,
                                        fontWeight: FontWeight.w500,
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
                            ),
                          ])),
                  SizedBox(height: 10),
                  Container(
                      padding: const EdgeInsets.all(10.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: widget.currentColors['container'],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: widget.currentColors['container']!,
                            width: 1.0),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Title',
                                labelStyle: TextStyle(
                                    color: widget.currentColors['text'],
                                    fontWeight: FontWeight.bold),
                                hintText: 'What is your post about?',
                                hintStyle: TextStyle(
                                    color: widget.currentColors['hintText'])),
                          ),
                          Divider(),
                          TextField(
                            controller: contentController,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 8,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Content',
                                labelStyle: TextStyle(
                                    color: widget.currentColors['text'],
                                    fontWeight: FontWeight.bold),
                                hintText: 'What is your post about?',
                                hintStyle: TextStyle(
                                    color: widget.currentColors['hintText'])),
                          )
                        ],
                      ))
                ]))

            //container (column)
            //  text field for title (col)
            //  divider (col)
            //  text field for post (col)
            //  divider (col)
            //  (row as a child) SAVE and CANCEL

            // en altta da navigation bar dı sanırsam adı ondan
            //şimdi çok uykum geldi yatcam
          ],
        ));
  }
}
