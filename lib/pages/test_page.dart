import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lexread/pages/focus_read_page.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DocumentListPage extends StatefulWidget {
  const DocumentListPage({Key? key}) : super(key: key);

  @override
  State<DocumentListPage> createState() => _DocumentListPageState();
}

class _DocumentListPageState extends State<DocumentListPage> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("PDFTest"),
        ),
        body: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Center(
                    child: SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Loading...",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              )
            : Center(
                child: ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? selectedFile = await FilePicker.platform
                          .pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'docx', 'doc']);
                      setState(() {
                        isLoading = true;
                      });
                      if (selectedFile != null &&
                          (selectedFile.files.first.extension == 'pdf' ||
                              selectedFile.files.first.extension == 'doc')) {
                        final doc = await compute(fileProcess, selectedFile);
                        List<List<List<String>>> tokenizedPages =
                            stringProcessing(doc["text"]);
                        doc["text"] = tokenizedPages;
                        doc["index"] = 0;
                        Map<dynamic, dynamic> config = {
                          "fontSize": 14.0,
                          "letterSpacing": 0.0,
                          "wordSpacing": 0.0,
                          "lineSpacing": 1.5,
                          "colorIndex": 1,
                          "fontColor": Colors.black,
                          "backgroundColor": Colors.white,
                          "newLineIncrement": 0,
                          "prevLineIncrement": 0,
                          "isSyllableSplit": false,
                          "isBlockHighlight": false,
                          "isShaderEnabled": false,
                        };
                        //Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FocusReadPage(
                              doc: doc,
                              config: config,
                            ),
                          ),
                        );
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: const Text("PDF Test")),
              ));
  }
}

Map<dynamic, dynamic> fileProcess(FilePickerResult result) {
  Map documentMap = {};
  String text = "";
  String filePath = result.files.first.path ?? "";
  File file = File(filePath);
  Uint8List bytes = file.readAsBytesSync();
  PdfDocument document = PdfDocument(inputBytes: bytes);

  documentMap['title'] = result.files.first.name;
  documentMap['pageCount'] = document.pages.count;
  documentMap['text'] = [];
  PdfTextExtractor extractor =
      PdfTextExtractor(document); // single page extract

  for (int i = 0; i < documentMap['pageCount']; i++) {
    text = extractor.extractText(startPageIndex: i);
    documentMap['text'].add(text);
  }

  return documentMap;
}

List<List<List<String>>> stringProcessing(List<dynamic> text) {
  List<List<List<String>>> pageList = [];
  List<String> sentenceList = [];
  RegExp re = RegExp(
      r"""(\w|\s|,|'|:|{|}|\\|-|\+|-|<|>|;|@|#|$|%|^|&|\[|\]|_|\/|\")+[.+?+!+]*\s*""");
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
