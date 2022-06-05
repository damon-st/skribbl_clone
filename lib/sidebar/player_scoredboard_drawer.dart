import 'package:flutter/material.dart';

class PlayerScore extends StatelessWidget {
  const PlayerScore({Key? key, required this.userData}) : super(key: key);

  final List userData;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: SizedBox(
          height: double.maxFinite,
          child: ListView.builder(
              itemCount: userData.length,
              itemBuilder: (context, index) {
                Map user = userData[index];
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
              }),
        ),
      ),
    );
  }
}
