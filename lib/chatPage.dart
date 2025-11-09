import 'package:flutter/material.dart';
import 'package:orcanet/message.dart';

//groups or chats iq
class ChatRoom {
  final String name;
  final String lastMessage;
  final String type; // 'Pods' or 'Orcas'

  ChatRoom(this.name, this.lastMessage, this.type);
}

final List<ChatRoom> allChats = [
  ChatRoom('HYHFC', 'What is our purpose?', 'Pods'),
  ChatRoom('Sailors', 'tonight is the night, its gonna happen again', 'Pods'),
  ChatRoom('Thank you god', 'For you have given us ai!!', 'Pods'),
  ChatRoom('Ismail', 'Neo', 'Orcas'),
  ChatRoom('Dildar', 'Trinity', 'Orcas'),
  ChatRoom('Deno', 'Morpheus', 'Orcas'),
];

//idk what this is ai helped wit it
class chatPage extends StatelessWidget {
  const chatPage({super.key, required this.currentColors});
  final Map<String, Color> currentColors;

  @override
  Widget build(BuildContext context) {
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
              unselectedLabelColor: currentColors['text']?.withOpacity(0.7),
              indicatorColor: currentColors['selected'],
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
                    currentColorsView: currentColors,
                  ),
                  // Filter chats for the 'Orcas' tab
                  ChatTabView(
                    chats: allChats.where((chat) => chat.type == 'Orcas').toList(),
                    currentColorsView: currentColors,
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
  final Map<String, Color> currentColorsView;
  const ChatTabView({required this.chats, super.key, required this.currentColorsView});

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
      return Center(
        child: Text(
          'No chat rooms in this section.',
          style: TextStyle(color: currentColorsView['text'], fontWeight: FontWeight.w600),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatRoomTile(chat: chat, currentColorsTile: currentColorsView);
      },
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  final ChatRoom chat;
  final Map<String, Color> currentColorsTile;
  const ChatRoomTile({required this.chat, super.key, required this.currentColorsTile});

  void _logChatRoomTap() {
    print('Tapped chat room: ${chat.name}');
  }
  
  void _logProfileTap() {
    print('Tapped profile avatar for chat: ${chat.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
      child: Card(
        color: currentColorsTile['container'],
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
          onTap: () {
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(kisiAdi: chat.name),
      ),  
    );
          }, 

          //chat room name
          title: Text(
            chat.name,

            style: TextStyle(color: currentColorsTile['text'], fontWeight: FontWeight.w600),
          ),
          
          subtitle: Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: currentColorsTile['text']?.withOpacity(0.8), fontWeight: FontWeight.w400),
          ),

          trailing: Icon(
            Icons.chevron_right,
            size: 20,
            color: currentColorsTile['text']?.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}