library backdrop_filter_loading;

import 'dart:ui';

import 'package:flutter/material.dart';

class BackdropFilterLoading extends StatefulWidget {
  BackdropFilterLoading({
    @required this.loading,
    this.durationInMiliseconds = 500,
    this.opacity = 0.7,
    @required this.child,
  });

  final bool loading;
  final int durationInMiliseconds;
  final double opacity;
  final Widget child;

  @override
  State<StatefulWidget> createState() => BackdropFilterLoadingState();
}

class BackdropFilterLoadingState extends State<BackdropFilterLoading> {
  List<Color> colorList = [
    Colors.white,
    Colors.grey,
    Colors.white,
    Colors.grey,
    Colors.white,
  ];

  int index = 0;
  Color startColor = Colors.white;
  Color endColor = Colors.grey;
  Alignment begin = Alignment.centerLeft;
  Alignment end = Alignment.centerRight;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        startColor = Colors.grey;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState:
          widget.loading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: Duration(seconds: widget.durationInMiliseconds),
      firstChild: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: Stack(
          children: [
            widget.child,
            AnimatedContainer(
              duration: Duration(seconds: 1),
              onEnd: () {
                setState(() {
                  index = index + 1;
                  // animate the color
                  startColor = colorList[index % colorList.length];
                  endColor = colorList[(index + 1) % colorList.length];
                });
              },
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: begin,
                  end: end,
                  colors: [
                    startColor.withOpacity(widget.opacity),
                    endColor.withOpacity(widget.opacity),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      secondChild: widget.child,
    );
  }
}
