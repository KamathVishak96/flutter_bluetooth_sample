import 'package:flutter/cupertino.dart';

class ControlledVisibility extends StatefulWidget {

  VisibilityController controller;
  Widget child;

  ControlledVisibility(this.controller, this.child);

  @override
  State<StatefulWidget> createState() => ControlledVisibilityState();

}

class VisibilityController extends ChangeNotifier {
  bool isVisible;

  VisibilityController(this.isVisible);

  void setVisibility(bool isVisible) {
    this.isVisible = isVisible;
    notifyListeners();
  }

}

class ControlledVisibilityState extends State<ControlledVisibility> {

  @override
  void initState() {
    widget.controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: widget.controller.isVisible, child: widget.child);
  }
}