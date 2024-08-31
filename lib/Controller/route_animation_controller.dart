import 'package:flutter/material.dart';

class PopStylePushReplacement extends PageRouteBuilder {
  final Widget page;
  PopStylePushReplacement({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Transition for the incoming page
            var begin = const Offset(-1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            // Transition for the outgoing page
            var outgoingBegin = Offset.zero;
            var outgoingEnd = const Offset(1.0, 0.0);
            var outgoingTween = Tween(begin: outgoingBegin, end: outgoingEnd)
                .chain(CurveTween(curve: curve));
            var outgoingOffsetAnimation =
                secondaryAnimation.drive(outgoingTween);

            return Stack(
              children: [
                SlideTransition(
                  position:
                      outgoingOffsetAnimation, // Moves the old page out to the right
                  child: child,
                ),
                SlideTransition(
                  position:
                      offsetAnimation, // Brings the new page in from the left
                  child: page,
                )
              ],
            );
          },
        );
}
