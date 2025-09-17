import 'package:fan_react/api/api_client.dart';
import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/models/statistic/match_statistic.dart';
import 'package:fan_react/services/firestore_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fan_react/models/match/match.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchDetailsScreen extends StatefulWidget {
  final Match match;
  const MatchDetailsScreen({super.key, required this.match});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  DateFormat dateFormatBack = DateFormat('EEEE, MMM d, yyyy');

  late ApiClient _apiClient;
  bool isStatSelected = true;
  bool isH2hSelected = false;
  bool isCommentsSelected = false;
  late FirestoreService _firestoreService;
  late ScrollController _scrollController;
  late PanelController _panelController;
  late TextEditingController _commentController;
  late FocusNode _focusNode;
  List<Match> homeTeamMatches = List.empty(growable: true);
  List<Match> awayTeamMatches = List.empty(growable: true);
  List<Match> h2hMatches = List.empty(growable: true);
  List<MatchStatistic> matchStatics = List.empty(growable: true);
  List<bool> homeTeamResults = List.empty(growable: true);
  List<bool> awayTeamResults = List.empty(growable: true);
  List<Map<String, dynamic>> listComments = List.empty(growable: true);
  bool showHeaders = true;
  bool isLoadingComments = false;
  bool isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _panelController = PanelController();
    _focusNode = FocusNode();
    _firestoreService = FirestoreService();
    _apiClient = ApiClient();
    _scrollController = ScrollController();
    _commentController = TextEditingController();

    getLastFiveMatches(widget.match.homeTeam.id, true).whenComplete(() {
      getTeamResults(homeTeamMatches, widget.match.homeTeam.id, true);
    });
    getLastFiveMatches(widget.match.awayTeam.id, false).whenComplete(() {
      getTeamResults(awayTeamMatches, widget.match.awayTeam.id, false);
    });

    getMatchStatistic(widget.match.id);
    getH2hMatches();
    fetchComments();
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

  Future<void> fetchComments() async {
    setState(() {
      isLoadingComments = true;
    });
    try {
      final fetchedComments =
          await _firestoreService.getComments(widget.match.id);

      listComments = fetchedComments;
      isLoadingComments = false;
      setState(() {});
    } catch (e) {
      isLoadingComments = false;
      setState(() {});
      debugPrint('Error fetching comments: $e');
    }
  }

  Future<void> sendComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to comment.')));
      return;
    }

    if (_commentController.text.isNotEmpty &&
        _commentController.text.length <= 140) {
      setState(() {
        isSubmittingComment = true;
      });
      _focusNode.unfocus();
      _panelController.close();
      try {
        await _firestoreService.addComment(
          widget.match.id,
          user.uid,
          _commentController.text,
        );
        _commentController.clear();
        await fetchComments();
      } catch (e) {
        debugPrint('Error sending comment: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to send comment.')));
        }
      } finally {
        setState(() {
          isSubmittingComment = false;
        });
      }
    }
  }

  void deleteComment(String commentId, String? currentUserId) async {
    await _firestoreService.deleteComment(
        widget.match.id, commentId, currentUserId!);
    await fetchComments();
  }

  void getH2hMatches() async {
    List<Match> h2hList = await _apiClient.getH2hMatches(
        widget.match.homeTeam.id, widget.match.awayTeam.id);

    h2hMatches = h2hList;
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

  void showClearDataAlert(
      BuildContext context, String commentId, String? currentUserId) async {
    _focusNode.unfocus();
    _panelController.close();
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text(deleteCommentTitle, style: size18semibold),
              content: Text(thisAction, style: size14medium),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancel,
                        style: size15medium.copyWith(
                            color: Colors.blue, fontSize: 17))),
                TextButton(
                    onPressed: () {
                      deleteComment(commentId, currentUserId);
                      Navigator.of(context).pop();
                    },
                    child: Text(delete,
                        style: size15medium.copyWith(
                            color: Colors.red, fontSize: 17)))
              ]);
        });
  }

  Widget teamLogoStats(Match match, bool isHome) {
    return Column(children: [
      Container(
          height: padding * 6,
          width: padding * 6,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(padding / 2),
          child: Image.network(
              isHome ? match.homeTeam.logo ?? '' : match.awayTeam.logo ?? '',
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.error_outline_outlined, color: G_100))),
      Container(
          width: padding * 6,
          height: padding * 2.5,
          alignment: Alignment.center,
          child: Text(isHome ? match.homeTeam.name : match.awayTeam.name,
              style: size15medium.copyWith(color: G_100),
              textAlign: TextAlign.center))
    ]);
  }

  Widget matchVibesWidget(double screenWidth, double screenHeight) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
            //width: 65,
            padding: const EdgeInsets.all(padding / 2),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: G_400, borderRadius: BorderRadius.circular(50)),
            child: Row(
              children: [
                SizedBox(height: 20, width: 20, child: Image.asset(loved)),
                const SizedBox(width: padding / 4),
                Text(widget.match.reactions?['loved'].toString() ?? '',
                    style: size12semibold),
              ],
            )),
        const SizedBox(width: padding / 4),
        Container(
            //width: 65,
            padding: const EdgeInsets.all(padding / 2),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: G_400, borderRadius: BorderRadius.circular(50)),
            child: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Image.asset(angry),
                ),
                const SizedBox(width: padding / 4),
                Text(widget.match.reactions?['angry'].toString() ?? '',
                    style: size12semibold),
              ],
            )),
        const SizedBox(width: padding / 4),
        Container(
            //width: 65,
            padding: const EdgeInsets.all(padding / 2),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: G_400, borderRadius: BorderRadius.circular(50)),
            child: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Image.asset(disappointed),
                ),
                const SizedBox(width: padding / 4),
                Text(widget.match.reactions?['disappointed'].toString() ?? '',
                    style: size12semibold),
              ],
            )),
        const SizedBox(width: padding / 4),
        Container(
            //width: 65,
            padding: const EdgeInsets.all(padding / 2),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: G_400, borderRadius: BorderRadius.circular(50)),
            child: Row(
              children: [
                SizedBox(height: 20, width: 20, child: Image.asset(cool)),
                const SizedBox(width: padding / 4),
                Text(widget.match.reactions?['cool'].toString() ?? '',
                    style: size12semibold),
              ],
            )),
        const SizedBox(width: padding / 4),
        Container(
            padding: const EdgeInsets.all(padding / 2),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: G_400, borderRadius: BorderRadius.circular(50)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 20, width: 20, child: Image.asset(shocked)),
                const SizedBox(width: padding / 4),
                Text(widget.match.reactions?['shocked'].toString() ?? '',
                    style: size12semibold),
              ],
            )),
      ])
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
          padding: const EdgeInsets.all(0.0),
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

  Widget commentsWidget(
      double screenHeight, double screenWidth, double minPanelHeight) {
    double textFieldWidth =
        screenWidth - padding * 2 - padding / 2 - padding * 3;
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    double inputContainerHeight = padding * 7;
    double listViewHeight = padding * 18;

    return isLoadingComments || isSubmittingComment
        ? Column(
            children: [
              SizedBox(
                  height: _focusNode.hasFocus
                      ? screenHeight - padding * 16 - keyboardHeight
                      : screenHeight - padding * 21 - inputContainerHeight,
                  child:
                      LottieBuilder.asset(preloader, width: 100, height: 100)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: textFieldWidth,
                        child: TextField(
                            controller: _commentController,
                            focusNode: _focusNode,
                            onTap: () {
                              _focusNode.requestFocus();
                              _panelController.open();
                            },
                            onChanged: (value) => setState(() {}),
                            expands: _commentController.text.length > 25
                                ? true
                                : false,
                            maxLines:
                                _commentController.text.length > 25 ? null : 1,
                            cursorColor: ACCENT_PRIMARY,
                            decoration: InputDecoration(
                                hintText: whatDoYouThink,
                                hintStyle: size15medium.copyWith(color: G_600),
                                contentPadding:
                                    const EdgeInsets.all(padding * 0.8),
                                fillColor: G_200,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: G_400)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: G_400))))),
                    const SizedBox(width: padding / 2),
                    InkWell(
                      onTap: () => sendComment(),
                      child: Container(
                        width: padding * 3,
                        height: padding * 3,
                        decoration: BoxDecoration(
                            color: _commentController.text.isNotEmpty
                                ? ACCENT_PRIMARY
                                : G_600,
                            borderRadius: BorderRadius.circular(buttonsRadius)),
                        child: SvgPicture.asset(
                            _commentController.text.isNotEmpty
                                ? sendActive
                                : sendDisabled),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        : listComments.isEmpty
            ? Column(children: [
                SizedBox(
                    height: _focusNode.hasFocus
                        ? screenHeight - padding * 18 - keyboardHeight
                        : !showHeaders
                            ? screenHeight - listViewHeight
                            : minPanelHeight - inputContainerHeight,
                    child: Column(children: [
                      SizedBox(height: (screenHeight - padding * 21) / 3),
                      Text(noCommentsYet, style: size15semibold),
                      Text(startConverstion,
                          style: size14medium.copyWith(color: G_700))
                    ])),
                Container(
                  height: padding * 7,
                  width: screenWidth,
                  padding: const EdgeInsets.symmetric(
                      horizontal: padding, vertical: padding),
                  decoration: BoxDecoration(
                      color: G_100,
                      border: Border(top: BorderSide(color: G_200))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: textFieldWidth,
                          child: TextField(
                              controller: _commentController,
                              focusNode: _focusNode,
                              onTap: () {
                                _focusNode.requestFocus();
                                _panelController.open();
                              },
                              onChanged: (value) => setState(() {}),
                              expands: _commentController.text.length > 25
                                  ? true
                                  : false,
                              maxLines: _commentController.text.length > 25
                                  ? null
                                  : 1,
                              cursorColor: ACCENT_PRIMARY,
                              decoration: InputDecoration(
                                  hintText: whatDoYouThink,
                                  hintStyle:
                                      size15medium.copyWith(color: G_600),
                                  contentPadding:
                                      const EdgeInsets.all(padding * 0.8),
                                  fillColor: G_200,
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: G_400)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: G_400))))),
                      const SizedBox(width: padding / 2),
                      InkWell(
                        onTap: () => sendComment(),
                        child: Container(
                          width: padding * 3,
                          height: padding * 3,
                          decoration: BoxDecoration(
                              color: _commentController.text.isNotEmpty
                                  ? ACCENT_PRIMARY
                                  : G_600,
                              borderRadius:
                                  BorderRadius.circular(buttonsRadius)),
                          child: SvgPicture.asset(
                              _commentController.text.isNotEmpty
                                  ? sendActive
                                  : sendDisabled),
                        ),
                      )
                    ],
                  ),
                ),
              ])
            : Column(
                children: [
                  SizedBox(
                    height: _focusNode.hasFocus
                        ? screenHeight - padding * 18 - keyboardHeight
                        : !showHeaders
                            ? screenHeight - listViewHeight
                            : minPanelHeight - inputContainerHeight,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: padding),
                      itemCount: listComments.length,
                      itemBuilder: (context, index) {
                        //
                        final comment = listComments[index];
                        final commentId = comment['commentId'];
                        final isAuthor = currentUserId == comment['userId'];
                        //
                        return Container(
                          padding: const EdgeInsets.only(bottom: padding / 2),
                          margin:
                              const EdgeInsets.symmetric(horizontal: padding),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                      'https://i.pravatar.cc/150?img=$index')),
                              const SizedBox(width: padding / 2),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text('${comment['userName']}',
                                        style: size14semibold),
                                    Text(comment['commentText'],
                                        style: size15medium),
                                  ])),
                              InkWell(
                                onTap: () => showClearDataAlert(
                                    context, commentId, currentUserId),
                                child: isAuthor
                                    ? SvgPicture.asset(trash,
                                        width: 20, height: 20)
                                    : Icon(Icons.more_horiz, color: G_900),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    height: padding * 7,
                    width: screenWidth,
                    padding: const EdgeInsets.symmetric(
                        horizontal: padding, vertical: padding),
                    decoration: BoxDecoration(
                        color: G_100,
                        border: Border(top: BorderSide(color: G_200))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: textFieldWidth,
                            child: TextField(
                                controller: _commentController,
                                focusNode: _focusNode,
                                onTap: () {
                                  _focusNode.requestFocus();
                                  _panelController.open();
                                },
                                onChanged: (value) => setState(() {}),
                                expands: _commentController.text.length > 25
                                    ? true
                                    : false,
                                maxLines: _commentController.text.length > 25
                                    ? null
                                    : 1,
                                cursorColor: ACCENT_PRIMARY,
                                decoration: InputDecoration(
                                    hintText: whatDoYouThink,
                                    hintStyle:
                                        size15medium.copyWith(color: G_600),
                                    fillColor: G_200,
                                    filled: true,
                                    contentPadding:
                                        const EdgeInsets.all(padding * 0.8),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: G_400)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: G_400))))),
                        const SizedBox(width: padding / 2),
                        InkWell(
                          onTap: () => sendComment(),
                          child: SizedBox(
                            width: padding * 3,
                            height: padding * 3,
                            child: _commentController.text.isNotEmpty
                                ? SvgPicture.asset(sendActive)
                                : SvgPicture.asset(sendDisabled),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
  }

  Widget h2hWidget(double screenHeight, double screenWidth) {
    return Container(
        width: screenWidth,
        height: screenHeight - padding * 21,
        padding: const EdgeInsets.symmetric(
            horizontal: padding, vertical: padding / 2),
        decoration: BoxDecoration(
            color: G_100,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(padding),
                topRight: Radius.circular(padding))),
        child: ListView.builder(
            itemCount: h2hMatches.length,
            padding: const EdgeInsets.all(0.0),
            itemBuilder: (context, index) {
              //
              Match match = h2hMatches[index];
              DateTime matchDate = DateTime.parse(match.date);
              String date = dateFormatBack.format(matchDate);
              //
              return Container(
                margin: const EdgeInsets.only(bottom: padding / 4),
                padding: const EdgeInsets.all(padding / 2),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: G_400, width: 1))),
                child: Column(
                  children: [
                    Text(date, style: size14medium.copyWith(color: G_700)),
                    const SizedBox(height: padding / 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(match.homeTeam.name, style: size14semibold),
                        const SizedBox(width: padding / 2),
                        SizedBox(
                            height: 30,
                            width: 30,
                            child: Image.network(match.homeTeam.logo ?? '')),
                        const SizedBox(width: padding),
                        Text(match.state.score.current ?? '',
                            style: size18semibold),
                        const SizedBox(width: padding),
                        SizedBox(
                            height: 30,
                            width: 30,
                            child: Image.network(match.awayTeam.logo ?? '')),
                        const SizedBox(width: padding / 2),
                        Text(match.awayTeam.name, style: size14semibold)
                      ],
                    )
                  ],
                ),
              );
            }));
  }

  Widget statisticListView() {
    return ListView.builder(
        controller: _scrollController,
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

  Widget statisticsWidget(double screenHeight, double screenWidth) {
    return Container(
        width: screenWidth,
        height: screenHeight - padding * 20,
        padding: const EdgeInsets.symmetric(horizontal: padding),
        decoration: BoxDecoration(
            color: G_100,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(padding),
                topRight: Radius.circular(padding))),
        child: Column(children: [
          const SizedBox(height: padding / 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            child: Offstage(
              offstage: !showHeaders,
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [Text(matchVibes, style: size15semibold)]),
                  const SizedBox(height: padding / 4),
                  matchVibesWidget(screenWidth, screenHeight),
                  const SizedBox(height: padding / 4),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [Text(gameStatistics, style: size15semibold)]),
                  const SizedBox(height: padding / 4),
                ],
              ),
            ),
          ),
          Row(children: [
            SizedBox(
                height: showHeaders
                    ? screenHeight - padding * 26
                    : screenHeight - padding * 12,
                width: screenWidth - padding * 2,
                child: matchStatics.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            LottieBuilder.asset(preloader,
                                width: 100, height: 100),
                            Text(loading, style: size15semibold)
                          ])
                    : statisticListView())
          ])
        ]));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;
    double maxPanelHeight = screenHeight - padding * 11;
    double minPanelHeight = screenHeight - padding * 21;
    bool isPenalties = widget.match.state.score.penalties != null;

    return InkWell(
      onTap: () {
        _focusNode.unfocus();
        _panelController.close();
      },
      child: SlidingUpPanel(
        controller: _panelController,
        minHeight: minPanelHeight,
        maxHeight: maxPanelHeight,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(padding),
            topRight: Radius.circular(padding)),
        onPanelClosed: () => setState(() {}),
        onPanelOpened: () => setState(() {}),
        onPanelSlide: (position) => setState(() {
          position > 0.2 ? showHeaders = false : showHeaders = true;
        }),
        header: Container(
            width: screenWidth,
            height: padding,
            alignment: Alignment.center,
            color: Colors.transparent,
            child: Container(
                width: padding * 3,
                height: padding / 4,
                decoration: BoxDecoration(
                    color: G_600,
                    borderRadius: BorderRadius.circular(buttonsRadius)))),
        panelBuilder: (sc) => isStatSelected
            ? statisticsWidget(screenHeight, screenWidth)
            : isH2hSelected
                ? h2hWidget(screenHeight, screenWidth)
                : commentsWidget(screenHeight, screenWidth, minPanelHeight),
        body: Scaffold(
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
                              borderRadius:
                                  BorderRadius.circular(buttonsRadius),
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
                                    colorFilter: ColorFilter.mode(
                                        G_100, BlendMode.srcIn),
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
                          Text(
                              !showHeaders
                                  ? '${widget.match.homeTeam.name} vs ${widget.match.awayTeam.name}'
                                  : widget.match.league.name,
                              style: size15medium.copyWith(color: G_100)),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            child: Offstage(
                              offstage: !showHeaders,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: padding),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(children: [
                                      teamLogoStats(widget.match, true),
                                      const SizedBox(height: padding / 2),
                                      winStats(homeTeamResults)
                                    ]),
                                    Column(children: [
                                      const SizedBox(height: padding),
                                      Text('${widget.match.state.clock}\'',
                                          style: size14medium.copyWith(
                                              color: G_100)),
                                      Text(
                                          widget.match.state.score.current ??
                                              '',
                                          style: size28bold.copyWith(
                                              color: G_100)),
                                      const SizedBox(height: padding / 2),
                                      Offstage(
                                          offstage: !isPenalties,
                                          child: Column(children: [
                                            Text(penalties,
                                                style: size14medium.copyWith(
                                                    color: G_100)),
                                            Text(
                                                widget.match.state.score
                                                        .penalties ??
                                                    '',
                                                style: size18semibold.copyWith(
                                                    color: G_100))
                                          ]))
                                    ]),
                                    Column(children: [
                                      teamLogoStats(widget.match, false),
                                      const SizedBox(height: padding / 2),
                                      winStats(awayTeamResults)
                                    ])
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: padding * 1.5),
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: padding),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                ]))),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
