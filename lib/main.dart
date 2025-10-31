import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/firebase_options.dart';
import 'package:orcanet/feedAndPodsPage.dart';
import 'package:orcanet/feedPage.dart';
import 'package:orcanet/makePostPage.dart';
import 'package:orcanet/utilityClass.dart';

final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(true);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier, 
      builder: (context, isDarkMode, _){
        final currentColors = isDarkMode ? Utilityclass.darkModeColor : Utilityclass.ligthModeColor;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: currentColors['bg'],
            appBarTheme: AppBarTheme(
              backgroundColor: currentColors['bar'],
              iconTheme: IconThemeData(color: currentColors['text']),
              titleTextStyle: TextStyle(
                color: currentColors['text'],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          home: feedPage(currentColors: currentColors),
        );
      }
      );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  var colors = <Color>{Colors.red, Colors.green, Colors.blue};

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: MediaQuery.sizeOf(context).height/3,
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                color: colors.elementAt(_counter%3)
              ),

            ),
            Container(
                height: MediaQuery.sizeOf(context).height/3,
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                    color: colors.elementAt((_counter+1)%3)
                )
            ),
            Container(
                height: MediaQuery.sizeOf(context).height/3,
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                    color: colors.elementAt((_counter+2)%3)
                )
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
