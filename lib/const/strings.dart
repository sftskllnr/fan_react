// ASSETS
// svg
String sendDisabled = 'assets/svg/send_disabled.svg';
String sendActive = 'assets/svg/send_active.svg';
String profileActive = 'assets/svg/profile_active.svg';
String profileDefault = 'assets/svg/profile_default.svg';
String historyActive = 'assets/svg/history_active.svg';
String historyDefault = 'assets/svg/history_default.svg';
String matchesActive = 'assets/svg/matches_active.svg';
String matchesDefault = 'assets/svg/matches_default.svg';
String missionsActive = 'assets/svg/missions_active.svg';
String missionsDefault = 'assets/svg/missions_default.svg';
String filterActive = 'assets/svg/filter_active.svg';
String filterDefault = 'assets/svg/filter_default.svg';
String radiobuttonSelect = 'assets/svg/radiobutton_select.svg';
String radiobuttonDefault = 'assets/svg/radiobutton_default.svg';
String icWin = 'assets/svg/win.svg';
String icLoss = 'assets/svg/loss.svg';
String icLoading = 'assets/svg/loading.svg';
String checkboxActive = 'assets/svg/checkbox_active.svg';
String checkboxDefault = 'assets/svg/checkbox_default.svg';
String paperPlane = 'assets/svg/paper_plane.svg';
String circle = 'assets/svg/circle.svg';
String arrowDown = 'assets/svg/arrow_down.svg';
String arrowRight = 'assets/svg/arrow_right.svg';
String arrowTop = 'assets/svg/arrow_top.svg';
String search = 'assets/svg/search.svg';
String close = 'assets/svg/close.svg';
String arrowLeftWhite = 'assets/svg/arrow_left_white.svg';
String arrowLeftBlack = 'assets/svg/arrow_left_black.svg';
String chatConversation = 'assets/svg/chat_conversation.svg';
String moreHorizontal = 'assets/svg/more_horizontal.svg';
String trash = 'assets/svg/trash_empty.svg';
String chatClose = 'assets/svg/chat_close.svg';
//
String cool = 'assets/png/cool.png';
String angry = 'assets/png/angry.png';
String disappointed = 'assets/png/dissapointed.png';
String shocked = 'assets/png/shocked.png';
String loved = 'assets/png/loved.png';
String commentVeteran = 'assets/svg/comment_veteran.svg';
String threeDayStreak = 'assets/svg/three_day_streak.svg';
String reactionMaster = 'assets/svg/reaction_master.svg';
String explorer = 'assets/svg/explorer.svg';
String coldBlooded = 'assets/svg/cold_blooded.svg';
String firstWord = 'assets/svg/first_word.svg';
String moodSwing = 'assets/svg/mood_swing.svg';
String mindBlown = 'assets/svg/mind_blown.svg';
String fanInLove = 'assets/svg/fan_in_love.svg';
String preloaderBack = 'assets/svg/preloader_back.svg';

// png
String firstOnboard = 'assets/png/first_onboard.png';
String secondOnboard = 'assets/png/second_onboard.png';

// lottie
String preloader = 'assets/json/preloader.json';

// SCREENS
// 1 board
String skip = 'Skip';
String shareFeelings = 'Share Your Game\nFeelings';
String pickEmtion =
    'Pick your emotion after the match, tell others how you felt, and join the conversation';
String next = 'Next';

// 2 board
String start = 'Start';
String relive = 'Relive Every\nMoment';
String checkMatch =
    'Check match stats, read comments, and dive deeper into the action with the community';

// guide
String communityGuidelines = 'Community Guidelines';
String letsKeep = 'Let’s keep comments friendly and fair:';
List<String> guideList = [
  'Be respectful — no hate, harassment, or personal attacks.',
  'No spam or misleading comments.',
  'Keep it clean — no offensive or violent language.',
  'Share honest thoughts and respect other opinions.',
  'Don’t pretend to be someone else or spread false info.'
];
String moderation = 'Moderation';
String iAgree = 'I agree to the community guidelines';
String acceptContinue = 'Accept & Continue';
String byContinuing =
    'By continuing, you agree to follow these rules and help us maintain a safe environment for all fans.';
String weReview =
    'We review comments and remove those that break the rules. Repeated violations may limit your account.';

// HOME
String ok = 'OK';
String matches = 'Matches';
String history = 'History';
String achievement = 'Achievement';
String profile = 'Profile';
String reactToMatches = 'React to matches!';
String selectReaction =
    'Select a reaction under the match to express your mood. Your reaction will be added to the match statistics and can be changed at any time.';
String filterLeague = 'Filter by League';
String choice = 'Choice:';
String all = 'All';
String searhLeague = 'Search League';
String searchBy = 'Search by full league name';
String toFind = 'To find a league, enter its full name';
String resetChoice = 'Reset choice';
String noResultFound = 'No results found';
String resetToSee = 'Reset filter to see all matches';
String loading = 'Loading...';

// DETAILS MATCH
String detailsMatch = 'Details Match';
String statistics = 'Statistics';
String h2h = 'H2H';
String comments = 'Comments';
String matchVibes = 'Match Vibes';
String gameStatistics = 'Game Statistics';
String noCommentsYet = 'No comments yet';
String startConverstion = 'Start the conversation — add a comment';
String whatDoYouThink = 'What do you think about the match?';
String deleteCommentTitle = 'Delete your comment?';
String thisAction = 'This action cannot be undone.';
String cancel = 'Cancel';
String delete = 'Delete';
String penalties = 'Penalties';

// HISTORY
String noActivity = 'No activity yet';
String matchesYou = 'Matches you react to or comment on will appear here';

final achievementsMap = {
  'fan_in_love': {
    'name': 'Fan in Love',
    'description': 'React with ❤️ on 10 different matches',
    'targetValue': 10,
    'type': 'reaction',
  },
  'mind_blown': {
    'name': 'Mind = Blown',
    'description': 'Use the 😲 reaction in 3 matches in a row.',
    'targetValue': 3,
    'type': 'reaction',
  },
  'mood_swing': {
    'name': 'Mood Swing',
    'description': 'Use all 5 types of reactions in a single day.',
    'targetValue': 5,
    'type': 'reaction',
  },
  'first_word': {
    'name': 'First Word',
    'description': 'Be the first to comment on a match.',
    'targetValue': 1,
    'type': 'comment',
  },
  'cold_blooded': {
    'name': 'Cold Blooded',
    'description': 'Give your initial reaction to the match',
    'targetValue': 1,
    'type': 'reaction',
  },
  'explorer': {
    'name': 'Explorer',
    'description': 'React or comment on matches from 5 different leagues.',
    'targetValue': 5,
    'type': 'comment',
  },
  'reaction_master': {
    'name': 'Reaction Master',
    'description': 'Give 50 total reactions across matches.',
    'targetValue': 50,
    'type': 'reaction',
  },
  '3_day_streak': {
    'name': '3-Day Streak',
    'description': 'Log in to the app 3 days in a row.',
    'targetValue': 3,
    'type': 'login_streak',
  },
  'comment_veteran': {
    'name': 'Comment Veteran',
    'description': 'Leave comments on 25 different matches.',
    'targetValue': 25,
    'type': 'comment',
  },
};
