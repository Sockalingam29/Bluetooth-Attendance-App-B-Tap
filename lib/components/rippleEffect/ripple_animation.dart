// ignore_for_file: unnecessary_import, duplicate_import

import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:att_blue/components/rippleEffect/circle_painter.dart';
import 'package:att_blue/components/rippleEffect/curve_wave.dart';

import 'circle_painter.dart';

class RipplesAnimation extends StatefulWidget {
  const RipplesAnimation({
    Key? key,
    this.size = 108.0,
    this.color = const Color(0xFF673AB7),
    required this.onPressed,
    required this.child,
  }) : super(key: key);
  final double size;
  final Color color;
  final Widget child;
  final VoidCallback onPressed;
  @override
  // ignore: library_private_types_in_public_api
  _RipplesAnimationState createState() => _RipplesAnimationState();
}

class _RipplesAnimationState extends State<RipplesAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _button() {
    return GestureDetector(
        onTap: () {
          widget.onPressed();
        },
        child: Center(
            child: ClipRRect(
          borderRadius: BorderRadius.circular(72),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: <Color>[
                  widget.color,
                  const Color(0xFF673AB7),
                  // Color.lerp(widget.color, Colors.black, 0.2) ?? Colors.black,
                ],
              ),
            ),
            child: ScaleTransition(
                scale: Tween(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const CurveWave(),
                  ),
                ),
                child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(72),
                    ),
                    child: const Icon(Icons.bluetooth,
                        size: 84, color: Colors.white))),
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: CirclePainter(
          _controller,
          color: widget.color,
        ),
        child: SizedBox(
          width: widget.size * 4.125,
          height: widget.size * 4.125,
          child: _button(),
        ),
      ),
    );
  }
}
