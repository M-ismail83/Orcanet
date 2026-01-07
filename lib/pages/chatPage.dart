import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';

//idk what this is ai helped wit it
class chatPage extends StatelessWidget {
  const chatPage({super.key, required this.currentColors});
  final Map<String, Color> currentColors;

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    //tab controller
    return DefaultTabController(
      length: 2, // Pods and Orcas
      child: Scaffold(
        //body :)
        body: Column(
          children: <Widget>[
            //places the tab bar at the top of the body
            //it goes purple whenever it is chosen how does one fix that
            TabBar(
              labelColor: currentColors['text'],
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20
              ),
              unselectedLabelColor: currentColors['text']?.withAlpha(170),
              overlayColor: WidgetStateProperty.all(currentColors['bg']),
              indicatorColor: currentColors['selected'],
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Pods'),
                Tab(text: 'Orcas'),
              ],
            ),
            
            SizedBox(height: 7),
            //ai helped with this part idk how it works, explain??
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('participants', arrayContains: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text("No active chats",
                          style: TextStyle(color: currentColors['text'])));
                }

                var docs = snapshot.data!.docs;

                var podsList =
                    docs.where((doc) => doc['type'] == 'Pods').toList();
                var orcasList =
                    docs.where((doc) => doc['type'] == 'Orcas').toList();

                return TabBarView(children: [
                  ChatTabView(
                    chats: podsList,
                    currentColorsView: currentColors,
                    currentUserId: currentUserId,
                  ),
                  ChatTabView(
                    chats: orcasList,
                    currentColorsView: currentColors,
                    currentUserId: currentUserId,
                  ),
                ]);
              },
            )),
          ],
        ),
      ),
    );
  }
}

//idont understand this part aswell?
class ChatTabView extends StatelessWidget {
  final List chats;
  final String currentUserId;
  final Map<String, Color> currentColorsView;

  ChatTabView(
      {required this.chats,
      super.key,
      required this.currentColorsView,
      required this.currentUserId});

  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
      return Center(
        child: Text(
          'No chat rooms in this section.',
          style: TextStyle(
              color: currentColorsView['text'], fontWeight: FontWeight.w600, fontSize: 16
            ),
        ),
      );
    }

    try {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                var chat = chats[index].data() as Map<String, dynamic>;
                String docId = chats[index].id;

                List<dynamic> participants = chat['participants'] ?? [];
                List receiverId =
                    participants.where((id) => id != currentUserId).toList();

                String displayName = chat['chatName'] ?? 'User';

                return ChatRoomTile(
                  name: displayName,
                  lastMessage: chat['lastMessage'] ?? "No messages yet",
                  chatId: docId,
                  receiverId: receiverId,
                  currentColors: currentColorsView,
                );
              },
            ),
          ),

          // create pod page link button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 5,
              backgroundColor: currentColorsView['acc1'],
              side: BorderSide(
                color: currentColorsView['acc1border']!,
                width: 3,
                ),
              foregroundColor: currentColorsView['text'],

            ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => createPodPage(currentColors: currentColorsView,),
                  ),
                );
              },
              child: Text("Create a New Pod!", style: TextStyle(color: currentColorsView['text'], fontWeight: FontWeight.w600, fontSize: 16),)),
          SizedBox(height: 20),
        ],
      );
    } catch (e) {
      print("Error: $e");
    }
    return CircularProgressIndicator();
  }
}

class ChatRoomTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String chatId;
  final List receiverId;
  final Map<String, Color> currentColors;

  const ChatRoomTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.chatId,
    required this.receiverId,
    required this.currentColors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
      child: Card(
        color: currentColors['container'],
        elevation: 2,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: currentColors['bg']!.withAlpha(175), width: 3),
          borderRadius: BorderRadius.circular(13.0),
        ),

        //this part weirds me tf out
        child: ListTile(
          //Tapping the leading CircleAvatar logs the profile tap
          leading: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(50),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: const Color.fromRGBO(137, 139, 139, 1),
              foregroundColor: Colors.white,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "?",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          //Tapping the rest of the tile logs the chat room tap
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => ChatScreen(
                    kisiAdi: name,
                    receiverId: receiverId,
                    chatId: chatId,
                    currentColors: currentColors),
              ),
            );
          },

          //chat room name
          title: Text(
            name,
            style: TextStyle(
                color: currentColors['text'], fontWeight: FontWeight.w600, fontSize: 20),
          ),

          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: currentColors['text']?.withAlpha(170),
                fontWeight: FontWeight.w500,
                fontSize: 18
                ),
          ),

          trailing: Icon(
            Icons.chevron_right,
            size: 27,
            color: currentColors['text']?.withOpacity(0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}