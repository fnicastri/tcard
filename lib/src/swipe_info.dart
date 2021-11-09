// ignore_for_file: constant_identifier_names

enum SwipeDirection {
  Left,
  Right,
  Up,
  None,
}

class SwipeInfo {
  final int cardIndex;
  final SwipeDirection direction;

  SwipeInfo(
    this.cardIndex,
    this.direction,
  );
}
