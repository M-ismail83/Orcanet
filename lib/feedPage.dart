import "package:flutter/material.dart";

class feedPage extends StatelessWidget {
  feedPage({super.key});

  static Container tagContainer(String tagName) {
    return Container(
      alignment: Alignment.center,
      height: 30,
      width: 65,
      decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(189, 76, 237, 1)),
          borderRadius: BorderRadius.circular(10)),
      child: Text(
        "Hello",
        style: TextStyle(color: Color.fromRGBO(240, 232, 230, 1)),
      ),
    );
  }

  static Container nameCard(BuildContext context, Image profilePhoto, String name, String desc) {
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                name,
                style: TextStyle(
                    color: Color.fromRGBO(240, 232, 230, 1),
                    fontWeight: FontWeight.bold),
              ),
              Text(desc,
                  style: TextStyle(
                    color: Color.fromRGBO(240, 232, 230, 1),
                  ))
            ],
          ),
          Spacer(),
          Ink(
            decoration: ShapeDecoration(
                shape: CircleBorder(
                    side:
                        BorderSide(color: Color.fromRGBO(143, 222, 89, 1)))),
            child: IconButton(
              onPressed: () {
                showModalBottomSheet(
                  elevation: 4.0,
                  backgroundColor: Color.fromRGBO(60, 49, 43, 1),
                    context: context,
                    builder: (BuildContext context) {
                      return const CommentsSection();
                    }
                );
              },
              icon: Icon(Icons.message),
              color: Color.fromRGBO(240, 232, 230, 1),
              iconSize: 18,
              alignment: Alignment.center,
            ),
          ),
          Ink(
            decoration: ShapeDecoration(
                shape: CircleBorder(
                    side:
                        BorderSide(color: Color.fromRGBO(143, 222, 89, 1)))),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.group),
              color: Color.fromRGBO(240, 232, 230, 1),
              iconSize: 20,
              alignment: Alignment.center,
            ),
          )
        ],
      ),
    );
  }

  final List<Widget> tagList = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(60, 49, 43, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(145, 118, 104, 1),
          title: Text(
            "ORCA/NET",
            style: TextStyle(
                fontSize: 17,
                color: Color.fromRGBO(240, 232, 230, 1),
                fontWeight: FontWeight.w600),
          ),
          leading: Image.asset(
            "lib/images/Logo.png",
            alignment: Alignment.centerRight,
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
                  nameCard: nameCard(context, Image.asset("lib/images/placeholder.jpg"),
                      "Steve", "Short desc")),
              postCard(
                  image: AssetImage("lib/images/placeholder.jpg"),
                  title: "I need people",
                  bodyText:
                      "Hello. I need exeactly 1313 people for my project and yes I have enough money and I'm fucin rich.",
                  tags: tagList,
                  nameCard: nameCard(context, Image.asset("lib/images/placeholder.jpg"),
                      "Steve", "Short desc"))
            ]));
  }
}

class postCard extends StatefulWidget {
  final AssetImage image;
  final String title;
  final String bodyText;
  final List<Widget> tags;
  final Container nameCard;

  const postCard(
      {super.key,
      required this.image,
      required this.title,
      required this.bodyText,
      required this.tags,
      required this.nameCard});
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
              color: Color.fromRGBO(189, 76, 237, 1),
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
        color: Color.fromRGBO(92, 81, 68, 1),
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
                  style: TextStyle(color: Color.fromRGBO(240, 232, 230, 1)),
                ),
                Divider(
                    thickness: 2, color: Color.fromRGBO(145, 118, 104, 1)),
                if (!_isExtended)
                  Text(
                    widget.bodyText,
                    style: TextStyle(color: Color.fromRGBO(240, 232, 230, 1)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    widget.bodyText,
                    style: TextStyle(color: Color.fromRGBO(240, 232, 230, 1)),
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
  const CommentsSection({super.key});

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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'Comments (125)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color.fromRGBO(240, 232, 230, 1)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: 50,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    tileColor: Color.fromRGBO(92, 81, 68, 100)  ,
                    title: Text('User ${index + 1}', style: TextStyle(color: Color.fromRGBO(240, 232, 230, 1)),),
                    subtitle: const Text('This is a great post! I totally agree.', style: TextStyle(color: Color.fromRGBO(240, 232, 230, 1)),
                  )
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
