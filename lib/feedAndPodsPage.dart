import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';

class Feedandpodspage extends StatefulWidget {
  const Feedandpodspage({super.key});

  @override
  State<StatefulWidget> createState() => _FeedandpodspageState();
}

class _FeedandpodspageState extends State<Feedandpodspage> {
  Widget customContainerPods(
      BuildContext context, String text, String bottomText) {
    return Container(
        height: 140,
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                image: AssetImage("lib/images/placeholder.jpg"))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StrokeText(text: text,
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.start,
              strokeColor: Colors.white,
              strokeWidth: 2,
            ),
            StrokeText(text: bottomText,
              textStyle: const TextStyle(
                  fontSize: 12, color: Color.fromRGBO(90, 90, 90, 1)),
              strokeColor: Colors.white,
              strokeWidth: 2,
            )
          ],
        ));
  }

  Widget customContainerOrca(
      BuildContext context, String text, String secondText) {
    return Container(
        height: 50,
        width: 395,
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.only(left: 60, top: 2),
        decoration: const BoxDecoration(
            image: DecorationImage(
                alignment: Alignment.centerLeft,
                image: AssetImage("lib/images/placeholder.jpg"))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.start,
            ),
            Text(
              secondText,
              style: const TextStyle(
                  fontSize: 12, color: Color.fromRGBO(90, 90, 90, 1)),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(25, 15, 25, 5),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 242, 228, 242),
                border: Border.all(), borderRadius: BorderRadius.circular(25)),
            child: const TextField(
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                  suffixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(50, 13, 0, 0),
                  hintText: "Search for Orcas and Pods",
                  hintStyle: TextStyle(color: Color.fromRGBO(70, 70, 70, 0.8))),
            ),
          ),
          const Text(
            "     Orcas",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(children: [
                  Row(
                    children: [
                      customContainerPods(context, "Label", "Second Label"),
                      customContainerPods(context, "Label", "Second Label"),
                      customContainerPods(context, "Label", "Second Label"),
                      customContainerPods(context, "Label", "Second Label"),
                      customContainerPods(context, "Label", "Second Label"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    customContainerPods(context, "Label", "Second Label"),
                    customContainerPods(context, "Label", "Second Label"),
                    customContainerPods(context, "Label", "Second Label"),
                    customContainerPods(context, "Label", "Second Label"),
                    customContainerPods(context, "Label", "Second Label"),
                  ])
                ]),
              )),
          const Text(
            "   Pods",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            height: 260,
            color: Color.fromARGB(255, 242, 228, 242),
            child: SingleChildScrollView(
                child: Column(
              children: [
                customContainerOrca(context, "Label", "Second Label"),
                customContainerOrca(context, "Label", "Second Label"),
                customContainerOrca(context, "Label", "Second Label"),
                customContainerOrca(context, "Label", "Second Label"),
                customContainerOrca(context, "Label", "Second Label"),
              ],
            )),
          )
        ],
      ),
    );
  }
}
