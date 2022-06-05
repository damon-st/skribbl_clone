import 'package:flutter/material.dart';

class FinalLeadBoard extends StatelessWidget {
  const FinalLeadBoard(
      {Key? key, required this.scoreboard, required this.winner})
      : super(key: key);
  final List scoreboard;
  final String winner;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(
          8,
        ),
        height: size.height,
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              primary: true,
              itemCount: scoreboard.length,
              itemBuilder: (context, index) {
                Map user = scoreboard[index];
                return ListTile(
                  title: Text(
                    user["nickname"],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 23,
                    ),
                  ),
                  trailing: Text(
                    "${user["points"]}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "$winner has won the game!",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
