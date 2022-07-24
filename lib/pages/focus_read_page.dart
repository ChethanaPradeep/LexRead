import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lexread/pages/test_page.dart';
import 'package:page_transition/page_transition.dart';

double roundDouble(double value, int places) {
  double mod = pow(10.0, places).toDouble();
  return ((value * mod).round().toDouble() / mod);
}

List<List<String>> formatPage(
    int newLineIncrement, int prevLineIncrement, List<List<String>> text) {
  int modifier = newLineIncrement - prevLineIncrement;
  if (modifier > 0) {
    for (int i = 0; i < text.length; i++) {
      for (int j = 0; j < text[i].length; j++) {
        if (text[i][j].isNotEmpty &&
            text[i][j][text[i][j].length - 1] == "\n") {
          text[i][j] = text[i][j] + "\n" * 1;
        }
      }
    }
  } else if (modifier < 0) {
    for (int i = 0; i < text.length; i++) {
      for (int j = 0; j < text[i].length; j++) {
        if (text[i][j].isNotEmpty &&
            text[i][j][text[i][j].length - 1] == "\n") {
          text[i][j] = text[i][j].substring(0, text[i][j].length - 1);
        }
      }
    }
  }
  return text;
}

class FocusReadPage extends StatefulWidget {
  final Map<dynamic, dynamic> doc;
  final Map<dynamic, dynamic> config;
  const FocusReadPage({Key? key, required this.doc, required this.config})
      : super(key: key);
  Map<dynamic, dynamic>? get configGet {
    return config;
  }

  @override
  State<FocusReadPage> createState() => _FocusReadPageState();
}

class _FocusReadPageState extends State<FocusReadPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late Map<dynamic, dynamic> config = widget.config;
  Map<int, List<Color>> colorSet = {
    1: const [Color(0xFF000000), Color(0xFFFFFFFF)],
    2: const [Color(0xFF000000), Color(0xFFFFFF00)],
    3: const [Color(0xFF000000), Color(0xFFFAFAC8)],
    4: const [Color(0xFF0A0A0A), Color(0xFFFFFFE5)],
    5: const [Color(0xFF00007D), Color(0xFFFFFFFF)],
    6: const [Color(0xFF1E1E00), Color(0xFFB9B900)],
    7: const [Color(0xFF282800), Color(0xFFA0A000)],
    8: const [Color(0xFF00007D), Color(0xFFFFFF00)]
  };
  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.blue.shade900, Colors.red.shade600],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 450.0, 70.0));

  @override
  Widget build(BuildContext context) {
    List<List<String>> text = widget.doc["text"][widget.doc["index"]];
    text = formatPage(
        config["newLineIncrement"], config["prevLineIncrement"], text);
    //text = temp[0];
    config["prevLineIncrement"] = config["newLineIncrement"];
    return SafeArea(
        child: Scaffold(
      backgroundColor: config["backgroundColor"],
      key: scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text(
          widget.doc["title"],
          overflow: TextOverflow.ellipsis,
          //style: ,
          softWrap: false,
          maxLines: 1,
          style: const TextStyle(fontSize: 17.0),
        ),
        leading: IconButton(
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("(${widget.doc["index"] + 1}/${widget.doc["pageCount"]})"),
            ],
          ),
          IconButton(
            visualDensity:
                const VisualDensity(horizontal: -4.0, vertical: -4.0),
            onPressed: () {
              if (widget.doc["index"] > 0) {
                var newDoc = widget.doc;
                newDoc["index"]--;
                Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                      type: PageTransitionType.leftToRight,
                      child: FocusReadPage(doc: newDoc, config: config),
                    ),
                    (route) => false);
              } else {}
            },
            icon: const Icon(Icons.arrow_left_sharp),
          ),
          IconButton(
              onPressed: () {
                if (widget.doc["index"] < widget.doc["pageCount"] - 1) {
                  var newDoc = widget.doc;
                  newDoc["index"]++;
                  Navigator.pushAndRemoveUntil(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: FocusReadPage(
                            doc: newDoc,
                            config: config,
                          )),
                      (route) => false);
                }
              },
              icon: const Icon(Icons.arrow_right_sharp)),
          IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentListPage(),
                    ),
                    (route) => false);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const Text("Just testing this out"),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (config["fontSize"] < 45.0) {
                          config["fontSize"]++;
                          config["fontSize"] =
                              roundDouble(config["fontSize"], 1);
                          // print("FontSize: $fontSize");
                        }
                      });
                    },
                    child: const Text("Font+")),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (config["fontSize"] > 8.0) {
                        config["fontSize"]--;
                        config["fontSize"] = roundDouble(config["fontSize"], 1);
                        // print("FontSize: $fontSize");
                      }
                    });
                  },
                  child: const Text("Font-"),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (config["letterSpacing"] < 10.0) {
                          config["letterSpacing"] =
                              roundDouble((config["letterSpacing"] + 0.1), 2);
                          // print("LetterSpacing: $letterSpacing");
                        }
                      });
                    },
                    child: const Text("Letter+")),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (config["letterSpacing"] > 0.0) {
                          config["letterSpacing"] =
                              roundDouble((config["letterSpacing"] - 0.1), 2);
                          // print("LetterSpacing: $letterSpacing");
                        }
                      });
                    },
                    child: const Text("Letter-"))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (config["colorIndex"] < 8) {
                    config["colorIndex"]++;
                  } else {
                    config["colorIndex"] = 1;
                  }
                  config["fontColor"] = colorSet[config["colorIndex"]]![0];
                  config["backgroundColor"] =
                      colorSet[config["colorIndex"]]![1];
                });
              },
              child: const Text("FType"),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (config["lineSpacing"] < 10.0) {
                          config["lineSpacing"] =
                              roundDouble((config["lineSpacing"] + 0.05), 2);
                          // print("LetterSpacing: $letterSpacing");
                        }
                      });
                    },
                    child: const Text("Line+")),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (config["lineSpacing"] > 1.5) {
                        config["lineSpacing"] =
                            roundDouble((config["lineSpacing"] - 0.05), 2);
                        // print("LetterSpacing: $letterSpacing");
                      }
                    });
                  },
                  child: const Text("Line-"),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (config["newLineIncrement"] < 10) {
                          config["newLineIncrement"] =
                              config["newLineIncrement"] + 1;
                          // print("LetterSpacing: $letterSpacing");
                        }
                      });
                    },
                    child: const Text("newLineCount+")),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (config["newLineIncrement"] > 0) {
                        config["newLineIncrement"] =
                            config["newLineIncrement"] - 1;
                        // print("LetterSpacing: $letterSpacing");
                      }
                    });
                  },
                  child: const Text("newLineIncrement-"),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  config["isBlockHighlight"] = !config["isBlockHighlight"];
                });
              },
              child: const Text("BlockHighlight"),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  config["isShaderEnabled"] = !config["isShaderEnabled"];
                });
              },
              child: const Text("Cognitive Helper"),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: text.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: config["isBlockHighlight"]
                          ? Border.all(
                              color: Colors.red,
                              width: 2.0 // red as border color
                              )
                          : Border.all(width: 0, color: Colors.white),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        text[index].join().trimRight(),
                        style: TextStyle(
                          color: !config["isShaderEnabled"]
                              ? config["fontColor"]
                              : null,
                          fontSize: config["fontSize"],
                          letterSpacing: config["letterSpacing"],
                          wordSpacing: config["wordSpacing"],
                          height: config["lineSpacing"],
                          fontFamily: ('OpenDyslexic'),
                          leadingDistribution: TextLeadingDistribution.even,
                          foreground: config["isShaderEnabled"]
                              ? (Paint()..shader = linearGradient)
                              : null,
                        ),
                      ),
                    ),
                  ),
                  Text(text[index][text[index].length - 1])
                ],
              );
            },
          ),
        ),
      ),
    ));
  }
}
