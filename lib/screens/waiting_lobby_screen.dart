import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WawitingLobbyScreen extends StatefulWidget {
  const WawitingLobbyScreen({
    Key? key,
    required this.occupancy,
    required this.noOfPlayers,
    required this.lobbyName,
    required this.players,
  }) : super(key: key);

  final int occupancy;
  final int noOfPlayers;
  final String lobbyName;
  final List players;

  @override
  State<WawitingLobbyScreen> createState() => _WawitingLobbyScreenState();
}

class _WawitingLobbyScreenState extends State<WawitingLobbyScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: size.height * .03,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              "Waiting for ${widget.occupancy - widget.noOfPlayers} players to join",
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
          ),
          SizedBox(
            height: size.height * .06,
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: TextField(
              onTap: () {
                //copy room code
                Clipboard.setData(
                  ClipboardData(
                    text: widget.lobbyName,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Copied!",
                    ),
                  ),
                );
              },
              readOnly: true,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xffF5F5FA),
                  hintText: "Tap to copy room name!",
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  )),
            ),
          ),
          SizedBox(
            height: size.height * .1,
          ),
          const Text(
            "Players: ",
            style: TextStyle(fontSize: 18),
          ),
          Expanded(
            child: ListView.builder(
                primary: true,
                shrinkWrap: true,
                itemCount: widget.noOfPlayers,
                itemBuilder: (context, index) {
                  Map player = widget.players[index];
                  return ListTile(
                    leading: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    title: Text(
                      player["nickname"],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
