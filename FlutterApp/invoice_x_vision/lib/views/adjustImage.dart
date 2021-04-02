
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_size_getter/file_input.dart';
import 'dart:io';

import 'package:image_size_getter/image_size_getter.dart';
import 'package:invoice_x_vision/helper/crop_painter.dart';
import 'package:invoice_x_vision/views/showImage.dart';

class AdjustImage extends StatefulWidget {

  File image;
  AdjustImage(this.image);
  @override
  _AdjustImageState createState() => _AdjustImageState();

}

class _AdjustImageState extends State<AdjustImage> {

  final GlobalKey key = GlobalKey();
  double width, height;
  Size imagePixelSize;
  bool isFile = false;
  Offset tl, tr, bl, br;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 2000), getImageSize);
  }

  void getImageSize() {
    RenderBox imageBox = key.currentContext.findRenderObject();
    width = imageBox.size.width;
    height = imageBox.size.height;
    imagePixelSize = ImageSizeGetter.getSize(FileInput(widget.image));
    tl = new Offset(20, 20);
    tr = new Offset(width - 20, 20);
    bl = new Offset(20, height - 20);
    br = new Offset(width - 20, height - 20);
    setState(() {
      isFile = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeData.dark().canvasColor,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(top:MediaQuery.of(context).size.height * 0.08, left:10, right:10),
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    GestureDetector(
                      onPanDown: (details) {
                        double x1 = details.localPosition.dx;
                        double y1 = details.localPosition.dy;
                        double x2 = tl.dx;
                        double y2 = tl.dy;
                        double x3 = tr.dx;
                        double y3 = tr.dy;
                        double x4 = bl.dx;
                        double y4 = bl.dy;
                        double x5 = br.dx;
                        double y5 = br.dy;
                        if (sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) <
                            30 &&
                            x1 >= 0 &&
                            y1 >= 0 &&
                            x1 < width / 2 &&
                            y1 < height / 2) {
                          print(details.localPosition);
                          setState(() {
                            tl = details.localPosition;
                          });
                        } else if (sqrt((x3 - x1) * (x3 - x1) +
                            (y3 - y1) * (y3 - y1)) <
                            30 &&
                            x1 >= width / 2 &&
                            y1 >= 0 &&
                            x1 < width &&
                            y1 < height / 2) {
                          setState(() {
                            tr = details.localPosition;
                          });
                        } else if (sqrt((x4 - x1) * (x4 - x1) +
                            (y4 - y1) * (y4 - y1)) <
                            30 &&
                            x1 >= 0 &&
                            y1 >= height / 2 &&
                            x1 < width / 2 &&
                            y1 < height) {
                          setState(() {
                            bl = details.localPosition;
                          });
                        } else if (sqrt((x5 - x1) * (x5 - x1) +
                            (y5 - y1) * (y5 - y1)) <
                            30 &&
                            x1 >= width / 2 &&
                            y1 >= height / 2 &&
                            x1 < width &&
                            y1 < height) {
                          setState(() {
                            br = details.localPosition;
                          });
                        }
                      },
                      onPanUpdate: (details) {
                        double x1 = details.localPosition.dx;
                        double y1 = details.localPosition.dy;
                        double x2 = tl.dx;
                        double y2 = tl.dy;
                        double x3 = tr.dx;
                        double y3 = tr.dy;
                        double x4 = bl.dx;
                        double y4 = bl.dy;
                        double x5 = br.dx;
                        double y5 = br.dy;
                        if (sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) <
                            30 &&
                            x1 >= 0 &&
                            y1 >= 0 &&
                            x1 < width / 2 &&
                            y1 < height / 2) {
                          print(details.localPosition);
                          setState(() {
                            tl = details.localPosition;
                          });
                        } else if (sqrt((x3 - x1) * (x3 - x1) +
                            (y3 - y1) * (y3 - y1)) <
                            30 &&
                            x1 >= width / 2 &&
                            y1 >= 0 &&
                            x1 < width &&
                            y1 < height / 2) {
                          setState(() {
                            tr = details.localPosition;
                          });
                        } else if (sqrt((x4 - x1) * (x4 - x1) +
                            (y4 - y1) * (y4 - y1)) <
                            30 &&
                            x1 >= 0 &&
                            y1 >= height / 2 &&
                            x1 < width / 2 &&
                            y1 < height) {
                          setState(() {
                            bl = details.localPosition;
                          });
                        } else if (sqrt((x5 - x1) * (x5 - x1) +
                            (y5 - y1) * (y5 - y1)) <
                            30 &&
                            x1 >= width / 2 &&
                            y1 >= height / 2 &&
                            x1 < width &&
                            y1 < height) {
                          setState(() {
                            br = details.localPosition;
                          });
                        }
                      },
                      child: SafeArea(
                        child: Container(
                          color: ThemeData.dark().canvasColor,
                          constraints: BoxConstraints(maxHeight:450),
                          child: Image.file(
                            widget.image,
                            key: key,
                          ),
                        ),
                      ),
                    ),
                    isFile
                        ? SafeArea(
                      child: CustomPaint(
                        painter: CropPainter(tl, tr, bl, br),
                      ),
                    )
                        : SizedBox()
                  ],
                ),
                bottomSheet()
              ],
            ),
          ),
        ));
  }

  Widget bottomSheet() {
    return Container(
      color: ThemeData.dark().canvasColor,
      width: MediaQuery.of(context).size.width,
      height: 120,
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              "Drag the handles to adjust the borders. You can",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Padding(
                padding: EdgeInsets.only(top:MediaQuery.of(context).size.height * 0.02),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.blue,
                        ),
                        child: isLoading
                            ? Container(
                          width: 60.0,
                          height: 20.0,
                          child: Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                          ),
                        )
                            : isFile
                            ? FlatButton(
                          child: Text(
                            "Continue",
                            softWrap: true,
                            style: TextStyle(
                                color: Colors.white, fontSize: 23),
                          ),
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            Timer(Duration(seconds: 1), () {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                  builder: (context) => ShowImage(
                                    tl: tl,
                                    tr: tr,
                                    bl: bl,
                                    br: br,
                                    width: width,
                                    height: height,
                                    image: widget.image,
                                    imagePixelSize: imagePixelSize,
                                  )));
                            });
                          },
                        )
                            : Container(
                          width: 60,
                          height: 20.0,
                          child: Center(
                              child: Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                        Colors.white),
                                  ))),
                        ),
                      ),
                    )
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}
