import 'package:flutter/material.dart';
import 'package:orcanet/utilityClass.dart';

class profilePage extends StatefulWidget {
  const profilePage({super.key, required this.currentColors}); //constructor
  final Map<String, Color> currentColors; //field for constructor

  @override
  State<StatefulWidget> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {

  Container tagContainer(String tagName) {
    return Container(
      alignment: Alignment.center,
      height: 30,
      width: 65,
      decoration: BoxDecoration(
          color: widget.currentColors['acc1'],
          border: Border.all(color: widget.currentColors['acc1']!),
          borderRadius: BorderRadius.circular(10)),
      child: Text(
        tagName,
        style: TextStyle(color: widget.currentColors['text']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.currentColors['bg'],
      body: SafeArea(child:
       ListView(
        //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            Container( //uppermost container structure:
              //
              decoration: BoxDecoration(
                color: widget.currentColors['container'],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: widget.currentColors['container']!, width: 1.0),
              ),
              padding: EdgeInsets.all(15.0),
              margin: EdgeInsets.all(15.0),
              width: double.infinity,

              // *** FIX 1: Removed the Expanded widget here ***
              child: Column(
                children: [
                  Row( // Use a Row to align the CircleAvatar and the text/progress bar
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profile Picture
                  CircleAvatar(
                    backgroundImage: Image.asset(
                      "lib/images/placeholder.jpg",
                      fit: BoxFit.fill,
                    ).image,
                  ),
                  const SizedBox(width: 12),

                  // 2. User Info (Username, Name, Progress Bar)
                  // We wrap this entire section in an Expanded so it takes the remaining space
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stack the two Text widgets
                        Text(
                          "Herald W. Hidepain",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // *** FIX 2: Adjusted or removed unnecessary height property ***
                            fontSize: 18,
                            color: widget.currentColors['text'],
                          ),
                        ),
                        Text(
                          "@username",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            color: widget.currentColors['text']!.withOpacity(0.7),
                          ),
                        ),

                        // Vertical space before the progress bar
                        const SizedBox(height: 10),

                        // Krill/Points Progress Bar
                        LinearProgressIndicator(
                          value: 0.7,
                          minHeight: 8.0,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.blue.shade700,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                            onPressed: (){},
                            child: Text("Invite")
                        ),
                        IconButton(
                            onPressed: (){},
                            icon: const Icon(Icons.message)
                        )
                      ],
                  )
                  )
                ],
              ),
                  Container(
                    decoration: BoxDecoration(
                      color: widget.currentColors["bar"],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: widget.currentColors['container']!, width: 1.0),
                    ),
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(8.0),
                    width: 300.0,
                    height: 80.0,
                    child: Text("asdfghjklşrtyuıowertyuıcv",
                      style: TextStyle(
                        fontSize: 15,
                        color: widget.currentColors['text'],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        tagContainer("orca"),
                        tagContainer("orca"),
                        tagContainer("orca"),
                        tagContainer("orca"),
                        tagContainer("orca"),
                      ],
                    ),
                  )
              ]
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: widget.currentColors['container'],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: widget.currentColors['container']!, width: 1.0),
              ),
              padding: EdgeInsets.all(15.0),
              margin: EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
              width: double.infinity,

              child:
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child:
                Text(
                    """I am a visual learner, i worked at valve and microsoft at the same time. I am a machine that turns using pain i suffer from the work load. These are some of the jobs i worked on:
-Red alert 2
-Team fortress as a red spy
-Microsoft store algotihm
-Minecraft as Steve""",
                  style: TextStyle(
                  fontSize: 15,
                  color: widget.currentColors['text'],
                ),
                ),

              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: widget.currentColors['container'],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: widget.currentColors['container']!, width: 1.0),
              ),
              padding: EdgeInsets.all(15.0),
              margin: EdgeInsets.all(15.0),
              width: double.infinity,

              child: Text(
                  """Links:
-linkedin_link
-github_link
-steam_link
-clashroyale_account_link""",
                  style: TextStyle(
                    fontSize: 15,
                    color: widget.currentColors['text'],
                  ),
                )
            ),

            Container(
              decoration: BoxDecoration(
                color: widget.currentColors['container'],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: widget.currentColors['container']!, width: 1.0),
              ),
              padding: EdgeInsets.all(15.0),
              margin: EdgeInsets.all(15.0),
              width: double.infinity,

              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: widget.currentColors["bar"],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: widget.currentColors['container']!, width: 1.0),
                    ),
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(8.0),
                    width: 300.0,
                    height: 80.0,
                    child: Text("asdfghjklşrtyuıowertyuıcv",
                      style: TextStyle(
                        fontSize: 15,
                        color: widget.currentColors['text'],
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: widget.currentColors["bar"],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: widget.currentColors['container']!, width: 1.0),
                    ),
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(8.0),
                    width: 300.0,
                    height: 80.0,
                    child: Text("asdfghjklşrtyuıowertyuıcv",
                      style: TextStyle(
                        fontSize: 15,
                        color: widget.currentColors['text'],
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: widget.currentColors["bar"],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: widget.currentColors['container']!, width: 1.0),
                    ),
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(8.0),
                    width: 300.0,
                    height: 80.0,
                    child: Text("asdfghjklşrtyuıowertyuıcv",
                      style: TextStyle(
                        fontSize: 15,
                        color: widget.currentColors['text'],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}