import 'package:mina_reader/book_library/model/section.dart';

class Book {
  final String title, assetFolder;
  final List<Section> sections;

  Book(
      {required this.sections, required this.assetFolder, required this.title});

  isLittleBooks() {
    return assetFolder == 'kucuk_kitaplar';
  }

  removeTXTFromSectionFileName(int index) {
    return sections[index].fileName.replaceAll('.txt', '');
  }

  getHighlightFileName(int index) {
    try {
      if (isLittleBooks()) {
        return assetFolder + "_section_$index";
      } else {
        final bookNameParts = sections[index].fileName.split("-");

        final sectionNumber = bookNameParts.firstWhere((element) {
          return int.parse(element, onError: (element) {
                return -1;
              }) >
              0;
        });

        return assetFolder + "_" + sectionNumber;
      }
    } catch (e) {
      return "${assetFolder}_$index";
    }
  }
}
