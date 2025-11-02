import "package:flutter/material.dart";
import 'package:orcanet/main.dart';
import 'package:orcanet/utilityClass.dart';

class feedPage extends StatelessWidget {
  const feedPage({super.key, required this.currentColors});
  final Map<String, Color> currentColors;
  Container tagContainer(String tagName) {
    return Container(
      alignment: Alignment.center,
      height: 30,
      width: 65,
      decoration: BoxDecoration(
        color: currentColors['acc1'],
          border: Border.all(color: currentColors['acc1']!),
          borderRadius: BorderRadius.circular(10)),
      child: Text(
        "Hello",
        style: TextStyle(color: currentColors['text']),
      ),
    );
  }

  Container nameCard(BuildContext context, Image profilePhoto, String name, String desc) {
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
              onTap: () {},
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
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                    color: currentColors['text'],
                    fontWeight: FontWeight.bold),
              ),
              Text(desc,
                  style: TextStyle(
                    color: currentColors['text'],
                  ))
            ],
          ),
          Spacer(),
          Ink(
            decoration: ShapeDecoration(
              color: currentColors['acc2'],
                shape: CircleBorder(
                    side:
                        BorderSide(color: currentColors['acc2']!))),
            child: IconButton(
              onPressed: () {
                showModalBottomSheet(
                  elevation: 4.0,
                  backgroundColor: currentColors['bg'],
                    context: context,
                    builder: (BuildContext context) {
                      return CommentsSection(currentColorsComment: currentColors);
                    }
                );
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
                    side:
                        BorderSide(color: currentColors['acc2']!))),
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
  @override
  Widget build(BuildContext context) {

    List<Widget> tagList = [
    tagContainer("Yes"),
    tagContainer("Yes"),
    tagContainer("Yes"),
    tagContainer("Yes"),
    tagContainer("Yes"),
    tagContainer("Yes"),
    tagContainer("Yes"),
    tagContainer("Yes"),
    tagContainer("Yes"),
    tagContainer("Yes"),
  ];

    return Scaffold(
        backgroundColor: currentColors['bg'],
        appBar: AppBar(
          backgroundColor: currentColors['bar'],
          title: Text(
            "ORCA/NET",
            style: TextStyle(
                fontSize: 17,
                color: currentColors['text'],
                fontWeight: FontWeight.w600),
          ),
          leading: InkWell(
            onTap: () {
              isDarkModeNotifier.value = !isDarkModeNotifier.value;
            },
            splashColor: Colors.transparent,
            child: CircleAvatar(
              backgroundColor: currentColors['bar'],
              backgroundImage: AssetImage("lib/images/Logo.png"),
            ),
          ),
          leadingWidth: 55,
        ),
        body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              postCard(
                  image: AssetImage("lib/images/placeholder.jpg"),
                  title: "I need people",
                  bodyText:
                      "Hello. I need exeactly 1313 people for my project and yes I have enough money and I'm fucin rich.",
                  tags: tagList,
                  nameCard: nameCard(context, Image.asset("lib/images/placeholder.jpg"),"Steve", "Short desc"),
                  currentColorsPost: currentColors,
                 ), 
              postCard(
                  image: AssetImage("lib/images/placeholder.jpg"),
                  title: "I need people",
                  bodyText:
                      "Hello. I need exeactly 1313 people for my project and yes I have enough money and I'm fucin rich.",
                  tags: tagList,
                  nameCard: nameCard(context, Image.asset("lib/images/placeholder.jpg"),
                      "Steve", "Short desc"),
                      currentColorsPost: currentColors,)
            ]));
  }
}

class postCard extends StatefulWidget {
  final AssetImage image;
  final String title;
  final String bodyText;
  final List<Widget> tags;
  final Container nameCard;
  final Map<String, Color> currentColorsPost;

  const postCard(
      {super.key,
      required this.image,
      required this.title,
      required this.bodyText,
      required this.tags,
      required this.nameCard,
      required this.currentColorsPost
      });
  @override
  State<StatefulWidget> createState() => _postCardState();
}

class _postCardState extends State<postCard> {
  bool _isExtended = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> displayedTags = [];
    const maxTagCount = 3;
    if (_isExtended || widget.tags.length <= maxTagCount) {
      displayedTags = widget.tags;
    } else {
      displayedTags = widget.tags.take(maxTagCount).toList();
      displayedTags.add(SizedBox(
        height: 30,
        width: 65,
        child: Text(
          "...",
          style: TextStyle(
              color: widget.currentColorsPost['acc1'],
              fontWeight: FontWeight.bold,
              fontSize: 17),
        ),
      ));
    }

    return InkWell(
      onTap: () {
        setState(() {
          _isExtended = !_isExtended;
        });
      },
      splashColor: Colors.transparent,
      child: Card(
        color: widget.currentColorsPost['container'],
        clipBehavior: Clip.antiAlias,
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 250,
                  width: 350,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          fit: BoxFit.fill, image: widget.image)),
                ),
                SizedBox(height: 7),
                Text(
                  widget.title,
                  style: TextStyle(color: widget.currentColorsPost['text']),
                ),
                Divider(
                    thickness: 2, color: widget.currentColorsPost['bar']),
                if (!_isExtended)
                  Text(
                    widget.bodyText,
                    style: TextStyle(color: widget.currentColorsPost['text']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    widget.bodyText,
                    style: TextStyle(color: widget.currentColorsPost['text']),
                  ),
                SizedBox(height: 7),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: displayedTags,
                    )),
                SizedBox(height: 7),
                widget.nameCard
              ],
            ),
          ),
        ),
      ),
    );
  }
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
