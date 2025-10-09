// stoqle_text_post_page.dart
// Apple-like text-post page for Stoqle — left-centered typing, larger font, and auto-scaling text to avoid hiding.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stoqle/component/colors/color.dart';
import 'dart:ui';

import 'background.dart';

class StoqleTextPostPage extends StatefulWidget {
  const StoqleTextPostPage({Key? key}) : super(key: key);

  @override
  State<StoqleTextPostPage> createState() => _StoqleTextPostPageState();
}

class _StoqleTextPostPageState extends State<StoqleTextPostPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _cardKey = GlobalKey();

  late final AnimationController _cursorController;

  // dynamic font sizing
  double _fontSize = 24.0; // default large font
  static const double _minFontSize = 14.0;
  static const double _maxFontSize = 28.0;

  // to avoid repeated heavy recalculations
  Size? _lastCardSize;
  String _lastMeasuredText = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      // trigger rebuild & font adjust when text changes
      _adjustFontSizeIfNeeded();
      setState(() {});
    });
    _focusNode.addListener(() {
      // adjust when focus changes (keyboard may show/hide affecting available size)
      _adjustFontSizeIfNeeded();
      setState(() {});
    });

    // blinking animation for simulated caret on placeholder
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  void _onBack() => Navigator.of(context).maybePop();

  void _onNext() {
    final text = _controller.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TextBackgroundPickerPage(initialText: "$text"),
      ),
    );
    // Navigator.of(context).pop(text);
  }

  bool get _keyboardVisible => MediaQuery.of(context).viewInsets.bottom > 0;

  final Gradient _pageGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEAF9EA),
      Color.fromARGB(255, 240, 237, 237),
      Color(0xFFF6FFF4),
    ],
  );

  /// or the minimum font size is reached.
  void _adjustFontSizeIfNeeded() {
    // schedule after current frame so we have up-to-date size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cardContext = _cardKey.currentContext;
      if (cardContext == null) return;
      final rb = cardContext.findRenderObject() as RenderBox?;
      if (rb == null) return;
      final size = rb.size;

      // if nothing changed (size or text) avoid recalculation
      if (_lastCardSize == size && _lastMeasuredText == _controller.text)
        return;

      _lastCardSize = size;
      _lastMeasuredText = _controller.text;

      final horizontalPadding = 28.0; // matches container padding
      final verticalPadding = 28.0;
      final availableWidth = (size.width - horizontalPadding).clamp(
        50.0,
        double.infinity,
      );
      final availableHeight = (size.height - verticalPadding).clamp(
        20.0,
        double.infinity,
      );

      // start with max font size and reduce until it fits.
      double candidate = _maxFontSize;
      final textToMeasure = _controller.text.isEmpty ? 'A' : _controller.text;

      // Conservative safety limit
      int loopGuard = 0;
      while (loopGuard < 40) {
        loopGuard++;
        final span = TextSpan(
          text: textToMeasure,
          style: TextStyle(
            fontSize: candidate,
            height: 1.18, // line height factor
            fontWeight: FontWeight.normal,
          ),
        );

        final tp = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
        );

        tp.layout(maxWidth: availableWidth);

        // If the content height fits, accept candidate.
        if (tp.height <= availableHeight || candidate <= _minFontSize) {
          break;
        } else {
          candidate -= 1.0; // step down font size
          if (candidate < _minFontSize) {
            candidate = _minFontSize;
            break;
          }
        }
      }

      if ((candidate - _fontSize).abs() >= 0.5) {
        // Only setState when change is reasonably large to avoid extra rebuilds
        setState(() {
          _fontSize = candidate.clamp(_minFontSize, _maxFontSize);
        });
      } else {
        // still ensure font size within bounds
        _fontSize = _fontSize.clamp(_minFontSize, _maxFontSize);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _controller.text.length;

    // placeholder visible when there's no text and field is not focused
    final bool placeholderVisible =
        _controller.text.isEmpty && !_focusNode.hasFocus;

    final size = MediaQuery.of(context).size;
    final double boxHeight = _keyboardVisible
        ? size.height / 2.6
        : size.height / 1.7;

    // Ensure we attempt font adjustment when layout changes (e.g., keyboard open/close)
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _adjustFontSizeIfNeeded(),
    );

    return Scaffold(
      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: _onBack,
          child: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: AppColors.kDarkMode,
          ),
        ),
        title: Text('Text note', style: TextStyle(color: AppColors.kDarkMode)),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: _pageGradient),
        ),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.2, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _keyboardVisible
                ? Padding(
                    key: const ValueKey('appbar_next'),
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: _controller.text.trim().isEmpty ? null : _onNext,
                      child: Container(
                        // width: 40,
                        width: MediaQuery.of(context).size.width / 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _controller.text.trim().isEmpty
                              ? AppColors.kDefault.withOpacity(0.5)
                              : AppColors.kDefault,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            'Next',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.lightBackground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(gradient: _pageGradient),
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          kToolbarHeight + 10,
                          18,
                          20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card with key for measurement
                            AnimatedContainer(
                              key: _cardKey,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              height: boxHeight,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Stack(
                                children: [
                                  // Left-centered placeholder (with simulated caret)
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 260),
                                    switchInCurve: Curves.easeOut,
                                    switchOutCurve: Curves.easeIn,
                                    child: placeholderVisible
                                        ? GestureDetector(
                                            onTap: () {
                                              _focusNode.requestFocus();
                                              // place caret at start
                                              _controller.selection =
                                                  const TextSelection.collapsed(
                                                    offset: 0,
                                                  );
                                            },
                                            child: Container(
                                              key: const ValueKey(
                                                'placeholder_left',
                                              ),
                                              alignment: Alignment
                                                  .centerLeft, // left-centered
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center, // vertical center
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start, // left align
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      const Text(
                                                        "Share Thoughts",
                                                        style: TextStyle(
                                                          fontSize: 30,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      FadeTransition(
                                                        opacity:
                                                            _cursorController
                                                                .drive(
                                                                  Tween(
                                                                    begin: 0.0,
                                                                    end: 1.0,
                                                                  ),
                                                                ),
                                                        child: Container(
                                                          width: 2,
                                                          height: 28,
                                                          margin:
                                                              const EdgeInsets.only(
                                                                bottom: 2,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  1,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    "Share something or ask...",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),

                                  // Actual TextField: left aligned horizontally, vertically centered, and dynamic font sizing
                                  // contentPadding kept small so left start is close to edge
                                  //
                                  // *** MODIFIED WIDGET ***
                                  // Wrap the TextField in an Align widget to ensure it is always
                                  // centered vertically within the available space.
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextField(
                                      controller: _controller,
                                      focusNode: _focusNode,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      minLines: 6,
                                      // The textAlignVertical property is not needed with the Align widget.
                                      // You can keep it, but it might not be effective on its own.
                                      // textAlignVertical: TextAlignVertical.center,
                                      style: TextStyle(
                                        fontSize: _fontSize,
                                        height: 1.18,
                                        fontFamily: "bold",
                                        color: Colors.black,
                                      ),
                                      cursorColor: AppColors.kDefault,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 6,
                                        ),
                                      ),
                                    ),
                                  ),
                                  //
                                  // *** END OF MODIFIED WIDGET ***
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.tag,
                                        size: 18,
                                        color: kBlack,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Add tag',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: kBlack,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '$charCount',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.kDarkMode,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Floating Next when keyboard not visible
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 24,
                  child: AnimatedOpacity(
                    opacity: _keyboardVisible ? 0 : 1,
                    duration: const Duration(milliseconds: 220),
                    child: IgnorePointer(
                      ignoring: _keyboardVisible,
                      child: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: CupertinoButton.filled(
                            color: AppColors.kDefault,
                            borderRadius: BorderRadius.circular(12),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            onPressed: _controller.text.trim().isEmpty
                                ? null
                                : _onNext,
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 17,
                                color: AppColors.lightBackground,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
