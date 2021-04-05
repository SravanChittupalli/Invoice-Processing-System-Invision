
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:invoice_x_vision/assets/color.dart';
import 'package:invoice_x_vision/views/adjustImage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File _file;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
         appBar: AppBar(
          title: Text("Invoice Manager"),
          backgroundColor: AppColor.PRIMARY_BLUE_DARK,
        ),
        body: Container(
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery
                .of(context)
                .size
                .height * 0.1, left: 15, right: 15, bottom: 50),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ButtonTheme(
                      minWidth: MediaQuery
                          .of(context)
                          .size
                          .width * 0.85,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.09,
                      buttonColor: AppColor.PRIMARY_BLUE_DARK,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(26.0),
                      ),
                      child: RaisedButton(
                        textColor: AppColor.PRIMARY_WHITE,
                        elevation: 10,
                        color: AppColor.PRIMARY_BLUE_DARK,
                        child: Text('Scan', style: TextStyle(fontSize: 32),),
                        onPressed: () {
                          chooseImage(ImageSource.camera);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ButtonTheme(
                      minWidth: MediaQuery
                          .of(context)
                          .size
                          .width * 0.85,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.09,
                      buttonColor: AppColor.PRIMARY_BLUE_DARK,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(26.0),
                      ),
                      child: RaisedButton(
                        textColor: AppColor.PRIMARY_WHITE,
                        elevation: 10,
                        color: AppColor.PRIMARY_BLUE_DARK,
                        child: Text('Upload', style: TextStyle(fontSize: 32),),
                        onPressed: () {
                          chooseImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }

  void chooseImage(ImageSource source) async {
    File fileGallery = await ImagePicker.pickImage(source: source);
    if (fileGallery != null) {
      _file = fileGallery;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AdjustImage(fileGallery)));
    }
  }

}




//////////////////////////////////////////////////////////////////////////////////
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
//
// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//
//   //save the result of gallery file
//   File galleryFile;
// //save the result of camera file
//   File cameraFile;
//
//     @override
//     Widget build(BuildContext context) {
//
//       // display image selected from gallery
//       imageSelectorGallery() async {
//         galleryFile = await ImagePicker.pickImage(
//           source: ImageSource.gallery,
//           // maxHeight: 50.0,
//           // maxWidth: 50.0,
//         );
//         print("You selected gallery image : " + galleryFile.path);
//         setState(() {});
//       }
//
//       // display image selected from camera
//       imageSelectorCamera() async {
//         cameraFile = await ImagePicker.pickImage(
//           source: ImageSource.camera,
//           //maxHeight: 50.0,
//           //maxWidth: 50.0,
//         );
//         print("You selected camera image : " + cameraFile.path);
//         setState(() {});
//       }
//
//       return new Scaffold(
//         appBar: new AppBar(
//           title: new Text('Image Picker'),
//         ),
//         body: new Builder(
//           builder: (BuildContext context) {
//             return new Column(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: <Widget>[
//                 new RaisedButton(
//                   child: new Text('Select Image from Gallery'),
//                   onPressed: imageSelectorGallery,
//                 ),
//                 new RaisedButton(
//                   child: new Text('Select Image from Camera'),
//                   onPressed: imageSelectorCamera,
//                 ),
//                 displaySelectedFile(galleryFile),
//                 displaySelectedFile(cameraFile)
//               ],
//             );
//           },
//         ),
//       );
//     }
//
//     Widget displaySelectedFile(File file) {
//       return new SizedBox(
//         height: 200.0,
//         width: 300.0,
// //child: new Card(child: new Text(''+galleryFile.toString())),
// //child: new Image.file(galleryFile),
//         child: file == null
//             ? new Text('Sorry nothing selected!!')
//             : new Image.file(file),
//       );
//     }
//
//   }

