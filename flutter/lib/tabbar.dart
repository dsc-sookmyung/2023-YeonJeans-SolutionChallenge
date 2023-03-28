import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saera/home/bookmark_home/presentation/bookmark_home_screen.dart';

import 'package:saera/home/presentation/home_screen.dart';
import 'package:saera/learn/presentation/learn_screen.dart';
import 'package:saera/mypage/presentation/mypage_screen.dart';
import 'package:saera/style/color.dart';
import 'package:saera/style/font.dart';

class TabBarMainPage extends StatelessWidget {
  const TabBarMainPage({super.key});
  static final myTabbedPageKey = GlobalKey<_BottomNavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '새터민을 위한 억양 연습',
      home: BottomNavigator(
        key: TabBarMainPage.myTabbedPageKey,
      ),
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
    );
  }
}

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key});
  @override
  State<StatefulWidget> createState() {
    return _BottomNavigatorState();
  }
}

class _BottomNavigatorState extends State<BottomNavigator> with SingleTickerProviderStateMixin {

  late TabController tabController;

  int selectedIndex = 0;
  int prevIndex = 0;



  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(_handleTabSelection);

  }

  _handleTabSelection() {
    setState(() {
      selectedIndex = tabController.index;
    });

  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }


  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
  ];

  @override
  Widget build(BuildContext context) {

    bool isNeedSafeArea = MediaQuery.of(context).viewPadding.bottom > 0;

    return WillPopScope(
        onWillPop: () async {
        if (_navigatorKeys[tabController.index].currentState?.canPop() ?? false) {
          _navigatorKeys[tabController.index].currentState?.pop();
          return false;
        }
        else {
        return true;
      }
    },
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        height: isNeedSafeArea ? 72.0 : 60.0,
        padding: isNeedSafeArea ? EdgeInsets.only(bottom: 16.0) : EdgeInsets.all(0.0),
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: ColorStyles.tabGray.withOpacity(0.25), width: 1)
            )
        ),
        child: TabBar(
          controller: tabController,
          onTap: (index){
            if(prevIndex == tabController.index){
              _navigatorKeys[tabController.index].currentState?.popUntil((route) => route.isFirst);
            }
            prevIndex = selectedIndex;
          },
          tabs: <Widget>[
            Tab(
              icon: selectedIndex == 0 ?  SvgPicture.asset("assets/icons/home_filled.svg", color: ColorStyles.tabGray, width: 16, height: 16,): SvgPicture.asset("assets/icons/home_outlined.svg", color: ColorStyles.tabGray, width: 16, height: 16,),
              iconMargin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                '홈',
                style: selectedIndex == 0? TextStyles.tabBarBoldTextStyle : TextStyles.tabBarRegularTextStyle,
              ),
            ),
            Tab(
              icon: selectedIndex == 1 ? SvgPicture.asset("assets/icons/learn_filled.svg", color: ColorStyles.tabGray, width: 16, height: 16,): SvgPicture.asset("assets/icons/learn_outlined.svg", color: ColorStyles.tabGray, width: 16, height: 16,),
              iconMargin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                '학습',
                style: selectedIndex == 1? TextStyles.tabBarBoldTextStyle : TextStyles.tabBarRegularTextStyle,
              ),
            ),
            Tab(
              icon: selectedIndex == 2? SvgPicture.asset("assets/icons/star_filled.svg", color: ColorStyles.tabGray, width: 16, height: 16,): SvgPicture.asset("assets/icons/star_outlined.svg", color: ColorStyles.tabGray, width: 16, height: 16,),
              iconMargin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                '북마크',
                style: selectedIndex == 2? TextStyles.tabBarBoldTextStyle : TextStyles.tabBarRegularTextStyle,
              ),
            ),
            Tab(
              icon: selectedIndex == 3? SvgPicture.asset("assets/icons/user_filled.svg", color: ColorStyles.tabGray, width: 16, height: 16,): SvgPicture.asset("assets/icons/user_outlined.svg", color: ColorStyles.tabGray, width: 16, height: 16,),
              iconMargin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                '내 정보',
                style: selectedIndex == 3? TextStyles.tabBarBoldTextStyle : TextStyles.tabBarRegularTextStyle,
              ),
            ),
          ],
          indicatorColor: Colors.transparent,
        ),
      ),
      body:
      Stack(
        children: [
          _buildOffstageNavigator(0),
          _buildOffstageNavigator(1),
          _buildOffstageNavigator(2),
          _buildOffstageNavigator(3),
        ],
      ),
    )
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) {
        return [
          const HomePage(),
          const LearnPage(),
          const BookmarkPage(),
          const MyPage(),
        ].elementAt(index);
      },
    };
  }

  Widget _buildOffstageNavigator(int index) {
    var routeBuilders = _routeBuilders(context, index);

    return Offstage(
      offstage: selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name]!(context),
          );
        },
      ),
    );
  }

}
