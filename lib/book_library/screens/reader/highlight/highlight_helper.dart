import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mina_reader/book_library/model/highlight.dart';
import 'package:mina_reader/book_library/screens/reader/bloc/reader_bloc.dart';
import 'package:mina_reader/book_library/theme/text_theme.dart';
import '../../../../mina_reader.dart';
import '../../../model/highlight_type.dart';

void addHighlight(TextSelection selection,
    {int color = 0xFFFFCC00,
    required highlight_type type,
    required String sectionFileName}) {
  if (selection.baseOffset == -1) return;
  final newHighlight = Highlight(
      color: color,
      baseOffset: selection.baseOffset,
      extendOffset: selection.extentOffset,
      type: type);

  final _readerBloc = Get.find<ReaderBloc>(tag: sectionFileName);

  _readerBloc.highlights.add(
    newHighlight,
  );

  _readerBloc.highlights.sort((a, b) => a.compareTo(b));

  print(_readerBloc.highlights.last);
  _readerBloc.saveHighlights();
}

void clearHighlights(int sectionIndex, Book book) {
  box.put(book.getHighlightFileName(sectionIndex), null);
  final _readerBloc = Get.find<ReaderBloc>();
  _readerBloc.highlights = [];
  // setState(() {});
}

getTextStyle(Highlight highlight) {
  switch (highlight.type) {
    case highlight_type.underline:
      return readerBaseTextStyle.copyWith(decoration: TextDecoration.underline);
    case highlight_type.bold:
      return readerBaseTextStyle.copyWith(fontWeight: FontWeight.w900);
    case highlight_type.italic:
      return readerBaseTextStyle.copyWith(fontStyle: FontStyle.italic);
    default:
      return readerBaseTextStyle.copyWith(
          backgroundColor: Color(highlight.color));
  }
}
