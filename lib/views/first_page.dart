import 'package:battleships/controllers/home_page_controller.dart';
import 'package:battleships/models/games.dart';
import 'package:flutter/material.dart';
import 'package:battleships/utils/sessionmanager.dart';
import 'package:battleships/views/normal_game.dart';
import 'package:battleships/views/login_screen.dart';
import 'package:battleships/views/complete_games.dart';
import 'package:battleships/views/new_game_ai.dart';

bool isLoading = false;
Game gameDemo = Game(
    id: 4, player1: 'test1', player2: 'test2', position: 1, status: 1, turn: 1);

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<FirstPage> {
  int _selectedIndex = 0;
  String sessionUser = '';

  final HomePageController myController = HomePageController();

  void _changeSelection(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    _getUser();
  }

  Future<void> _getUser() async {
    final user = await SessionManager.getSessionUser();
    if (mounted) {
      setState(() {
        sessionUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Battleships"), actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
            ),
            onPressed: () {
              myController.updateGames();
            },
          )
        ]),
        drawer: MyDrawer(
            sessionUser: sessionUser,
            selected: _selectedIndex,
            changeSelection: _changeSelection,
            controller: myController),
        body: switch (_selectedIndex) {
          0 => NormalGame(controller: myController),
          1 => const NewGameAI(aiOpponent: ''),
          2 => const NewGameAI(aiOpponent: 'random'),
          3 => CompleteGames(),
          _ => NormalGame(controller: myController)
        });
  }
}

class MyDrawer extends StatelessWidget {
  final String sessionUser;
  final int selected;
  final void Function(int index) changeSelection;
  final HomePageController controller;

  const MyDrawer({
    required this.sessionUser,
    required this.selected,
    required this.changeSelection,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Battleships",
                      textAlign: TextAlign.justify,
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Logged in as $sessionUser",
                      style: const TextStyle(color: Colors.white),
                    )
                  ])),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("New Game"),
            selected: selected == 1,
            onTap: () {
              changeSelection(0);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NewGameAI(aiOpponent: '')),
              ).then((value) => {controller.updateGames()});
            },
          ),
          ListTile(
            leading: const Icon(Icons.computer),
            title: const Text("New Game (AI)"),
            selected: selected == 2,
            onTap: () {
              changeSelection(0);
              Navigator.pop(context);
              _setAI(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("Show completed games"),
            selected: selected == 3,
            onTap: () {
              changeSelection(0);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CompleteGames()),
              ).then((value) => {controller.updateGames()});
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            selected: selected == 4,
            onTap: () {
              _doLogout(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _doLogout(context) async {
    // get rid of the session token
    await SessionManager.clearSession();

    // if (!mounted) return;

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ));
  }

  onReturn(BuildContext context) {}

  void _setAI(BuildContext context) {
    print('Choose AI...');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select an Option'),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildOptionItem('Random', context, 'random'),
                _buildOptionItem('Perfect', context, 'perfect'),
                _buildOptionItem('One Ship (A1)', context, 'oneship'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(
      String option, BuildContext context, String aiOpponent) {
    return ListTile(
      title: Text(option),
      onTap: () {
        print('Selected: $option');
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NewGameAI(aiOpponent: aiOpponent)),
        ).then((value) => {controller.updateGames()});
      },
    );
  }
}
