import 'package:flutter/material.dart';
class postCard extends StatefulWidget {
  final String title;
  final String bodyText;
  final List<Container> tags;
  final Container nameCard;
  final Map<String, Color> currentColorsPost;
  final String uuid;

  const postCard(
      {super.key,
      required this.title,
      required this.bodyText,
      required this.tags,
      required this.nameCard,
      required this.currentColorsPost,
      required this.uuid
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
                  style: TextStyle(color: widget.currentColorsPost['text'], fontSize: 18, fontWeight: FontWeight.bold),
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

