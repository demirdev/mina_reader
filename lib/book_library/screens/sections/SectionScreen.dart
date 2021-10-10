import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:mina_reader/book_library/components/loading.dart';
import 'package:mina_reader/book_library/model/book.dart';
import 'package:mina_reader/book_library/screens/sections/bloc/section_bloc.dart';
import 'package:mina_reader/book_library/theme/text_theme.dart';

import 'widgets/section_list_widget.dart';

class SectionScreen extends StatefulWidget {
  final Book book;

  SectionScreen(this.book, {Key? key}) : super(key: key);

  @override
  _SectionScreenState createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
  late final SectionBloc sectionBloc;

  @override
  void initState() {
    sectionBloc = Get.put(SectionBloc(widget.book));
    sectionBloc.add(SectionGoToLastReadingRequired());
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
            widget.book.title,
            style: TextStyle(color: kBookTitleColor),
          ),
        ),
      ),
      body: BlocProvider<SectionBloc>.value(
        value: sectionBloc,
        child: BlocBuilder<SectionBloc, SectionState>(
          builder: (context, state) {
            if (state is SectionInitial) {
              return SectionList(widget.book);
            } else {
              return Loading();
            }
          },
        ),
      ),
    );
  }
}
