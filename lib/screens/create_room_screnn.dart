import 'package:flutter/material.dart';
import 'package:skribbl_clone/screens/paint_screnn.dart';
import 'package:skribbl_clone/widgets/custom_text_field.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final nameController = TextEditingController();
  final roomController = TextEditingController();

  final itemsRounds = ["2", "5", "10", "15"];
  final itemsPlayers = ["2", "3", "4", "5", "6", "7", "8"];

  String? _maxRoundsValue;
  String? _roomSizeValue;
  @override
  void dispose() {
    nameController.dispose();
    roomController.dispose();
    super.dispose();
  }

  void createRoom() {
    if (nameController.text.isNotEmpty &&
        roomController.text.isNotEmpty &&
        _maxRoundsValue != null &&
        _roomSizeValue != null) {
      Map data = {
        "nickname": nameController.text,
        "name": roomController.text,
        "occupancy": _roomSizeValue,
        "maxRounds": _maxRoundsValue,
      };
      Navigator.of(context).push(MaterialPageRoute(builder: (c) {
        return PaintScreen(data: data, screenFrom: "createRoom");
      }));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Completa los datos porfavor")));
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
              "Create Room",
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
            DropdownButton<String>(
              focusColor: const Color(0xffF5F6FA),
              items: itemsRounds
                  .map(
                    (String value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChangedDrowMenu,
              value: _maxRoundsValue,
              hint: const Text(
                "Select Max Rounds",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            DropdownButton<String>(
              focusColor: const Color(0xffF5F6FA),
              items: itemsPlayers
                  .map(
                    (String value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChangedDrowMenu2,
              value: _roomSizeValue,
              hint: const Text(
                "Select Room Size",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: createRoom,
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(
                  Size(size.width / 2.5, 50),
                ),
                backgroundColor: MaterialStateProperty.all(
                  Colors.blue,
                ),
              ),
              child: const Text(
                "Create",
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

  void onChangedDrowMenu(String? value) {
    if (value != null) {
      setState(() {
        _maxRoundsValue = value;
      });
    }
  }

  void onChangedDrowMenu2(String? value) {
    if (value != null) {
      setState(() {
        _roomSizeValue = value;
      });
    }
  }
}
