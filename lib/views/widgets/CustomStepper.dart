import 'package:flutter/material.dart';
import 'package:beautician_app/utils/colors.dart';

class CustomStepper extends StatelessWidget {
  final List<String> listStep;
  final int step;

  const CustomStepper({super.key, required this.listStep, required this.step});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70, 
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                for (int i = 0; i < listStep.length - 1; i++)
                  Expanded(
                    child: Row(
                      children: [
                        circleStepper(i),
                        Expanded(child: lineStepper(i)),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: circleStepper(listStep.length - 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < listStep.length - 1; i++)
                  Expanded(child: stepperTitle(i)),
                stepperTitle(listStep.length - 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget stepperTitle(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          listStep[index],
          style: TextStyle(
            color: index <= step ? Colors.black : Colors.black.withOpacity(.5),
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget lineStepper(int index) {
    return Container(
      width: double.infinity,
      height: 5,
      child: CustomPaint(
        painter: step > index ? SolidLinePainter() : DashedLinePainter(),
      ),
    );
  }

  Widget circleStepper(int index) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: step >= index ? null : Border.all(color: Colors.black),
          color: index > step ? Colors.transparent : kPrimaryColor,
        ),
        child: step >= index
            ? const Icon(
          Icons.check,
          color: Colors.white,
          size: 20,
        )
            : null,
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 5, dashSpace = 5;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height / 2), Offset(startX + dashWidth, size.height / 2), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SolidLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = kPrimaryColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
