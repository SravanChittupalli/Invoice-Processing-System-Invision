import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:invoice_x_vision/Model/invoiceJsonModel.dart';
import 'package:invoice_x_vision/assets/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowExtractedJSON extends StatefulWidget {

  File img;
  ShowExtractedJSON(this.img);
  @override
  _ShowExtractedJSONState createState() => _ShowExtractedJSONState();
}

class _ShowExtractedJSONState extends State<ShowExtractedJSON> {

  String date;
  String time;
  String total;
  String CompanyName;
  String GSTNumber;
  String email;
  List<String> PhoneNumber;
  String InvoiceNumber;
  String currency;

  String IP;

  Future<void> getStringValuesSF() async {
    print("In here");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('Server_IP') ?? "https://531c01984bc2.ngrok.io/getObs";
    setState(() {
      IP = stringValue;
      print("set state");
      print(IP);
    });
  }

  @override
  void initState() {
    getStringValuesSF();
  }

  Future<InvoiceJSON> _sendToServer() async{
    // var request = http.MultipartRequest('POST', Uri.parse("https://531c01984bc2.ngrok.io/getObs"));
    print("IN send to Server: " + IP);
    String url = IP + "/getObs";
    print("URL: " + url);
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          widget.img.path,
        )
    );
    InvoiceJSON inv = new InvoiceJSON();
    var res = await request.send();
    print(res.statusCode);
    if(res.statusCode == 200) {
      // print(res.stream.bytesToString());
      await http.Response.fromStream(res).then((response) {
        print(response.body);
        try{
          var jsonObj = convert.jsonDecode(response.body);
          print("Printing.. $jsonObj");
          inv.date = jsonObj['output']['date'];
          inv.time = jsonObj['output']['time'];
          inv.total = jsonObj['output']['total'];
          inv.CompanyName = jsonObj['output']['CompanyName'];
          inv.GSTNumber = jsonObj['output']['GSTNumber'];
          inv.email = jsonObj['output']['email'];
          inv.PhoneNumber = jsonObj['output']['PhoneNumber'];
          inv.InvoiceNumber = jsonObj['output']['InvoiceNumber'];
          inv.currency = jsonObj['output']['currency'];
          print(inv);
        } on Exception catch (e){
          print("Exception occurred!: $e");
        }
      });
      return inv;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invoice data"),
        elevation: 0,
      ),
      body: Container(
          child: FutureBuilder(
              future: _sendToServer(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                // print(snapshot.data);
                if(snapshot.data == null){
                  return Container(
                      decoration: new BoxDecoration(color: Colors.white),
                      child: Center(
                          child: SpinKitFadingCircle(
                              color: AppColor.PRIMARY_BLUE_DARK,
                              size: 150.0
                          )
                      )
                  );
                }else{
                  print(snapshot.data.CompanyName);
                  print(snapshot.data.time);
                  return Container(
                    height:  MediaQuery.of(context).size.height * 0.87,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(top:25, left:10, right:10),
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
                              child: Text(snapshot.data.CompanyName, textAlign: TextAlign.center, style: TextStyle(fontSize: 45, color: AppColor.PRIMARY_BLUE_DARK),)
                          ),
                          Padding(
                              padding: EdgeInsets.only(top:8),
                              child: Text(snapshot.data.PhoneNumber, textAlign: TextAlign.center, style: TextStyle(fontSize: 25, color: AppColor.PRIMARY_BLUE_DARK),)
                          ),
                          Padding(
                              padding: EdgeInsets.only(top:8),
                              child: Text(snapshot.data.email, textAlign: TextAlign.center, style: TextStyle(fontSize: 25, color: AppColor.PRIMARY_BLUE_DARK),)
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
                                  padding: EdgeInsets.only(top:30, left: 40),
                                  child: Text("Date:  " + snapshot.data.date, textAlign: TextAlign.center, style: TextStyle(fontSize: 27, color: AppColor.PRIMARY_BLACK),)
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(top:30, left: 40),
                                  child: Text("Time:  " + snapshot.data.time, textAlign: TextAlign.center, style: TextStyle(fontSize: 27, color: AppColor.PRIMARY_BLACK),)
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(top:30, left: 40),
                                  child: Text("Invoice Number:  " + snapshot.data.InvoiceNumber, textAlign: TextAlign.center, style: TextStyle(fontSize: 27, color: AppColor.PRIMARY_BLACK),)
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(top:30, left: 40),
                                  child: Text("GST Number:  " + snapshot.data.GSTNumber, textAlign: TextAlign.center, style: TextStyle(fontSize: 27, color: AppColor.PRIMARY_BLACK),)
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(top:30, left: 40),
                                  child: Text("Total Amount:  " + snapshot.data.currency + "  " + snapshot.data.total, textAlign: TextAlign.center, style: TextStyle(fontSize: 27, color: AppColor.PRIMARY_BLACK),)
                              ),
                            ],
                          ),
                        ],
                      ),

                    ),
                  );
                }
              }
          )
      ),

    );
  }
}
