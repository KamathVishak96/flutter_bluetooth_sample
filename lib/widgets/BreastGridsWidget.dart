import 'package:bluetooth_sample/Models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BreastGridsWidget extends StatefulWidget {
  List<ScanTile> grids;
  int selectedPos = 0;
  String? breastSide;
  int boxSize;
  final void Function(int pos) onItemClicked;
  final BreastGridsWidgetController? controller;

  BreastGridsWidget(
      {Key? key,
      required this.onItemClicked,
      required this.breastSide,
      required this.controller,
      required this.grids,
      this.boxSize = 40})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => BreastGridsWidgetState();
}

class BreastGridsWidgetState extends State<BreastGridsWidget> {
  @override
  void initState() {
    widget.controller?.addListener(() {
      widget.grids = widget.controller?.grids ?? [];
      widget.selectedPos = widget.controller?.selectedPosition ?? -1;
      widget.breastSide = widget.controller?.breastSide;
      setState(() {});
    });
    widget.grids = widget.controller?.grids ?? [];
    widget.selectedPos = widget.controller?.selectedPosition ?? -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      width: widget.boxSize * 5.0,
      height: widget.boxSize * 6.0,
      child: GridView.count(
        physics: null,
        shrinkWrap: false,
        crossAxisCount: 5,
        children: widget.controller?.grids.map((item) {
          int index = widget.controller?.grids.indexOf(item) ?? -1;
          return InkWell(
            child: Container(
                decoration: BoxDecoration(
              color: item.data != null && item.data?.isAbnormal == true
                  ? Colors.red
                  : item.data != null
                      ? Colors.green
                      : widget.selectedPos == index
                          ? Colors.white
                          : Colors.white,
              border: widget.selectedPos == index
                  ? Border.all(
                      color: Colors.green,
                      width: 2,
                    )
                  : Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
            )),
            onTap: () {
              widget.onItemClicked(index);
            },
          );
        }).toList() ?? [],
      ),
    );
  }

  BoxDecoration dividerDecoration(int index, int gridViewCrossAxisCount) {
    return BoxDecoration(
      border: Border(
        left: BorderSide(
          color: index <= gridViewCrossAxisCount
              ? Colors.grey
              : Colors.transparent,
          width: 1,
        ),
        top: BorderSide(
          color: index >= gridViewCrossAxisCount
              ? Colors.grey
              : Colors.transparent,
          width: 1,
        ),
        right: BorderSide(
          color: index == gridViewCrossAxisCount
              ? Colors.grey
              : Colors.transparent,
        ),
        bottom: BorderSide(
          color: index == gridViewCrossAxisCount
              ? Colors.grey
              : Colors.transparent,
        ),
      ),
    );
  }
}

class BreastGridsWidgetController extends ChangeNotifier {
  List<ScanTile> grids;
  int selectedPosition = -1;
  String breastSide;

  BreastGridsWidgetController(this.grids, this.breastSide);

  void setGrids(List<ScanTile> grids) {
    this.grids = grids;
    notifyListeners();
  }

  void setSelectedPosition(int pos) {
    selectedPosition = pos;
    notifyListeners();
  }

  void setBreastSide(String side) {
    breastSide = side;
    notifyListeners();
  }
}
