import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
              onPressed: () {
                fileTest(context);
              },
              child: const Text("PDF Test")),
        ],
      )),
    );
  }
}

void fileTest(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    String filePath = result.files.first.path ?? "";
    File file = File(filePath);
    Uint8List bytes = file.readAsBytesSync();
    PdfDocument document = PdfDocument(inputBytes: bytes);
    PdfTextExtractor extractor = PdfTextExtractor(document);
    String text = extractor.extractText();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Extracted text'),
            content: Scrollbar(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Text(text),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        });
  } else {
    // User canceled the picker
    print("Settttt");
  }
}
