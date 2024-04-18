import 'dart:convert';

import 'package:battleships/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:battleships/utils/sessionmanager.dart';
import 'package:battleships/utils/api_helper.dart';

bool isLoading = false;

class NewGameAI extends StatefulWidget {
  final String aiOpponent;
  const NewGameAI({super.key, required this.aiOpponent});

  @override
  State<NewGameAI> createState() => _NewGameAIState();
}

class _NewGameAIState extends State<NewGameAI> {
  bool isLoggedIn = false;

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

  Map<dynamic, dynamic> moves = {
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

  Map inverse(Map f) {
    return f.map((k, v) => MapEntry(v, k));
  }

  Map<dynamic, dynamic> moveIndex = {};

  Map<int, String> myShips = {};
  List<int> selectedIndexList = [];

  @override
  void initState() {
    super.initState();
    moveIndex = inverse(moves);
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldMessengerKey,
        appBar: AppBar(
          title: const Text('Place Ships'),
        ),
        body: Column(children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                // childAspectRatio: itemWidth / itemHeight,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
              itemCount: 36,
              itemBuilder: (context, index) {
                return Card(
                  color: (selectedIndexList.contains(index))
                      ? Colors.blueGrey[500]
                      : Colors.white,
                  elevation: !_inActiveList.contains(index) ? 10 : 0,
                  shape: const RoundedRectangleBorder(
                      // borderRadius: 2,
                      ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: (!_inActiveList.contains(index))
                              ? () {
                                  print('Item ${index}');

                                  if (!mounted) return;
                                  setState(() {
                                    if (myShips.containsKey(index)) {
                                      myShips.remove(index);
                                      selectedIndexList.remove(index);
                                    } else if (myShips.length < 5) {
                                      myShips.addAll({index: moveIndex[index]});
                                      selectedIndexList.add(index);
                                    }
                                  });

                                  // print(myShips);
                                  // print(selectedIndexList);
                                }
                              : null,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                (_inActiveList.contains(index))
                                    ? (index != 0)
                                        ? Text('${lables[index]}')
                                        : Container()
                                    : (selectedIndexList.contains(index))
                                        ? Icon(Icons.directions_boat_rounded)
                                        : Container(), //Icon(Icons.add),
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
            padding: const EdgeInsets.fromLTRB(1, 1, 1, 25.0),
            child: TextButton(
              style: AppTheme.flatButtonStyle,
              onPressed: () {
                if (selectedIndexList.length == 5) {
                  _addNewGame(selectedIndexList);
                } else {
                  print('5 not selected..');
                  // _scaffoldMessengerKey.currentState?.showSnackBar(
                  // 	const SnackBar(content: Text('Please add 5 ships!')),
                  // );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please add 5 ships!')),
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

  void _addNewGame(List<int> activeList) async {
    //Send request
    try {
      //Convet to cords
      List<String> ships = [];
      for (int i in activeList) {
        ships.add(moveIndex[i]);
      }

      final token = await SessionManager.getSessionToken();

      Map<String, dynamic> requestBody = {'ships': ships};

      //If opponent is AI
      if (widget.aiOpponent.isNotEmpty) {
        requestBody["ai"] = widget.aiOpponent;
      }

      String data = jsonEncode(requestBody);

      isLoading = true;

      final response = await ApiHelper.callApi('/games', data, token: token);
      final jsonRes = jsonDecode(response.body);

      print(jsonRes);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ships added successfully!')),
        );

        //Go back
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error Adding game!')),
        );
      }
    } catch (e) {
      // Handle exceptions, e.g., log the error or handle it appropriately.
      print('An error occurred: $e');
    }

    isLoading = false;
  }
}
