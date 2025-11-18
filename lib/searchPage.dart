import 'package:flutter/material.dart';

class searchPage extends StatefulWidget {
  const searchPage({super.key, required this.currentColors});

  final Map<String, Color> currentColors;

  @override State<StatefulWidget> createState() => _searchPageState(); //what is this ughhhhhhhhhhh im so tireddd
}

class _searchPageState extends State<searchPage> {
  //Widget
  final List<String> _allTags = [
    'Flutter',
    'Dart',
    'Widgets',
    'Design',
    'Mobile',
    'Backend',
  ];

  Set<String> _selectedTags = {};

  bool _isSelected(String tag) {
    return _selectedTags.contains(tag);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: widget.currentColors['bg'],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.all(10.0), // This is the "padding on the outside"
              child: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        color: widget.currentColors['container'],
                        borderRadius: BorderRadius.circular(17.0)
                      ),

                      padding: const EdgeInsets.all(5.0),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextField(
                              cursorColor: widget.currentColors['hintText'],  
                              style: TextStyle(
                                color: widget.currentColors['text'],
                              ),

                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,

                              hintText: 'Type a message',
                              hintStyle: TextStyle(
                                color: widget.currentColors['hintText']
                              ),
                            ),
                          ),

                            Divider(
                              thickness: 2.0,
                              color: widget.currentColors["bg"],
                            ),

                            SizedBox(height: 4),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Wrap(
                                spacing: 8.0,
                                children: _allTags.map((tag){ 
                                  final isSelected = _isSelected(tag);

                                  return FilterChip(
                                      showCheckmark: false,
                                      label: Text(tag),
                                      selected: isSelected,
                                      selectedColor: widget.currentColors['acc1'],
                                      backgroundColor: widget.currentColors['container'],
                                      shape: StadiumBorder(
                                        side: BorderSide(
                                          color: widget.currentColors['acc1']!,
                                          width: 1.0,
                                        ),
                                      ),
                                      labelStyle: TextStyle(
                                        color: widget.currentColors['text']!,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      onSelected: (bool selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedTags.add(tag);
                                          }
                                          else {
                                            _selectedTags.remove(tag);
                                          }
                                        });
                                      },
                                      );
                                }).toList()
                              ),
                            ),
                          ]
                      )
                  ),
                  SizedBox(height: 10),
                ]
              )
          )
        ],
      )
    );
  }}