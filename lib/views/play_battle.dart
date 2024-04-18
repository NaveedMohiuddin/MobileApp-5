import 'dart:convert';

import 'package:battleships/models/game_mode.dart';
import 'package:battleships/models/games.dart';
import 'package:battleships/utils/sessionmanager.dart';
import 'package:battleships/utils/api_helper.dart';
import 'package:battleships/utils/app_theme.dart';
import 'package:flutter/material.dart';

late GameMode gameMode;
bool isLoading = true;
bool firstTimePlay = false;

// ignore: must_be_immutable
class PlayBattle extends StatefulWidget {
  Game game;
  PlayBattle({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  State<PlayBattle> createState() => _PlayGameState();
}

class _PlayGameState extends State<PlayBattle> {
  bool isLoggedIn = false;
  int _isSelected = 0;

  final List<int> _inActiveList = [0, 1, 2, 3, 4, 5, 6, 12, 18, 24, 30];

  Map<int, String> lables = {
    1: "1",
    2: "2",
    3: "3",
    4: "4",
    5: "5",
    6: "A",
    12: "B",
    18: "C",
    24: "D",
    30: "E",
  };

  Map<String, int> moves = {
    "A1": 7,
    "A2": 8,
    "A3": 9,
    "A4": 10,
    "A5": 11,
    "B1": 13,
    "B2": 14,
    "B3": 15,
    "B4": 16,
    "B5": 17,
    "C1": 19,
    "C2": 20,
    "C3": 21,
    "C4": 22,
    "C5": 23,
    "D1": 25,
    "D2": 26,
    "D3": 27,
    "D4": 28,
    "D5": 29,
    "E1": 31,
    "E2": 32,
    "E3": 33,
    "E4": 34,
    "E5": 35,
  };
  Map<dynamic, dynamic> movesIndex = {};

  @override
  void initState() {
    super.initState();
    movesIndex = ApiHelper.inverse(moves);

    _getGameMode(context, widget.game.id);

    if (widget.game.status == 3) {
      firstTimePlay = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: (firstTimePlay)
                ? const Text('Play Game')
                : const Text('Game History'),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.black,
                ),
                onPressed: () {
                  _getGameMode(context, widget.game.id);
                },
              )
            ]),
        // ignore: unnecessary_null_comparison
        body: isLoading || gameMode == null
            ? Container(
                color: Colors.white, // Add a semi-transparent background
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      // childAspectRatio: itemWidth / itemHeight,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                    ),
                    itemCount: 36,
                    itemBuilder: (context, index) {
                      List<Widget> gameIcons = [];
                      Widget gridIcon = Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: gameIcons,
                      );

                      if (gameMode.ships.contains(movesIndex[index])) {
                        //active ships
                        gameIcons
                            .add(const Icon(Icons.directions_boat_rounded));
                      }
                      if (gameMode.wrecks.contains(movesIndex[index])) {
                        //Wrecked
                        gameIcons.add(const Icon(
                          Icons.bubble_chart,
                          color: Colors.blue,
                        ));
                      }
                      if (gameMode.shots.contains(movesIndex[index]) &&
                          !gameMode.sunk.contains(movesIndex[index])) {
                        gameIcons.add(Icon(
                          Icons.whatshot,
                          color: Colors.red[500],
                        )); //whatshot
                      }

                      if (gameMode.sunk.contains(movesIndex[index])) {
                        gameIcons.add(const Icon(
                          Icons.check_circle_outline_outlined,
                          color: Colors.green,
                        )); //whatshot
                      }

                      if (_isSelected == index) {
                        gameIcons.add(const Icon(
                          Icons.whatshot,
                          color: Color.fromARGB(255, 244, 241, 54),
                        ));
                      }

                      return Card(
                        // color: AppTheme.deckBackgroundColor,
                        elevation: !_inActiveList.contains(index) ? 10 : 0,
                        shape: const RoundedRectangleBorder(
                            // borderRadius: 2,
                            ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: (!_inActiveList.contains(
                                            index) //disable for outer region
                                        &&
                                        !gameMode.sunk.contains(movesIndex[
                                            index]) //Disable  for sunk location
                                        &&
                                        !gameMode.shots.contains(movesIndex[
                                            index]) // disable for shots already made
                                        &&
                                        !gameMode.ships.contains(movesIndex[
                                            index]) // disable for own ships
                                        &&
                                        !gameMode.wrecks.contains(movesIndex[
                                            index]) // disable for shots for wrecked positions
                                        &&
                                        gameMode.status ==
                                            3 //Only when game is active
                                    )
                                    ? () {
                                        //print('Item ${index}');
                                        setState(() {
                                          _isSelected = index;
                                        });
                                      }
                                    : () {},
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      (_inActiveList.contains(index))
                                          ? (index != 0)
                                              ? Text('${lables[index]}')
                                              : Container()
                                          : gridIcon,
                                    ],
                                  ),
                                ),
                              ),

                              // Add circular progress loader here (e.g., CircularProgressIndicator)
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 25.0),
                  child: TextButton(
                    style: AppTheme.flatButtonStyle,
                    onPressed: () {
                      if (_isSelected != 0) {
                        _playShot(
                            context, widget.game.id, movesIndex[_isSelected]);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No shot selected!')),
                        );
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ]));
  }

  void _playShotText(BuildContext context, int id, String move) {
    //print('Game $id Shot $move');

    setState(() {
      _isSelected = 0;
    });
  }

  void _getGameModeTest(BuildContext context, int id, {showLoading = true}) {
    print('GetGameMode');
    GameMode gameStats = GameMode(
        id: 1,
        status: 1,
        position: 1,
        turn: 1,
        player1: 'test1',
        player2: 'test2',
        ships: ['A1', 'A2', 'A3', 'A4'],
        wrecks: ['A5'],
        shots: ['B2', 'A5', 'D3'],
        sunk: ['E2']);

    setState(() {
      gameMode = gameStats;
    });
  }

  Future<void> _getGameMode(BuildContext context, int id,
      {showLoading = true}) async {
    try {
      final token = await SessionManager.getSessionToken();

      String data = jsonEncode(<String, String>{});

      if (showLoading) {
        isLoading = true;
      }

      final response =
          await ApiHelper.callApiGet('/games/$id', data, token: token);
      final jsonRes = jsonDecode(response.body);

      print(jsonRes);

      if (response.statusCode == 200) {
        // Successful parse games
        if (jsonRes['status'] == 2 && firstTimePlay) {
          //Show won
          _showDialog('Sorry', 'You lost!', () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            firstTimePlay = false;
            Navigator.pop(context);
          });
        }

        GameMode newGameMode = GameMode.fromJson(jsonRes);
        setState(() {
          gameMode = newGameMode;
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fetching games failed!')),
        );
      }
    } catch (e) {
      // Handle exceptions, e.g., log the error or handle it appropriately.
      print('An error occurred: $e');
    }

    if (showLoading) {
      isLoading = false;
    }
  }

  Future<void> _playShot(BuildContext context, int id, String move) async {
    //print('Game $id Shot $move');

    setState(() {
      _isSelected = 0; //deselect
    });

    try {
      final token = await SessionManager.getSessionToken();

      String data = jsonEncode(<String, String>{"shot": move});

      // isLoading = true;

      final response =
          await ApiHelper.callApiPut('/games/$id', data, token: token);
      final jsonRes = jsonDecode(response.body);

      print(jsonRes);

      if (response.statusCode == 200) {
        // Successful parse games
        //mesage, sunk_ship, won
        String msg = '';
        if (jsonRes['sunk_ship']) {
          msg = 'Success Enemy Ship sunk!';
        } else {
          msg = 'Failed to hit enemy ship!';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Move added: $msg')),
        );

        if (jsonRes['won']) {
          //Show won
          _showDialog('Congratulations', 'You won!', () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            firstTimePlay = false;
            Navigator.pop(context);
          });
        }

        if (jsonRes['sunk_ship']) {
          //Add sunk ship
          setState(() {
            gameMode.sunk.add(move);
          });
        }

        //Refresh the game
        _getGameMode(context, id, showLoading: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Move not added!')),
        );
      }
    } catch (e) {
      // Handle exceptions, e.g., log the error or handle it appropriately.
      print('An error occurred: $e');
    }

    // isLoading = false;
  }

  void _showDialog(String t, String s, Function f) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(t),
          content: SizedBox(
            width: double.maxFinite,
            child: Text(s),
          ),
        );
      },
    ).then((value) {
      //print('Dialog closed');
      f();
    });
  }
}
