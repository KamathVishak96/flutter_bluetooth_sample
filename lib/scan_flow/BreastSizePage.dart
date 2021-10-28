import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../Models.dart';
import 'bloc/ScanStreamBloc.dart';

class BreastSizePage extends StatefulWidget {
  final void Function(int ub, int lb) onBreastSizeSet;

  BreastSizePage({
    Key? key,
    required this.onBreastSizeSet,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => BreastSizePageState();
}

class BreastSizePageState extends State<BreastSizePage> {
  int upperBust = 0;
  int lowerBust = 0;
  ScanDetails? scanDetails;

  List<int> ubSizes = [
    0,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
  ];
  List<int> lbSizes = [
    0,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
  ];

  @override
  void initState() {
    scanDetails = context.read<ScanStreamBloc>().scanDetails;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(scanDetails?.breastType ?? ""),
              DropdownButton<int>(
                hint: Text("Upper Bust"),
                value: upperBust,
                onChanged: (int? value) {
                  setState(() {
                    if (value != null) upperBust = value;
                  });
                },
                items: ubSizes.map((int size) {
                  return DropdownMenuItem<int>(
                    value: size,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          size.toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              DropdownButton<int>(
                hint: Text("Lower Bust"),
                value: lowerBust,
                onChanged: (int? value) {
                  setState(() {
                    if (value != null) lowerBust = value;
                  });
                },
                items: lbSizes.map((int size) {
                  return DropdownMenuItem<int>(
                    value: size,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          size.toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Positioned(
            bottom: 16,
            right: 16,
            child: MaterialButton(
              child: Text("Confirm"),
              onPressed: lowerBust != null && upperBust != null
                  ? () {
                      widget.onBreastSizeSet(upperBust, lowerBust);
                    }
                  : null,
            ))
      ],
    );
  }
}
