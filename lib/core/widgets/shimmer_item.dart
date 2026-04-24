import 'package:flutter/material.dart';

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.radius = 8,
    this.margin = EdgeInsets.zero,
  });

  final double height;
  final double width;
  final double radius;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: SizedBox(
        height: height,
        width: width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white, // Shimmer.fromColors shu rangni animate qiladi
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
        ),
      ),
    );
  }
}