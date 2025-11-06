import 'package:flutter/material.dart';

class makePostPage extends StatefulWidget {
  const makePostPage({super.key, required this.currentColors});

  final Map<String, Color> currentColors;

  @override State<StatefulWidget> createState() => _makePostPageState(); //what is this ughhhhhhhhhhh im so tireddd
}

class _makePostPageState extends State<makePostPage> {
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
              padding: const EdgeInsets.all(16.0), // This is the "padding on the outside"
              child: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent)
                      ),
                      padding: const EdgeInsets.all(5.0),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownMenu(
                            width: 300,
                            // 2. To style the text field (the "box")
                            inputDecorationTheme: InputDecorationTheme(
                              hintStyle: TextStyle(color: widget.currentColors['hintText']),
                              // Set the background color of the text field
                              fillColor: widget.currentColors['container'],
                              filled: true,
                              // Apply a border radius
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none, // No outline border
                              ),
                            ),
                            hintText: "Select a Pod",

                            // 3. To style the dropdown list that appears
                            menuStyle: MenuStyle(
                              // Set the background color of the menu list
                              backgroundColor: WidgetStateProperty.all(widget.currentColors['container']),
                              // Apply a border radius to the menu list
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )),
                            ),

                            dropdownMenuEntries: <DropdownMenuEntry<Color>>[
                              DropdownMenuEntry(value: Colors.red, label: 'Orcas'),
                              DropdownMenuEntry(value: Colors.blue, label: 'Dolphins'),
                              DropdownMenuEntry(value: Colors.green, label: 'Whales'),
                              DropdownMenuEntry(value: Colors.amber, label: 'Students')
                            ],

                            onSelected: (Color? selectedColor) {
                              // Your logic here
                            },

                          ),
                            SizedBox(height: 10),
                            Divider(
                              thickness: 1.0,
                              color: Colors.grey,
                            ),
                            Text(
                              'Tags:',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: widget.currentColors['text']),
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
                                      backgroundColor: widget.currentColors['bg'],
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
                  Container(
                      padding: const EdgeInsets.all(10.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: widget.currentColors['container'],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: widget.currentColors['container']!, width: 1.0),),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Title',
                            labelStyle: TextStyle(color: widget.currentColors['text'], fontWeight: FontWeight.bold),
                            hintText: 'What is your post about?',
                            hintStyle: TextStyle(color: widget.currentColors['hintText'])
                          ),
                        ),
                        Divider(),
                        TextField(
                          minLines: 1,
                          maxLines: 8,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Content',
                              labelStyle: TextStyle(color: widget.currentColors['text'], fontWeight: FontWeight.bold),
                              hintText: 'What is your post about?',
                              hintStyle: TextStyle(color: widget.currentColors['hintText'])
                          ),
                        )
                      ],
                    )
                  )
                ]
              )
          )


          //container (column)
          //  text field for title (col)
          //  divider (col)
          //  text field for post (col)
          //  divider (col)
          //  (row as a child) SAVE and CANCEL

          // en altta da navigation bar dı sanırsam adı ondan
          //şimdi çok uykum geldi yatcam
        ],
      )
    );
  }}