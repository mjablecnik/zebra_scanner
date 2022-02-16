import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:zebra_scanner/core/i18n/strings.g.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(color: Colors.blue, height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: GestureDetector(
                  onTap: () => Modular.to.pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                    child: Icon(
                      CupertinoIcons.back,
                      size: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0x4371D0E8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Text(
                translate.example.customDesign.title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Center(
                  child: Text(
                translate.example.customDesign.content,
                style: TextStyle(color: Colors.black, fontSize: 16, decoration: TextDecoration.none),
              )),
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(width: 1))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BottomBarIcon(Icons.person),
                BottomBarIcon(Icons.home),
                BottomBarIcon(Icons.message),
                BottomBarIcon(Icons.settings),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomBarIcon extends StatelessWidget {
  BottomBarIcon(
    this.icon, {
    Key? key,
  }) : super(key: key);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Icon(icon),
    );
  }
}
