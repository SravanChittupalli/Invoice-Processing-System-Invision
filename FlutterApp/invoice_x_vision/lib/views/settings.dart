import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:invoice_x_vision/assets/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  String IP = " ";

  saveIP(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Server_IP', ip);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        height:  MediaQuery.of(context).size.height * 0.51,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top:80, left:10, right:10),
        child: Card(
          elevation: 15.0,
          shadowColor: AppColor.PRIMARY_BLUE_DARK,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
          ),
          color: AppColor.PRIMARY_WHITE,
          child: Column(
            children: [
            Padding(
                  padding: EdgeInsets.only(top:15),
                  child: Text("Settings", textAlign: TextAlign.center, style: TextStyle(fontSize: 45, color: AppColor.PRIMARY_BLUE_DARK),)
              ),
              Padding(
                padding: EdgeInsets.only(left:30, right: 30),
                child: Divider(
                  color: AppColor.PRIMARY_BLACK,
                  thickness: 3,
                ),
              ),

              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left:30, right: 30, top: 50),
                    child: Text("Enter Server IP:", style: TextStyle(fontSize: 20),),
                  ),

                ],
              ),
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                        child: Padding(
                          padding: EdgeInsets.only(left:30, right: 30),
                          child: TextField(
                            decoration: new InputDecoration(
                              hintText: "https://531c01984bc2.ngrok.io",
                            ),
                            onChanged: (text){
                              IP = text;
                            },
                            onSubmitted: (String submission) {
                              IP = submission;
                            },
                          ),
                        ),
                      ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top:5, left: 30),
                    child: ButtonTheme(
                      buttonColor: Colors.red,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(26.0),
                      ),
                      child: ButtonBar(
                        buttonPadding: EdgeInsets.only(left:23, right: 23, top: 13, bottom: 13),
                        alignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right:30),
                            child: RaisedButton(
                              color: Colors.blue,
                              child: Text('SAVE', style: TextStyle(fontSize: 32),),
                              onPressed: () {
                                saveIP(IP);
                                return showDialog(
                                    context: context,
                                    builder: (context) {
                                      Timer(Duration(seconds: 2),
                                            ()=>Navigator.pop(context),
                                      );
                                      return FractionallySizedBox(
                                        alignment: Alignment.center,
                                        widthFactor: 0.6,
                                        heightFactor: 0.2,
                                        child: Container(
                                          color: AppColor.PRIMARY_WHITE,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child:Text("Connected!", style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic, color: AppColor.PRIMARY_BLUE_DARK),),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
