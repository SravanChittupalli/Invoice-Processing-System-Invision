
import 'package:flutter/material.dart';
import 'package:invoice_x_vision/views/home.dart';
import 'package:invoice_x_vision/views/settings.dart';



class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {


  int _selectedIndex = 0; //by default -> Home
  List<Widget>__navBarOptions = <Widget>[
    Home(),
    Text("History Reports"),
    Settings()];

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: __navBarOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar( type: BottomNavigationBarType.fixed, items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.add_photo_alternate_rounded),
          title: Text("Upload"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article_rounded),
          title: Text("Records"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text("Settings"),
        ),
      ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
