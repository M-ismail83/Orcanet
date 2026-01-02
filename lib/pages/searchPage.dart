import 'package:flutter/material.dart';
import 'package:sodium_libs/sodium_libs.dart';

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
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                        color: widget.currentColors['container'],
                        borderRadius: BorderRadius.circular(17.0),
                        border: BoxBorder.all(
                          color: widget.currentColors['bg']!.withAlpha(160),
                          width: 3,
                        ),
                      ),

                      padding: const EdgeInsets.all(7.0),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextField(
                              textCapitalization: TextCapitalization.words,
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: widget.currentColors['hintText'],
                              cursorWidth: 2.5,
                              style: TextStyle(
                                color: widget.currentColors['text'],
                                fontSize: 20,
                                fontWeight: FontWeight.w500
                              ),

                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left:1, right:1),
                                child: Icon(Icons.search, color: widget.currentColors['hintText'], size: 35),
                                ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,

                              hintText: 'Search for Orcas...',
                              hintStyle: TextStyle(
                                fontSize: 20,
                                color: widget.currentColors['hintText'],
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ),

                            Divider(
                              thickness:2,
                              color: widget.currentColors["bar"],
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
                                          color: widget.currentColors['acc1border']!,
                                          width: 3.0,
                                        ),
                                      ),
                                      labelStyle: TextStyle(
                                        color: widget.currentColors['text']!,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
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