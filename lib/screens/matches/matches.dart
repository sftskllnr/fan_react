import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/main.dart';
import 'package:fan_react/screens/details/match_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  int? _lastFetchedLeagueId;

  @override
  void initState() {
    super.initState();
    _initializeMatches();
  }

  void getLeagueMatches(int leagueId) async {
    if (leagueId == 0) {
      return;
    }
    if (_lastFetchedLeagueId != leagueId) {
      isLoadingMatches = true;
      try {
        List<Match> matches = await apiClient.getLeagueMatches(leagueId);
        selectedLeagueMatches.clear();
        selectedLeagueMatches.addAll(matches);
        _lastFetchedLeagueId = leagueId;
        isLoadingMatches = false;
        setState(() {});
      } catch (e) {
        selectedLeagueMatches.clear();
        _lastFetchedLeagueId = null;
        isLoadingMatches = false;
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load matches: $e')),
          );
        }
      }
    }
  }

  Future<void> _initializeMatches() async {
    setState(() => isLoadingMatches = true);
    try {
      List<Match> apiMatches = await apiClient.getAllMatches();

      await firestoreService.addMatchesList(apiMatches);

      final matchSnapshot = await firestoreService.matchesCollection.get();
      allMatches.clear();
      allMatches.addAll(matchSnapshot.docs.map((doc) => doc.data()).toList());

      await _updateReactionsForMatches(allMatches);

      await loadMatchActivities();

      setState(() => isLoadingMatches = false);
    } catch (e) {
      setState(() => isLoadingMatches = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize matches: $e')),
        );
      }
    }
  }

  Future<void> loadMatchActivities() async {
    try {
      final matches = await firestoreService.getMatchesWithUserActivity();
      setState(() {
        matchesWithActivities.value = matches;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading comments: $e')),
        );
      }
    }
  }

  Future<void> sendReaction(int matchId, String reactionType) async {
    try {
      final currentReaction = selectedReactions[matchId];
      await firestoreService.updateReaction(matchId, reactionType);
      final updatedMatch = await firestoreService.getMatch(matchId);
      if (updatedMatch != null) {
        final indexAll = allMatches.indexWhere((m) => m.id == matchId);
        if (indexAll != -1) {
          allMatches[indexAll] = updatedMatch;
        }
        final indexSelected =
            selectedLeagueMatches.indexWhere((m) => m.id == matchId);
        if (indexSelected != -1) {
          selectedLeagueMatches[indexSelected] = updatedMatch;
        }
        if (currentReaction == reactionType) {
          selectedReactions.remove(matchId);
        } else {
          selectedReactions[matchId] = reactionType;
        }
        setState(() {});

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await firestoreService.checkAchievements(
            user.uid,
            'reaction',
            matchId: matchId,
            reactionType: reactionType,
            isCancellation: currentReaction == reactionType,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating reaction: $e')),
        );
      }
    }
  }

  Future<void> _updateReactionsForMatches(List<Match> matches) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final reactionFutures = matches.map((match) async {
      for (final reactionType in [
        'loved',
        'angry',
        'disappointed',
        'cool',
        'shocked'
      ]) {
        final hasReacted =
            await firestoreService.hasUserReacted(match.id, reactionType);
        if (hasReacted) {
          selectedReactions[match.id] = reactionType;
          setState(() {});
          break;
        }
      }
    }).toList();
    await Future.wait(reactionFutures);
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
    return StreamBuilder<Match>(
        stream: firestoreService.getMatchStream(match.id),
        builder: (context, snapshot) {
          final selectedReaction = selectedReactions[match.id];
          final currentMatch = snapshot.data ?? match;
          final currentReactions = currentMatch.reactions;

          return InkWell(
              onTap: () => onTap(match),
              child: Container(
                padding: const EdgeInsets.all(padding),
                decoration: BoxDecoration(
                    color: G_100,
                    borderRadius: BorderRadius.circular(buttonsRadius)),
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
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(
                                                  Icons.error_outline_outlined))
                                      : SvgPicture.network(match.country.logo,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(Icons
                                                  .error_outline_outlined))),
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
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_outlined,
                            color: G_900, size: padding, weight: 1)
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
                    Row(children: [
                      InkWell(
                        onTap: () => sendReaction(match.id, 'loved'),
                        child: Container(
                            padding: const EdgeInsets.all(padding / 4),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: selectedReaction == 'loved'
                                  ? ACCENT_PRIMARY
                                  : G_400,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(children: [
                              SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Image.asset(loved)),
                              const SizedBox(width: padding / 4),
                              Text(currentReactions['loved'].toString(),
                                  style: selectedReaction == 'loved'
                                      ? size12semibold.copyWith(color: G_100)
                                      : size12semibold)
                            ])),
                      ),
                      const SizedBox(width: padding / 4),
                      InkWell(
                        onTap: () => sendReaction(match.id, 'angry'),
                        child: Container(
                            padding: const EdgeInsets.all(padding / 4),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: selectedReaction == 'angry'
                                  ? ACCENT_PRIMARY
                                  : G_400,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(children: [
                              SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Image.asset(angry)),
                              const SizedBox(width: padding / 4),
                              Text(currentReactions['angry'].toString(),
                                  style: selectedReaction == 'angry'
                                      ? size12semibold.copyWith(color: G_100)
                                      : size12semibold)
                            ])),
                      ),
                      const SizedBox(width: padding / 4),
                      InkWell(
                        onTap: () => sendReaction(match.id, 'disappointed'),
                        child: Container(
                            padding: const EdgeInsets.all(padding / 4),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: selectedReaction == 'disappointed'
                                  ? ACCENT_PRIMARY
                                  : G_400,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(children: [
                              SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Image.asset(disappointed)),
                              const SizedBox(width: padding / 4),
                              Text(currentReactions['disappointed'].toString(),
                                  style: selectedReaction == 'disappointed'
                                      ? size12semibold.copyWith(color: G_100)
                                      : size12semibold)
                            ])),
                      ),
                      const SizedBox(width: padding / 4),
                      InkWell(
                        onTap: () => sendReaction(match.id, 'cool'),
                        child: Container(
                            padding: const EdgeInsets.all(padding / 4),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: selectedReaction == 'cool'
                                  ? ACCENT_PRIMARY
                                  : G_400,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(children: [
                              SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Image.asset(cool)),
                              const SizedBox(width: padding / 4),
                              Text(currentReactions['cool'].toString(),
                                  style: selectedReaction == 'cool'
                                      ? size12semibold.copyWith(color: G_100)
                                      : size12semibold)
                            ])),
                      ),
                      const SizedBox(width: padding / 4),
                      InkWell(
                        onTap: () => sendReaction(match.id, 'shocked'),
                        child: Container(
                            padding: const EdgeInsets.all(padding / 4),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                                color: selectedReaction == 'shocked'
                                    ? ACCENT_PRIMARY
                                    : G_400,
                                borderRadius: BorderRadius.circular(50)),
                            child: Row(children: [
                              SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Image.asset(shocked)),
                              const SizedBox(width: padding / 4),
                              Text(currentReactions['shocked'].toString(),
                                  style: selectedReaction == 'shocked'
                                      ? size12semibold.copyWith(color: G_100)
                                      : size12semibold)
                            ])),
                      ),
                    ])
                  ],
                ),
              ));
        });
  }

  Map<String, List<Match>> groupMatchesByDate(List<Match> matches) {
    final Map<String, List<Match>> groupedMatches = {};
    for (var match in matches) {
      final date =
          DateFormat('EEEE, dd MMMM yyyy').format(DateTime.parse(match.date));
      if (!groupedMatches.containsKey(date)) {
        groupedMatches[date] = [];
      }
      groupedMatches[date]!.add(match);
    }
    return groupedMatches;
  }

  Widget selectedMatchesGroup() {
    return ListView.builder(
        itemCount: groupMatchesByDate(selectedLeagueMatches).length,
        itemBuilder: (context, index) {
          final groupedMatches = groupMatchesByDate(selectedLeagueMatches);
          final dates = groupedMatches.keys.toList();
          final date = dates[index];
          final matchesForDate = groupedMatches[date]!;
          return Padding(
            padding: const EdgeInsets.only(top: padding / 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: padding / 2),
                  child: Text(
                    date,
                    style: size15semibold.copyWith(color: G_700),
                  ),
                ),
                ...matchesForDate.map((match) => Padding(
                      padding: const EdgeInsets.only(top: padding / 2),
                      child: matchItem(match, goToMatchDetails),
                    )),
              ],
            ),
          );
        });
  }

  Widget allMatchesGroup() {
    return ListView.builder(
      itemCount: groupMatchesByDate(allMatches).length,
      itemBuilder: (context, index) {
        final groupedMatches = groupMatchesByDate(allMatches);
        final dates = groupedMatches.keys.toList();
        final date = dates[index];
        final matchesForDate = groupedMatches[date]!;
        return Padding(
          padding: const EdgeInsets.only(top: padding / 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(date, style: size15semibold.copyWith(color: G_700)),
              ...matchesForDate.map(
                (match) => Padding(
                  padding: const EdgeInsets.only(top: padding / 2),
                  child: matchItem(match, goToMatchDetails),
                ),
              ),
            ],
          ),
        );
      },
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
              padding: const EdgeInsets.symmetric(horizontal: padding),
              height: screenHeight -
                  appBar.preferredSize.height -
                  padding * 2 -
                  navBatHeight,
              child: ValueListenableBuilder(
                valueListenable: isLeagueSelected,
                builder: (context, isSelected, child) {
                  return isLoadingMatches
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              LottieBuilder.asset(preloader,
                                  width: 100, height: 100),
                              Text(loading, style: size15semibold)
                            ])
                      : isSelected
                          ? selectedLeagueMatches.isEmpty
                              ? noResultsFound()
                              : selectedMatchesGroup()
                          : allMatches.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      LottieBuilder.asset(preloader,
                                          width: 100, height: 100),
                                      Text(loading, style: size15semibold)
                                    ])
                              : allMatchesGroup();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
