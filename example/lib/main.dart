import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mina_reader/book_library/model/menu_button.dart';
import 'package:mina_reader/mina_reader.dart';

void main() {
  MinaReader.initReader();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: BooksScreen(
          highlightMenuColorButtons: [
            HighlightMenuButton(
              label: 'Purple',
              colorIntValue: Colors.deepPurpleAccent.value,
            ),
            HighlightMenuButton(
              label: 'Orange',
              colorIntValue: Colors.deepOrangeAccent.value,
            )
          ],
          title: 'Books',
          booksAssetsFolder: "assets/books/",
          books: [
            Book(
              title: 'Asâ-yı Musa',
              assetFolder: 'asayi_musa',
              sections: [
                Section(
                  title: 'Mukaddimat',
                  fileName: 'mukaddimat.txt',
                ),
                Section(
                    title: 'Birinci Mesele', fileName: 'birinci_mesele.txt'),
                Section(
                  title: 'İkinci Mesele',
                  fileName: 'ikinci_mesele.txt',
                )
              ],
            ),
            Book(
              title: 'Sözler',
              sections: [
                Section(
                  title: 'Birinci Söz',
                  fileName: 'birinci_soz.txt',
                ),
                Section(title: 'İkinci Söz', fileName: 'ikinci_soz.txt'),
                Section(
                  title: 'Üçüncü Söz',
                  fileName: 'ucuncu_soz.txt',
                )
              ],
              assetFolder: 'sozler',
            ),
          ],
        ),
      ),
    );
  }
}
