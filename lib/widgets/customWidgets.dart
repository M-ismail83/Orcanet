import 'package:flutter/material.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';

Container nameCard(BuildContext context, String name, String tag, String uid, Map<String, Color> currentColors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3),
      height: 45,
      width: 350,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipOval(
            child: InkWell(
              onTap: () {
                Utilityclass().navigator(
                    context,
                    profilePage(
                      currentColors: currentColors,
                      uid: uid,
                    ));
              },
              splashColor: Colors.transparent,
              child: Image.asset(
                "lib/images/placeholder.jpg",
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                      color: currentColors['text'],
                      fontWeight: FontWeight.bold),
                ),
                Text(tag,
                    style: TextStyle(
                      color: currentColors['text'],
                    ))
              ],
            ),
          ),
          Spacer(),
          Ink(
            decoration: ShapeDecoration(
                color: currentColors['acc2'],
                shape: CircleBorder(
                    side: BorderSide(color: currentColors['acc2']!))),
            child: IconButton(
              onPressed: () {
                showModalBottomSheet(
                    elevation: 4.0,
                    backgroundColor: currentColors['bg'],
                    context: context,
                    builder: (BuildContext context) {
                      return CommentsSection(
                          currentColorsComment: currentColors);
                    });
              },
              icon: Icon(Icons.message),
              color: currentColors['text'],
              iconSize: 18,
              alignment: Alignment.center,
            ),
          ),
          Ink(
            decoration: ShapeDecoration(
                color: currentColors['acc2'],
                shape: CircleBorder(
                    side: BorderSide(color: currentColors['acc2']!))),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.group),
              color: currentColors['text'],
              iconSize: 20,
              alignment: Alignment.center,
            ),
          )
        ],
      ),
    );
  }

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