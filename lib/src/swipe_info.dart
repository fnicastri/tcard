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
