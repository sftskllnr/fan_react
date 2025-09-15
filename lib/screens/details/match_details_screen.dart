import 'package:fan_react/api/api_client.dart';
import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/models/statistic/match_statistic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fan_react/models/match/match.dart';
import 'package:lottie/lottie.dart';

class MatchDetailsScreen extends StatefulWidget {
  final Match match;
  const MatchDetailsScreen({super.key, required this.match});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  late ApiClient _apiClient;
  bool isStatSelected = true;
  bool isH2hSelected = false;
  bool isCommentsSelected = false;
  late ScrollController scrollController;
  List<Match> homeTeamMatches = List.empty(growable: true);
  List<Match> awayTeamMatches = List.empty(growable: true);
  List<MatchStatistic> matchStatics = List.empty(growable: true);
  List<bool> homeTeamResults = List.empty(growable: true);
  List<bool> awayTeamResults = List.empty(growable: true);
  bool showHeaders = true;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    scrollController = ScrollController();

    scrollController.addListener(() {
      setState(() {
        showHeaders = scrollController.offset <= 0;
      });
    });

    getLastFiveMatches(widget.match.homeTeam.id, true).whenComplete(() {
      getTeamResults(homeTeamMatches, widget.match.homeTeam.id, true);
    });
    getLastFiveMatches(widget.match.awayTeam.id, false).whenComplete(() {
      getTeamResults(awayTeamMatches, widget.match.awayTeam.id, false);
    });

    getMatchStatistic(widget.match.id);
  }

  Future<void> getLastFiveMatches(int teamId, bool isHome) async {
    if (isHome) {
      homeTeamMatches = await _apiClient.getLastFiveMatches(teamId);
    } else {
      awayTeamMatches = await _apiClient.getLastFiveMatches(teamId);
    }
    setState(() {});
  }

  void getMatchStatistic(int matchId) async {
    matchStatics = await _apiClient.getMatchStatistic(matchId);
    setState(() {});
  }

  void getTeamResults(List<Match> matches, int teamId, bool isHome) {
    for (var match in matches) {
      List<int> scoreParts =
          match.state.score.current!.split(' - ').map(int.parse).toList();
      int homeScore = scoreParts[0];
      int awayScore = scoreParts[1];
      bool isWin;

      if (match.homeTeam.id == teamId) {
        isWin = homeScore > awayScore;
      } else {
        isWin = awayScore > homeScore;
      }
      isHome ? homeTeamResults.add(isWin) : awayTeamResults.add(isWin);
    }
    setState(() {});
  }

  void selectTab(bool isStat, bool isH2h) {
    if (isStat) {
      isStatSelected = true;
      isH2hSelected = false;
      isCommentsSelected = false;
      setState(() {});
      return;
    }
    if (isH2h) {
      isStatSelected = false;
      isH2hSelected = true;
      isCommentsSelected = false;
      setState(() {});
      return;
    } else {
      isStatSelected = false;
      isH2hSelected = false;
      isCommentsSelected = true;
      setState(() {});
      return;
    }
  }

  Widget teamLogoStats(Match match, bool isHome) {
    return Column(children: [
      Container(
          height: padding * 6,
          width: padding * 6,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(padding),
          child: Image.network(
              isHome ? match.homeTeam.logo ?? '' : match.awayTeam.logo ?? '',
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.error_outline_outlined, color: G_100))),
      Container(
          width: padding * 6,
          alignment: Alignment.center,
          child: Text(isHome ? match.homeTeam.name : match.awayTeam.name,
              style: size15medium.copyWith(color: G_100),
              textAlign: TextAlign.center))
    ]);
  }

  Widget winStats(List<bool> results) {
    return SizedBox(
      height: padding * 1.5,
      width: padding * 9,
      child: ListView.builder(
          itemCount: results.length,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            bool isWin = results[index] == true;

            return Padding(
              padding: const EdgeInsets.only(right: padding / 4),
              child: Container(
                  width: padding * 1.6,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: isWin ? G_100 : ACCENT_SECONDARY,
                      borderRadius: BorderRadius.circular(buttonsRadius)),
                  child: Text(isWin ? 'W' : 'L',
                      style: size10bold.copyWith(
                          color: isWin ? ACCENT_PRIMARY : G_100))),
            );
          }),
    );
  }

  Widget statisticListView() {
    return ListView.builder(
        controller: scrollController,
        itemCount: matchStatics[0].statistics.length,
        padding: const EdgeInsets.all(0),
        itemBuilder: (context, index) {
          bool isMoreValue = matchStatics[0].statistics[index].value >
              matchStatics[1].statistics[index].value;
          return Padding(
              padding: const EdgeInsets.only(bottom: padding / 3),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        height: padding * 1.5,
                        padding:
                            const EdgeInsets.symmetric(horizontal: padding),
                        decoration: BoxDecoration(
                            color: G_200,
                            borderRadius: BorderRadius.circular(padding),
                            border: Border.all(
                                color: isMoreValue ? ACCENT_PRIMARY : G_200)),
                        child: Text(
                            matchStatics[0].statistics[index].value.toString(),
                            style: size14semibold.copyWith(
                                color: isMoreValue ? ACCENT_PRIMARY : G_900))),
                    Text(matchStatics[0].statistics[index].displayName,
                        style: size15medium.copyWith(color: G_700)),
                    Container(
                        height: padding * 1.5,
                        padding:
                            const EdgeInsets.symmetric(horizontal: padding),
                        decoration: BoxDecoration(
                            color: G_200,
                            borderRadius: BorderRadius.circular(padding),
                            border: Border.all(
                                color: !isMoreValue ? ACCENT_PRIMARY : G_200)),
                        child: Text(
                            matchStatics[1].statistics[index].value.toString(),
                            style: size14semibold.copyWith(
                                color: !isMoreValue ? ACCENT_PRIMARY : G_900)))
                  ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
        extendBodyBehindAppBar: true,
        body: SizedBox(
            height: screenHeight,
            child: Stack(alignment: Alignment.topCenter, children: [
              Container(color: ACCENT_PRIMARY, height: padding * 23),
              Positioned(
                  top: padding / 2,
                  left: padding,
                  child: SafeArea(
                      child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(buttonsRadius),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: padding / 1.5,
                                  vertical: padding / 1.5),
                              decoration: BoxDecoration(
                                  color: ACCENT_SECONDARY,
                                  borderRadius:
                                      BorderRadius.circular(buttonsRadius)),
                              child: SvgPicture.asset(
                                arrowLeftBlack,
                                colorFilter:
                                    ColorFilter.mode(G_100, BlendMode.srcIn),
                              ))))),
              Padding(
                padding: const EdgeInsets.only(top: padding / 2),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SafeArea(
                      child: Column(
                    children: [
                      Text(detailsMatch,
                          style: size18semibold.copyWith(color: G_100)),
                      Text(widget.match.league.name,
                          style: size15medium.copyWith(color: G_100)),
                      const SizedBox(height: padding / 2),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: padding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                teamLogoStats(widget.match, true),
                                const SizedBox(height: padding / 2),
                                winStats(homeTeamResults),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: padding),
                              child: Column(children: [
                                Text('${widget.match.state.clock}\'',
                                    style: size14medium.copyWith(color: G_100)),
                                Text(widget.match.state.score.current ?? '',
                                    style: size28bold.copyWith(color: G_100))
                              ]),
                            ),
                            Column(
                              children: [
                                teamLogoStats(widget.match, false),
                                const SizedBox(height: padding / 2),
                                winStats(awayTeamResults),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: padding * 1.5),
                      Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: padding),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                    onTap: () => selectTab(true, false),
                                    child: Text(statistics,
                                        style: size15bold.copyWith(
                                            color: isStatSelected
                                                ? G_100
                                                : BACKGROUND_PRIMARY))),
                                InkWell(
                                    onTap: () => selectTab(false, true),
                                    child: Text(h2h,
                                        style: size15bold.copyWith(
                                            color: isH2hSelected
                                                ? G_100
                                                : BACKGROUND_PRIMARY))),
                                InkWell(
                                    onTap: () => selectTab(false, false),
                                    child: Text(comments,
                                        style: size15bold.copyWith(
                                            color: isCommentsSelected
                                                ? G_100
                                                : BACKGROUND_PRIMARY)))
                              ])),
                    ],
                  )),
                ),
              ),
              Positioned(
                  top: padding * 22,
                  child: Container(
                      width: screenWidth,
                      height: screenHeight - padding * 22,
                      padding: const EdgeInsets.symmetric(horizontal: padding),
                      decoration: BoxDecoration(
                          color: G_100,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(padding),
                              topRight: Radius.circular(padding))),
                      child: Column(children: [
                        AnimatedOpacity(
                            opacity: showHeaders ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: Offstage(
                                offstage: !showHeaders,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(matchVibes, style: size15semibold)
                                    ]))),
                        AnimatedOpacity(
                            opacity: showHeaders ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: Offstage(
                                offstage: !showHeaders,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(gameStatistics,
                                          style: size15semibold)
                                    ]))),
                        Row(children: [
                          SizedBox(
                              height: !showHeaders
                                  ? screenHeight - padding * 23
                                  : screenHeight - padding * 26,
                              width: screenWidth - padding * 2,
                              child: matchStatics.isEmpty
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                          LottieBuilder.asset(preloader,
                                              width: 100, height: 100),
                                          Text(loading, style: size15semibold)
                                        ])
                                  : statisticListView())
                        ])
                      ])))
            ])));
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
