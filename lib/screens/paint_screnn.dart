import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:skribbl_clone/screens/final_leadborad.dart';
import 'package:skribbl_clone/screens/home_screnn.dart';
import 'package:skribbl_clone/screens/waiting_lobby_screen.dart';
import 'package:skribbl_clone/sidebar/player_scoredboard_drawer.dart';
import 'package:skribbl_clone/utils/my_custom_painter.dart';
import 'package:skribbl_clone/utils/touch_poinst.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  const PaintScreen({Key? key, required this.data, required this.screenFrom})
      : super(key: key);

  final Map data;
  final String screenFrom;

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _soket;

  Map dataOfRoom = {};

  List<TouchPoinst> points = [];

  StrokeCap strokeType = StrokeCap.round;

  Color selectColor = Colors.black;

  double opacity = 1.0;

  double strokeWidth = 2.0;

  List<Widget> textBlanckWidget = [];

  final _scrollController = ScrollController();

  List<Map> messages = [];

  final messageController = TextEditingController();

  int guessedUserCtr = 0;

  Timer? _timer;

  final ValueNotifier<int> _start = ValueNotifier(60);

  var scafolKey = GlobalKey<ScaffoldState>();

  List scoreboard = [];

  bool isTextInputReadOnly = false;

  int maxPoints = 0;

  String winner = "";
  bool isShowFinalLeaderBoard = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      connect();
    });
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_start.value == 0) {
        _soket.emit("change-turn", dataOfRoom["name"]);
        _timer?.cancel();
      } else {
        _start.value--;
      }
    });
  }

  void renderTextBlank(String text) {
    textBlanckWidget.clear();
    for (var i = 0; i < text.length; i++) {
      textBlanckWidget.add(const Text(
        "_",
        style: TextStyle(
          fontSize: 30,
        ),
      ));
    }
  }

  //Scoket io client connection
  void connect() {
    _soket = IO.io("http://192.168.1.6:3000", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    _soket.connect();

    if (widget.screenFrom == "createRoom") {
      _soket.emit("create-game", widget.data);
    } else {
      _soket.emit("join-game", widget.data);
    }

    //listen to scoket
    _soket.onConnect((data) {
      print("coneecte");

      _soket.on("updateRoom", (roomData) {
        print(roomData);
        if (!mounted) return;
        setState(() {
          renderTextBlank(roomData["word"]);
          dataOfRoom = roomData;
          scoreboard.clear();
          scoreboard.addAll(dataOfRoom["players"]);
        });
        if (roomData["isJoin"] != true) {
          // start the timer
          startTimer();
        }
      });

      _soket.on("points", (point) {
        if (point["details"] != null) {
          if (!mounted) return;
          setState(() {
            points.add(
              TouchPoinst(
                paint: Paint()
                  ..color = selectColor.withOpacity(opacity)
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..strokeWidth = strokeWidth,
                points: Offset((point['details']['dx']).toDouble(),
                    (point['details']['dy']).toDouble()),
              ),
            );
          });
        }
      });

      _soket.on("updateScore", (roomData) {
        if (!mounted) return;
        scoreboard.clear();
        setState(() {
          scoreboard.addAll(roomData["players"]);
        });
      });

      _soket.on("show-leaderboard", (roomPlayers) {
        if (!mounted) return;
        scoreboard.clear();
        scoreboard.addAll(roomPlayers);
        for (var i = 0; i < scoreboard.length; i++) {
          if (maxPoints < int.parse(scoreboard[i]["points"].toString())) {
            winner = scoreboard[i]["nickname"];
            maxPoints = int.parse(scoreboard[i]["points"].toString());
          }
        }
        _timer?.cancel();
        isShowFinalLeaderBoard = true;
        setState(() {});
      });

      _soket.on("color-change", (colorString) {
        int value = int.parse(colorString, radix: 16);
        Color otherColor = Color(value);
        if (!mounted) return;
        setState(() {
          selectColor = otherColor;
        });
      });

      _soket.on("stroke-with", (value) {
        if (!mounted) return;
        setState(() {
          strokeWidth = double.parse(value.toString());
        });
      });

      _soket.on("clean-screen", (data) {
        if (!mounted) return;
        setState(() {
          points.clear();
        });
      });

      _soket.on("msg", (data) {
        if (!mounted) return;
        setState(() {
          messages.add(data);
          guessedUserCtr = data["guessedUserCtr"];
        });
        if (guessedUserCtr == dataOfRoom["players"].length - 1) {
          _soket.emit("change-turn", dataOfRoom["name"]);
        }
        try {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 40,
            duration: const Duration(milliseconds: 200),
            curve: Curves.linear,
          );
        } catch (e) {}
      });

      _soket.on("change-turn", (data) {
        String oldWord = dataOfRoom["word"];
        if (!mounted) return;
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            dataOfRoom = data;
            renderTextBlank(data["word"]);
            guessedUserCtr = 0;
            _start.value = 60;
            points.clear();
            isTextInputReadOnly = false;
          });
        });
        showDialog(
            context: context,
            builder: (context) {
              Future.delayed(const Duration(seconds: 3), () {
                _timer?.cancel();
                startTimer();
                Navigator.pop(context);
              });
              return AlertDialog(
                title: Center(
                  child: Text("Word was $oldWord"),
                ),
              );
            });
      });

      _soket.on("closeInput", (data) {
        _soket.emit("updateScore", widget.data["name"]);
        if (!mounted) return;
        setState(() {
          isTextInputReadOnly = true;
        });
      });

      _soket.on("user-disconnected", (data) {
        if (!mounted) return;

        scoreboard.clear();
        scoreboard.addAll(data.players);
        setState(() {});
      });

      _soket.on("notCorrectGame", (data) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (c) => const HomeScreen()),
            (r) => false);
      });
    });
  }

  void selectedColor() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: BlockPicker(
                  pickerColor: selectColor,
                  onColorChanged: (color) {
                    String colorString = color.toString();
                    String valueString =
                        colorString.split("(0x")[1].split(")")[0];
                    print(valueString);
                    print(colorString);
                    Map data = {
                      "color": valueString,
                      "roomName": dataOfRoom["name"],
                    };
                    _soket.emit("color-change", data);
                  }),
            ),
            title: const Text(
              "Choose Color",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cerrar",
                ),
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    _soket.dispose();
    _scrollController.dispose();
    messageController.dispose();
    _timer?.cancel();
    _start.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      key: scafolKey,
      drawer: PlayerScore(userData: scoreboard),
      backgroundColor: Colors.white,
      body: dataOfRoom.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : dataOfRoom["isJoin"] != true
              ? isShowFinalLeaderBoard
                  ? FinalLeadBoard(
                      winner: winner,
                      scoreboard: scoreboard,
                    )
                  : Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: size.width,
                              height: size.height * .55,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  if (dataOfRoom["turn"]["nickname"] !=
                                      widget.data["nickname"]) {
                                  } else {
                                    _soket.emit("paint", {
                                      "details": {
                                        "dx": details.localPosition.dx,
                                        "dy": details.localPosition.dy,
                                      },
                                      "roomName": widget.data["name"],
                                    });
                                  }
                                },
                                onPanStart: (details) {
                                  if (dataOfRoom["turn"]["nickname"] !=
                                      widget.data["nickname"]) {
                                  } else {
                                    _soket.emit("paint", {
                                      "details": {
                                        "dx": details.localPosition.dx,
                                        "dy": details.localPosition.dy,
                                      },
                                      "roomName": widget.data["name"],
                                    });
                                  }
                                },
                                onPanEnd: (details) {
                                  if (dataOfRoom["turn"]["nickname"] !=
                                      widget.data["nickname"]) {
                                  } else {
                                    _soket.emit("paint", {
                                      "details": null,
                                      "roomName": widget.data["name"],
                                    });
                                  }
                                },
                                child: SizedBox.expand(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(
                                        20,
                                      ),
                                    ),
                                    child: RepaintBoundary(
                                      child: CustomPaint(
                                        size: Size.infinite,
                                        painter:
                                            MyCustomPainter(pointsList: points),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            dataOfRoom["turn"]["nickname"] !=
                                    widget.data["nickname"]
                                ? const SizedBox()
                                : Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          selectedColor();
                                        },
                                        icon: Icon(
                                          Icons.color_lens,
                                          color: selectColor,
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          min: 1.0,
                                          max: 10.0,
                                          activeColor: selectColor,
                                          label: "Strockwidth $strokeWidth",
                                          value: strokeWidth,
                                          onChanged: (value) {
                                            Map data = {
                                              "value": value,
                                              "roomName": widget.data["name"]
                                            };
                                            _soket.emit("stroke-with", data);
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _soket.emit("clean-screen",
                                              dataOfRoom["name"]);
                                        },
                                        icon: Icon(
                                          Icons.layers_clear,
                                          color: selectColor,
                                        ),
                                      )
                                    ],
                                  ),
                            dataOfRoom["turn"]["nickname"] !=
                                    widget.data["nickname"]
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: textBlanckWidget,
                                  )
                                : Center(
                                    child: Text(
                                      dataOfRoom["word"],
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                  ),
                            SizedBox(
                              width: size.width,
                              height: size.height * .3,
                              child: ListView.builder(
                                shrinkWrap: true,
                                controller: _scrollController,
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  var msg = messages[index];
                                  return ListTile(
                                    title: Text(
                                      msg["username"],
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      msg["msg"],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        dataOfRoom["turn"]["nickname"] !=
                                widget.data["nickname"]
                            ? Positioned.fill(
                                child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: TextField(
                                    readOnly: isTextInputReadOnly,
                                    onSubmitted: (value) {
                                      if (value.trim().isNotEmpty) {
                                        Map data = {
                                          "username": widget.data["nickname"],
                                          "msg": value.trim(),
                                          "word": dataOfRoom["word"],
                                          "roomName": widget.data["name"],
                                          "guessedUserCtr": guessedUserCtr,
                                          "totalTime": 60,
                                          "timeTaken": 60 - _start.value,
                                        };
                                        _soket.emit("msg", data);
                                        messageController.clear();
                                      }
                                    },
                                    controller: messageController,
                                    autocorrect: false,
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xffF5F5FA),
                                      hintText: "Message",
                                      hintStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                              ))
                            : const SizedBox(),
                        SafeArea(
                          child: IconButton(
                            onPressed: () {
                              scafolKey.currentState!.openDrawer();
                            },
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    )
              : WawitingLobbyScreen(
                  players: dataOfRoom["players"],
                  lobbyName: widget.data["name"],
                  noOfPlayers: dataOfRoom["players"].length,
                  occupancy: dataOfRoom["occupancy"],
                ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          bottom: 30,
        ),
        child: FloatingActionButton(
            onPressed: () {},
            elevation: 7,
            backgroundColor: Colors.white,
            child: ValueListenableBuilder(
                valueListenable: _start,
                builder: (c, v, w) {
                  return w!;
                },
                child: Text(
                  "${_start.value}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                  ),
                ))),
      ),
    );
  }
}
