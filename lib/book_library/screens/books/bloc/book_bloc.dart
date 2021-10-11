import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:mina_reader/book_library/model/book.dart';
import 'package:mina_reader/book_library/model/book_list.dart';

import '../../../../mina_reader.dart';
import '../../sections/SectionScreen.dart';

part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  BookBloc() : super(BookInitial()) {}

  @override
  Stream<BookState> mapEventToState(
    BookEvent event,
  ) async* {
    if (event is BookTapped) {
      yield* _mapBookTappedToState(event);
    }
  }

  Stream<BookState> _mapBookTappedToState(BookTapped event) async* {
    final book = event.book;

    if (book.title == SampleRisaleBookList.littleBooksLabel) {
      gotoLittleBooks(book);
    } else {
      gotoSectionScreen(book);
    }
  }

  void gotoSectionScreen(Book book) {
    Get.to(() => SectionScreen(book));
  }

  void gotoLittleBooks(Book book) {
    Get.to(
      SectionScreen(
        Book(
          sections: book.sections,
          assetFolder: book.assetFolder,
          title: SampleRisaleBookList.littleBooksLabel,
        ),
      ),
    );
  }
}
