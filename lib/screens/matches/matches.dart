import 'package:fan_react/api/api_client.dart';
import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/screens/details/match_details_screen.dart';
import 'package:fan_react/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fan_react/models/match/match.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class Matches extends StatefulWidget {
  final void Function()? showHidePanel;
  const Matches({super.key, this.showHidePanel});

  @override
  State<Matches> createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  late ApiClient _apiClient;
  List<Match> allMatches = List<Match>.empty(growable: true);
  List<Match> selectedLeagueMatches = List.empty(growable: true);
  int? _lastFetchedLeagueId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    getAllMatches();
  }

  void getLeagueMatches(int leagueId) async {
    if (leagueId == 0) {
      // selectedLeagueMatches.clear();
      // _lastFetchedLeagueId = null;
      // isLoading = false;
      // setState(() {});
      return;
    }
    if (_lastFetchedLeagueId != leagueId) {
      isLoading = true;

      try {
        List<Match> matches = await _apiClient.getLeagueMatches(leagueId);

        selectedLeagueMatches.clear();
        selectedLeagueMatches.addAll(matches);
        _lastFetchedLeagueId = leagueId;
        isLoading = false;
        setState(() {});
      } catch (e) {
        selectedLeagueMatches.clear();
        _lastFetchedLeagueId = null;
        isLoading = false;
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load matches: $e')),
          );
        }
      }
    }
  }

  void getAllMatches() async {
    try {
      List<Match> matches = await _apiClient.getAllMatches();
      setState(() {
        allMatches.clear();
        allMatches.addAll(matches);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load matches: $e')),
        );
      }
    }
  }

  void goToMatchDetails(Match match) async {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => MatchDetailsScreen(match: match)));
  }

  Widget noResultsFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(noResultFound, style: size15semibold),
        Text(resetToSee, style: size14medium.copyWith(color: G_700)),
        const SizedBox(height: padding),
        Container(
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
              color: ACCENT_PRIMARY,
              borderRadius: BorderRadius.circular(buttonsRadius)),
          child:
              Text(resetChoice, style: size15semibold.copyWith(color: G_100)),
        )
      ],
    );
  }

  Widget matchItem(Match match, void Function(Match) onTap) {
    return InkWell(
      onTap: () => onTap(match),
      child: Container(
        padding: const EdgeInsets.all(padding),
        decoration: BoxDecoration(
            color: G_100, borderRadius: BorderRadius.circular(buttonsRadius)),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(padding / 4),
                      child: SizedBox(
                          width: 40,
                          height: 25,
                          child: match.country.name == 'World'
                              ? Image.network(match.country.logo,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error_outline_outlined))
                              : SvgPicture.network(match.country.logo,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                          Icons.error_outline_outlined))),
                    ),
                  ],
                ),
                const SizedBox(width: padding / 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(match.country.name,
                        style: size12semibold.copyWith(color: G_700)),
                    Text(match.league.name, style: size12semibold)
                  ],
                )
              ],
            ),
            const SizedBox(height: padding / 2),
            Row(
              children: [
                SizedBox(
                    width: 40,
                    height: 25,
                    child: Image.network(match.homeTeam.logo ?? '',
                        errorBuilder: (context, error, stackTrace) =>
                            Container())),
                const SizedBox(width: padding / 4),
                Text(match.homeTeam.name, style: size15semibold),
                const Spacer(),
                Text(match.state.score.current?.substring(0, 1) ?? '0',
                    style: size15semibold)
              ],
            ),
            const SizedBox(height: padding / 4),
            Row(
              children: [
                SizedBox(
                    width: 40,
                    height: 25,
                    child: Image.network(match.awayTeam.logo ?? '',
                        errorBuilder: (context, error, stackTrace) =>
                            Container())),
                const SizedBox(width: padding / 4),
                Text(match.awayTeam.name, style: size15semibold),
                const Spacer(),
                Text(match.state.score.current?.substring(4, 5) ?? '0',
                    style: size15semibold)
              ],
            ),
            const SizedBox(height: padding / 2),
            Row(
              children: [
                Container(
                    width: 55,
                    padding: const EdgeInsets.all(padding / 4),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        color: G_400, borderRadius: BorderRadius.circular(50)),
                    child: Row(
                      children: [
                        SizedBox(
                            height: 25, width: 25, child: Image.asset(cool)),
                        const Spacer(),
                        Text('1', style: size15semibold),
                        const SizedBox(width: padding / 2)
                      ],
                    )),
                SizedBox(width: padding / 4),
                Container(
                    width: 55,
                    padding: const EdgeInsets.all(padding / 4),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        color: G_400, borderRadius: BorderRadius.circular(50)),
                    child: Row(
                      children: [
                        SizedBox(
                            height: 25, width: 25, child: Image.asset(angry)),
                        const Spacer(),
                        Text('1', style: size15semibold),
                        const SizedBox(width: padding / 2)
                      ],
                    )),
                SizedBox(width: padding / 4),
                Container(
                    width: 55,
                    padding: const EdgeInsets.all(padding / 4),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        color: G_400, borderRadius: BorderRadius.circular(50)),
                    child: Row(
                      children: [
                        SizedBox(
                            height: 25,
                            width: 25,
                            child: Image.asset(disappointed)),
                        const Spacer(),
                        Text('1', style: size15semibold),
                        const SizedBox(width: padding / 2)
                      ],
                    )),
                SizedBox(width: padding / 4),
                Container(
                    width: 55,
                    padding: const EdgeInsets.all(padding / 4),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        color: G_400, borderRadius: BorderRadius.circular(50)),
                    child: Row(
                      children: [
                        SizedBox(
                            height: 25, width: 25, child: Image.asset(cool)),
                        const Spacer(),
                        Text('1', style: size15semibold),
                        const SizedBox(width: padding / 2)
                      ],
                    )),
                SizedBox(width: padding / 4),
                Container(
                    width: 55,
                    padding: const EdgeInsets.all(padding / 4),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        color: G_400, borderRadius: BorderRadius.circular(50)),
                    child: Row(
                      children: [
                        SizedBox(
                            height: 25, width: 25, child: Image.asset(shocked)),
                        const Spacer(),
                        Text('1', style: size15semibold),
                        const SizedBox(width: padding / 2)
                      ],
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormatBack = DateFormat('EEEE, MMM d, yyyy');
    var yesterday = DateTime.now().subtract(const Duration(days: 1));
    String date = dateFormatBack.format(yesterday);

    double screenHeight = MediaQuery.sizeOf(context).height;

    AppBar appBar = AppBar(
        centerTitle: false,
        title: Text(matches, style: size24bold),
        actions: [
          ValueListenableBuilder(
              valueListenable: isLeagueSelected,
              builder: (context, isSelected, child) {
                return InkWell(
                    onTap: widget.showHidePanel,
                    child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: padding),
                        child: isSelected
                            ? SvgPicture.asset(filterActive)
                            : SvgPicture.asset(filterDefault)));
              })
        ]);

    return InkWell(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBar,
        resizeToAvoidBottomInset: false,
        body: ValueListenableBuilder(
          valueListenable: selectedLeagueId,
          builder: (context, leagueId, child) {
            getLeagueMatches(leagueId);
            return Container(
              color: G_400,
              padding: const EdgeInsets.symmetric(horizontal: padding / 2),
              height: screenHeight -
                  appBar.preferredSize.height -
                  padding * 2 -
                  navBatHeight,
              child: Column(
                children: [
                  Container(
                      alignment: Alignment.center,
                      height: padding * 2,
                      child: Text(date,
                          style: size14semibold.copyWith(color: G_700))),
                  SizedBox(
                    height: screenHeight -
                        appBar.preferredSize.height -
                        padding * 6 -
                        navBatHeight,
                    child: ValueListenableBuilder(
                      valueListenable: isLeagueSelected,
                      builder: (context, isSelected, child) {
                        return isLoading
                            ? const Center(
                                child: CircularProgressIndicator.adaptive())
                            : isSelected
                                ? selectedLeagueMatches.isEmpty
                                    ? noResultsFound()
                                    : ListView.builder(
                                        itemCount: selectedLeagueMatches.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: padding / 4),
                                            child: matchItem(
                                                selectedLeagueMatches[index],
                                                goToMatchDetails),
                                          );
                                        })
                                : allMatches.isEmpty
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                            LottieBuilder.asset(preloader,
                                                width: 100, height: 100),
                                            Text(loading, style: size15semibold)
                                          ])
                                    : ListView.builder(
                                        itemCount: allMatches.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: padding / 4),
                                              child: matchItem(
                                                  allMatches[index],
                                                  goToMatchDetails));
                                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
