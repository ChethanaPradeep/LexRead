import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lexread/pages/newdoc_list.dart';
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
    colors: <Color>[
      Colors.redAccent.shade400,
      Colors.blue,
    ],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 400.0, 70.0));

  @override
  Widget build(BuildContext context) {
    List<List<String>> text = widget.doc["text"][widget.doc["index"]];
    text = formatPage(
        config["newLineIncrement"], config["prevLineIncrement"], text);
    config["prevLineIncrement"] = config["newLineIncrement"];
    return SafeArea(
        child: Scaffold(
      drawerEnableOpenDragGesture: false,
      backgroundColor: config["backgroundColor"],
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.amber[300],
        titleSpacing: 0.0,
        title: Text(
          widget.doc["title"],
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          maxLines: 1,
          style: TextStyle(
            color: Colors.grey[800],
            fontFamily: 'OpenDyslexic',
          ),
        ),
        leading: IconButton(
          color: Colors.grey[800],
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "(${widget.doc["index"] + 1}/${widget.doc["pageCount"]})",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontFamily: 'OpenDyslexic',
                ),
              ),
            ],
          ),
          IconButton(
            color: Colors.grey[800],
            visualDensity:
                const VisualDensity(horizontal: -4.0, vertical: -4.0),
            onPressed: () {
              if (widget.doc["index"] > 0) {
                var newDoc = widget.doc;
                newDoc["index"]--;
                Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                      duration: Duration.zero,
                      type: PageTransitionType.leftToRight,
                      child: FocusReadPage(doc: newDoc, config: config),
                    ),
                    (route) => false);
              } else {}
            },
            icon: const Icon(Icons.arrow_left_sharp),
          ),
          IconButton(
              color: Colors.grey[800],
              onPressed: () {
                if (widget.doc["index"] < widget.doc["pageCount"] - 1) {
                  var newDoc = widget.doc;
                  newDoc["index"]++;
                  Navigator.pushAndRemoveUntil(
                      context,
                      PageTransition(
                          duration: Duration.zero,
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
              color: Colors.grey[800],
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ListOfDocs(),
                    ),
                    (route) => false);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.amber[200],
        child: Column(
          children: [
            AppBar(
              leadingWidth: 7.0,
              leading: Container(),
              title: Text(
                "Edit Document",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 90,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(23, 0, 20, 0),
                          child: Text(
                            "Font Size:",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                        Text(
                          double.parse(config["fontSize"].toString())
                              .toInt()
                              .toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                        value: config["fontSize"],
                        max: 45.0,
                        min: 8.0,
                        activeColor: Colors.amber[800],
                        inactiveColor: Colors.amber[400],
                        //label: config["fontSize"].toString(),
                        onChanged: (newFontSize) {
                          setState(() {
                            config["fontSize"] = roundDouble(newFontSize, 0);
                          });
                        }),
                    const SizedBox(
                      height: 13,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(23, 0, 20, 0),
                              child: Text(
                                "Word Spacing:",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            Text(
                              double.parse(config["wordSpacing"].toString())
                                  .toInt()
                                  .toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Slider(
                            value: config["wordSpacing"],
                            max: 100.0,
                            min: 0.0,
                            divisions: 100,
                            activeColor: Colors.amber[800],
                            inactiveColor: Colors.amber[400],
                            //label: config["fontSize"].toString(),
                            onChanged: (newLetterSpace) {
                              setState(() {
                                config["wordSpacing"] =
                                    roundDouble(newLetterSpace, 1);
                              });
                            })
                      ],
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(23, 0, 20, 0),
                              child: Text(
                                "Letter Spacing:",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            Text(
                              double.parse(config["letterSpacing"].toString())
                                  .toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Slider(
                            value: config["letterSpacing"],
                            max: 10.0,
                            min: 0.0,
                            divisions: 100,
                            activeColor: Colors.amber[800],
                            inactiveColor: Colors.amber[400],
                            //label: config["fontSize"].toString(),
                            onChanged: (newLetterSpace) {
                              setState(() {
                                config["letterSpacing"] =
                                    roundDouble(newLetterSpace, 0);
                              });
                            })
                      ],
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(23, 0, 20, 0),
                              child: Text(
                                "Line Spacing:",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            Text(
                              double.parse((config["lineSpacing"]).toString())
                                  .toStringAsFixed(2),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Slider(
                            value: config["lineSpacing"],
                            max: 10.00,
                            min: 1.70,
                            divisions: 166,
                            activeColor: Colors.amber[800],
                            inactiveColor: Colors.amber[400],
                            //label: config["fontSize"].toString(),
                            onChanged: (newLineSpace) {
                              setState(() {
                                config["lineSpacing"] =
                                    roundDouble(newLineSpace, 2);
                              });
                            })
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(23, 0, 20, 0),
                              child: Text(
                                "Paragraph Spacing:",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            Text(
                              double.parse(
                                      config["newLineIncrement"].toString())
                                  .toInt()
                                  .toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Slider(
                            value: double.parse(
                                config["newLineIncrement"].toString()),
                            max: 10.0,
                            min: 0.0,
                            activeColor: Colors.amber[800],
                            inactiveColor: Colors.amber[400],
                            onChanged: (newLineIncrement) {
                              setState(() {
                                config["newLineIncrement"] =
                                    newLineIncrement.toInt();
                              });
                            })
                      ],
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(23, 0, 20, 0),
                          child: Text(
                            "Color Sets:",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (config["colorIndex"] > 1) {
                                  config["colorIndex"]--;
                                } else {
                                  config["colorIndex"] = 8;
                                }
                                if (!config["isShaderEnabled"]) {
                                  config["fontColor"] =
                                      colorSet[config["colorIndex"]]![0];
                                }
                                config["backgroundColor"] =
                                    colorSet[config["colorIndex"]]![1];
                              });
                            },
                            child: Icon(
                              Icons.keyboard_arrow_left_outlined,
                              color: Colors.grey[800],
                              size: 30,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (config["colorIndex"] < 8) {
                                  config["colorIndex"]++;
                                } else {
                                  config["colorIndex"] = 1;
                                }
                                config["fontColor"] =
                                    colorSet[config["colorIndex"]]![0];
                                config["backgroundColor"] =
                                    colorSet[config["colorIndex"]]![1];
                              });
                            },
                            child: Icon(
                              Icons.keyboard_arrow_right_outlined,
                              color: Colors.grey[800],
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(23, 0, 20, 0),
                          child: Text(
                            "Block Highlighting:",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                        Checkbox(
                          checkColor: Colors.amber[200],
                          activeColor: Colors.amber[800],
                          value: config["isBlockHighlight"],
                          onChanged: (value) {
                            setState(() {
                              config["isBlockHighlight"] =
                                  !config["isBlockHighlight"];
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(23, 0, 30, 0),
                          child: Text(
                            "Cognitive Helper:",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                        Checkbox(
                          checkColor: Colors.amber[200],
                          activeColor: Colors.amber[800],
                          value: config["isShaderEnabled"],
                          onChanged: (value) {
                            setState(() {
                              config["isShaderEnabled"] =
                                  !config["isShaderEnabled"];
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                  ],
                ),
              ),
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
                          : null,
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
