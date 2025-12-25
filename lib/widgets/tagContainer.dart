import 'package:flutter/material.dart';

Container tagContainer(String tagName, Map<String, Color> currentColors) {
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