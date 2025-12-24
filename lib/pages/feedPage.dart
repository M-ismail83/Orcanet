import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:orcanet/main.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';
import 'package:orcanet/widgets/postCard.dart';
import 'package:orcanet/widgets/customWidgets.dart';
class feedPage extends StatefulWidget {
  const feedPage({super.key, required this.currentColors});
  final Map<String, Color> currentColors;

  @override
  State<feedPage> createState() => _feedPageState();
}

class _feedPageState extends State<feedPage> {
  Container tagContainer(String tagName) {
    return Container(
      alignment: Alignment.center,
      height: 30,
      width: 65,
      decoration: BoxDecoration(
          color: widget.currentColors['acc1'],
          border: Border.all(color: widget.currentColors['acc1']!),
          borderRadius: BorderRadius.circular(10)),
      child: Text(
        tagName,
        style: TextStyle(color: widget.currentColors['text']),
      ),
    );
  }

  final ScrollController _scroolController = ScrollController();
  List<DocumentSnapshot> posts = [];
  bool _isLoading = false;
  bool hasMore = true;
  int _limit = 5;
  Map<String, String> _nicknameCache = {};

  @override
  void initState() {
    super.initState();
    _getPosts();

    _scroolController.addListener(() {
      if (_scroolController.position.pixels ==
          _scroolController.position.maxScrollExtent) {
        _getPosts();
      }
    });
  }

  Future<void> _getPosts() async {
    if (_isLoading || !hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(_limit);

      if (posts.isNotEmpty) {
        query = query.startAfterDocument(posts.last);
      }

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.length < _limit) {
        hasMore = false;
      }

      // ... (Your existing user nickname fetching loop is fine) ...
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        // Get the UID from the post
        String uid = data['senderUid'] ?? "";

        // Only fetch if we have a UID and we haven't fetched this user yet
        if (uid.isNotEmpty && !_nicknameCache.containsKey(uid)) {
          // Go to 'profile' collection -> Find the document with that UID
          var profileDoc = await FirebaseFirestore.instance
              .collection('profile')
              .doc(uid)
              .get();

          if (profileDoc.exists) {
            var profileData = profileDoc.data() as Map<String, dynamic>;
            // Save the nickname to our cache
            _nicknameCache[uid] = profileData['nickname'] ?? "Unknown Orca";
          }
        }
      }

      if (context.mounted) {
        setState(() {
        posts.addAll(snapshot.docs);
        _isLoading = false;
      });
      }
    } catch (e) {
      print("Error getting posts: $e"); // Added error printing to help debug
      if (context.mounted){
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.currentColors['bg'],
      body: ListView.builder(
        controller: _scroolController,
        // Add 1 for the spinner at the bottom
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          // 1. CHECK IF WE ARE AT THE BOTTOM
          if (index == posts.length) {
            return hasMore
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator()))
                : const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("No more posts!")),
                  );
          }

          // 2. GET DATA safely
          final data = posts[index].data() as Map<String, dynamic>;

          // 3. GENERATE TAGS ON THE FLY (Don't use global list)
          List<Container> currentPostTags = (data['tags'] as List<dynamic>?)
                  ?.map((tag) => tagContainer(tag.toString()))
                  .toList() ??
              [];

          return postCard(
            title: data['title'] ?? 'No Title',
            bodyText: data['subTitle'] ??
                'No Content', // FIXED: 'suTitle' -> 'subTitle'
            tags: currentPostTags, // Pass the local list
            currentColorsPost: widget.currentColors,
            uuid: posts[index].id,
            nameCard: nameCard(
                context,
                // Use nickname cache, fallback to 'Unknown'
                _nicknameCache[data['senderUid']] ?? "Unknown User",
                "Member", // Or fetch their role if you have it
                data['senderUid'] ?? "Unknown UID",
                widget.currentColors
                ),
          );
        },
      ),
    );
  }
}
