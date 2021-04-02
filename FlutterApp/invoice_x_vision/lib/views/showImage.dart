import 'dart:io';

import 'package:flutter/material.dart';
import 'package:invoice_x_vision/assets/color.dart';
import 'package:invoice_x_vision/views/extractedInvoice.dart';

class ShowImage extends StatefulWidget {

  File image;
  var imagePixelSize;
  double width;
  double height;
  Offset tl, tr, bl, br;

  ShowImage(
      {this.image,
        this.bl,
        this.br,
        this.tl,
        this.height,
        this.tr,
        this.imagePixelSize,
        this.width});

  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Invoice Manager'),
        ),
        body: new Builder(
          builder: (BuildContext context) {
            return new Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child:SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: widget.image == null
                        ? new Text('Sorry nothing selected!!')
                        : new Image.file(widget.image),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(top:50, right:20),
                    child: ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.06,
                      buttonColor: AppColor.PRIMARY_BLUE_DARK,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0),
                      ),
                      child: CircleAvatar(
                        // backgroundColor: AppColor.PRIMARY_BLUE_DARK,
                        radius: 30,
                        child: new IconButton(
                          icon: new Icon(Icons.check, color: AppColor.PRIMARY_WHITE,size: 33),
                          tooltip: 'Process',
                          onPressed: () {
                            // todo: show up slider new page with loading sign!
                            print("SENDING HTTP POST REQUEST");
                            Navigator.push(context,
                                PageRouteBuilder(
                                    transitionDuration: Duration(seconds: 1),
                                    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secAnimation, Widget child){
                                      animation = CurvedAnimation(parent: animation, curve: Curves.elasticInOut);
                                      return ScaleTransition(
                                        alignment: Alignment.center,
                                        scale: animation,
                                        child: child,
                                      );
                                    },
                                    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secAnimation){
                                      return ShowExtractedJSON(widget.image);
                                    }
                                )
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
  }
}
