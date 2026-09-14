import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:http/http.dart' as http;

abstract class AppTheme {
  static const Color primaryBlue = Color(0xFF114B97);
  static const Color accentBlue = Color(0xFF0A84FF);
  static const Color alertRed = Color(0xFFE12B2B);

  static const Color backgroundDark = Color(0xFF121214);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color cardDark = Color(0xFF2C2C2E);
  static const Color borderDark = Color(0xFF38383A);

  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textBody = Color(0xFFEBEBF5);
  static const Color textMuted = Color(0xFF8E8E93);

  static const Color tagWorldBg = Color(0xFF1A2634);
  static const Color tagWorldText = Color(0xFF64B5F6);

  static const Color tagTechBg = Color(0xFF1B2E23);
  static const Color tagTechText = Color(0xFF81C784);

  static const TextStyle brandHeaderStyle = TextStyle(
    fontFamily: 'serif',
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: textWhite,
    letterSpacing: -0.5,
  );

  static const TextStyle modalTitleStyle = TextStyle(
    fontFamily: 'serif',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: textWhite,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: textWhite,
  );

  static const TextStyle authorStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: accentBlue,
  );

  static const TextStyle dateStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textMuted,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: textBody,
  );

  static const TextStyle alertBadgeStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: textWhite,
    letterSpacing: 0.8,
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceDark,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: borderDark),
    boxShadow: const [
      BoxShadow(
        color: Color(0x40000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );
}

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
      const Center(child: Text("Profile", style: TextStyle(color: AppTheme.textWhite))),
    ];

    return CupertinoApp(
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTheme.backgroundDark,
        primaryColor: AppTheme.primaryBlue,
      ),
      debugShowCheckedModeBanner: false,
      home: GlassScaffold(
        bottomBar: GlassTabBar.bottom(
          settings: const LiquidGlassSettings(chromaticAberration: 1),
          tabs: const [
            GlassTab(
              icon: FaIcon(FontAwesomeIcons.house, size: 20),
              activeIcon: Icon(CupertinoIcons.house_fill, color: AppTheme.accentBlue),
            ),
            GlassTab(
              icon: Icon(CupertinoIcons.add_circled),
              activeIcon: Icon(CupertinoIcons.add_circled_solid, color: AppTheme.accentBlue),
            ),
            GlassTab(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill, color: AppTheme.accentBlue),
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
  List<dynamic> filteredNewsFeed = [];
  bool isLoading = true;
  bool isOffline = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
      isOffline = false;
    });

    try {
      final uri = "${server}getNews.php";
      final response = await http
          .get(Uri.parse(uri))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          newsFeed = data;
          filteredNewsFeed = data;
          isLoading = false;
          isOffline = false;
        });
        _filterNews(searchController.text);
      } else {
        setState(() {
          isOffline = true;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching news: $e");
      setState(() {
        isOffline = true;
        isLoading = false;
      });
    }
  }

  void _filterNews(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredNewsFeed = newsFeed;
      });
    } else {
      final lowerQuery = query.toLowerCase();
      setState(() {
        filteredNewsFeed = newsFeed.where((article) {
          final title = (article["title"] ?? "").toString().toLowerCase();
          final author = (article["author"] ?? "").toString().toLowerCase();
          final body = (article["body"] ?? "").toString().toLowerCase();

          return title.contains(lowerQuery) ||
              author.contains(lowerQuery) ||
              body.contains(lowerQuery);
        }).toList();
      });
    }
  }

  String _getPublishedDate(Map<String, dynamic> article) {
    final rawDate = article["created_at"] ?? article["date"] ?? article["published_at"];
    if (rawDate == null || rawDate.toString().isEmpty) {
      return "Recently Published";
    }
    return rawDate.toString();
  }

  void _openArticleDetail(Map<String, dynamic> article) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.alertRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "GLOBAL NEWS READER",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.borderDark, height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.tagWorldBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "WORLD COVERAGE",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.tagWorldText),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article["title"] ?? "",
                      style: AppTheme.modalTitleStyle,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(CupertinoIcons.person_fill, size: 14, color: AppTheme.accentBlue),
                            const SizedBox(width: 6),
                            Text(
                              "By ${article["author"] ?? 'Unknown'}",
                              style: AppTheme.authorStyle,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.clock, size: 12, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              _getPublishedDate(article),
                              style: AppTheme.dateStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.borderDark),
                    const SizedBox(height: 16),
                    Text(
                      article["body"] ?? "",
                      style: AppTheme.bodyStyle.copyWith(fontSize: 16, height: 1.6),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ARES NEWS", style: AppTheme.brandHeaderStyle),
                  Text(
                    "DAILY NEWS BUGLE",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.2),
                  ),
                ],
              ),
              GestureDetector(
                onTap: fetchNews,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: const Icon(CupertinoIcons.refresh, size: 18, color: AppTheme.accentBlue),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: CupertinoSearchTextField(
            controller: searchController,
            onChanged: _filterNews,
            placeholder: "Search headlines, authors, or articles...",
            placeholderStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
            backgroundColor: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            itemColor: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        const Divider(color: AppTheme.borderDark, height: 1),

        Expanded(
          child: isLoading
              ? const Center(child: CupertinoActivityIndicator(color: AppTheme.accentBlue))
              : isOffline
              ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GlassContainer(
                settings: const LiquidGlassSettings(chromaticAberration: 0.5),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "XAMPP Server Offline",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Unable to connect to Apache/MySQL server. Make sure XAMPP is STARTED and the IP address is correct.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFEBEBF5),
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: const Color(0xFF48484A).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                          onPressed: fetchNews,
                          child: const Text(
                            "Retry Connection",
                            style: TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              : filteredNewsFeed.isEmpty
              ? Center(
            child: Text(
              newsFeed.isEmpty ? "No news published yet." : "No articles found.",
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          )
              : ListView.builder(
            itemCount: filteredNewsFeed.length,
            padding: const EdgeInsets.only(bottom: 100, top: 12),
            itemBuilder: (context, index) {
              final article = filteredNewsFeed[index];
              final isBreaking = index == 0 && searchController.text.isEmpty;

              return GestureDetector(
                onTap: () => _openArticleDetail(article),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isBreaking) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.alertRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text("BREAKING NEWS", style: AppTheme.alertBadgeStyle),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: index % 2 == 0 ? AppTheme.tagWorldBg : AppTheme.tagTechBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              index % 2 == 0 ? "WORLD" : "TECH",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: index % 2 == 0 ? AppTheme.tagWorldText : AppTheme.tagTechText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        article["title"] ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.cardTitleStyle,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            "By: ${article["author"] ?? 'Unknown'}",
                            style: AppTheme.authorStyle,
                          ),
                          const Spacer(),
                          const Icon(CupertinoIcons.clock, size: 12, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            _getPublishedDate(article),
                            style: AppTheme.dateStyle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        article["body"] ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodyStyle,
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Text(
                            "Read full article",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentBlue,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 14,
                            color: AppTheme.accentBlue,
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
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    getNews();
  }

  Future<void> getNews() async {
    setState(() {
      isLoading = true;
      isOffline = false;
    });

    try {
      final uri = "${server}getNews.php";
      final response = await http
          .get(Uri.parse(uri))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        setState(() {
          publishedNews = jsonDecode(response.body);
          isLoading = false;
          isOffline = false;
        });
      } else {
        setState(() {
          isOffline = true;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching news: $e");
      setState(() {
        isOffline = true;
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
      ).timeout(const Duration(seconds: 4));
      getNews();
    } catch (e) {
      debugPrint("Error adding news: $e");
      setState(() {
        isOffline = true;
      });
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
      ).timeout(const Duration(seconds: 4));
      getNews();
    } catch (e) {
      debugPrint("Error editing news: $e");
      setState(() {
        isOffline = true;
      });
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final uri = "${server}deleteNews.php";
      await http.post(
        Uri.parse(uri),
        body: {"id": id},
      ).timeout(const Duration(seconds: 4));
      getNews();
    } catch (e) {
      debugPrint("Error deleting news: $e");
      setState(() {
        isOffline = true;
      });
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
            child: GlassContainer(
              settings: const LiquidGlassSettings(chromaticAberration: 0.5),
              child: Container(
                width: MediaQuery.of(dialogContext).size.width * 0.78,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderDark.withValues(alpha: 0.6)),
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
                        color: AppTheme.backgroundDark.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.borderDark),
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
                        color: AppTheme.backgroundDark.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.borderDark),
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
                        color: AppTheme.backgroundDark.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.borderDark),
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
                                color: isEditing ? AppTheme.alertRed : const Color(0xFF8E8E93),
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
                          child: const Text(
                            "Publish",
                            style: TextStyle(
                              color: AppTheme.accentBlue,
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textWhite),
                  ),
                  GestureDetector(
                    onTap: getNews,
                    child: const Icon(CupertinoIcons.refresh, size: 22, color: AppTheme.accentBlue),
                  ),
                ],
              ),
            ),

            const Divider(color: AppTheme.borderDark),

            Expanded(
              child: isLoading
                  ? const Center(child: CupertinoActivityIndicator(color: AppTheme.accentBlue))
                  : isOffline
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GlassContainer(
                    settings: const LiquidGlassSettings(chromaticAberration: 0.5),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Server Connection Failed",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Unable to connect to Apache/MySQL server. Make sure XAMPP is STARTED and the IP address is correct.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFEBEBF5),
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              color: const Color(0xFF48484A).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16),
                              onPressed: getNews,
                              child: const Text(
                                "Retry Connection",
                                style: TextStyle(
                                  color: AppTheme.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
                  : publishedNews.isEmpty
                  ? const Center(child: Text("No news published yet.", style: TextStyle(color: AppTheme.textMuted)))
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
                        decoration: AppTheme.cardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["title"] ?? "",
                              style: AppTheme.cardTitleStyle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "By: ${item["author"] ?? 'Unknown'}",
                              style: AppTheme.authorStyle,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item["body"] ?? "",
                              style: AppTheme.bodyStyle,
                            ),
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
                color: AppTheme.primaryBlue,
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
                color: AppTheme.textWhite,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}