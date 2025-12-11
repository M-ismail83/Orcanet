import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/messagingService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orcanet/utilityClass.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {super.key,
      required this.receiverId,
      required this.kisiAdi,
      required this.currentColors,
      required this.chatId});

  final String kisiAdi;
  final String receiverId;
  final Map<String, Color> currentColors;
  final String chatId;


  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  void handleSend() {
    if (_controller.text.trim().isEmpty) return;

    // Call the function we defined earlier
    sendMessage(
      senderId: _auth.currentUser!.uid,
      receiverId: widget.receiverId,
      chatId: widget.chatId,
      text: _controller.text.trim(),
    );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(60, 49, 43, 1.0),
      appBar: AppBar(
        title: Text(widget.kisiAdi),
        backgroundColor: const Color.fromRGBO(145, 118, 104, 1.0),

        actions: [
            IconButton(
              icon: const Icon(Icons.menu_outlined),
              tooltip: 'Opens task menu',
              onPressed: () {
                showModalBottomSheet(
                  elevation: 4.0,
                  backgroundColor: widget.currentColors['bg'],
                    context: context,
                    builder: (BuildContext context) {
                      return TaskSection(currentColorsComment: widget.currentColors);
                    }
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.call),
              tooltip: 'Calling yo twin',
              onPressed: () {
                // handle the press
              },
            ),
          ],
          
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
            stream: getMessagesStream(widget.chatId),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data!.docs;

              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message =
                      messages[index].data() as Map<String, dynamic>;
                  bool isMe = message['senderId'] == _auth.currentUser!.uid;

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isMe
                            ? widget.currentColors['msgBubbleSender']
                            : widget.currentColors['msgBubbleReciever'],
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text(
                        message['text'],
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          )),
          Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, bottom: 15.0, top: 0.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: widget.currentColors['text']),
                      cursorColor: widget.currentColors['hintText'],
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromRGBO(60, 49, 43, 0.70)),
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                        filled: true,
                        fillColor: widget.currentColors['container'],
                        hintText: 'Type a message',
                        hintStyle: TextStyle(
                          color: widget.currentColors['hintText'],
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              style: BorderStyle.solid,
                              color: const Color.fromRGBO(60, 49, 43, 0.70)),
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                              left: 0.1, top: 7.0, bottom: 7.0),
                          child: ElevatedButton(
                            onPressed: handleSend,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(184, 167, 148, 1),
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12.0),
                              elevation: 0,
                            ),
                            child: const Icon(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(60, 49, 43, 1),
                                size: 25.0,
                                Icons.attach_file),
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(
                              right: 0.1, top: 7.0, bottom: 7.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_controller.text.isNotEmpty) {
                                sendMessage(
                                    senderId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    receiverId: widget.receiverId,
                                    chatId: widget.chatId,
                                    text: _controller.text);
                                _controller.clear();
                              } else {
                                BottomAppBar(
                                  color: Colors.red,
                                  child: Text('Cannot send empty message',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(184, 167, 148, 1),
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12.0),
                              elevation: 0,
                            ),
                            child: const Icon(
                                color: Color.fromRGBO(60, 49, 43, 1),
                                size: 25,
                                Icons.send),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class Task {
  final String title;
  final String description;
  String status;
  final Color statusColor;
  final String? buttonText;

  Task({required this.title, required this.description, required this.status, required this.statusColor, this.buttonText});
}

class TaskCategory {
  final String title;
  final Color labelColor;
  List<Task> tasks;

  TaskCategory({required this.title, required this.labelColor, required this.tasks});
}

final List<TaskCategory> taskSections = [
  TaskCategory(
    title: 'Incoming Task',
    labelColor: Color.fromRGBO(153, 39, 39, 1.0),
    //generates a custom list for just showcase
    tasks: List.generate(5, (i) => Task(
      title: 'Incoming $i', 
      description: 'Do that shi $i.', 
      status: 'New', 
      statusColor: Color.fromRGBO(153, 39, 39, 1.0), 
      buttonText: 'Accept'
    )),
  ),
  TaskCategory(
    title: 'Ongoing Task',
    labelColor: Color.fromRGBO(246, 194, 88, 1.0),
    //generates a custom list for just showcase
    tasks: List.generate(4, (i) => Task(
      title: 'Ongoing $i', 
      description: 'Im on that shi $i.', 
      status: 'Ongoing', 
      statusColor: Color.fromRGBO(246, 194, 88, 1.0), 
      buttonText: 'Finish Task'
    )),
  ),
  TaskCategory(
    title: 'Completed Task',
    labelColor: Color.fromRGBO(17, 123, 77, 1.0),
    //generates a custom list for just showcase
    tasks: List.generate(6, (i) => Task(
      title: 'Completed $i', 
      description: 'Completed that shi $i.', 
      status: 'Completed', 
      statusColor: Color.fromRGBO(17, 123, 77, 1.0),
      buttonText: null,
    )),
  ),
];


  class TaskSection extends StatefulWidget {
    const TaskSection({super.key, required this.currentColorsComment});

    final Map<String, Color> currentColorsComment;

    @override
    State<TaskSection> createState() => _TaskSectionState();
  }

  class _TaskSectionState extends State<TaskSection> {
    late List<TaskCategory> taskSections;

    @override
    void initState() {
      super.initState();
      // Initialize mock data here
      taskSections = [
        TaskCategory(
          title: 'Incoming Task',
          labelColor: Colors.orangeAccent,
          tasks: List.generate(3, (i) => Task(
            title: 'User ${i + 1} - New', 
            description: 'Review document $i.', 
            status: 'Incoming', 
            statusColor: Colors.orangeAccent, 
            buttonText: 'Accept'
          )),
        ),
        TaskCategory(
          title: 'Ongoing Task',
          labelColor: Colors.lightBlueAccent,
          tasks: List.generate(2, (i) => Task(
            title: 'User ${i + 1} - Active', 
            description: 'Develop feature $i.', 
            status: 'Ongoing', 
            statusColor: Colors.lightBlueAccent, 
            buttonText: 'Finish Task'
          )),
        ),
        TaskCategory(
          title: 'Completed Task',
          labelColor: Colors.greenAccent,
          tasks: List.generate(1, (i) => Task(
            title: 'User ${i + 1} - Done', 
            description: 'Test case $i passed.', 
            status: 'Completed', 
            statusColor: Colors.greenAccent, 
            buttonText: null
          )),
        ),
      ];
    }

  void handleTaskAction(Task task, int sourceCategoryIndex) {
    setState(() {
      int destinationCategoryIndex = -1;
      
      if (task.buttonText == 'Accept') {
        // Move from Incoming (index 0) to Ongoing (index 1)
        destinationCategoryIndex = 1;
        task.status = 'Ongoing'; // Update task status
      } else if (task.buttonText == 'Finish Task') {
        // Move from Ongoing (index 1) to Completed (index 2)
        destinationCategoryIndex = 2;
        task.status = 'Completed'; // Update task status
      }

      if (destinationCategoryIndex != -1) {
        // A. Remove the task from the source list
        taskSections[sourceCategoryIndex].tasks.remove(task);

        // B. Add the task to the destination list
        taskSections[destinationCategoryIndex].tasks.add(task);
        
        print('Task ${task.title} moved from ${taskSections[sourceCategoryIndex].title} to ${taskSections[destinationCategoryIndex].title}');
      }
    });
  }

@override
  Widget build(BuildContext context) {
    const double cardWidth = 250.0;
    const double cardHeight = 180.0;

    // Use widget.currentColorsComment to access the property from the StatefulWidget
    final currentColorsComment = widget.currentColorsComment;

    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 1,
      minChildSize: 1,
      builder: (BuildContext context, ScrollController scrollController) {
        return Column(
          children: [
            // ... (Header and Divider remains the same) ...

            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: taskSections.length,
                itemBuilder: (context, sectionIndex) {
                  final category = taskSections[sectionIndex];
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Category Label
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 8.0),
                        child: Text(
                          '${category.title} (${category.tasks.length})', // Added count for verification
                          style: TextStyle(
                            color: category.labelColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      // 2. Inner Horizontal List
                      SizedBox(
                        height: cardHeight,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: category.tasks.length,
                          itemBuilder: (context, taskIndex) {
                            final task = category.tasks[taskIndex];
                            
                            Widget? actionButton;
                            if (task.buttonText != null) {
                              actionButton = ElevatedButton(
                                onPressed: () {
                                  // *** KEY CHANGE: Call handler and pass the sectionIndex ***
                                  handleTaskAction(task, sectionIndex); 
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF5A785D),
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  minimumSize: Size.zero, 
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(task.buttonText!, style: TextStyle(color: Colors.white, fontSize: 12)),
                              );
                            }

                            // ... (rest of the task card UI remains the same) ...
                            return Padding(
                              padding: EdgeInsets.only(
                                left: taskIndex == 0 ? 16.0 : 8.0, 
                                right: 8.0
                              ),
                              child: Container(
                                width: cardWidth,
                                padding: const EdgeInsets.all(16.0), 
                                decoration: BoxDecoration(
                                  color: currentColorsComment['container'],
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task.title, style: TextStyle(color: currentColorsComment['text'], fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4.0),
                                    Expanded(
                                      child: Text(task.description, style: TextStyle(color: currentColorsComment['text']), maxLines: 4, overflow: TextOverflow.ellipsis),
                                    ),
                                    if (actionButton != null) ...[
                                      const SizedBox(height: 8.0),
                                      Row(
                                        children: [
                                          Spacer(),
                                          actionButton,
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }//
}