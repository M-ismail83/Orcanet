import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orcanet/pages/loginPage.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';
import 'package:sodium_libs/sodium_libs.dart';
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

  final List<String> _badges = [
    'lib/images/badge1.png',
    'lib/images/badge2.png',
  ];

  final List<String> _avatars = [
    'lib/images/avatar1.png',
    'lib/images/avatar2.png',
    'lib/images/avatar3.png',
    'lib/images/avatar4.png',
  ];

  int _selectedAvatarIndex = 0;

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
        _selectedAvatarIndex =
          ((result['avatarIndex'] ?? 0) as num).toInt();
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

    int selectedAvatarIndex = (userData!['avatarIndex'] ?? _selectedAvatarIndex) as int;

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
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                actionsPadding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
                actionsAlignment: MainAxisAlignment.end,
                backgroundColor: widget.currentColors['bg'],
                title: Text("Customize Your Profile",
                    style: TextStyle(color: widget.currentColors['text'],
                    fontWeight: FontWeight.bold
                    )
                  ),
                content: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.60, 
                    maxWidth: 450,
                  ),
                    child: SingleChildScrollView(
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        style: TextStyle(
                          color: widget.currentColors['text']
                        ),
                          controller: descController,
                          maxLength: 350,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: widget.currentColors['bar']!,
                                width: 2
                              )
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: widget.currentColors['bar']!,
                                width: 2
                              )
                            ),
                            label: Text("Description",
                                style: TextStyle(
                                    color: widget.currentColors['text'],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18
                                    )
                                  ),
                            hintText: "Describe yourself...",
                            hintStyle: TextStyle(
                              color: widget.currentColors['hintText'],
                            ),
                          )),
                        
                      TextFormField(
                        style: TextStyle(
                          color: widget.currentColors['text']
                        ),
                        controller: linkGithubController,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.currentColors['bar']!,
                              width: 2
                            )
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.currentColors['bar']!,
                              width: 2
                            )
                          ),
                          label: Text("GitHub Link",
                              style: TextStyle(
                                  color: widget.currentColors['text'],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18
                                  )
                                ),
                        ),
                      ),

                      const SizedBox(height: 15,),
                      TextFormField(
                        style: TextStyle(
                          color: widget.currentColors['text']
                        ),
                        controller: linkLinkController,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.currentColors['bar']!,
                              width: 2
                            )
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.currentColors['bar']!,
                              width: 2
                            )
                          ),

                          label: Text("LinkedIn Link",
                              style: TextStyle(
                                  color: widget.currentColors['text'],
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600
                                  )
                                ),
                        ),
                      ),

                      const SizedBox(height: 15),
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
                                backgroundColor: widget.currentColors['bg'],
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: widget.currentColors['acc1border']!,
                                    width: 3.0,
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: widget.currentColors['text']!,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16
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
                      ),

                      const SizedBox(height: 10,),

                      Text(
                        "Choose Your Character!!",
                        style: TextStyle(
                          color: widget.currentColors['text'],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8,),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_avatars.length, (index) {
                            final bool isSelected = index == selectedAvatarIndex;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: GestureDetector(
                                onTap: () {
                                  setStateDialog(() {
                                    selectedAvatarIndex = index;
                                  });
                                } ,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                            ? widget.currentColors['acc1']!
                                            : widget.currentColors['bar']!,
                                          width: isSelected ? 3 : 2
                                        )
                                      ),
                                      child: CircleAvatar(
                                        radius: 35,
                                        backgroundColor: widget.currentColors['bg'],
                                        backgroundImage: AssetImage(_avatars[index]),
                                      ),
                                    )
                                  ],
                                ),
                                ),
                              );
                          }),
                        ),
                      ),

                      const SizedBox(height: 18,),

                      Text(
                        "Here is your hard earned badges!!",
                        style: TextStyle(
                          color: widget.currentColors['text'],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),

                      SizedBox(
                        height: 64,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _badges.map((assetPath) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: _buildBadge(assetPath),
                                );
                              }).toList(),
                          ),
                        )
                      )

                    ],
                  ),
                ),
                ),

                actions: [
                  TextButton(
                    child: Text(
                      'Approve',
                      style: TextStyle(
                        color: widget.currentColors['acc1']
                      ),
                      ),
                    onPressed: () async {
                      Map<String, String> links = {
                        "github": linkGithubController.text,
                        'linkedin': linkLinkController.text
                      };

                      await profRec.set({
                        'desc': descController.text,
                        'links': links,
                        'tags': tags,
                        'avatarIndex': selectedAvatarIndex,
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

  Widget _buildBadge(String assetPath) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.currentColors['container']!.withAlpha(170),
          width: 3
        ),
      ),
      child: ClipOval(
        child: Image.asset(assetPath, fit: BoxFit.cover),
      )
    );
  }

  Widget _buildBadgeRow() {
    return Container(
      decoration: BoxDecoration(
        color: widget.currentColors["bar"],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.currentColors['mbrBorder']!.withAlpha(180),
          width: 3.0,
        ),
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 1, top: 9, bottom: 10, left: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Badges",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.currentColors['text'],
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _badges.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _buildBadge(_badges[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Container tagContainer(String tagName) {
    return Container(
      alignment: Alignment.center,
      height: 30,
      width: 83,
      decoration: BoxDecoration(
          color: widget.currentColors['acc1'],
          border: Border.all(color: widget.currentColors['acc1border']!, width: 3),
          borderRadius: BorderRadius.circular(10)),
      child: Text(
        tagName,
        style: TextStyle(color: widget.currentColors['text']),
      ),
    );
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
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.currentColors['bg']!.withAlpha(80),
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Transform.scale(
                            scale: 1.12,
                            child: Image.asset(
                              _avatars[_selectedAvatarIndex],
                              fit: BoxFit.cover,
                            ),
                          )
                        ),
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

                  _buildBadgeRow(),

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
                      width: 400.0,
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
                      width: 400.0,
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
                      width: 400.0,
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
