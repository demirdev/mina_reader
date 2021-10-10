import 'package:flutter/material.dart';
import 'package:mina_reader/book_library/model/book.dart';
import 'package:mina_reader/book_library/theme/text_theme.dart';

class BookListTileWidget extends StatelessWidget {
  const BookListTileWidget({
    Key? key,
    required this.book,
  }) : super(key: key);

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: kBookCardBackgroundColor,
      child: Center(
          child: Text(
        book.title,
        style: bookNameTextStyle,
      )),
    );
  }
}
