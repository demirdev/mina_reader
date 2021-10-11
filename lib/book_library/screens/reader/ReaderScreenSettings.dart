import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mina_reader/book_library/components/scroll_speed_widget.dart';
import 'package:mina_reader/book_library/model/menu_button.dart';
import 'package:mina_reader/book_library/screens/reader/reading_settings_texts.dart';
import 'package:mina_reader/book_library/text_selection_controls.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mina_reader/book_library/theme/text_theme.dart';

class ReaderScreenSettings extends StatefulWidget {
  ReaderScreenSettings({Key? key}) : super(key: key);

  static late final ReadingSettingsTexts texts;

  @override
  _ReaderScreenSettingsState createState() => _ReaderScreenSettingsState();
}

class _ReaderScreenSettingsState extends State<ReaderScreenSettings> {
  String sectionName = " ";

  String highlightFileName = "";

  late List<HighlightMenuButton> buttons;

  @override
  void initState() {
    buttons = MyMaterialTextSelectionControls.loadHighlightColorButtons();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconTheme.of(context).copyWith(color: kBookTitleColor),
        backgroundColor: kBookCardBackgroundColor,
        title: FittedBox(
            child: Text(
          ReaderScreenSettings.texts.readingScreenSettingsTitle,
          style: TextStyle(color: kBookTitleColor),
        )),
      ),
      body: Container(
        padding: EdgeInsets.all(0.02.sw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...labels(),
            ScrollSpeedWidget(onChanged: (newValue) {
              setState(() {});
            }),
            Card(
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text(
                    ReaderScreenSettings.texts.resetLabelNamesToColorNames),
                onTap: () async {
                  for (int i = 0; i < buttons.length; i++) {
                    final butt =
                        MyMaterialTextSelectionControls.defaultColorButtons[i];

                    buttons[i].label = butt.label;
                  }
                  //
                  buttons = MyMaterialTextSelectionControls.defaultColorButtons;

                  // await MyMaterialTextSelectionControls
                  //     .saveHighlightColorButtons(buttons);

                  await MyMaterialTextSelectionControls
                      .deleteHighlightColorButtons();

                  setState(() {});
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  labels() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          ReaderScreenSettings.texts.labelNames,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final title = buttons[index].label;
          return Container(
            color: buttons[index].color,
            child: ListTile(
              title: Text(title),
              onTap: () async {
                HighlightMenuButton button = buttons[index];
                final TextEditingController _controller =
                    TextEditingController();
                _controller.text = button.label;
                Get.defaultDialog(
                    title: ReaderScreenSettings.texts.changeColorLabel,
                    content: Column(
                      children: [
                        TextFormField(
                          controller: _controller,
                          autofocus: true,
                        ),
                      ],
                    ),
                    onConfirm: () {
                      button.label = _controller.text;
                      MyMaterialTextSelectionControls.saveHighlightColorButtons(
                          buttons);
                      Get.back();

                      setState(() {});
                    },
                    textConfirm: ReaderScreenSettings.texts.ok,
                    confirmTextColor: Colors.white,
                    textCancel: ReaderScreenSettings.texts.cancel);
              },
              trailing: Icon(Icons.edit),
            ),
          );
        },
        itemCount: buttons.length,
      ),
    ];
  }
}
