import 'dart:convert';

import 'package:battleships/controllers/home_page_controller.dart';
import 'package:battleships/models/games.dart';
import 'package:battleships/utils/api_helper.dart';
import 'package:battleships/utils/sessionmanager.dart';
import 'package:battleships/views/play_battle.dart';
import 'package:flutter/material.dart';

bool isLoading = false;
List<Game> games = [];

class NormalGame extends StatefulWidget {
  final HomePageController controller;

  const NormalGame({Key? key, required this.controller}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<NormalGame> createState() => _NormalGameState(controller: controller);
}

class _NormalGameState extends State<NormalGame> {

  HomePageController controller;
  _NormalGameState({required this.controller}) {
    controller.updateGames = updateGames;
  }

  bool isLoggedIn = false;
  List<Game> games = [];

  @override
  void initState() {
    super.initState();
    controller.ctx = context;
    updateGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : ListView.builder(
                itemCount: games.length,
                itemBuilder: (context, index) {
                  //Prep
                  int gameID = games[index].id;
                  String gameMsg = '';
                  int gameStatus = games[index].status;
                  String battleStatusMsg = '';
                  int gameTurn = games[index].turn;
                  int gamePosition = games[index].position;

                  if (gameStatus == 0) {
                    gameMsg = 'Waiting for Opponent';
                    battleStatusMsg = 'matchmaking';
                  } else if (gameStatus == 1) {
                    gameMsg = 'Player1 Won';
                    if (gamePosition == 2) {
                      battleStatusMsg = 'GameLost :(';
                    } else {
                      battleStatusMsg = 'GameWon :)';
                    }
                  } else if (gameStatus == 2) {
                    gameMsg = 'Player 2 won';
                    if (gamePosition == 1) {
                      battleStatusMsg = 'gameLost :(';
                    } else {
                      battleStatusMsg = 'gameWon :)';
                    }
                  } else if (gameStatus == 3) {
                    gameMsg =
                        '${games[index].player1} vs ${games[index].player2}';

                    if (gameTurn == gamePosition) {
                      battleStatusMsg = 'myTurn';
                    } else {
                      battleStatusMsg = 'Opponent Turn';
                    }
                  }

                  String item = '#$gameID $gameMsg';

                  return (games[index].status == 0 || games[index].status == 3)
                      ? Dismissible(
                          key: Key('${games[index].id}'),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            // // Remove the item from the data source
                            _deleteGame(context, games[index].id, index);
                          },
                          child: ListTile(
                            title: Text(item),
                            trailing: Text(battleStatusMsg),
                            onTap: () {
                              if (games[index].status != 0 &&
                                  (gameTurn == gamePosition)) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PlayBattle(game: games[index])),
                                ).then((value) => {updateGames()});
                              }
                            },
                          ))
                      : Container();
                }));
  }

  void updateGamesTest() {
    List<Game> newGames = [
      Game(
          id: 3,
          player1: 'test1',
          player2: 'test2',
          position: 1,
          status: 0,
          turn: 1),
      Game(
          id: 4,
          player1: 'test1',
          player2: 'test2',
          position: 1,
          status: 1,
          turn: 1)
    ];

    setState(() {
      games = newGames;
    });
  }

  Future<void> updateGames() async {
    try {
      final token = await SessionManager.getSessionToken();

      String data = jsonEncode(<String, String>{});

      isLoading = true;

      final response = await ApiHelper.callApiGet('/games', data, token: token);
      final jsonRes = jsonDecode(response.body);

      print(jsonRes);

      if (response.statusCode == 200) {
        // Successful parse games
        List<Game> newGames = [];
        final jsonGames = jsonRes['games'];

        for (var i = 0; i < jsonGames.length; i++) {
          newGames.add(Game.fromJson(jsonGames[i]));
        }

        if (!mounted) return;

        setState(() {
          games = newGames;
        });
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        // const SnackBar(content: Text('Fetching games failed!')),
        // );
      }
    } catch (e) {
      // Handle exceptions, e.g., log the error or handle it appropriately.
      //print('An error occurred: $e');
    }

    isLoading = false;
  }

  Future<void> _deleteGame(BuildContext context, int id, int index) async {
    try {
      final token = await SessionManager.getSessionToken();

      String data = jsonEncode(<String, String>{});

      // isLoading = true;

      final response =
          await ApiHelper.callApiDelete('/games/$id', data, token: token);

      //print(jsonRes);

      if (response.statusCode == 200) {
        // Successful parse games
        setState(() {
          games.removeAt(index);
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        // const SnackBar(content: Text('Game deeted!')),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleting games failed!')),
        );
      }
    } catch (e) {
      // Handle exceptions, e.g., log the error or handle it appropriately.
      print('An error occurred: $e');
    }

    // isLoading = false;
  }
}
