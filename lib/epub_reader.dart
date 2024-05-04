import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:epub_reader/custom_menu.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class EpubReaderScreen extends StatefulWidget {
  final String link;
  const EpubReaderScreen({super.key, required this.link});
  @override
  State<EpubReaderScreen> createState() => _EpubReaderScreenState();
}
class _EpubReaderScreenState extends State<EpubReaderScreen> {
  EpubBook? epubBook;
  List<String>? pages = [];
  int currentPageIndex = 0;
  List<List<String>>? chapterPages = [];
  double fontSize = 18;
  String? selectedText;

  @override
  void initState() {
    super.initState();
    loadEpubBook();
  }
  Future<Uint8List> loadEpubFromNetwork(String url) async {
    final response = await http.get(Uri.parse(url));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File('${documentDirectory.path}/book.epub');
    file.writeAsBytesSync(response.bodyBytes);
    return file.readAsBytesSync();
  }
  Future<void> loadEpubBook() async {
    final bookBytes = await loadEpubFromNetwork(widget.link);
    epubBook = await EpubReader.readBook(bookBytes);
    loadChapterContent(0); // Load the first chapter initially
  }
  Future<void> loadChapterContent(int chapterIndex) async {
    final EpubChapter chapter = epubBook!.Chapters![chapterIndex];
    final List<String> chapterContent = chapter.HtmlContent!.split('\n');
    final double screenHeight = MediaQuery.of(context).size.height;
    final List<String> pages = [];
    List<String> currentPage = [];
    double currentPageHeight = 0;
    for (final line in chapterContent) {
      final double lineHeight = _calculateLineHeight(line);
      if (currentPageHeight + lineHeight <= screenHeight) {
        currentPage.add(line);
        currentPageHeight += lineHeight;
      } else {
        pages.add(currentPage.join('\n'));
        currentPage = [line];
        currentPageHeight = lineHeight;
      }
    }
    if (currentPage.isNotEmpty) {
      pages.add(currentPage.join('\n'));
    }
    setState(() {
      chapterPages = [pages];
      currentPageIndex = 0;
    });
  }
  double _calculateLineHeight(String line) {
    return 24.0;
  }
  void showCommentDialog(String? selectedText) {
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Comments"),
          content: Text(selectedText!),
        );
      },
    );
  }
  void changeChapter(int index) {
    setState(() {
      currentPageIndex = index;
    });
    loadChapterContent(index);
  }
  void onPortraitButtonPressed() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
  void showChaptersDialog() {
    showAlignedDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Align(
            alignment: const AlignmentDirectional(0, -1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 20,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.8,
                    decoration: const BoxDecoration(
                      color: Color(0x4D0F172A),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            epubBook?.Title ?? 'Loading...',
                            style: TextStyle(
                              fontFamily: 'Proxima Nova',
                              fontSize: 23,
                              letterSpacing: 0,
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: epubBook?.Chapters?.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(
                                    epubBook?.Chapters?[index].Title ?? 'Chapter $index',
                                    style: TextStyle(
                                      color: index == currentPageIndex
                                          ? Colors.blue
                                          : Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    changeChapter(index);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  void showTextDialog() {
    showAlignedDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: const AlignmentDirectional(0, 0.65),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10,
                sigmaY: 20,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: const BoxDecoration(
                    color: Color(0x4D0F172A),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Background',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const Row(),
                        const Text(
                          'Font',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        // Add controls for changing font size, etc.
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final List<ContextMenuButtonItem> buttonItems = [
      ContextMenuButtonItem(
        type: ContextMenuButtonType.values[1],
        label: "Post",
        onPressed: () {
          showCommentDialog(selectedText);
        },
      ),
      ContextMenuButtonItem(
        type: ContextMenuButtonType.custom,
        label: "Menu",
        onPressed: () {
          showAlignedDialog(
            barrierColor: Colors.transparent,
            context: context,
            isGlobal: true,
            builder: (context) => CustomMenu(
              context,
              onPortraitButtonPressed: onPortraitButtonPressed,
              onMenuButtonPressed: () => showChaptersDialog(),
              onCommentButtonPressed: () => showCommentDialog(selectedText),
              onTextSizeButtonPressed: () => showTextDialog(),
              context: context,
              text: 'Menu',
            ),
          );
        },
      ),
    ];
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomLeft,
              colors: [
                const Color(0xFF0F172A),
                const Color(0xFF450A0A),
              ],
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                child: Text(
                  epubBook?.Chapters?[currentPageIndex].Title ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Flexible(
                child: GestureDetector(
                  onDoubleTap: () {
                    showAlignedDialog(
                      barrierColor: Colors.transparent,
                      context: context,
                      isGlobal: true,
                      builder: (context) => CustomMenu(
                        context,
                        onMenuButtonPressed: () => showChaptersDialog(),
                        onCommentButtonPressed: () => showCommentDialog(selectedText),
                        onTextSizeButtonPressed: () => showTextDialog(),
                        context: context,
                        text: 'Menu',
                      ),
                    );
                  },
                  child: PageView.builder(
                    onPageChanged: (index) {
                      setState(() {
                        currentPageIndex = index;
                      });
                    },
                    itemCount: chapterPages!.length,
                    itemBuilder: (context, chapterIndex) {
                      final List<String> chapterContent = chapterPages![chapterIndex];
                      final String fullChapterContent = chapterContent.join('\n');
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SelectionArea(
                            contextMenuBuilder: (context, editableTextState) {
                              return AdaptiveTextSelectionToolbar.buttonItems(
                                anchors: editableTextState.contextMenuAnchors,
                                buttonItems: buttonItems,
                              );
                            },
                            onSelectionChanged: (value) {
                              selectedText = value?.plainText;
                            },
                            child: Html(
                              data: fullChapterContent,
                              style: {
                                "body": Style(
                                  color: Colors.white,
                                  fontSize: FontSize(fontSize),
                                ),
                                "h1": Style(
                                  display: Display.none,
                                ),
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

