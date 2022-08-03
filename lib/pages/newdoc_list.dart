import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:lexread/pages/focus_read_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ListOfDocs extends StatefulWidget {
  const ListOfDocs({Key? key}) : super(key: key);

  @override
  State<ListOfDocs> createState() => _ListOfDocsState();
}

class _ListOfDocsState extends State<ListOfDocs> {
  List<List<String>> litems = [];
  bool isLoading = false;

  void _prefAsync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int prefCount = prefs.getKeys().length;
    for (int i = 0; i < prefCount; i++) {
      setState(() {
        litems.add(prefs.getStringList(i.toString())!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _prefAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[200],
      appBar: AppBar(
        title: Text(
          'LexRead',
          style: TextStyle(
            color: Colors.grey[800],
            fontFamily: 'OpenDyslexic',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber[300],
      ),
      body: isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    width: 40.0,
                    height: 40.0,
                    child: CircularProgressIndicator(
                      color: Colors.amber[800],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Loading your document...",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "OpenDyslexic",
                    ),
                  ),
                )
              ],
            )
          : ListView.builder(
              itemCount: litems.length,
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (BuildContext ctxt, int index) {
                return Card(
                    color: Colors.amber[50],
                    child: ListTile(
                      onTap: () async {
                        //read file from path and redirect to page
                        setState(() {
                          isLoading = true;
                        });
                        final resultList =
                            await compute(fileProcess, litems[index]);
                        final docMap = resultList[0];
                        Map<dynamic, dynamic> config = resultList[1];
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FocusReadPage(
                              doc: docMap,
                              config: config,
                            ),
                          ),
                          (route) => false,
                        );
                        setState(() {
                          isLoading = false;
                        });
                      },
                      title: Text(
                        litems[index][0],
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      trailing: Text(
                        formatBytes(int.parse(litems[index][2]), 2),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontSize: 13),
                      ),
                      subtitle: Text(
                        litems[index][1],
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontSize: 12),
                      ),
                      leading: CircleAvatar(
                          backgroundColor: Colors.amber[200],
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: Colors.amber[800],
                          )),
                    ));
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[800],
        onPressed: () async {
          FilePickerResult? selectedFile = await FilePicker.platform
              .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
          setState(() {
            isLoading = true;
          });
          if (selectedFile != null &&
              (selectedFile.files.first.extension == 'pdf')) {
            PlatformFile fileObject = selectedFile.files.first;
            final resultList = await compute(fileProcess,
                [fileObject.name, fileObject.path, fileObject.size]);
            final docMap = resultList[0];
            Map<dynamic, dynamic> config = resultList[1];
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => FocusReadPage(
                  doc: docMap,
                  config: config,
                ),
              ),
              (route) => false,
            );
            // List<List<List<String>>> tokenizedPages =
            //     stringProcessing(doc["text"]);
            // doc["text"] = tokenizedPages;
            // doc["index"] = 0;
            // Map<dynamic, dynamic> config = {
            //   "fontSize": 14.0,
            //   "letterSpacing": 0.0,
            //   "wordSpacing": 0.0,
            //   "lineSpacing": 1.70,
            //   "colorIndex": 1,
            //   "fontColor": Colors.black,
            //   "backgroundColor": Colors.white,
            //   "newLineIncrement": 0,
            //   "prevLineIncrement": 0,
            //   "isSyllableSplit": false,
            //   "isBlockHighlight": false,
            //   "isShaderEnabled": false,
            // };
            //Navigator.of(context).pop();
            // Navigator.pushAndRemoveUntil(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => FocusReadPage(
            //       doc: docMap,
            //       config: config,
            //     ),
            //   ),
            //   (route) => false,
            // );
            List<String> docInfoPersist = [
              docMap["title"],
              docMap["path"],
              docMap["size"].toString(),
            ];
            final pref = await SharedPreferences.getInstance();
            int docIndex = await preferenceUpdate(docInfoPersist, pref);
            setState(() {
              if (docIndex >= 0) {
                litems.add(pref.getStringList(docIndex.toString())!);
              }
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}

Future<int> preferenceUpdate(
    List<String> docInfoPersist, SharedPreferences pref) async {
  int storedDocCount = pref.getKeys().length;
  for (int i = 0; i < storedDocCount; i++) {
    if (docInfoPersist[1] == pref.getStringList(i.toString())![1]) {
      return -1;
    }
  }
  pref.setStringList(storedDocCount.toString(), docInfoPersist);
  return storedDocCount;
}

String formatBytes(int bytes, int decimals) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return ("${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}");
}

List<dynamic> fileProcess(List<dynamic> fileMap) {
  Map documentMap = {};
  String text = "";
  String filePath = fileMap[1];
  File file = File(filePath);
  Uint8List bytes = file.readAsBytesSync();
  PdfDocument document = PdfDocument(inputBytes: bytes);

  documentMap['title'] = fileMap[0];
  documentMap['pageCount'] = document.pages.count;
  documentMap['text'] = [];
  documentMap['path'] = filePath;
  documentMap['size'] = fileMap[2];
  PdfTextExtractor extractor =
      PdfTextExtractor(document); // single page extract

  for (int i = 0; i < documentMap['pageCount']; i++) {
    text = extractor.extractText(startPageIndex: i);
    documentMap['text'].add(text);
  }
  List<List<List<String>>> tokenizedPages =
      stringProcessing(documentMap["text"]);
  documentMap["text"] = tokenizedPages;
  documentMap["index"] = 0;
  Map<dynamic, dynamic> config = {
    "fontSize": 20.0,
    "letterSpacing": 2.0,
    "wordSpacing": 22.0,
    "lineSpacing": 3.00,
    "colorIndex": 5,
    "fontColor": Colors.black,
    "backgroundColor": Colors.white,
    "newLineIncrement": 0,
    "prevLineIncrement": 0,
    "isSyllableSplit": false,
    "isBlockHighlight": false,
    "isShaderEnabled": false,
  };
  //documentMap["config"] = config;
  return [documentMap, config];
}

List<List<List<String>>> stringProcessing(List<dynamic> text) {
  List<List<List<String>>> pageList = [];
  List<String> sentenceList = [];
  RegExp re = RegExp(
      r"""(\w|\s|,|'|:|{|}|\\|-|\+|-|<|>|;|@|#|$|%|^|&|\[|\]|_|\/|\"|\*|\||`|~)+[.+?+!+]*\s*""");
  for (int i = 0; i < text.length; i++) {
    Iterable matches = re.allMatches(text[i]);
    pageList.add([]);
    sentenceList = [];
    for (Match match in matches) {
      String sentence = match.group(0) ?? "";
      if (sentence.isNotEmpty) {
        if (sentence[sentence.length - 1] == "\n") {
          RegExp regExp = RegExp(r"\n");
          int newLineCount = regExp.allMatches(sentence).length;
          sentence = sentence.split("\n")[0];
          sentenceList.add(sentence);
          sentenceList.add("\n" * newLineCount);
          pageList[i] = pageList[i] + [sentenceList];
          sentenceList = [];
        } else {
          sentenceList.add(sentence);
        }
      }
    }
  } //basic regex to be updated with all elements
  return pageList;
}
