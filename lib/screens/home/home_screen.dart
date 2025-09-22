import 'dart:async';
import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/main.dart';
import 'package:fan_react/models/league/league_season.dart';
import 'package:fan_react/screens/achievements/achievements.dart';
import 'package:fan_react/screens/history/history.dart';
import 'package:fan_react/screens/home/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:fan_react/screens/home/bottom_nav_bar/bottom_nav_bar_item.dart';
import 'package:fan_react/screens/matches/matches.dart';
import 'package:fan_react/screens/profile/profile.dart';
import 'package:fan_react/singleton/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smart_snackbars/enums/animate_from.dart';
import 'package:smart_snackbars/smart_snackbars.dart';

class HomeScreen extends StatefulWidget {
  final String? payload;
  const HomeScreen({super.key, this.payload});

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  late PanelController _panelController;
  late List<Widget> _listWidgets;
  late TextEditingController _searchController;
  late ScrollController _scrollController;

  double topPadding = 150;
  List<LeagueSeason> leaguesList = List<LeagueSeason>.empty(growable: true);
  String selectedLeagueName = '';
  List<LeagueSeason> _filteredLeagues =
      List<LeagueSeason>.empty(growable: true);
  Timer? _debounce;
  int? _selectedLeagueIndex;

  @override
  void initState() {
    super.initState();
    _panelController = PanelController();
    _searchController = TextEditingController();
    _scrollController = ScrollController();

    _listWidgets = [
      Matches(showHidePanel: showHidePanel),
      const History(),
      const Achievements(),
      const Profile()
    ];
    _getAllLeagues();
    _getIsFirstLaunch();

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), _filterLeagues);
    });
  }

  void _filterLeagues() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLeagues = List<LeagueSeason>.from(leaguesList);
      } else {
        _filteredLeagues = leaguesList
            .where((league) => league.name.toLowerCase().contains(query))
            .toList();
      }
      if (selectedLeagueId.value != 0) {
        _selectedLeagueIndex = _filteredLeagues
            .indexWhere((league) => league.id == selectedLeagueId.value);
      } else {
        _selectedLeagueIndex = null;
      }
    });
  }

  void showHidePanel() {
    if (_panelController.isPanelOpen) {
      _panelController.close();
    } else {
      _panelController.open();

      if (_selectedLeagueIndex != null && _selectedLeagueIndex! >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToSelectedLeague(_scrollController);
        });
      }
    }
  }

  Future<void> _getIsFirstLaunch() async {
    var prefs = await SharedPrefsSingleton.getInstance();
    bool? isFirstLaunch = prefs.getBool('isFirstLaunch');
    if (isFirstLaunch == null) {
      _show();
    }
  }

  Future<void> _getAllLeagues() async {
    List<LeagueSeason> leagues = await apiClient.getAllLeagues();
    setState(() {
      leaguesList.clear();
      leaguesList.addAll(leagues);
      _filteredLeagues = List<LeagueSeason>.from(leaguesList);

      if (selectedLeagueId.value != 0) {
        _selectedLeagueIndex = leaguesList
            .indexWhere((league) => league.id == selectedLeagueId.value);
      }
    });
  }

  void setLeagueId(LeagueSeason league) {
    setState(() {
      isLeagueSelected.value = true;
      selectedLeagueId.value = league.id;
      selectedLeagueName = league.name;

      _selectedLeagueIndex =
          (_searchController.text.isEmpty ? leaguesList : _filteredLeagues)
              .indexWhere((l) => l.id == league.id);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedLeague(_scrollController);
      });
    });
  }

  void clearChoice() {
    setState(() {
      selectedLeagueId.value = 0;
      selectedLeagueName = '';
      isLeagueSelected.value = false;
      _searchController.clear();
      _filteredLeagues = List<LeagueSeason>.from(leaguesList);
      _selectedLeagueIndex = null;
    });
  }

  void _scrollToSelectedLeague(ScrollController sc) {
    if (_selectedLeagueIndex != null && _selectedLeagueIndex! >= 0) {
      const double itemHeight = 60.0;
      final double offset = _selectedLeagueIndex! * (itemHeight + padding);
      sc.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _show() async {
    SmartDialog.show(builder: (_) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: HINT_COLOR),
        child: Stack(
            alignment: Alignment.topCenter, children: [_pointA(), _pointB()]),
      );
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Widget _pointA() {
    return Positioned(
      left: padding,
      top: topPadding,
      child: Builder(builder: (context) {
        aContext = context;
        return matchItem(context);
      }),
    );
  }

  Widget _pointB() {
    return Positioned(
      left: padding,
      right: padding,
      top: topPadding * 2 + padding,
      child: Builder(builder: (context) {
        bContext = context;
        return reactDescription();
      }),
    );
  }

  Widget matchItem(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width - padding * 2,
      child: Image.asset('assets/png/match.png'),
    );
  }

  Widget reactDescription() {
    return Container(
        padding: const EdgeInsets.all(padding),
        decoration: BoxDecoration(
            color: G_100,
            borderRadius:
                const BorderRadius.all(Radius.circular(buttonsRadius))),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reactToMatches, style: size15bold),
                    Text(selectReaction,
                        style: size14medium.copyWith(color: G_700)),
                  ],
                ),
              ),
              Column(children: [
                InkWell(
                    onTap: () async => await SmartDialog.dismiss(),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: padding * 1.5, vertical: padding / 2),
                        decoration: BoxDecoration(
                            color: BACKGROUND_PRIMARY,
                            borderRadius: BorderRadius.circular(buttonsRadius)),
                        child: Text(ok,
                            style: size14semibold.copyWith(
                                color: ACCENT_SECONDARY))))
              ])
            ]));
  }

  Widget leagueInput() {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.fromLTRB(padding, padding / 2, padding, padding),
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(color: G_400))),
          child: TextField(
            controller: _searchController,
            onTap: () => _searchController.text.isEmpty
                ? _filteredLeagues.clear()
                : null,
            cursorColor: ACCENT_PRIMARY,
            decoration: InputDecoration(
                prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: padding),
                    child: SvgPicture.asset(search,
                        colorFilter: ColorFilter.mode(G_900, BlendMode.srcIn))),
                suffixIcon: InkWell(
                    onTap: () => _searchController.clear(),
                    child: const Icon(Icons.cancel_rounded)),
                hintText: searhLeague,
                hintStyle: size15medium.copyWith(color: G_600),
                contentPadding: const EdgeInsets.all(padding),
                fillColor: G_200,
                filled: true,
                enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: G_400)),
                focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: G_400))),
          ),
        ),
      ],
    );
  }

  Widget leagueItem(
      LeagueSeason league, bool isWorld, double width, ScrollController sc) {
    bool isSelected = league.id == selectedLeagueId.value;
    return Container(
      padding: const EdgeInsets.all(padding),
      decoration: BoxDecoration(
          color: G_100, borderRadius: BorderRadius.circular(buttonsRadius)),
      child: Row(
        children: [
          SizedBox(
              height: 30,
              width: 50,
              child: isWorld
                  ? Image.network(league.country.logo,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error_outline_outlined))
                  : SvgPicture.network(league.country.logo,
                      fit: BoxFit.contain,
                      errorBuilder: (context, item, stack) =>
                          const Icon(Icons.error_outline_outlined))),
          const SizedBox(width: padding * 0.8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                width: width, child: Text(league.name, style: size15semibold)),
            Text(league.country.name,
                style: size14medium.copyWith(color: G_600))
          ]),
          InkWell(
              onTap: () => setLeagueId(league),
              child: isSelected
                  ? Icon(Icons.radio_button_checked_outlined,
                      color: ACCENT_PRIMARY)
                  : Icon(Icons.radio_button_off_outlined, color: G_700))
        ],
      ),
    );
  }

  Widget _leaguesPanel(
      ScrollController sc, double maxPanelHeight, double width) {
    double listHeight =
        maxPanelHeight - 4 - padding * 7 - padding - 1 - padding * 7;

    return InkWell(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: G_600,
                  borderRadius: BorderRadius.circular(buttonsRadius))),
          SizedBox(
              height: padding * 1.5,
              child: Text(filterLeague, style: size18semibold)),
          SizedBox(
              height: padding * 1.5,
              child: Text(
                  '$choice ${selectedLeagueName == '' ? all : selectedLeagueName}',
                  style: size15semibold.copyWith(color: G_700))),
          leagueInput(),
          _searchController.text.isEmpty
              ? Container(
                  height: listHeight,
                  padding: const EdgeInsets.symmetric(horizontal: padding),
                  decoration: BoxDecoration(color: G_200),
                  child: ListView.builder(
                      controller: sc,
                      padding: const EdgeInsets.all(0.0),
                      itemCount: leaguesList.length,
                      itemBuilder: (context, index) {
                        bool isWorld =
                            leaguesList[index].country.name == 'World';
                        return Padding(
                            padding: const EdgeInsets.only(top: padding),
                            child: leagueItem(
                                leaguesList[index], isWorld, width, sc));
                      }))
              : _filteredLeagues.isEmpty
                  ? Container(
                      height: listHeight,
                      width: Size.infinite.width,
                      color: G_200,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(searchBy, style: size15semibold),
                            Text(toFind,
                                style: size14medium.copyWith(color: G_700))
                          ]))
                  : Container(
                      height: listHeight,
                      padding: const EdgeInsets.symmetric(horizontal: padding),
                      decoration: BoxDecoration(color: G_200),
                      child: ListView.builder(
                          controller: sc,
                          padding: const EdgeInsets.all(0.0),
                          itemCount: _filteredLeagues.length,
                          itemBuilder: (context, index) {
                            bool isWorld =
                                _filteredLeagues[index].country.name == 'World';
                            return Padding(
                                padding: const EdgeInsets.only(top: padding),
                                child: leagueItem(_filteredLeagues[index],
                                    isWorld, width, sc));
                          })),
          Container(
            padding: const EdgeInsets.all(padding),
            decoration: BoxDecoration(
                color: G_100, border: Border(top: BorderSide(color: G_400))),
            child: InkWell(
              onTap: () => selectedLeagueName != '' ? clearChoice() : null,
              child: Container(
                height: padding * 4,
                width: Size.infinite.width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: selectedLeagueName == '' ? G_600 : ACCENT_PRIMARY,
                    borderRadius: BorderRadius.circular(buttonsRadius)),
                child: Text(resetChoice,
                    style: size15semibold.copyWith(color: G_100)),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double minPanelHeight = 0.0;
    double maxPanelHeight = MediaQuery.sizeOf(context).height * 0.875;
    double screenWidth = MediaQuery.sizeOf(context).width;

    return ValueListenableBuilder(
        valueListenable: selectedIndexGlobal,
        builder: (context, value, child) {
          return SlidingUpPanel(
            backdropEnabled: true,
            color: G_100,
            minHeight: minPanelHeight,
            maxHeight: maxPanelHeight,
            controller: _panelController,
            borderRadius: BorderRadius.circular(buttonsRadius),
            padding:
                const EdgeInsetsDirectional.symmetric(vertical: padding / 2),
            panel: _leaguesPanel(_scrollController, maxPanelHeight,
                screenWidth - padding * 6 - padding / 2 - padding * 3),
            body: InkWell(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                backgroundColor: G_200,
                resizeToAvoidBottomInset: false,
                body: IndexedStack(
                    index: selectedIndexGlobal.value, children: _listWidgets),
                bottomNavigationBar: SizedBox(
                  height: navBarHeight,
                  child: BottomNavBar(
                      curentIndex: selectedIndexGlobal.value,
                      onTap: (index) => setState(() {
                            selectedIndexGlobal.value = index;
                          }),
                      children: [
                        BottomNavBarItem(
                            title: matches,
                            svgIcon: selectedIndexGlobal.value == 0
                                ? SvgPicture.asset(matchesActive)
                                : SvgPicture.asset(matchesDefault)),
                        BottomNavBarItem(
                            title: history,
                            svgIcon: selectedIndexGlobal.value == 1
                                ? SvgPicture.asset(historyActive)
                                : SvgPicture.asset(historyDefault)),
                        BottomNavBarItem(
                            title: achievement,
                            svgIcon: selectedIndexGlobal.value == 2
                                ? SvgPicture.asset(missionsActive)
                                : SvgPicture.asset(missionsDefault)),
                        BottomNavBarItem(
                            title: profile,
                            svgIcon: selectedIndexGlobal.value == 3
                                ? SvgPicture.asset(profileActive)
                                : SvgPicture.asset(profileDefault)),
                      ]),
                ),
              ),
            ),
          );
        });
  }
}

void showNoInternetSnackbar(BuildContext context, Function() onTap) {
  SmartSnackBars.showTemplatedSnackbar(
      context: context,
      backgroundColor: SYSTEM_ONE,
      persist: true,
      animationCurve: Curves.ease,
      animateFrom: AnimateFrom.fromBottom,
      outerPadding: const EdgeInsets.symmetric(vertical: padding * 6),
      borderRadius: BorderRadius.circular(0.0),
      titleWidget:
          Text(connectionError, style: size15bold.copyWith(color: G_100)),
      subTitleWidget:
          Text(checkYourInternet, style: size14medium.copyWith(color: G_100)),
      trailing: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.all(padding / 2),
            decoration: BoxDecoration(
                color: G_100,
                borderRadius: BorderRadius.circular(buttonsRadius)),
            child: Text(reload, style: size14semibold.copyWith(color: G_900))),
      ));
}
