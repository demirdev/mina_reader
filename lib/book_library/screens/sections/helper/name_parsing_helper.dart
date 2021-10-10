import 'package:mina_reader/book_library/model/book.dart';

String? getSectionTitle(int index, Book book) {
  if (book.sections[index].title != null) {
    return book.sections[index].title;
  }

  // for Risale-i Nur section names
  return book.assetFolder == 'kucuk_kitaplar'
      ? book.sections[index].fileName.replaceAll('.txt', '')
      : book.sections[index].fileName.substring(
          book.sections[index].fileName.lastIndexOf("-") + 1,
          book.sections[index].fileName.lastIndexOf(".txt"));
}
