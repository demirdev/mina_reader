import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:mina_reader/book_library/model/book.dart';
import 'package:mina_reader/book_library/screens/sections/helper/name_parsing_helper.dart';

import '../../../../mina_reader.dart';
import '../../reader/book_reader_screen.dart';

part 'section_event.dart';
part 'section_state.dart';

class SectionBloc extends Bloc<SectionEvent, SectionState> {
  final Book book;

  SectionBloc(this.book) : super(SectionInitial());

  @override
  Stream<SectionState> mapEventToState(
    SectionEvent event,
  ) async* {
    if (event is SectionTapped) {
      yield* _mapSectionTappedToState(event);
    }
    if (event is SectionGoToLastReadingRequired) {
      yield* _mapSectionGoToLastReadingRequiredToState(event);
    }
  }

  Stream<SectionState> _mapSectionTappedToState(SectionTapped event) async* {
    gotoReadingScreen(event.sectionIndex, event.title);
  }

  void gotoLastReadingSction() {
    final lastReadedSectionId =
        boxLastReadedSectionId.get(book.assetFolder, defaultValue: -1);
    if (lastReadedSectionId != -1) {
      gotoReadingScreen(
          lastReadedSectionId, book.sections[lastReadedSectionId].title ?? '');
    }
  }

  void gotoReadingScreen(int sectionIndex, String title) {
    saveLastReadedSection(sectionIndex);

    Get.to(() => BookReaderScreen(
          book: book,
          sectionIndex: sectionIndex,
          onTapNextSection: () {
            gotoReadingScreen(
                sectionIndex + 1, book.sections[sectionIndex + 1].title ?? '');
          },
          nextSectionTitle: (sectionIndex + 1) >= book.sections.length
              ? null
              : getSectionTitle(sectionIndex + 1, book),
        ));
  }

  void saveLastReadedSection(int index) {
    boxLastReadedSectionId.put(book.assetFolder, index);
  }

  Stream<SectionState> _mapSectionGoToLastReadingRequiredToState(
      SectionGoToLastReadingRequired event) async* {
    gotoLastReadingSction();
  }
}
