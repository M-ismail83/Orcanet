import 'package:flutter/material.dart';

class makePostPage extends StatefulWidget {
  const makePostPage({super.key});

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
      backgroundColor: Color.fromRGBO(60, 49, 43, 1),
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
                              // Set the background color of the text field
                              fillColor: Color.fromRGBO(240, 232, 230, 1),
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
                              backgroundColor: WidgetStateProperty.all(Color.fromRGBO(240, 232, 230, 1)),
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
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color.fromRGBO(240, 232, 230, 1)),
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
                                      selectedColor: Color.fromRGBO(189, 76, 237, 1),
                                      backgroundColor: Color.fromRGBO(60, 49, 43, 1),
                                      shape: StadiumBorder(
                                        side: BorderSide(
                                          color: Color.fromRGBO(189, 76, 237, 1),
                                          width: 1.0,
                                        ),
                                      ),
                                      labelStyle: TextStyle(
                                        color: Color.fromRGBO(240, 232, 230, 1),
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
                        color: Color.fromRGBO(92, 81, 68, 1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color.fromRGBO(92, 81, 68, 1), width: 1.0),),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Title',
                            labelStyle: TextStyle(color: Color.fromRGBO(240, 232, 230, 1), fontWeight: FontWeight.bold),
                            hintText: 'What is your post about?',
                            hintStyle: TextStyle(color: Color.fromRGBO(240, 232, 230, 0.5))
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
                              labelStyle: TextStyle(color: Color.fromRGBO(240, 232, 230, 1), fontWeight: FontWeight.bold),
                              hintText: 'What is your post about?',
                              hintStyle: TextStyle(color: Color.fromRGBO(240, 232, 230, 0.5))
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