import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:http/http.dart' as http;

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
      const HomePage(),
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String server = "http://192.168.100.218/news_api/";
  List<dynamic> newsFeed = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final uri = "${server}getNews.php";
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        setState(() {
          newsFeed = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching news: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _openArticleDetail(Map<String, dynamic> article) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "ARTICLE DETAILS",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(CupertinoIcons.xmark_circle_fill, color: CupertinoColors.systemGrey),
                  ),
                ],
              ),
            ),
            const Divider(color: CupertinoColors.systemGrey4, height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article["title"] ?? "",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.person_fill, size: 14, color: CupertinoColors.systemBlue),
                        const SizedBox(width: 6),
                        Text(
                          "By ${article["author"] ?? 'Unknown'}",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      article["body"] ?? "",
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "News Feed",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: fetchNews,
                child: const Icon(CupertinoIcons.refresh, size: 22, color: CupertinoColors.systemBlue),
              ),
            ],
          ),
        ),
        const Divider(color: CupertinoColors.systemGrey4, height: 1),
        Expanded(
          child: isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : newsFeed.isEmpty
              ? const Center(child: Text("No news published yet."))
              : ListView.builder(
            itemCount: newsFeed.length,
            padding: const EdgeInsets.only(bottom: 100, top: 12),
            itemBuilder: (context, index) {
              final article = newsFeed[index];

              return GestureDetector(
                onTap: () => _openArticleDetail(article),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CupertinoColors.systemGrey.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article["title"] ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                          color: CupertinoColors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "By: ${article["author"] ?? 'Unknown'}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        article["body"] ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: CupertinoColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Text(
                            "Read full article",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.systemBlue,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 14,
                            color: CupertinoColors.systemBlue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AddNewsPage extends StatefulWidget {
  const AddNewsPage({super.key});

  @override
  State<AddNewsPage> createState() => _AddNewsPageState();
}

class _AddNewsPageState extends State<AddNewsPage> {
  final String server = "http://192.168.100.218/news_api/";

  List<dynamic> publishedNews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getNews();
  }

  Future<void> getNews() async {
    try {
      final uri = "${server}getNews.php";
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        setState(() {
          publishedNews = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching news: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addNews(String title, String author, String body) async {
    try {
      final uri = "${server}addNews.php";
      await http.post(
        Uri.parse(uri),
        body: {
          "title": title,
          "author": author,
          "body": body,
        },
      );
      getNews();
    } catch (e) {
      debugPrint("Error adding news: $e");
    }
  }

  Future<void> editNews(String id, String title, String author, String body) async {
    try {
      final uri = "${server}editNews.php";
      await http.post(
        Uri.parse(uri),
        body: {
          "id": id,
          "title": title,
          "author": author,
          "body": body,
        },
      );
      getNews();
    } catch (e) {
      debugPrint("Error editing news: $e");
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final uri = "${server}deleteNews.php";
      await http.post(
        Uri.parse(uri),
        body: {"id": id},
      );
      getNews();
    } catch (e) {
      debugPrint("Error deleting news: $e");
    }
  }

  void _showNewsDialog({Map<String, dynamic>? newsItem}) {
    final bool isEditing = newsItem != null;
    final TextEditingController titleController = TextEditingController(text: isEditing ? newsItem['title'] : '');
    final TextEditingController authorController = TextEditingController(text: isEditing ? newsItem['author'] : '');
    final TextEditingController bodyController = TextEditingController(text: isEditing ? newsItem['body'] : '');

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(dialogContext).size.width * 0.78,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? "Edit News" : "Create News",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEBEBF5),
                    ),
                  ),
                  const SizedBox(height: 14),

                  CupertinoTextField(
                    controller: titleController,
                    placeholder: "Title",
                    placeholderStyle: const TextStyle(color: Color(0xFF636366), fontSize: 13),
                    style: const TextStyle(color: CupertinoColors.white, fontSize: 13),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),

                  CupertinoTextField(
                    controller: authorController,
                    placeholder: "Author",
                    placeholderStyle: const TextStyle(color: Color(0xFF636366), fontSize: 13),
                    style: const TextStyle(color: CupertinoColors.white, fontSize: 13),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),

                  CupertinoTextField(
                    controller: bodyController,
                    placeholder: "Body...",
                    placeholderStyle: const TextStyle(color: Color(0xFF636366), fontSize: 13),
                    style: const TextStyle(color: CupertinoColors.white, fontSize: 13),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    maxLines: 4,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (isEditing) {
                            deleteTask(newsItem['id'].toString());
                          }
                          Navigator.pop(dialogContext);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(
                            isEditing ? "Delete" : "Cancel",
                            style: TextStyle(
                              color: isEditing ? const Color(0xFFFF453A) : const Color(0xFF8E8E93),
                              fontSize: 14,
                              fontWeight: isEditing ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (titleController.text.trim().isNotEmpty) {
                            if (isEditing) {
                              editNews(
                                newsItem['id'].toString(),
                                titleController.text.trim(),
                                authorController.text.trim(),
                                bodyController.text.trim(),
                              );
                            } else {
                              addNews(
                                titleController.text.trim(),
                                authorController.text.trim(),
                                bodyController.text.trim(),
                              );
                            }
                            Navigator.pop(dialogContext);
                          }
                        },
                        child: Text(
                          isEditing ? "Save" : "Publish",
                          style: const TextStyle(
                            color: Color(0xFF0A84FF),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "News Management",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: getNews,
                    child: const Icon(CupertinoIcons.refresh, size: 22, color: CupertinoColors.systemBlue),
                  ),
                ],
              ),
            ),

            const Divider(color: CupertinoColors.systemGrey4),

            Expanded(
              child: isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : publishedNews.isEmpty
                  ? const Center(child: Text("No news published yet."))
                  : ListView.builder(
                itemCount: publishedNews.length,
                padding: const EdgeInsets.only(bottom: 180),
                itemBuilder: (context, index) {
                  final item = publishedNews[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () {
                        _showNewsDialog(newsItem: item);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: CupertinoColors.darkBackgroundGray,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CupertinoColors.systemGrey.withValues(alpha: 0.3)),
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
                              "By: ${item["author"] ?? 'Unknown'}",
                              style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                            ),
                            const SizedBox(height: 8),
                            Text(item["body"] ?? ""),
                          ],
                        ),
                      ),
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
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showNewsDialog(),
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