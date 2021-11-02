import 'package:flutter/material.dart';

import 'swipe_info.dart';

/// Card Sizes
class CardSizes {
  static Size front(BoxConstraints constraints) {
    return Size(constraints.maxWidth * 0.95, constraints.maxHeight * 0.95);
    return Size(constraints.maxWidth * 0.9, constraints.maxHeight * 0.9);
  }

  static Size middle(BoxConstraints constraints) {
    return Size(constraints.maxWidth * 0.85, constraints.maxHeight * 0.9);
    return Size(constraints.maxWidth * 0.85, constraints.maxHeight * 0.9);
  }

  static Size back(BoxConstraints constraints) {
    return Size(constraints.maxWidth * 0.8, constraints.maxHeight * 0.9);
    return Size(constraints.maxWidth * 0.8, constraints.maxHeight * 0.9);
  }
}

/// Card Alignments
class CardAlignments {
  static Alignment front = const Alignment(0.0, -0.0);
  static Alignment middle = const Alignment(0.0, 0.0);
  static Alignment back = const Alignment(0.0, 0.0);
}

/// Card Forward Animations
class CardAnimations {
  /// The first card's disappearance animation
  static Animation<Alignment> frontCardDisappearAnimation(
    AnimationController parent,
    Alignment beginAlignment,
    SwipeInfo info,
  ) {
    double x, y;
    switch (info.direction) {
      case SwipeDirection.Left:
        x = beginAlignment.x - 40.0;
        y = 0.0;
        break;
      case SwipeDirection.Right:
        x = beginAlignment.x + 40.0;
        y = 0.0;
        break;
      case SwipeDirection.Up:
        y = beginAlignment.y - 50.0;
        x = 0.0;
        break;
      case SwipeDirection.None:
        x = 0.0;
        y = 0.0;
        break;
    }
    return AlignmentTween(
      begin: beginAlignment,
      end: Alignment(
        x,
        y,
      ),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  /// Intermediate card location conversion animation
  static Animation<Alignment> middleCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.middle,
      end: CardAlignments.front,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  /// Intermediate card size transform animation
  static Animation<Size?> middleCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.middle(constraints),
      end: CardSizes.front(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  /// Last face card position conversion animation
  static Animation<Alignment> backCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.back,
      end: CardAlignments.middle,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }

  /// Last face card size transform animation
  static Animation<Size?> backCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.back(constraints),
      end: CardSizes.middle(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }
}

/// Card Backward Animations
class CardReverseAnimations {
  /// Adventive animation of the front card
  static Animation<Alignment> frontCardShowAnimation(
    AnimationController parent,
    Alignment endAlignment,
    SwipeInfo info,
  ) {
    double x, y;
    switch (info.direction) {
      case SwipeDirection.Left:
        x = endAlignment.x - 30.0;
        y = 0.0;
        break;
      case SwipeDirection.Right:
        x = endAlignment.x + 30.0;
        y = 0.0;
        break;
      case SwipeDirection.Up:
        y = endAlignment.y - 30.0;
        x = 0.0;
        break;
      case SwipeDirection.None:
        x = 0.0;
        y = 0.0;
        break;
    }
    return AlignmentTween(
      begin: Alignment(x, y),
      end: endAlignment,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  /// Intermediate card location conversion animation
  static Animation<Alignment> middleCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.front,
      end: CardAlignments.middle,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  /// Intermediate card size transform animation
  static Animation<Size?> middleCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.front(constraints),
      end: CardSizes.middle(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  /// Last face card position conversion animation
  static Animation<Alignment> backCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.middle,
      end: CardAlignments.back,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }

  /// Last face card size transform animation
  static Animation<Size?> backCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.middle(constraints),
      end: CardSizes.back(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }
}
