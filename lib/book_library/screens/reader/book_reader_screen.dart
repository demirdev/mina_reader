import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:mina_reader/book_library/components/loading.dart';
import 'package:mina_reader/book_library/components/scroll_speed_widget.dart';
import 'package:mina_reader/book_library/model/book.dart';
import 'package:mina_reader/book_library/model/highlight.dart';
import 'package:mina_reader/book_library/model/menu_button.dart';
import 'package:mina_reader/book_library/screens/reader/bloc/reader_bloc.dart';
import 'package:mina_reader/book_library/screens/reader/widgets/next_section_widget.dart';
import 'package:mina_reader/book_library/screens/sections/helper/name_parsing_helper.dart';
import 'package:mina_reader/book_library/text_selection_controls.dart';
import 'package:mina_reader/book_library/theme/text_theme.dart';

import '../../../mina_reader.dart';
import 'ReaderScreenSettings.dart';
import 'highlight/highlight_helper.dart';

// TODO: lugat icin suanki yontemde dosyalar cok yer kapliyor. ayni kelimeden birden cok kayit olusuyor.
// TODO: lugat kelime anlami goruntulendiginde kapanma duzgun olmuyor.

class BookReaderScreen extends StatefulWidget {
  final Book book;
  final int sectionIndex; // sectionIndex
  final Function onTapNextSection;
  final String? nextSectionTitle;

  const BookReaderScreen(
      {Key? key,
      required this.onTapNextSection,
      this.nextSectionTitle,
      required this.book,
      required this.sectionIndex})
      : super(key: key);

  @override
  _BookReaderScreenState createState() =>
      _BookReaderScreenState(book, sectionIndex);
}

class _BookReaderScreenState extends State<BookReaderScreen>
    with WidgetsBindingObserver {
  late ReaderBloc _readerBloc;
  final Book book;
  final int index;

  TextSelection currentTextSelection =
      TextSelection(baseOffset: -1, extentOffset: -1);
  ScrollController _scrollController = ScrollController();

  final transparentHighlight = Highlight(
      color: Colors.transparent.value, baseOffset: 0, extendOffset: 0);

  TapUpDetails? lastSelectedHighlightGestureDetails;

  bool _isAllReaded = false;

  bool _showScrollSpeed = false;

  _BookReaderScreenState(this.book, this.index);

  @override
  void initState() {
    _readerBloc = Get.put(
        ReaderBloc(
            sectionFileName: book.sections[index].fileName,
            highlightFileName: book.getHighlightFileName(index),
            scrollController: _scrollController,
            bookFolder: book.assetFolder),
        tag: book.sections[index].fileName);

    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addObserver(this);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (WidgetsBinding.instance != null)
      WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _readerBloc.add(ReaderLastLocationChanged(_scrollController.offset));
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _readerBloc,
      child: WillPopScope(
        onWillPop: () async {
          _readerBloc.add(ReaderLastLocationChanged(_scrollController.offset));
          return true;
        },
        child: Scaffold(
          backgroundColor: Color(0xFFFFEDE6B7),
          appBar: AppBar(
            iconTheme: IconTheme.of(context).copyWith(color: kBookTitleColor),
            backgroundColor: kBookCardBackgroundColor,
            title: FittedBox(
                child: Text(
              getSectionTitle(index, book) ??
                  book.removeTXTFromSectionFileName(index),
              style: TextStyle(color: kBookTitleColor),
            )),
            actions: [
              if (_readerBloc.isScrolling)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showScrollSpeed = !_showScrollSpeed;
                    });
                  },
                  icon: RotatedBox(
                    quarterTurns: 1,
                    child: Icon(
                      Icons.settings_ethernet,
                      // color: Colors.white,
                    ),
                  ),
                ),
              IconButton(
                onPressed: () async {
                  await _readerBloc.toggleAutoScroll();
                  setState(() {});
                },
                icon: Icon(
                  _readerBloc.isScrolling
                      ? Icons.stop_circle_outlined
                      : Icons.arrow_downward,
                  // color: Colors.white,
                ),
              ),
              if (_readerBloc.currentSelectedHighlight != null)
                IconButton(
                  onPressed: () {
                    _readerBloc.highlights
                        .remove(_readerBloc.currentSelectedHighlight);
                    _readerBloc.currentSelectedHighlight = null;
                    _readerBloc.saveHighlights();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.highlight_remove,
                    color: Color(_readerBloc.currentSelectedHighlight?.color ??
                        0xFFFFFF),
                  ),
                ),
              IconButton(
                onPressed: () {
                  Get.to(() => ReaderScreenSettings());
                },
                icon: Icon(
                  Icons.settings,
                  // color: Colors.white,
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: NotificationListener(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    _readerBloc.isScrolling) {
                  setState(() {
                    _readerBloc.isScrolling = false;
                    _isAllReaded = true;
                  });
                  _readerBloc
                      .add(ReaderLastLocationChanged(_scrollController.offset));

                  // Future.delayed(Duration(seconds: 1), () {
                  //   toggleAutoScroll(forceScroll: true);
                  // });
                } else if (notification is ScrollEndNotification) {
                  final metrics = notification.metrics;
                  if (metrics.atEdge) {
                    if (metrics.pixels == 0) {
                      // at top
                      if (_isAllReaded) {
                        setState(() {
                          _isAllReaded = false;
                        });
                      }
                      print("nooo pixelsss");
                    } else {
                      if (!_isAllReaded) {
                        setState(() {
                          _isAllReaded = true;
                        });
                      }
                    }
                  }
                }
                return true;
              },
              child: Column(
                children: [
                  if (_showScrollSpeed)
                    ScrollSpeedWidget(
                      onChanged: (newValue) async {
                        await _readerBloc.scrollSpeedChanged(newValue);
                        setState(() {});
                      },
                      onTapClose: () {
                        setState(() {
                          _showScrollSpeed = false;
                        });
                      },
                    ),
                  BlocBuilder<ReaderBloc, ReaderState>(
                    builder: (context, state) {
                      if (state is ReaderReady) {
                        return Expanded(
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Stack(
                                    children: [
                                      GestureDetector(
                                        onScaleStart: (details) =>
                                            _readerBloc.baseScaleFactor =
                                                _readerBloc.scaleFactor,
                                        onScaleUpdate: (details) {
                                          setState(() {
                                            _readerBloc.scaleFactor =
                                                _readerBloc.baseScaleFactor *
                                                    details.scale;
                                          });
                                        },
                                        child: buildSelectableText(),
                                      ),
                                      if (_readerBloc
                                                  .currentSelectedHighlight !=
                                              null &&
                                          lastSelectedHighlightGestureDetails !=
                                              null)
                                        Positioned.fill(
                                          child:
                                              buildSelectionHighlightTextMenu(),
                                        ),
                                    ],
                                  ),
                                  // if (_isAllReaded)
                                  if (widget.nextSectionTitle != null)
                                    NextSectionWidget(
                                        onTapNextSection:
                                            widget.onTapNextSection,
                                        nextSectionTitle:
                                            widget.nextSectionTitle!),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Loading();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  late SelectableText selectableTextWidget;

  SelectableText buildSelectableText() {
    selectableTextWidget = SelectableText.rich(
      TextSpan(
        children:
            //   _readerBloc.highlights.length == 0
            //     ? handleDictionary(_readerBloc.allText)
            //     :
            handleHighlight(_readerBloc.allText),
      ),
      textScaleFactor: _readerBloc.scaleFactor,
      toolbarOptions: ToolbarOptions(copy: false, selectAll: false),
      onTap: () {},
      selectionControls: MyMaterialTextSelectionControls(
          onTapped: onTappedMenuButton,
          currentTextSelection: currentTextSelection),
      onSelectionChanged: (selection, cause) async {
        if (selection.baseOffset == selection.extentOffset)
          findBeforeAndAfterWords(selection);
        if (selection.baseOffset == selection.extentOffset) {
        } else {
          currentTextSelection = selection;
        }
      },
      scrollPhysics: NeverScrollableScrollPhysics(),
    );

    return selectableTextWidget;
  }

  onTappedMenuButton(HighlightMenuButton button) {
    final value = button.color;

    if (!allowInsert(currentTextSelection)) return;

    addHighlight(currentTextSelection, color: value.value, type: button.type);

    currentTextSelection = TextSelection(baseOffset: -1, extentOffset: -1);
    setState(() {});

    if (lastSelectedHighlightGestureDetails != null) {}
    lastSelectedHighlightGestureDetails = null;
  }

  void hideTextSelectionToolbar() {
    if (_readerBloc.currentSelectedHighlight != null) {
      setState(() {
        _readerBloc.currentSelectedHighlight = null;
      });
    }
  }

  handleHighlight(String text) {
    // highlihghtList in bastan sona siralandigi kabul edildi.
    int index = 0;
    final int length = text.length;
    final List<TextSpan> widgets = [];

    for (int i = 0; i < _readerBloc.highlights.length; i++) {
      final highlight = _readerBloc.highlights.elementAt(i);
      if (index == highlight.baseOffset) {
        index = highlight.extendOffset;

        final textStyle = getTextStyle(highlight);

        widgets.add(
          TextSpan(
            text: text.substring(highlight.baseOffset, highlight.extendOffset),
            style: textStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                hideTextSelectionToolbar();

                print("${highlight.baseOffset} ${highlight.extendOffset}");
                setState(() {
                  _readerBloc.currentSelectedHighlight = highlight;
                });
              }
              ..onTapUp = (details) {
                lastSelectedHighlightGestureDetails = details;
                currentTextSelection = TextSelection(
                    baseOffset: highlight.baseOffset,
                    extentOffset: highlight.extendOffset);
                print(details);
              }
              ..onTapDown = (details) {
                if (_readerBloc.currentSelectedHighlight != null) {
                  hideTextSelectionToolbar();
                }
              },
          ),
        );
      } else {
        widgets.add(TextSpan(
            text: text.substring(index, highlight.baseOffset),
            style: getTextStyle(transparentHighlight),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                hideTextSelectionToolbar();

                // Fluttertoast.showToast(msg: dictionaryHighlight.text ?? "");
                // print(dictionaryHighlight);
                // if (  _readerBloc.currentSelectedHighlight != null) {
                //   setState(() {
                //       _readerBloc.currentSelectedHighlight = null;
                //   });
                // }
              }));

        // widgets.addAll(
        //   handleDictionaryInner(index, highlight.extendOffset, text),
        // );
        index = highlight.baseOffset;
        i -= 1;
      }
    }

    if (index != length) {
      widgets.add(TextSpan(
          text: text.substring(index, length),
          style: getTextStyle(transparentHighlight)));
    }

    return widgets;
  }

  void findBeforeAndAfterWords(TextSelection selection) {
    final middleIndex = selection.baseOffset;
    int startIndex = middleIndex - 1;
    int endIndex = middleIndex;

    if (_readerBloc.lugat != null) {
      final meaning = _readerBloc.lugat!.firstWhere((element) {
        // return true;
        return element['s'] <= startIndex && element['e'] >= endIndex;
      });

      Get.defaultDialog(
          title: meaning['o'],
          content: Container(
            width: 0.8.sw,
            height: 0.5.sh,
            child: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    child: ListView(shrinkWrap: true, children: [
                      Text(
                        meaning['m'],
                        style: getTextStyle(transparentHighlight),
                      ),
                    ]),
                  ),
                ),
                // Row(
                //   children: [
                //     IconButton(
                //         icon: Icon(Icons.favorite_border), onPressed: () {}),
                //   ],
                // ),
              ],
            ),
          ));
      return;
    }

    bool find = true;
    bool isFirstSpace = true;

    while (find && startIndex != -1) {
      if (isEndChar(_readerBloc.allText[startIndex])) {
        if (isFirstSpace) {
          find = true;
          isFirstSpace = false;
        } else {
          find = false;
        }
        startIndex--;
      } else {
        startIndex--;
      }
    }

    find = true;
    isFirstSpace = true;

    while (find && endIndex < _readerBloc.allText.length) {
      if (isEndChar(_readerBloc.allText[endIndex])) {
        if (isFirstSpace) {
          find = true;
          isFirstSpace = false;
        } else {
          find = false;
        }
        endIndex++;
      } else {
        endIndex++;
      }
    }

    print("start word:\n" +
        _readerBloc.allText.substring(startIndex + 1, endIndex));

    // print(getMeaning(selection.baseOffset));
  }

  bool isEndChar(String letter) {
    return letter == " " || letter == "\n" || letter == "\0" || letter == "\r";
  }

  bool allowInsert(TextSelection currentTextSelection) {
    _readerBloc.highlights.removeWhere((element) =>
        element.baseOffset >= currentTextSelection.baseOffset &&
        element.extendOffset <= currentTextSelection.extentOffset);

    final first = _readerBloc.highlights.indexWhere((element) =>
        ((currentTextSelection.baseOffset >= element.baseOffset &&
                currentTextSelection.baseOffset <= element.extendOffset) ||
            (currentTextSelection.extentOffset >= element.baseOffset &&
                currentTextSelection.extentOffset <= element.extendOffset)));
    return first == -1;
  }

  buildSelectionHighlightTextMenu() {
    if (lastSelectedHighlightGestureDetails == null) return Container();
    final Rect globalEditableRegion = Rect.fromPoints(
        lastSelectedHighlightGestureDetails!.globalPosition,
        lastSelectedHighlightGestureDetails!.globalPosition);

    final TextSelectionPoint startTextSelectionPoint = TextSelectionPoint(
        lastSelectedHighlightGestureDetails!.localPosition, TextDirection.ltr);
    final TextSelectionPoint endTextSelectionPoint = TextSelectionPoint(
        lastSelectedHighlightGestureDetails!.localPosition, TextDirection.ltr);

    final selectionMidpoint =
        lastSelectedHighlightGestureDetails!.globalPosition;

    final textLineHeight = 1.5;
    final Offset anchorAbove = Offset(
        globalEditableRegion.left + selectionMidpoint.dx,
        globalEditableRegion.top +
            startTextSelectionPoint.point.dy -
            textLineHeight -
            MyMaterialTextSelectionControls.kToolbarContentDistance);
    final Offset anchorBelow = Offset(
      globalEditableRegion.left + selectionMidpoint.dx,
      globalEditableRegion.top +
          endTextSelectionPoint.point.dy +
          MyMaterialTextSelectionControls.kToolbarContentDistanceBelow,
    );

    final myTextSelectionControls = MyMaterialTextSelectionControls(
        onTapped: onTappedMenuButton,
        currentTextSelection: currentTextSelection);

    final zeroOffset = lastSelectedHighlightGestureDetails!.localPosition;
    final zeroOffsetBelow = lastSelectedHighlightGestureDetails!.localPosition;

    return myTextSelectionControls.buildTextSelectionToolbar(
        zeroOffset, zeroOffsetBelow);
  }

  void closeScrollSpeedWidget() {
    if (_showScrollSpeed) _showScrollSpeed = false;
  }
}
