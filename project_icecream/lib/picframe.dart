import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:screenshot/screenshot.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PicFrameGenerator extends StatefulWidget {
  @override
  _PicFrameGeneratorState createState() => _PicFrameGeneratorState();
}

class _PicFrameGeneratorState extends State<PicFrameGenerator> {
  Uint8List uploadedImage;
  File previewImage;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                onPressed: _startFilePicker,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Upload file",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                color: Colors.blueAccent,
              ),
            ],
          ),
          (uploadedImage != null)
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Screenshot(
                      controller: screenshotController,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.memory(
                              uploadedImage,
                              fit: BoxFit.fill,
                            ),
                            Image.asset(
                              'assets/images/frame.png',
                              fit: BoxFit.fill,
                            )
                          ],
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: _capturePng,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Download Image",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      color: Colors.blueAccent,
                    ),
                    (previewImage != null)
                        ? Image.memory(previewImage.readAsBytesSync())
                        : Text("No preview")
                  ],
                ))
              : Center(child: Text("Upload an image"))
        ],
      ),
    );
  }

  _startFilePicker() async {
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      // read file content as dataURL
      final files = uploadInput.files;
      if (files.length == 1) {
        final file = files[0];
        html.FileReader reader = html.FileReader();

        reader.onLoadEnd.listen((e) {
          setState(() {
            uploadedImage = reader.result;
          });
        });

        reader.onError.listen((fileEvent) {
          print("Some error occured");
        });

        reader.readAsArrayBuffer(file);
      }
    });
  }

  _capturePng() async {
    screenshotController
        .capture(delay: Duration(milliseconds: 10))
        .then((value) {
      img.Image png64b = img.decodeImage(value.readAsBytesSync());
      File('dp.png')..writeAsBytesSync(img.encodePng(png64b));
      setState(() {
        previewImage = value;
        final bytes = value.readAsBytesSync();
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = 'dp.png';
        html.document.body.children.add(anchor);

        // download
        anchor.click();

        // cleanup
        html.document.body.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      });
    });
  }
}
