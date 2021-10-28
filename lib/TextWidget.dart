
import 'package:flutter/cupertino.dart';

class TextWidget extends StatefulWidget {
  final TextWidgetController controller;

  TextWidget(this.controller);

  @override
  State<StatefulWidget> createState() => TextWidgetState();
}

class TextWidgetState extends State<TextWidget> {
  @override
  void initState() {
    widget.controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.controller.text);
  }
}

class TextWidgetController extends ChangeNotifier {
  String text = "";

  TextWidgetController({this.text = ""});

  void setText(String text) {
    this.text = text;
    notifyListeners();
  }
}
