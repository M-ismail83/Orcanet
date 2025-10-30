import 'package:flutter/material.dart';

//groups or chats iq
class ChatRoom {
  final String name;
  final String lastMessage;
  final String type; // 'Pods' or 'Orcas'

  ChatRoom(this.name, this.lastMessage, this.type);
}

final List<ChatRoom> allChats = [
  ChatRoom('Hasan yiit hate club', 'we hate that mf frfr type shi', 'Pods'),
  ChatRoom('Sailors', 'tonight is the night, its gonna happen again', 'Pods'),
  ChatRoom('Thank you god', 'For you have given us ai!!', 'Pods'),
  ChatRoom('Ismail', 'Big Boss', 'Orcas'),
  ChatRoom('Dildar', 'Big Bossette?', 'Orcas'),
  ChatRoom('Deno', 'the msku urinal shi**er', 'Orcas'),
];

//idk what this is ai helped wit it
class chatPage extends StatelessWidget {
  const chatPage({super.key});

  @override
  Widget build(BuildContext context) {
    //tab controller 
    return DefaultTabController(
      length: 2, // Pods and Orcas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ORCA/NET', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(240, 232, 230, 1))),
          elevation: 4,
          backgroundColor: Color.fromRGBO(145, 118, 104, 1),

        ),
        
        //body :)
        body: Column(
          children: <Widget>[
            //places the tab bar at the top of the body
            //it goes purple whenever it is chosen how does one fix that 
            TabBar(
              labelColor: Color.fromRGBO(240, 248, 230, 1),
              unselectedLabelColor: const Color.fromRGBO(240, 232, 230, 0.7), 
              indicatorColor: Color.fromRGBO(240, 248, 230, 1),
              tabs: const [
                Tab(text: 'Pods'),
                Tab(text: 'Orcas'),
              ],
            ),
            
            //ai helped with this part idk how it works, explain??
            Expanded(
              child: TabBarView(
                children: [
                  // Filter chats for the 'Pods' tab
                  ChatTabView(
                    chats: allChats.where((chat) => chat.type == 'Pods').toList(),
                  ),
                  // Filter chats for the 'Orcas' tab
                  ChatTabView(
                    chats: allChats.where((chat) => chat.type == 'Orcas').toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//idont understand this part aswell?
class ChatTabView extends StatelessWidget {
  final List<ChatRoom> chats;

  const ChatTabView({required this.chats, super.key});

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
      return const Center(
        child: Text(
          'No chat rooms in this section.',
          style: TextStyle(color: Color.fromRGBO(240, 232, 230, 1), fontWeight: FontWeight.w600),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatRoomTile(chat: chat);
      },
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  final ChatRoom chat;

  const ChatRoomTile({required this.chat, super.key});

  void _logChatRoomTap() {
    print('Tapped main tile for chat: ${chat.name}');
  }
  
  void _logProfileTap() {
    print('Tapped profile avatar for chat: ${chat.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
      child: Card(
        color: Color.fromRGBO(92, 81, 68, 1),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        
        //this part weirds me tf out
        child: ListTile(
          //Tapping the leading CircleAvatar logs the profile tap
          leading: InkWell(
            onTap: _logProfileTap, 
            borderRadius: BorderRadius.circular(50), 
            child: CircleAvatar(
              backgroundColor: const Color.fromRGBO(137, 139, 139, 1),
              foregroundColor: Colors.white,
              child: Text(
                chat.name[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          //Tapping the rest of the tile logs the chat room tap
          onTap: _logChatRoomTap, 

          //chat room name
          title: Text(
            chat.name,

            style: const TextStyle(color: Color.fromRGBO(240, 232, 230, 1), fontWeight: FontWeight.w600),
          ),
          
          subtitle: Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color.fromRGBO(240, 232, 230, 0.8), fontWeight: FontWeight.w400),
          ),

          trailing: const Icon(
            Icons.chevron_right, 
            size: 20, 
            color: Color.fromRGBO(240, 232, 230, 0.5), // Changed to fit dark theme
          ),
        ),
      ),
    );
  }
}