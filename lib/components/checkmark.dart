import 'package:checkmark/checkmark.dart';
import 'package:flutter/material.dart';

class CheckMarkPage extends StatefulWidget {
  const CheckMarkPage({Key? key}) : super(key: key);

  @override
  _CheckMarkPageState createState() => _CheckMarkPageState();
}

class _CheckMarkPageState extends State<CheckMarkPage> {
  bool checked = false;
  // set check to true in 2 sec

  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), toggleValue);
  }

  void toggleValue() {
    setState(() {
      checked = !checked;
    });
    // Call toggleValue again after 2 seconds
    Future.delayed(const Duration(milliseconds: 1500), toggleValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          setState(() {
            checked = !checked;
          });
        },
        child: SizedBox(
          height: 72,
          width: 92,
          child: CheckMark(
            active: checked,
            curve: Curves.decelerate,
            duration: const Duration(milliseconds: 1000),
            activeColor: Colors.green,
          ),
        ),
      ),
    );
  }
}
