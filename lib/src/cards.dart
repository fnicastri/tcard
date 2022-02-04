// ignore_for_file: unnecessary_getters_setters

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:tcard/src/animations.dart';
import 'package:tcard/src/controller.dart';
import 'package:tcard/src/swipe_info.dart';

typedef ForwardCallback = Function(int index, SwipeInfo info, dynamic card);
typedef BackCallback = Function(int index, SwipeInfo info);
typedef EndCallback = Function();

/// Card list
class TCard extends StatefulWidget {
  /// Card size
  final Size size;

  /// Card list
  final List<Widget> cards;

  /// Forward callback method
  final ForwardCallback? onForward;

  /// Backward callback method
  final BackCallback? onBack;

  /// End callback method
  final EndCallback? onEnd;

  /// Card controller
  final TCardController? controller;

  /// Control the Y axis
  final bool lockYAxis;

  /// How quick should it be slided? less is slower. 10 is a bit slow. 20 is a quick enough.
  final double slideSpeed;

  /// How long does it have to wait until the next slide is sliable? less is quicker. 100 is fast enough. 500 is a bit slow.
  final int delaySlideFor;

  /// Overlay to show during slide right
  final Widget? slideRightOverlay;

  /// Overlay to show during slide left
  final Widget? slideLeftOverlay;

  /// Overlay to show during slide up
  final Widget? slideUpOverlay;

  const TCard({
    Key? key,
    required this.cards,
    this.controller,
    this.onForward,
    this.onBack,
    this.onEnd,
    this.lockYAxis = false,
    this.slideSpeed = 20,
    this.delaySlideFor = 500,
    this.size = const Size(380, 400),
    this.slideRightOverlay,
    this.slideLeftOverlay,
    this.slideUpOverlay,
  })  : assert(cards.length > 0),
        super(key: key);

  @override
  TCardState createState() => TCardState();
}

class TCardState extends State<TCard> with TickerProviderStateMixin {
  //  Initial card list
  List<Widget> _cards = [];

  set cards(List<Widget> value) {
    _cards = value;
  }

  List<Widget> get cards => _cards;

  // Card swipe directions
  final List<SwipeInfo> _swipeInfoList = [];
  List<SwipeInfo> get swipeInfoList => _swipeInfoList;

  // Index of the front card
  int _frontCardIndex = 0;
  int get frontCardIndex => _frontCardIndex;

  // The position of the front card
  Alignment _frontCardAlignment = CardAlignments.front;
  // The rotation angle of the front card
  double _frontCardRotation = 0.0;
  // Card position change animation controller
  late AnimationController _cardChangeController;
  // Card position recovery animation controller
  late AnimationController _cardReverseController;
  // Card rebound animation
  late Animation<Alignment> _reboundAnimation;
  // Card rebound animation controller
  late AnimationController _reboundController;
  // Front card
  Widget _frontCard(BoxConstraints constraints) {
    Widget child =
        _frontCardIndex < _cards.length ? _cards[_frontCardIndex] : Container();
    bool forward = _cardChangeController.status == AnimationStatus.forward;
    bool reverse = _cardReverseController.status == AnimationStatus.forward;
    SwipeDirection? a = _judgeShowOverlay();
    Widget rotate = Transform.rotate(
      angle: (math.pi / 180.0) * _frontCardRotation,
      child: SizedBox.fromSize(
        size: CardSizes.front(constraints),
        child: Stack(alignment: AlignmentDirectional.center, children: [
          child,
          if (a == SwipeDirection.Right) widget.slideRightOverlay!,
          if (a == SwipeDirection.Left) widget.slideLeftOverlay!,
          if (a == SwipeDirection.Up) widget.slideUpOverlay!,
        ],),
      ),
    );

    if (reverse) {
      return Align(
        alignment: CardReverseAnimations.frontCardShowAnimation(
          _cardReverseController,
          CardAlignments.front,
          _swipeInfoList[_frontCardIndex],
        ).value,
        child: rotate,
      );
    } else if (forward) {
      return Align(
        alignment: CardAnimations.frontCardDisappearAnimation(
          _cardChangeController,
          _frontCardAlignment,
          _swipeInfoList[_frontCardIndex],
        ).value,
        child: rotate,
      );
    } else {
      return Align(
        alignment: _frontCardAlignment,
        child: rotate,
      );
    }
  }

  // Middle card
  Widget _middleCard(BoxConstraints constraints) {
    Widget child = _frontCardIndex < _cards.length - 1
        ? _cards[_frontCardIndex + 1]
        : Container();
    bool forward = _cardChangeController.status == AnimationStatus.forward;
    bool reverse = _cardReverseController.status == AnimationStatus.forward;

    if (reverse) {
      return Align(
        alignment: CardReverseAnimations.middleCardAlignmentAnimation(
          _cardReverseController,
        ).value,
        child: SizedBox.fromSize(
          size: CardReverseAnimations.middleCardSizeAnimation(
            _cardReverseController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else if (forward) {
      return Align(
        alignment: CardAnimations.middleCardAlignmentAnimation(
          _cardChangeController,
        ).value,
        child: SizedBox.fromSize(
          size: CardAnimations.middleCardSizeAnimation(
            _cardChangeController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else {
      return Align(
        alignment: CardAlignments.middle,
        child: SizedBox.fromSize(
          size: CardSizes.middle(constraints),
          child: child,
        ),
      );
    }
  }

  // Back card
  Widget _backCard(BoxConstraints constraints) {
    Widget child = _frontCardIndex < _cards.length - 2
        ? _cards[_frontCardIndex + 2]
        : Container();
    bool forward = _cardChangeController.status == AnimationStatus.forward;
    bool reverse = _cardReverseController.status == AnimationStatus.forward;

    if (reverse) {
      return Align(
        alignment: CardReverseAnimations.backCardAlignmentAnimation(
          _cardReverseController,
        ).value,
        child: SizedBox.fromSize(
          size: CardReverseAnimations.backCardSizeAnimation(
            _cardReverseController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else if (forward) {
      return Align(
        alignment: CardAnimations.backCardAlignmentAnimation(
          _cardChangeController,
        ).value,
        child: SizedBox.fromSize(
          size: CardAnimations.backCardSizeAnimation(
            _cardChangeController,
            constraints,
          ).value,
          child: child,
        ),
      );
    } else {
      return Align(
        alignment: CardAlignments.back,
        child: SizedBox.fromSize(
          size: CardSizes.back(constraints),
          child: child,
        ),
      );
    }
  }

  // Determine whether an animation is in progress
  bool _isAnimating() {
    return _cardChangeController.status == AnimationStatus.forward ||
        _cardReverseController.status == AnimationStatus.forward;
  }

  // Run card rebound animation
  void _runReboundAnimation(Offset pixelsPerSecond, Size size) {
    _reboundAnimation = _reboundController.drive(
      AlignmentTween(
        begin: _frontCardAlignment,
        end: CardAlignments.front,
      ),
    );

    final double unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final double unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;
    const spring = SpringDescription(mass: 30.0, stiffness: 1.0, damping: 1.0);
    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _reboundController.animateWith(simulation);
    _resetFrontCard();
  }

  // Run the card forward animation
  void _runChangeOrderAnimation() {
    if (_isAnimating()) {
      return;
    }

    if (_frontCardIndex >= _cards.length) {
      return;
    }

    _cardChangeController.reset();
    _cardChangeController.forward();
  }

  void Function() get runChangeOrderAnimation => _runChangeOrderAnimation;

  // Run card back animation
  void _runReverseOrderAnimation() {
    if (_isAnimating()) {
      return;
    }

    if (_frontCardIndex == 0) {
      _swipeInfoList.clear();
      return;
    }

    _cardReverseController.reset();
    _cardReverseController.forward();
  }

  void Function() get runReverseOrderAnimation => _runReverseOrderAnimation;

  // Execute after the forward animation is completed
  void _forwardCallback() {
    _frontCardIndex++;
    _resetFrontCard();
    if (widget.onForward != null && widget.onForward is Function) {
      widget.onForward!(_frontCardIndex, _swipeInfoList[_frontCardIndex - 1],
          _cards[_frontCardIndex - 1],);
    }

    if (widget.onEnd != null &&
        widget.onEnd is Function &&
        _frontCardIndex >= _cards.length) {
      widget.onEnd!();
    }
  }

  // Back animation callback
  void _backCallback() {
    _resetFrontCard();
    _swipeInfoList.removeLast();
    if (widget.onBack != null && widget.onBack is Function) {
      int index = _frontCardIndex > 0 ? _frontCardIndex - 1 : 0;
      SwipeInfo info = _swipeInfoList.isNotEmpty
          ? _swipeInfoList[index]
          : SwipeInfo(-1, SwipeDirection.None);

      widget.onBack!(_frontCardIndex, info);
    }
  }

  // Reset the position of the front card
  void _resetFrontCard() {
    _frontCardRotation = 0.0;
    _frontCardAlignment = CardAlignments.front;
    setState(() {});
  }

  // Reset all cards
  void reset({List<Widget>? cards}) {
    _cards.clear();
    if (cards != null) {
      _cards.addAll(cards);
    } else {
      _cards.addAll(widget.cards);
    }
    _swipeInfoList.clear();
    _frontCardIndex = 0;
    _resetFrontCard();
  }

  // Stop animations
  void _stop() {
    _reboundController.stop();
    _cardChangeController.stop();
    _cardReverseController.stop();
  }

  // 更新最前面卡片的位置
  void _updateFrontCardAlignment(DragUpdateDetails details, Size size) {
    // 卡片移动速度 widget.slideSpeed
    _frontCardAlignment += Alignment(
      details.delta.dx / (size.width / 2) * widget.slideSpeed,
      widget.lockYAxis
          ? 0
          : details.delta.dy / (size.height / 2) * widget.slideSpeed,
    );

    // Set the rotation angle of the front card
    _frontCardRotation = _frontCardAlignment.x;
    setState(() {});
  }

  // judge whenever show an overlay
  SwipeDirection? _judgeShowOverlay() {
    // Card horizontal distance limit
    const double limit = 10;
    final bool isSwipeLeft = _frontCardAlignment.x < -limit;
    final bool isSwipeRight = _frontCardAlignment.x > limit;
    final bool isSwipeUp = _frontCardAlignment.y < -(limit * 0.8);

    // Judging whether it runs forward animation, otherwise rebound
    if (isSwipeLeft || isSwipeRight || isSwipeUp) {
      if (isSwipeLeft) {
        return SwipeDirection.Left;
      } else if (isSwipeRight) {
        return SwipeDirection.Right;
      } else if (isSwipeUp) {
        return SwipeDirection.Up;
      }
    }
    return null;
  }

  // Judging whether there is an animation
  void _judgeRunAnimation(DragEndDetails details, Size size) {
    // Card horizontal distance limit
    const double limit = 10.0;
    final bool isSwipeLeft = _frontCardAlignment.x < -limit;
    final bool isSwipeRight = _frontCardAlignment.x > limit;
    final bool isSwipeUp = _frontCardAlignment.y < -(limit * 0.8);

    // Judging whether it runs forward animation, otherwise rebound
    if (isSwipeLeft || isSwipeRight || isSwipeUp) {
      _runChangeOrderAnimation();
      if (isSwipeLeft) {
        _swipeInfoList.add(SwipeInfo(_frontCardIndex, SwipeDirection.Left));
      } else if (isSwipeRight) {
        _swipeInfoList.add(SwipeInfo(_frontCardIndex, SwipeDirection.Right));
      } else if (isSwipeUp) {
        _swipeInfoList.add(SwipeInfo(_frontCardIndex, SwipeDirection.Up));
      }
    } else {
      _runReboundAnimation(details.velocity.pixelsPerSecond, size);
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize all incoming cards
    _cards.addAll(widget.cards);

    // Binding controller
    if (widget.controller != null && widget.controller is TCardController) {
      widget.controller!.bindState(this);
    }

    // Initialization forward animation controller
    _cardChangeController = AnimationController(
      duration: Duration(milliseconds: widget.delaySlideFor),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _forwardCallback();
        }
      });

    // Animation controller after initialization
    _cardReverseController = AnimationController(
      duration: Duration(milliseconds: widget.delaySlideFor),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          _frontCardIndex--;
        } else if (status == AnimationStatus.completed) {
          _backCallback();
        }
      });

    // Animation controller initialized rebound
    _reboundController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.delaySlideFor),
    )..addListener(() {
        setState(() {
          _frontCardAlignment = _reboundAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _cardReverseController.dispose();
    _cardChangeController.dispose();
    _reboundController.dispose();
    if (widget.controller != null) {
      widget.controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: widget.size,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Use the LayoutBuilder to get the size of the container,
          // pass a child to calculate card size
          final Size size = MediaQuery.of(context).size;

          return Stack(
            children: <Widget>[
              _backCard(constraints),
              _middleCard(constraints),
              _frontCard(constraints),
              // Use a SizedBox to overwrite the entire area of the parent element
              _cardChangeController.status != AnimationStatus.forward
                  ? SizedBox.expand(
                      child: GestureDetector(
                        onPanDown: (DragDownDetails details) {
                          _stop();
                        },
                        onPanUpdate: (DragUpdateDetails details) {
                          _updateFrontCardAlignment(details, size);
                        },
                        onPanEnd: (DragEndDetails details) {
                          _judgeRunAnimation(details, size);
                        },
                      ),
                    )
                  : const IgnorePointer(),
            ],
          );
        },
      ),
    );
  }
}
