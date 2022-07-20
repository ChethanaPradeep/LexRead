import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lexread/pages/focus_read_page.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class TestPage extends StatelessWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDFTest"),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () async {
                FilePickerResult? selectedFile = await filePickCheck();
                if (selectedFile != null) {
                  var doc = await fileProcess(selectedFile);
                  List<List<String>> tokenizedPages =
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
                  };
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FocusReadPage(
                        doc: doc,
                        config: config,
                      ),
                    ),
                  );
                }
              },
              child: const Text("PDF Test")),
        ],
      )),
    );
  }
}

Future<FilePickerResult?> filePickCheck() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  return result;
}

Future<Map<dynamic, dynamic>> fileProcess(FilePickerResult result) async {
  Map documentMap = {};
  //List<String> pages = [];
  String text = "";
  String filePath = result.files.first.path ?? "";
  File file = File(filePath);
  Uint8List bytes = file.readAsBytesSync();
  PdfDocument document = PdfDocument(inputBytes: bytes);

  //PdfDocumentInformation documentInfo = document.documentInformation;
  documentMap['title'] = result.files.first.name;
  documentMap['pageCount'] = document.pages.count;
  documentMap['text'] = [];
  PdfTextExtractor extractor =
      PdfTextExtractor(document); // single page extract

  for (int i = 0; i < documentMap['pageCount']; i++) {
    text = extractor.extractText(startPageIndex: i);
    documentMap['text'].add(text);
  }

  //documentMap["text"] = extractor.extractText();

  return documentMap;
}

List<List<String>> stringProcessing(List<dynamic> text) {
  List<List<String>> displayList = [];
  RegExp re = RegExp(r"(\w|\s|,|')+[。.?!]*\s*");
  for (int i = 0; i < text.length; i++) {
    Iterable matches = re.allMatches(text[i]);
    displayList.add([]);
    for (Match match in matches) {
      String? sentence = match.group(0);
      displayList[i].add(sentence ?? "");
    }
  } //basic regex to be updated with all elements
  return displayList;
}
