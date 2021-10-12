import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_reader/book_library/model/book.dart';
import 'package:mina_reader/book_library/screens/books/bloc/book_bloc.dart';
import 'package:mina_reader/book_library/screens/sections/SectionScreen.dart';

import 'book_list_tile_widget.dart';

class BooksWidget extends StatelessWidget {
  const BooksWidget({
    Key? key,
    required this.books,
  }) : super(key: key);

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: BlocProvider.of<BookBloc>(context),
      listener: (BuildContext context, BookState state) {
        if (state is BookGoToSection) {
          if (state.bookType == BookTypes.normalBook) {
            gotoSectionScreen(context, state);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 4.0, mainAxisSpacing: 4.0),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                BlocProvider.of<BookBloc>(context)
                    .add(BookTapped(books[index]));
              },
              child: BookListTileWidget(book: books[index]),
            );
          },
          itemCount: books.length,
        ),
      ),
    );
  }

  void gotoSectionScreen(BuildContext context, BookGoToSection state) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SectionScreen(state.book)),
    );
  }
}
