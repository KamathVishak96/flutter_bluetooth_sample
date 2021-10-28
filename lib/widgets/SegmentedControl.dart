import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SegmentedControl extends StatefulWidget {
  final void Function(String side) onValueChanged;
  int segmentedControlValue = 0;

  SegmentedControl({Key? key, required this.onValueChanged, required this.segmentedControlValue}) : super(key: key);

  @override
  _SegmentedControlState createState() => _SegmentedControlState();
}

class _SegmentedControlState extends State<SegmentedControl> {

  Widget segmentedControl() {
    return Container(
      width: 80,
      height: 64,
      child: CupertinoSlidingSegmentedControl(
          groupValue: widget.segmentedControlValue,
          backgroundColor: Colors.blue.shade200,
          children: const <int, Widget>{
            0: Text('Left'),
            1: Text('Right'),
          },
          onValueChanged: (int? value) {
            setState(() {
              widget.segmentedControlValue = value ?? 0;
              widget.onValueChanged(value == 0 ? "Left" : "Right");
            });
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return segmentedControl();
  }
}
