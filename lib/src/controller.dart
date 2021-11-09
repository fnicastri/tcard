import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:tcard/src/cards.dart';
import 'package:tcard/src/swipe_info.dart';

/// Card controller
class TCardController {
  TCardState? state;

  void bindState(TCardState state) {
    this.state = state;
  }

  int get index => state?.frontCardIndex ?? 0;

  void forward({SwipeDirection? direction}) {
    direction ??=
        Random().nextBool() ? SwipeDirection.Left : SwipeDirection.Right;

    state!.swipeInfoList.add(SwipeInfo(state!.frontCardIndex, direction));
    state!.runChangeOrderAnimation();
  }

  back() {
    state!.runReverseOrderAnimation();
  }

  void mergeDecks({
    required List<Widget> cards,
    int frontItemsToRetain = 0,
  }) {
    List<Widget> newDeck = (state?.cards ?? []) + cards;
    final ids = <String>{};
    newDeck.retainWhere((x) => ids.add(x.key.toString()));
    if (state?.cards != null) {
      state!.cards = newDeck;
    }
  }

  void updateDeck({
    required List<Widget> cards,
    int frontItemsToRetain = 0,
  }) {
    List<Widget> frontDeck = [];
    if (frontItemsToRetain > 0 &&
        state?.frontCardIndex != null &&
        state?.cards != null) {
      final stateCards = state!.cards;
      int startIndex = state!.frontCardIndex;
      int endIndex = startIndex + frontItemsToRetain;
      endIndex =
          endIndex <= stateCards.length ? endIndex : stateCards.length - 1;
      frontDeck = state!.cards.getRange(0, endIndex).toList();
    }
    List<Widget> newDeck = List.from(frontDeck);
    final frontDeckKeys = <String>{};
    for (var element in frontDeck) {
      frontDeckKeys.add(element.key.toString());
    }
    cards.retainWhere((x) => frontDeckKeys.add(x.key.toString()));
    newDeck.addAll(cards);
    if (state?.cards != null) {
      // state!.reset(cards: newDeck);
      state!.cards = newDeck;
    }
  }

  get reset => state!.reset;

  void dispose() {
    state = null;
  }
}
