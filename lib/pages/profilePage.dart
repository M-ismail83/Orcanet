import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/pages/loginPage.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';
import 'package:orcanet/widgets/tagContainer.dart';

class profilePage extends StatefulWidget {
  const profilePage(
      {super.key,
      required this.currentColors,
      required this.uid}); //constructor
  final Map<String, Color> currentColors; //field for constructor
  final String uid;

  @override
  State<StatefulWidget> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  Map<String, dynamic>? userData; // 1. Variable starts as null
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData(); // 2. Trigger the fetch immediately
  }

  void _loadData() async {
    var result = await getProfileData(widget.uid);
    // 3. Update the UI when data arrives
    if (mounted) {
      setState(() {
        userData = result;
        isLoading = false;
      });
    }
  }

  final List<String> _allTags = [
    'Flutter',
    'Dart',
    'Widgets',
    'Design',
    'Mobile',
    'Backend',
  ];

  static FirebaseAuth auth = FirebaseAuth.instance;

  late DocumentReference profRec =
      FirebaseFirestore.instance.collection('profile').doc(widget.uid);

  Future<void> editProfile() async {  
    // BONUS TIP: Pre-fill the boxes with existing data!
    // It's annoying for users to type from scratch every time.
    TextEditingController descController = TextEditingController(text: userData!['desc'] ?? "");
    TextEditingController linkGithubController = TextEditingController(text: userData!['links']?['github'] ?? "");
    TextEditingController linkLinkController = TextEditingController(text: userData!['links']?['linkedin'] ?? "");
    
    List<dynamic> tags = List.from(userData!['tags'] ?? []); // Copy existing tags

    bool _isSelected(String tag) {
      return tags.contains(tag);
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder( // Use StatefulBuilder to make the Dialog update (for tags)
            builder: (context, setStateDialog) {
              return AlertDialog(
                backgroundColor: widget.currentColors['bg'],
                title: Text("Customize Your Profile",
                    style: TextStyle(color: widget.currentColors['text'])),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      TextFormField(
                          controller: descController,
                          maxLength: 350,
                          decoration: InputDecoration(
                            label: Text("Description",
                                style: TextStyle(
                                    color: widget.currentColors['text'])),
                            hintText: "Describe yourself...",
                            hintStyle: TextStyle(
                              color: widget.currentColors['hintText'],
                            ),
                          )),
                      TextFormField(
                        controller: linkGithubController,
                        decoration: InputDecoration(
                          label: Text("GitHub Link",
                              style: TextStyle(
                                  color: widget.currentColors['text'])),
                        ),
                      ),
                      TextFormField(
                        controller: linkLinkController,
                        decoration: InputDecoration(
                          label: Text("LinkedIn Link",
                              style: TextStyle(
                                  color: widget.currentColors['text'])),
                        ),
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
                                label: Text(tag),
                                selected: isSelected,
                                selectedColor: widget.currentColors['acc1'],
                                backgroundColor:
                                    widget.currentColors['container'],
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
                                  // Update the DIALOG state, not the page state
                                  setStateDialog(() {
                                    if (selected) {
                                      tags.add(tag);
                                    } else {
                                      tags.remove(tag);
                                    }
                                  });
                                },
                              );
                            }).toList()),
                      )
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('Approve'),
                    onPressed: () async {
                      Map<String, String> links = {
                        "github": linkGithubController.text,
                        'linkedin': linkLinkController.text
                      };

                      await profRec.set({
                        'desc': descController.text,
                        'links': links,
                        'tags': tags
                      }, SetOptions(merge: true));

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                      _loadData(); 
                    },
                  ),
                ],
              );
            }
          );
        });
  }

  Future<Map<String, dynamic>> getProfileData(String docId) async {
    DocumentSnapshot snapshot = await profRec.get();
    return snapshot.data() as Map<String, dynamic>;
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
        backgroundColor: widget.currentColors['bg'],
        body: SafeArea(
          child: ListView(
            //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.currentColors['container'],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: widget.currentColors['container']!, width: 1.0),
                ),
                padding: EdgeInsets.all(15.0),
                margin: EdgeInsets.all(15.0),
                width: double.infinity,

                child: Column(children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: Image.asset(
                          "lib/images/placeholder.jpg",
                          fit: BoxFit.fill,
                        ).image,
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData!['nickname'] ?? "Yes",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: widget.currentColors['text'],
                              ),
                            ),
                            Text(
                              userData!['userName'] ?? "Yes",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                                color:
                                    widget.currentColors['text']!.withAlpha(70),
                              ),
                            ),

                            // Vertical space before the progress bar
                            const SizedBox(height: 10),

                            // Krill/Points Progress Bar
                            LinearProgressIndicator(
                              value: 0.7,
                              minHeight: 8.0,
                              backgroundColor: Colors.grey.shade300,
                              color: Colors.blue.shade700,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (auth.currentUser!.uid == widget.uid)
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: widget.currentColors['text'],
                              ),
                              onPressed: () {
                                editProfile();
                              },
                            ),
                          if (auth.currentUser!.uid != widget.uid)
                            ElevatedButton(
                                onPressed: () {
                                  InviteNotificationService().showPodSelectionDialog(
                                      context, widget.uid);
                                }, child: Text("Invite")),
                          if (auth.currentUser!.uid != widget.uid)
                            IconButton(
                                onPressed: () {
                                  Utilityclass().startChat(
                                      context,
                                      widget.uid,
                                      userData!['nickname'] ?? "NoName",
                                      auth.currentUser!.uid,
                                      widget.currentColors);
                                },
                                icon: const Icon(Icons.message))
                        ],
                      ))
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: widget.currentColors["bar"],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: widget.currentColors['container']!,
                          width: 1.0),
                    ),
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(8.0),
                    width: 300.0,
                    height: 80.0,
                    child: Text(
                      "",
                      style: TextStyle(
                        fontSize: 15,
                        color: widget.currentColors['text'],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        userData!['tags'] != null
                            ? Wrap(
                                spacing: 8.0,
                                children: List<Widget>.from(
                                  userData!['tags'].map<Widget>(
                                    (tag) => tagContainer(tag, widget.currentColors),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  )
                ]),
              ),
              Container(
                decoration: BoxDecoration(
                  color: widget.currentColors['container'],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: widget.currentColors['container']!, width: 1.0),
                ),
                padding: EdgeInsets.all(15.0),
                margin: EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    userData!['desc'] ?? "No description provided.",
                    style: TextStyle(
                      fontSize: 15,
                      color: widget.currentColors['text'],
                    ),
                  ),
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    color: widget.currentColors['container'],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: widget.currentColors['container']!, width: 1.0),
                  ),
                  padding: EdgeInsets.all(15.0),
                  margin: EdgeInsets.all(15.0),
                  width: double.infinity,
                  child: Text(
                    userData!['links'] != null
                        ? "GitHub: ${userData!['links']['github']}\nLinkedIn: ${userData!['links']['linkedin']}"
                        : "No links provided.",
                    style: TextStyle(
                      fontSize: 15,
                      color: widget.currentColors['text'],
                    ),
                  )),
              Container(
                decoration: BoxDecoration(
                  color: widget.currentColors['container'],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: widget.currentColors['container']!, width: 1.0),
                ),
                padding: EdgeInsets.all(15.0),
                margin: EdgeInsets.all(15.0),
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: widget.currentColors["bar"],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: widget.currentColors['container']!,
                            width: 1.0),
                      ),
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.all(8.0),
                      width: 300.0,
                      height: 80.0,
                      child: Text(
                        "asdfghjklşrtyuıowertyuıcv",
                        style: TextStyle(
                          fontSize: 15,
                          color: widget.currentColors['text'],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: widget.currentColors["bar"],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: widget.currentColors['container']!,
                            width: 1.0),
                      ),
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.all(8.0),
                      width: 300.0,
                      height: 80.0,
                      child: Text(
                        "asdfghjklşrtyuıowertyuıcv",
                        style: TextStyle(
                          fontSize: 15,
                          color: widget.currentColors['text'],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: widget.currentColors["bar"],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: widget.currentColors['container']!,
                            width: 1.0),
                      ),
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.all(8.0),
                      width: 300.0,
                      height: 80.0,
                      child: Text(
                        "asdfghjklşrtyuıowertyuıcv",
                        style: TextStyle(
                          fontSize: 15,
                          color: widget.currentColors['text'],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await logOut();
                  await signOutWithGoogle();

                  if (context.mounted) {
                    Utilityclass().navigator(
                        context,
                        LoginScreen(
                          currentColors: widget.currentColors,
                        ));
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
              ),
            ],
          ),
        ));
  }
}
