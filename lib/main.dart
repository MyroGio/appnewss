import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const Center(child: Text("HomePage")),
      const AddNewsPage(),
      const Center(child: Text("Profile")),
    ];

    return CupertinoApp(
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: GlassScaffold(
        bottomBar: GlassTabBar.bottom(
          settings: const LiquidGlassSettings(chromaticAberration: 1),
          tabs: const [
            GlassTab(
              icon: FaIcon(FontAwesomeIcons.house),
              activeIcon: Icon(CupertinoIcons.house_fill, color: CupertinoColors.systemBlue),
            ),
            GlassTab(
              icon: Icon(CupertinoIcons.add_circled),
              activeIcon: Icon(CupertinoIcons.add_circled_solid, color: CupertinoColors.systemBlue),
            ),
            GlassTab(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill, color: CupertinoColors.systemBlue),
            ),
          ],
          selectedIndex: selectedIndex,
          onTabSelected: (page) {
            setState(() {
              selectedIndex = page;
            });
          },
        ),
        body: SafeArea(child: pages[selectedIndex]),
      ),
    );
  }
}

class AddNewsPage extends StatefulWidget {
  const AddNewsPage({super.key});

  @override
  State<AddNewsPage> createState() => _AddNewsPageState();
}

class _AddNewsPageState extends State<AddNewsPage> {
  List<Map<String, String>> publishedNews = [];

  void _showCreateNewsDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    final TextEditingController bodyController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(dialogContext).size.width * 0.88,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Create News",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CupertinoTextField(
                    controller: titleController,
                    placeholder: "Title",
                    placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
                    style: const TextStyle(color: CupertinoColors.white, fontSize: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  CupertinoTextField(
                    controller: authorController,
                    placeholder: "Author",
                    placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
                    style: const TextStyle(color: CupertinoColors.white, fontSize: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  CupertinoTextField(
                    controller: bodyController,
                    placeholder: "Body...",
                    placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
                    style: const TextStyle(color: CupertinoColors.white, fontSize: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    maxLines: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Color(0xFFFF453A),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (titleController.text.trim().isNotEmpty) {
                            setState(() {
                              publishedNews.add({
                                "title": titleController.text,
                                "author": authorController.text,
                                "body": bodyController.text,
                              });
                            });
                            Navigator.pop(dialogContext);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(
                            "Publish",
                            style: TextStyle(
                              color: Color(0xFF0A84FF),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                "News Feed",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            const Divider(color: CupertinoColors.systemGrey4),

            Expanded(
              child: publishedNews.isEmpty
                  ? const Center(child: Text("No news published yet."))
                  : ListView.builder(
                itemCount: publishedNews.length,
                padding: const EdgeInsets.only(bottom: 180),
                itemBuilder: (context, index) {
                  final item = publishedNews[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.darkBackgroundGray,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CupertinoColors.systemGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["title"] ?? "",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "By: ${item["author"]}",
                          style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                        ),
                        const SizedBox(height: 8),
                        Text(item["body"] ?? ""),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        Positioned(
          bottom: 110,
          right: 20,
          child: GestureDetector(
            onTap: _showCreateNewsDialog,
            child: Container(
              height: 52,
              width: 52,
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.add,
                color: CupertinoColors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}