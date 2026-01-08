import 'package:flutter/material.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';
import 'package:orcanet/widgets/commentSection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orcanet/services/avatar_paths.dart';

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
          FutureBuilder<int>(
            future: getAvatarIndex(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData ||
                  snapshot.hasError) {
                // loading / error durumunda placeholder
                return ClipOval(
                  child: Image.asset(
                    "lib/images/placeholder.jpg",
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                );
              }

              final avatarIndex = snapshot.data!;
              final avatar = avatarPaths[avatarIndex];

              // resmi önceden cache'le
              precacheImage(AssetImage(avatar), context);

              return ClipOval(
                child: InkWell(
                  onTap: () {
                    Utilityclass().navigator(
                      context,
                      profilePage(
                        currentColors: currentColors,
                        uid: uid,
                      ),
                    );
                  },
                  splashColor: Colors.transparent,
                  child: Image.asset(
                    avatar,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
              );
            },
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
                    side: BorderSide(color: currentColors['acc2border']!, width: 2))),
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
                    side: BorderSide(color: currentColors['acc2border']!, width: 2))),
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