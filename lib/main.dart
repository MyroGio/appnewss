import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0;
  List<Widget> pages = [
    Center(child: Text("HomePage")),
    Center(child: Text("Add News")),
    Center(child: Text("Profile"))
  ];
  @override

  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
          brightness: Brightness.dark
      ),
      debugShowCheckedModeBanner: false,
      home: GlassScaffold(

          bottomBar: GlassTabBar.bottom(
              settings: LiquidGlassSettings(
                  chromaticAberration: 1
              ),
              tabs: [
                GlassTab(icon: FaIcon(FontAwesomeIcons.house),activeIcon: Icon(CupertinoIcons.house_fill, color: CupertinoColors.systemBlue,),), //0
                GlassTab(icon: Icon(CupertinoIcons.add_circled),activeIcon: Icon(CupertinoIcons.add_circled_solid, color: CupertinoColors.systemBlue,),),
                GlassTab(icon: Icon(CupertinoIcons.person),activeIcon: Icon(CupertinoIcons.person_fill, color: CupertinoColors.systemBlue),), //1
              ], selectedIndex: selectedIndex, onTabSelected: (page){
            setState(() {
              selectedIndex = page;
            });
          }),
          body: SafeArea(child: pages[selectedIndex])
      ),
    );
  }
}