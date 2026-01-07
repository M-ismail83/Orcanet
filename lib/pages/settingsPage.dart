import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';
import 'package:orcanet/main.dart';
import 'package:flutter/widgets.dart';
import 'package:orcanet/services/utilityClass.dart';

class settingsPage extends StatefulWidget {
  const settingsPage({super.key, required this.currentColors});
  final Map<String, Color> currentColors;

  @override
  State<settingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<settingsPage> {
  // Variable to track the switch state
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          // --- Section 1: General ---
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text("General",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),

          // The simplest way to make a toggle item
          SwitchListTile(
            title: Text("Light Mode",
                style: TextStyle(color: widget.currentColors["text"])),
            secondary: const Icon(Icons.dark_mode),
            value: _isDark,
            onChanged: (bool value) {
              isDarkModeNotifier.value = !isDarkModeNotifier.value;

              setState(() {
                _isDark = value;
              });
            },
          ),

          ListTile(
            title: Text("Notifications",
                style: TextStyle(color: widget.currentColors["text"])),
            leading: const Icon(Icons.notifications),
            onTap: () {},
          ),

          const Divider(), // Adds a thin line

          // --- Section 2: Account ---
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text("Account",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),

          ListTile(
            title: Text("Email",
                style: TextStyle(color: widget.currentColors["text"])),
            subtitle: Text("${FirebaseAuth.instance.currentUser?.email}",
                style: TextStyle(
                    color: widget.currentColors["text"]
                        ?.withAlpha(175))), // Useful for showing info
            leading: const Icon(Icons.email),
            onTap: () {},
          ),

          ListTile(
            title: Text("Security",
                style: TextStyle(color: widget.currentColors["text"])),
            leading: const Icon(Icons.lock),
            onTap: () {},
          ),

          const Divider(),

          // --- Section 3: App Info ---
          ListTile(
            title: Text("Buy Us a Coffee",
                style: TextStyle(color: widget.currentColors["text"])),
            leading: const Icon(Icons.coffee),
            onTap: () async {
              final Uri url = Uri.parse("https://buymeacoffee.com/sailors");
              await Utilityclass().launchInBrowser(url);
            },
          ),
          ListTile(
            title: Text("App Version",
                style: TextStyle(color: widget.currentColors["text"])),
            subtitle: const Text("1.0.0"),
            leading: const Icon(Icons.info),
          ),

          ListTile(
            title: Text("Log Out",
                style: TextStyle(color: widget.currentColors["text"])),
            leading: const Icon(Icons.exit_to_app),
            iconColor: Colors.red, // Simple way to make it look dangerous
            textColor: Colors.red,
            onTap: () async {
              await logOut();
              await signOutWithGoogle();

              if (context.mounted) {
                Utilityclass().navigator(
                    context,
                    LoginScreen(
                      currentColors: widget.currentColors,
                    ));
              }
            },
          ),
        ],
      ),
    );
  }
}
