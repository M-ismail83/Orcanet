import 'package:flutter/material.dart';

class CommentsSection extends StatelessWidget {
  const CommentsSection({super.key, required this.currentColorsComment});

  final Map<String, Color> currentColorsComment;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController scrollController) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'Comments (125)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: currentColorsComment['text']),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: 50,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    tileColor: currentColorsComment['container'],
                    title: Text('User ${index + 1}', style: TextStyle(color: currentColorsComment['text'])),
                    subtitle: Text('This is a great post! I totally agree.', style: TextStyle(color: currentColorsComment['text'])),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}