import 'package:flutter/material.dart';

class postCard extends StatefulWidget {
  final String title;
  final String bodyText;
  final List<Container> tags;
  final Container nameCard;
  final Map<String, Color> currentColorsPost;

  const postCard(
      {super.key,
      required this.title,
      required this.bodyText,
      required this.tags,
      required this.nameCard,
      required this.currentColorsPost});
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
      displayedTags.add(Container(
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
                Text(
                  widget.title,
                  style: TextStyle(
                      color: widget.currentColorsPost['text'],
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Divider(thickness: 2, color: widget.currentColorsPost['bar']),
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
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: currentColorsComment['text']),
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
                    title: Text('User ${index + 1}',
                        style: TextStyle(color: currentColorsComment['text'])),
                    subtitle: Text('This is a great post! I totally agree.',
                        style: TextStyle(color: currentColorsComment['text'])),
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
