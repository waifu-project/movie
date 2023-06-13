import 'dart:math';

import 'package:command_palette/command_palette.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_lorem/flutter_lorem.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ThemeMode themeMode = ThemeMode.light;
  String _currentUser = "";
  Color? color;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      themeMode: themeMode,
      home: Builder(
        builder: (context) {
          return CommandPalette(
            config: CommandPaletteConfig(
              // define a custom query
              // filter: (query, allActions) {

              // },
              style: CommandPaletteStyle(
                actionLabelTextAlign: TextAlign.left,
                textFieldInputDecoration: InputDecoration(
                  hintText: "Enter Something",
                  contentPadding: EdgeInsets.all(16),
                ),
              ),

              // Setting custom keyboard shortcuts
              // openKeySet: SingleActivator(LogicalKeyboardKey.keyP, meta: true),
              // closeKeySet: LogicalKeySet(
              //   LogicalKeyboardKey.control,
              //   LogicalKeyboardKey.keyC,
              // ),

              showInstructions: true,
            ),
            actions: [
              CommandPaletteAction.single(
                label: "Close Command Palette",
                description: "Closes the command palette",
                shortcut: ["esc"],
                leading: Icon(Icons.close),
                onSelect: () {
                  Navigator.of(context).pop();
                },
              ),
              CommandPaletteAction.nested(
                id: "change-theme", // ids can be strings
                label: "Change Theme",
                description: "Change the color theme of the app",
                shortcut: ["ctrl", "t"],
                leading: Icon(Icons.format_paint),
                childrenActions: [
                  CommandPaletteAction.single(
                    label: "Light",
                    onSelect: () {
                      setState(() {
                        themeMode = ThemeMode.light;
                      });
                    },
                  ),
                  CommandPaletteAction.single(
                    label: "Dark",
                    onSelect: () {
                      setState(() {
                        themeMode = ThemeMode.dark;
                      });
                    },
                  ),
                ],
              ),
              CommandPaletteAction.nested(
                id: 1, // or numbers (or really anything...)
                label: "Set User",
                shortcut: ["ctrl", "shift", "s"],
                leading: Icon(Icons.account_circle),
                childrenActions: [
                  ...["Maria", "Kurt", "Susanne", "Larissa", "Simon", "Admin"]
                      .map(
                    (e) => CommandPaletteAction.single(
                      label: e,
                      onSelect: () => setState(() {
                        _currentUser = e;
                        color = Colors.transparent;
                      }),
                    ),
                  ),
                ],
              ),
              if (_currentUser == "Admin")
                CommandPaletteAction.single(
                  label: "Some sorta super secret admin action",
                  onSelect: () {
                    setState(() {
                      color = Color(Random().nextInt(0xFFFFFF)).withAlpha(255);
                    });
                  },
                ),
              if (_currentUser.isNotEmpty)
                CommandPaletteAction.single(
                  label: "Log out",
                  shortcut: ["l", "o"],
                  description: "Logs the current user out",
                  onSelect: () {
                    setState(() {
                      _currentUser = "";
                      color = Colors.transparent;
                    });
                  },
                ),
              // for (int i = 0; i < 1000; i++)
              //   CommandPaletteAction(
              //     leading: Text("$i"),
              //     label: lorem(paragraphs: 1, words: 3),
              //     actionType: CommandPaletteActionType.single,
              //     onSelect: () {},
              //   )
            ],
            child: Builder(
              builder: (context) {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Welcome to the Command Palette example!"),
                        Text(
                          "Press ${defaultTargetPlatform == TargetPlatform.macOS ? 'Cmd' : 'Ctrl'}+K to open",
                        ),
                        TextButton(
                          child: Text("Or Click Here!"),
                          onPressed: () {
                            CommandPalette.of(context).open();
                          },
                        ),
                        if (_currentUser.isNotEmpty)
                          Text("Current User: $_currentUser")
                        else
                          TextButton(
                            child: Text("Set User"),
                            onPressed: () {
                              CommandPalette.of(context).openToAction(1);
                            },
                          ),
                        TextButton(
                          child: Text("Change Theme"),
                          onPressed: () {
                            CommandPalette.of(context)
                                .openToAction("change-theme");
                          },
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 1000),
                          width: 50,
                          height: 50,
                          color: color,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
