import 'package:flutter/material.dart';
import 'package:skribbl_clone/screens/paint_screnn.dart';
import 'package:skribbl_clone/widgets/custom_text_field.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final nameController = TextEditingController();
  final roomController = TextEditingController();

  final itemsRounds = ["2", "5", "10", "15"];
  final itemsPlayers = ["2", "3", "4", "5", "6", "7", "8"];

  @override
  void dispose() {
    nameController.dispose();
    roomController.dispose();
    super.dispose();
  }

  void joinRoom() {
    if (nameController.text.isNotEmpty && roomController.text.isNotEmpty) {
      Map data = {
        "nickname": nameController.text,
        "name": roomController.text,
      };

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (c) {
            return PaintScreen(data: data, screenFrom: "joinRoom");
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Join Room",
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            SizedBox(
              height: size.height * .08,
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: CustomTextField(
                nameController: nameController,
                hintText: "Enter your name",
              ),
            ),
            SizedBox(
              height: size.height * .02,
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: CustomTextField(
                nameController: roomController,
                hintText: "Enter Room Name",
              ),
            ),
            SizedBox(
              height: size.height * .02,
            ),
            ElevatedButton(
              onPressed: joinRoom,
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(
                  Size(size.width / 2.5, 50),
                ),
                backgroundColor: MaterialStateProperty.all(
                  Colors.blue,
                ),
              ),
              child: const Text(
                "Join",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
