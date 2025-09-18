import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/main.dart';
import 'package:fan_react/screens/details/match_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:fan_react/models/match/match.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  void initState() {
    // loadMatchActivities();
    super.initState();
  }

  Future<void> sendReaction(int matchId, String reactionType) async {
    try {
      await firestoreService.updateReaction(matchId, reactionType);

      final updatedMatch = await firestoreService.getMatch(matchId);
      if (updatedMatch != null) {
        final indexAll = allMatches.indexWhere((m) => m.id == matchId);
        if (indexAll != -1) allMatches[indexAll] = updatedMatch;
        final indexSelected =
            selectedLeagueMatches.indexWhere((m) => m.id == matchId);
        if (indexSelected != -1) {
          selectedLeagueMatches[indexSelected] = updatedMatch;
        }
        selectedReactions[matchId] = reactionType;
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating reaction: $e')),
        );
      }
    }
  }

  void goToMatchDetails(Match match) async {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => MatchDetailsScreen(match: match)));
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.sizeOf(context).height;
    double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(title: Text(history, style: size24bold)),
      body: ValueListenableBuilder(
        valueListenable: matchesWithActivities,
        builder: (context, matches, child) => Container(
          color: G_400,
          height: screenHeight,
          width: screenWidth,
          child: isLoadingMatches
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  LottieBuilder.asset(preloader, width: 100, height: 100),
                  Text(loading, style: size15semibold)
                ])
              : ListView.builder(
                  itemCount: matches.length,
                  padding: const EdgeInsets.symmetric(
                      vertical: padding / 2, horizontal: padding),
                  itemBuilder: (context, index) {
                    Match match = matches[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: padding / 2),
                      child: matchItem(match, goToMatchDetails),
                    );
                  }),
        ),
      ),
    );
  }
}
