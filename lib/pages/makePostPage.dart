import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/test/testing.dart';

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
  final FirebaseFirestore store = FirebaseFirestore.instance;
  //Widget

  Set<String> _selectedTags = {};

  bool _isSelected(String tag) {
    return _selectedTags.contains(tag);
  }

  String? selectedPodName;
  bool isUploading = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  Future<void> makePost(String title, String subtitle, String? senderName,
      String senderUid, String podName) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    await posts.add({
      'title': title,
      'subTitle': subtitle,
      'tags': _selectedTags.toList(),
      'senderUid': senderUid,
      'senderName': senderName,
      'podName': podName,
      'craetedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<String>> get podsStream {
    return store.collection('pods').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['podName'] as String).toList();
    });
  }

  Stream<List<String>> get allTagsStream {
    if (selectedPodName == null) {
      return Stream.value([]); // Return empty list if no pod selected
    }

    return store
        .collection('pods')
        .where('podName', isEqualTo: selectedPodName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .expand((doc) => List<String>.from(doc['tags'] as List<dynamic>))
          .toSet()
          .toList();
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
                      await makePost(title, content, currentUser.displayName,
                          currentUser.uid, pod);

                      if (mounted) {
                        widget.onPost();
                      }
                    }
                  } catch (e) {
                    print('Error: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Upload failed: $e")));
                    }
                  } finally {
                    if (context.mounted) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StreamBuilder<List<String>>(
                              stream:
                                  podsStream, // Use the stream we defined above
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                }

                                final podList = snapshot.data!;

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: widget.currentColors['container'],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color:
                                            widget.currentColors['container']!,
                                        width: 1.0),
                                  ),
                                  child: DropdownButton<String>(
                                  alignment: AlignmentGeometry.center,
                                  menuWidth: MediaQuery.sizeOf(context).width * 0.75,
                                  underline: SizedBox(),
                                  borderRadius: BorderRadius.circular(10),
                                  dropdownColor: widget.currentColors['container'],
                                  value: selectedPodName,
                                  hint: Text("Select a Pod", style: TextStyle(color: widget.currentColors['hintText'])),
                                  items: podList.map((pod) {
                                    return DropdownMenuItem(
                                      alignment: AlignmentGeometry.center,
                                        value: pod, child: Text(pod, style: TextStyle(color: widget.currentColors['text'])));
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedPodName = val;
                                      // Clear tags when pod changes if you want
                                      _selectedTags.clear();
                                    });
                                  },
                                ),
                                );
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
                            if (selectedPodName != null)
                              StreamBuilder<List<String>>(
                                stream: allTagsStream, // Use the tag stream
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container(); // Loading or empty
                                  }

                                  final tagList = snapshot.data!;

                                  return Wrap(
                                    spacing: 8.0,
                                    children: tagList.map((tag) {
                                      return FilterChip(
                                        label: Text(tag),
                                        selectedColor:
                                            widget.currentColors['acc1'],
                                        backgroundColor:
                                            widget.currentColors['container'],
                                        shape: StadiumBorder(
                                          side: BorderSide(
                                            color:
                                                widget.currentColors['acc1']!,
                                            width: 1.0,
                                          ),
                                        ),
                                        labelStyle: TextStyle(
                                          color: widget.currentColors['text']!,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        selected: _isSelected(tag),
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
                                    }).toList(),
                                  );
                                },
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
                          ),
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
