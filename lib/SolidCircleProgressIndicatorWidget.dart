import 'package:bluetooth_sample/TextWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SolidCircleProgressIndicatorWidget extends StatefulWidget {
  final IndicatorRadiusController controller;

  SolidCircleProgressIndicatorWidget(this.controller);

  @override
  State<StatefulWidget> createState() =>
      SolidCircleProgressIndicatorWidgetState();
}

class SolidCircleProgressIndicatorWidgetState
    extends State<SolidCircleProgressIndicatorWidget>
    with TickerProviderStateMixin {
  double pressure = 0.0;
  TextWidgetController textController = TextWidgetController(text: "");

  Animation<double>? animation;
  AnimationController? controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    widget.controller.addListener(() {
      if (this.mounted) setState(() {});
    });
    animate(pressure, widget.controller.radius);
    pressure = widget.controller.radius;
    super.initState();
  }

  void animate(double begin, double end) {
    Tween<double> _radiusTween = Tween(begin: begin, end: end);

    animation = _radiusTween.animate(controller!)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          //controller.repeat();
        } else if (status == AnimationStatus.dismissed) {
          //controller.forward();
        }
      });
    textController.setText("Pressure: ${animation?.value.toString()}, ");
    controller?.forward();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    animate(pressure, widget.controller.radius);
    return Visibility(
      visible: widget.controller.isVisible,
      child: SizedBox(
        width: 140,
        height: 140,
        child: Center(
          child: Stack(
            children: [
              Container(
                  width: 80,
                  height: 80,
                  child: AnimatedBuilder(
                    animation: animation!,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: SolidCirclePainter(
                          animation!.value,
                        ),
                      );
                    },
                  )),
              Container(
                width: 80,
                height: 80,
                child: CustomPaint(
                  painter: RingPainter(),
                ),
              ),
              TextWidget(textController),
            ],
          ),
        ),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var p = Paint()
      ..color = Color(0xffaa44aa)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(40, 40), 40, p);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class SolidCirclePainter extends CustomPainter {
  double pressure;

  SolidCirclePainter(this.pressure);

  @override
  void paint(Canvas canvas, Size size) {
    double r = (pressure < 45)
        ? (8 / 9) * pressure
        : (45 <= pressure && pressure <= 70)
            ? 40
            : 40 + ((pressure - 70) > 15 ? 15.0 : (pressure - 70));
    print("paint() called with pressure: $pressure, radius: $r");
    var p = Paint()
      ..color = Color((pressure < 45)
          ? 0xfffa9e77
          : (45 < pressure && pressure < 70)
              ? 0xff4EF0D2
              : 0xfffa9e77)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;
    //print("r: $r");
    canvas.drawCircle(Offset(40, 40), r, p);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class IndicatorRadiusController extends ChangeNotifier {
  double radius = 0.0;
  bool isVisible = false;

  void setRadius(double radius) {
    this.radius = radius;
    notifyListeners();
  }

  void setVisibility(bool visible) {
    isVisible = visible;
    notifyListeners();
  }
}
