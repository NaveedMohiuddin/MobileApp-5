import 'dart:convert';
import 'package:battleships/models/games.dart';
import 'package:battleships/utils/api_helper.dart';
import 'package:battleships/utils/sessionmanager.dart';
import 'package:battleships/views/play_battle.dart';
import 'package:flutter/material.dart';

bool isLoading = false;
List<Game> games = [];

class CompleteGames extends StatefulWidget {
  CompleteGames({Key? key}) : super(key: key);

  @override
  State<CompleteGames> createState() => _CompleteGamesState();
}

class _CompleteGamesState extends State<CompleteGames> {
  bool isLoggedIn = false;
  List<Game> games = [];

  @override
  void initState() {
    super.initState();

    updateGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Completed Games'), actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              updateGames();
            },
          )
        ]),
        body: isLoading
            ? Container(
                color: Colors.white, // Add a semi-transparent background
                child: Center(
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
                  String gameStatusMsg = '';
                  int gameTurn = games[index].turn;
                  int gamePosition = games[index].position;

                  if (gameStatus == 0) {
                    gameMsg = 'Waiting for Opponent';
                    gameStatusMsg = 'matchmaking';
                  } else if (gameStatus == 1) {
                    gameMsg = 'Player1 Won';
                    if (gamePosition == 2) {
                      gameStatusMsg = 'gameLost';
                    } else {
                      gameStatusMsg = 'gameWon';
                    }
                  } else if (gameStatus == 2) {
                    gameMsg = 'Player 2 won';
                    if (gamePosition == 1) {
                      gameStatusMsg = 'gameLost';
                    } else {
                      gameStatusMsg = 'gameWon';
                    }
                  } else if (gameStatus == 3) {
                    gameMsg =
                        '${games[index].player1} vs ${games[index].player2}';

                    if (gameTurn == gamePosition) {
                      gameStatusMsg = 'myTurn';
                    } else {
                      gameStatusMsg = 'opponentTurn';
                    }
                  }

                  String item = '#$gameID $gameMsg';
                  return (games[index].status != 3 || games[index].status == 0)
                      ? ListTile(
                          title: Text('$item'),
                          trailing: Text('$gameStatusMsg'),
                          onTap: () {
                            if (games[index] != 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PlayBattle(game: games[index])),
                              ).then((value) => {updateGames()});
                            }
                          },
                        )
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
      print('An error occurred: $e');
    }

    isLoading = false;
  }
}

// Declare a public interface for _CompleteGamesState
abstract class CompleteGamesInterface {
  void updateGames(BuildContext context);
}
