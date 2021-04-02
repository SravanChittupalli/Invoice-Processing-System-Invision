import 'package:flutter/material.dart';
import 'package:invoice_x_vision/views/home.dart';
import 'package:splashscreen/splashscreen.dart';

import 'assets/color.dart';
import 'nav.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // runApp(SplashScreenPage());
  runApp(MyApp());
}


// class SplashScreenPage extends StatefulWidget {
//   @override
//   _SplashScreenPageState createState() => _SplashScreenPageState();
// }
//
// class _SplashScreenPageState extends State<SplashScreenPage> {
//   @override
//   Widget build(BuildContext context) {
//
//     return MaterialApp(
//         theme: ThemeData(
//             appBarTheme: AppBarTheme(color: ThemeData.dark().canvasColor),
//             textSelectionColor: Colors.blueGrey,
//             floatingActionButtonTheme: FloatingActionButtonThemeData(
//                 backgroundColor: ThemeData.dark().canvasColor)),
//         home:SplashScreen(
//             seconds: 6,
//             navigateAfterSeconds: new MyApp(),
//             title: new Text('InvoiceXvision:Invision',
//               style: new TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 30.0
//               ),),
//             image: new Image.network('https://i.postimg.cc/HsCsnCGj/app-name.png'),
//             backgroundColor: Colors.white,
//             styleTextUnderTheLoader: new TextStyle(),
//             photoSize: 200.0,
//             onClick: ()=>print("Loading..."),
//             loaderColor: AppColor.PRIMARY_BLUE_DARK
//         ) ,
//     );
//   }
// }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: NavBar(),
      ),
      theme: new ThemeData(
        scaffoldBackgroundColor: AppColor.PRIMARY_WHITE,
      ),
    );
  }
}
