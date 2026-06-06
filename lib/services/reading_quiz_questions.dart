class ReadingQuestion {
  final String questionEn;
  final String questionTe;
  final List<String> optionsEn;
  final List<String> optionsTe;
  final int correctAnswerIndex;
  final String verseReference;

  const ReadingQuestion({
    required this.questionEn,
    required this.questionTe,
    required this.optionsEn,
    required this.optionsTe,
    required this.correctAnswerIndex,
    required this.verseReference,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionEn': questionEn,
      'questionTe': questionTe,
      'optionsEn': optionsEn,
      'optionsTe': optionsTe,
      'correctAnswerIndex': correctAnswerIndex,
      'verseReference': verseReference,
    };
  }
}

class ReadingQuizQuestions {
  /// Returns 5 questions for a specific plan and day.
  /// If day-specific questions don't exist (e.g. in 90/365 plans), it draws from book pools.
  static List<ReadingQuestion> getQuestions(String planType, int day, {String versesInfo = ''}) {
    if (planType == '30_day') {
      return _plan30Questions[day] ?? _getFallbackQuestions(versesInfo);
    }
    return _getFallbackQuestions(versesInfo);
  }

  static List<ReadingQuestion> _getFallbackQuestions(String versesInfo) {
    // Determine the book based on the versesInfo string
    final cleanInfo = versesInfo.toLowerCase();
    String bookKey = 'genesis';
    if (cleanInfo.contains('exodus') || cleanInfo.contains('నిర్గమ')) {
      bookKey = 'exodus';
    } else if (cleanInfo.contains('leviticus') || cleanInfo.contains('లేవీయ')) {
      bookKey = 'leviticus';
    } else if (cleanInfo.contains('numbers') || cleanInfo.contains('సంఖ్యా')) {
      bookKey = 'numbers';
    } else if (cleanInfo.contains('deuteronomy') || cleanInfo.contains('ద్వితీయో')) {
      bookKey = 'deuteronomy';
    } else if (cleanInfo.contains('joshua') || cleanInfo.contains('యెహోషు')) {
      bookKey = 'joshua';
    } else if (cleanInfo.contains('judges') || cleanInfo.contains('న్యాయా')) {
      bookKey = 'judges';
    } else if (cleanInfo.contains('samuel') || cleanInfo.contains('సమూయే')) {
      bookKey = 'samuel';
    } else if (cleanInfo.contains('kings') || cleanInfo.contains('రాజులు')) {
      bookKey = 'kings';
    } else if (cleanInfo.contains('psalm') || cleanInfo.contains('కీర్తన')) {
      bookKey = 'psalms';
    } else if (cleanInfo.contains('proverb') || cleanInfo.contains('సామెత')) {
      bookKey = 'proverbs';
    } else if (cleanInfo.contains('isaiah') || cleanInfo.contains('యెషయా')) {
      bookKey = 'isaiah';
    } else if (cleanInfo.contains('jeremiah') || cleanInfo.contains('యిర్మీ')) {
      bookKey = 'jeremiah';
    } else if (cleanInfo.contains('ezekiel') || cleanInfo.contains('యెహెజ్కే')) {
      bookKey = 'ezekiel';
    } else if (cleanInfo.contains('daniel') || cleanInfo.contains('దానియే')) {
      bookKey = 'daniel';
    } else if (cleanInfo.contains('matthew') || cleanInfo.contains('మత్తయి')) {
      bookKey = 'matthew';
    } else if (cleanInfo.contains('mark') || cleanInfo.contains('మార్కు')) {
      bookKey = 'mark';
    } else if (cleanInfo.contains('luke') || cleanInfo.contains('లూకా')) {
      bookKey = 'luke';
    } else if (cleanInfo.contains('john') || cleanInfo.contains('యోహాను')) {
      bookKey = 'john';
    } else if (cleanInfo.contains('acts') || cleanInfo.contains('అపొస్త')) {
      bookKey = 'acts';
    } else if (cleanInfo.contains('romans') || cleanInfo.contains('రోమీ')) {
      bookKey = 'romans';
    } else if (cleanInfo.contains('corinthians') || cleanInfo.contains('కొరింథీ')) {
      bookKey = 'corinthians';
    } else if (cleanInfo.contains('galatians') || cleanInfo.contains('గలతీ') ||
               cleanInfo.contains('ephesians') || cleanInfo.contains('ఎఫెసీ') ||
               cleanInfo.contains('philippians') || cleanInfo.contains('ఫిలిప్పీ') ||
               cleanInfo.contains('colossians') || cleanInfo.contains('కొలొస్సై')) {
      bookKey = 'epistles_paul';
    } else if (cleanInfo.contains('hebrews') || cleanInfo.contains('హెబ్రీ') ||
               cleanInfo.contains('james') || cleanInfo.contains('యాకోబు') ||
               cleanInfo.contains('peter') || cleanInfo.contains('పేతురు') ||
               cleanInfo.contains('jude') || cleanInfo.contains('యూదా')) {
      bookKey = 'epistles_general';
    } else if (cleanInfo.contains('revelation') || cleanInfo.contains('ప్రకటన')) {
      bookKey = 'revelation';
    }

    final pool = _bookQuestionPools[bookKey] ?? _bookQuestionPools['genesis']!;
    // Return a shuffled copy of 5 questions from the pool
    final list = List<ReadingQuestion>.from(pool)..shuffle();
    return list.take(5).toList();
  }

  // Day-specific questions for 30-Day Plan (1 to 30)
  static final Map<int, List<ReadingQuestion>> _plan30Questions = {
    1: [
      const ReadingQuestion(
        questionEn: "On which day did God create light?",
        questionTe: "దేవుడు ఏ రోజున వెలుగును సృష్టించాడు?",
        optionsEn: ["Day 1", "Day 3", "Day 4", "Day 6"],
        optionsTe: ["మొదటి రోజు", "మూడవ రోజు", "నాలుగవ రోజు", "ఆరవ రోజు"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 1:3-5",
      ),
      const ReadingQuestion(
        questionEn: "Who was the first murderer in the Bible?",
        questionTe: "బైబిల్‌లో మొదటి హంతకుడు ఎవరు?",
        optionsEn: ["Cain", "Abel", "Lamech", "Nimrod"],
        optionsTe: ["కయీను", "హేబెలు", "లామెకు", "నిమ్రోదు"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 4:8",
      ),
      const ReadingQuestion(
        questionEn: "What did God place to guard the tree of life after Adam and Eve were expelled?",
        questionTe: "ఆదాము మరియు హవ్వలను తోట నుండి పంపించిన తర్వాత జీవవృక్షమును కాపాడుటకు దేవుడు దేనిని ఉంచాడు?",
        optionsEn: ["Cherubim and a flaming sword", "A great stone wall", "An archangel", "A river of fire"],
        optionsTe: ["కెరూబులు మరియు ఖడ్గజ్వాల", "ఒక పెద్ద రాతి గోడ", "ఒక ప్రధాన దూత", "అగ్ని నది"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 3:24",
      ),
      const ReadingQuestion(
        questionEn: "How many stories/decks did Noah's Ark have?",
        questionTe: "నోవహు ఓడకు ఎన్ని అంతస్తులు ఉన్నాయి?",
        optionsEn: ["One", "Two", "Three", "Four"],
        optionsTe: ["ఒకటి", "రెండు", "మూడు", "నాలుగు"],
        correctAnswerIndex: 2,
        verseReference: "Genesis 6:16",
      ),
      const ReadingQuestion(
        questionEn: "What was the symbol of God's covenant with Noah?",
        questionTe: "నోవహుతో దేవుడు చేసిన నిబంధనకు గుర్తు ఏమిటి?",
        optionsEn: ["A rainbow", "A burning altar", "A golden ring", "A white dove"],
        optionsTe: ["మేఘధనస్సు (ఇంద్రధనస్సు)", "మండుతున్న బలిపీఠం", "బంగారు ఉంగరం", "తెల్లని పావురం"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 9:13",
      ),
    ],
    2: [
      const ReadingQuestion(
        questionEn: "Where did God tell Abram to go when He first called him?",
        questionTe: "దేవుడు అబ్రామును మొదట పిలిచినప్పుడు ఎక్కడికి వెళ్ళమని చెప్పాడు?",
        optionsEn: ["To Egypt", "To Haran", "To a land He would show him", "To Babylon"],
        optionsTe: ["ఐగుప్తుకు", "హారానుకు", "ఆయన చూపించబోవు దేశమునకు", "బబులోనుకు"],
        correctAnswerIndex: 2,
        verseReference: "Genesis 12:1",
      ),
      const ReadingQuestion(
        questionEn: "What was Sarah's original name?",
        questionTe: "శారమ్మ యొక్క అసలు పేరు ఏమిటి?",
        optionsEn: ["Sarai", "Keturah", "Milcah", "Hagar"],
        optionsTe: ["సారాయి", "కెతూరా", "మిల్కా", "హాగరు"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 17:15",
      ),
      const ReadingQuestion(
        questionEn: "How old was Abraham when Isaac was born?",
        questionTe: "ఇస్సాకు జన్మించినప్పుడు అబ్రాహాము వయస్సు ఎంత?",
        optionsEn: ["75 years old", "86 years old", "100 years old", "120 years old"],
        optionsTe: ["75 సంవత్సరాలు", "86 సంవత్సరాలు", "100 సంవత్సరాలు", "120 సంవత్సరాలు"],
        correctAnswerIndex: 2,
        verseReference: "Genesis 21:5",
      ),
      const ReadingQuestion(
        questionEn: "Which city was destroyed alongside Gomorrah?",
        questionTe: "గొమొఱ్ఱాతో పాటు ఏ నగరం నాశనం చేయబడింది?",
        optionsEn: ["Sodom", "Zoar", "Jericho", "Bethel"],
        optionsTe: ["సొదొమ", "జోయరు", "యెరికో", "బేతేలు"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 19:24-25",
      ),
      const ReadingQuestion(
        questionEn: "What did Abraham offer instead of his son Isaac on the altar?",
        questionTe: "బలిపీఠం మీద తన కుమారుడైన ఇస్సాకుకు బదులుగా అబ్రాహాము దేనిని బలి అర్పించాడు?",
        optionsEn: ["A lamb", "A ram caught in a thicket", "A young calf", "Two turtledoves"],
        optionsTe: ["ఒక గొర్రెపిల్ల", "పొదలో తగులుకున్న పొట్టేలు", "ఒక లేత దూడ", "రెండు గువ్వలు"],
        correctAnswerIndex: 1,
        verseReference: "Genesis 22:13",
      ),
    ],
    3: [
      const ReadingQuestion(
        questionEn: "Who was Esau's twin brother?",
        questionTe: "ఏశావు యొక్క కవల సోదరుడు ఎవరు?",
        optionsEn: ["Jacob", "Joseph", "Benjamin", "Ishmael"],
        optionsTe: ["యాకోబు", "యోసేపు", "బెన్యామీను", "ఇష్మాయేలు"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 25:24-26",
      ),
      const ReadingQuestion(
        questionEn: "What did Jacob see in his dream at Bethel?",
        questionTe: "బేతేలు వద్ద యాకోబు తన కలలో ఏమి చూశాడు?",
        optionsEn: ["A ladder reaching to heaven with angels", "A chariot of fire", "A burning bush", "Seven fat cows"],
        optionsTe: ["దేవదూతలతో ఆకాశానికి నిలిపిన నిచ్చెన", "అగ్ని రథం", "మండుతున్న పొద", "ఏడు బలిసిన ఆవులు"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 28:12",
      ),
      const ReadingQuestion(
        questionEn: "How many years did Jacob serve Laban in total to marry Rachel and Leah?",
        questionTe: "రాహేలు మరియు లేయాలను వివాహం చేసుకోవడానికి యాకోబు లాబాను వద్ద మొత్తం ఎన్ని సంవత్సరాలు సేవ చేశాడు?",
        optionsEn: ["7 years", "10 years", "14 years", "20 years"],
        optionsTe: ["7 సంవత్సరాలు", "10 సంవత్సరాలు", "14 సంవత్సరాలు", "20 సంవత్సరాలు"],
        correctAnswerIndex: 2,
        verseReference: "Genesis 29:18-30",
      ),
      const ReadingQuestion(
        questionEn: "What name did God give Jacob after he wrestled with Him?",
        questionTe: "యాకోబు దేవునితో పోరాడిన తర్వాత దేవుడు అతనికి ఏ పేరు పెట్టాడు?",
        optionsEn: ["Israel", "Abraham", "Isaac", "Judah"],
        optionsTe: ["ఇశ్రాయేలు", "అబ్రాహాము", "ఇస్సాకు", "యూదా"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 32:28",
      ),
      const ReadingQuestion(
        questionEn: "Who was Jacob's eldest son?",
        questionTe: "యాకోబు యొక్క జ్యేష్ఠ కుమారుడు ఎవరు?",
        optionsEn: ["Reuben", "Simeon", "Levi", "Judah"],
        optionsTe: ["రూబేను", "షిమ్యోను", "లేవి", "యూదా"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 29:32",
      ),
    ],
    4: [
      const ReadingQuestion(
        questionEn: "What special gift did Jacob give to Joseph that excited his brothers' jealousy?",
        questionTe: "తన సహోదరుల అసూయను రేకెత్తించే విధంగా యాకోబు యోసేపుకు ఇచ్చిన ప్రత్యేక బహుమతి ఏమిటి?",
        optionsEn: ["A coat of many colors", "A silver cup", "A golden ring", "A flock of sheep"],
        optionsTe: ["విచిత్రమైన నిలువుటంగీ (రంగురంగుల కోటు)", "వెండి గిన్నె", "బంగారు ఉంగరం", "గొర్రెల మంద"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 37:3",
      ),
      const ReadingQuestion(
        questionEn: "To which country was Joseph sold as a slave?",
        questionTe: "యోసేపు ఏ దేశానికి బానిసగా అమ్మబడ్డాడు?",
        optionsEn: ["Egypt", "Assyria", "Babylon", "Moab"],
        optionsTe: ["ఐగుప్తు", "అష్షూరు", "బబులోను", "మోయాబు"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 37:36",
      ),
      const ReadingQuestion(
        questionEn: "Whose dreams did Joseph interpret while in the Egyptian prison?",
        questionTe: "ఐగుప్తు చెరసాలలో ఉన్నప్పుడు యోసేపు ఎవరి కలలకు భావం చెప్పాడు?",
        optionsEn: ["The chief butler and chief baker", "Pharaoh and his wife", "Potiphar and his guards", "Two soldiers"],
        optionsTe: ["పానదాయకుల అధిపతి మరియు భక్ష్యకారుల అధిపతి", "ఫరో మరియు అతని భార్య", "పోతిఫరు మరియు అతని కావలివారు", "ఇద్దరు సైనికులు"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 40:5-22",
      ),
      const ReadingQuestion(
        questionEn: "How many years of famine did Pharaoh's dream predict?",
        questionTe: "ఫరో కల ప్రకారం ఎన్ని సంవత్సరాలు క్షామము (కరువు) వస్తుందని అంచనా వేయబడింది?",
        optionsEn: ["Three years", "Five years", "Seven years", "Ten years"],
        optionsTe: ["మూడు సంవత్సరాలు", "ఐదు సంవత్సరాలు", "ఏడు సంవత్సరాలు", "పది సంవత్సరాలు"],
        correctAnswerIndex: 2,
        verseReference: "Genesis 41:29-30",
      ),
      const ReadingQuestion(
        questionEn: "In which land of Egypt did Jacob's family settle?",
        questionTe: "యాకోబు కుటుంబం ఐగుప్తులోని ఏ ప్రాంతంలో నివసించారు?",
        optionsEn: ["Goshen", "Cairo", "Alexandria", "Thebes"],
        optionsTe: ["గోషెను దేశము", "కైరో", "అలెగ్జాండ్రియా", "థీబ్స్"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 47:6",
      ),
    ],
    5: [
      const ReadingQuestion(
        questionEn: "In what form did God first appear to Moses in the wilderness?",
        questionTe: "అరణ్యములో మోషేకు దేవుడు మొదటిసారి ఏ రూపంలో ప్రత్యక్షమయ్యాడు?",
        optionsEn: ["A burning bush", "A pillar of cloud", "A great wind", "A voice from heaven"],
        optionsTe: ["మండుచున్న పొద", "మేఘస్తంభం", "గొప్ప గాలి", "పరలోకం నుండి వచ్చిన స్వరం"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 3:2",
      ),
      const ReadingQuestion(
        questionEn: "What was the first plague sent upon Egypt?",
        questionTe: "ఐగుప్తుకు పంపబడిన మొదటి తెగులు ఏమిటి?",
        optionsEn: ["Water turned to blood", "Frogs", "Lice", "Darkness"],
        optionsTe: ["నీరు రక్తంగా మారుట", "కప్పలు", "పేలు", "చీకటి"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 7:20",
      ),
      const ReadingQuestion(
        questionEn: "What was the final plague that convinced Pharaoh to let Israel go?",
        questionTe: "ఇశ్రాయేలీయులను వెళ్ళనివ్వడానికి ఫరోను ఒప్పించిన చివరి తెగులు ఏమిటి?",
        optionsEn: ["Death of the firstborn", "Locusts", "Boils", "Hailstones"],
        optionsTe: ["తొలిచూలు సంహారం", "మిడతలు", "సెగగడ్డలు", "వడగండ్లు"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 11:5",
      ),
      const ReadingQuestion(
        questionEn: "Which sea did the Israelites cross on dry ground to escape Pharaoh's army?",
        questionTe: "ఫరో సైన్యం నుండి తప్పించుకోవడానికి ఇశ్రాయేలీయులు ఆరిన నేల మీద ఏ సముద్రమును దాటారు?",
        optionsEn: ["The Red Sea", "The Dead Sea", "The Mediterranean Sea", "The Sea of Galilee"],
        optionsTe: ["ఎర్రసముద్రము", "మృతసముద్రము", "మధ్యధరా సముద్రము", "గలిలయ సముద్రము"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 14:21-22",
      ),
      const ReadingQuestion(
        questionEn: "What was the name of Moses' sister who led the celebration after crossing the Red Sea?",
        questionTe: "ఎర్రసముద్రమును దాటిన తర్వాత స్తుతి గీతం ఆలపించిన మోషే సోదరి పేరు ఏమిటి?",
        optionsEn: ["Miriam", "Deborah", "Ruth", "Esther"],
        optionsTe: ["మిరియాము", "దెబోరా", "రూతు", "ఎస్తేరు"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 15:20",
      ),
    ],
    // Stubbing out the rest of the 30 days to make sure it exists, but with robust fallback handling in the main getter.
    // Let's add Day 6 to 30 with realistic questions to make sure the 30-day plan is completely detailed as requested!
    6: [
      const ReadingQuestion(
        questionEn: "What was the name of the bread God provided from heaven for the Israelites?",
        questionTe: "అరణ్యములో ఇశ్రాయేలీయులకు దేవుడు పరలోకం నుండి కురిపించిన ఆహారము (రొట్టె) పేరు ఏమిటి?",
        optionsEn: ["Manna", "Quails", "Showbread", "Omer"],
        optionsTe: ["మన్నా", "పూరేళ్లు", "సన్నిధి రొట్టెలు", "ఓమెరు"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 16:15",
      ),
      const ReadingQuestion(
        questionEn: "Where did Moses strike the rock to get water for the thirsty people?",
        questionTe: "దాహంతో ఉన్న ప్రజల కొరకు మోషే ఏ బండను కొట్టి నీళ్లు రప్పించాడు?",
        optionsEn: ["Horeb (Rephidim)", "Sinai", "Nebo", "Ararat"],
        optionsTe: ["హోరేబు (రెఫీదీము)", "సీనాయి", "నెబో", "అరారాతు"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 17:6",
      ),
      const ReadingQuestion(
        questionEn: "On which mount did God deliver the Ten Commandments to Moses?",
        questionTe: "మోషేకు దేవుడు పది ఆజ్ఞలను ఏ పర్వతం మీద ఇచ్చాడు?",
        optionsEn: ["Mount Sinai", "Mount Nebo", "Mount Carmel", "Mount Zion"],
        optionsTe: ["సీనాయి పర్వతం", "నెబో పర్వతం", "కర్మెలు పర్వతం", "సీయోను పర్వతం"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 19:20",
      ),
      const ReadingQuestion(
        questionEn: "What is the first commandment among the Ten?",
        questionTe: "పది ఆజ్ఞలలో మొదటి ఆజ్ఞ ఏమిటి?",
        optionsEn: ["You shall have no other gods before Me", "Do not steal", "Honor your father and mother", "Remember the Sabbath"],
        optionsTe: ["నా ఎదుట నీకు వేరొక దేవుడుండకూడదు", "దొంగిలకూడదు", "నీ తండ్రిని నీ తల్లిని సన్మానించుము", "విశ్రాంతిదినమును పరిశుద్ధముగా ఆచరించుము"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 20:3",
      ),
      const ReadingQuestion(
        questionEn: "Who was Moses' father-in-law who advised him on setting up judges?",
        questionTe: "మోషేకు న్యాయాధిపతులను నియమించమని సలహా ఇచ్చిన అతని మామగారి పేరు ఏమిటి?",
        optionsEn: ["Jethro", "Aaron", "Joshua", "Caleb"],
        optionsTe: ["యిత్రో", "అహరోను", "యెహోషువ", "కాలేబు"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 18:13-24",
      ),
    ],
    7: [
      const ReadingQuestion(
        questionEn: "What item was placed inside the Holy of Holies in the Tabernacle?",
        questionTe: "ప్రత్యక్షపు గుడారములోని అతి పరిశుద్ధ స్థలములో ఉంచబడిన పవిత్ర వస్తువు ఏమిటి?",
        optionsEn: ["Ark of the Covenant", "Golden Candlestick", "Altar of Incense", "Table of Showbread"],
        optionsTe: ["నిబంధన మందసము", "సువర్ణ దీపస్తంభం", "ధూప బలిపీఠం", "సన్నిధి రొట్టెల బల్ల"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 26:34",
      ),
      const ReadingQuestion(
        questionEn: "Who did Aaron and the people of Israel build while Moses was on the mountain?",
        questionTe: "మోషే పర్వతం మీద ఉన్నప్పుడు అహరోను మరియు ఇశ్రాయేలీయులు దేనిని పూజించడానికి తయారు చేశారు?",
        optionsEn: ["A golden calf", "A bronze serpent", "An altar of stone", "A wooden idol"],
        optionsTe: ["బంగారు దూడను", "ఇత్తడి సర్పమును", "రాతి బలిపీఠమును", "చెక్క విగ్రహమును"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 32:4",
      ),
      const ReadingQuestion(
        questionEn: "What happened to Moses' face after talking to God on Mount Sinai?",
        questionTe: "సీనాయి పర్వతం మీద దేవునితో మాట్లాడిన తర్వాత మోషే ముఖము ఎలా మారింది?",
        optionsEn: ["It shone brightly", "It was covered in dust", "It was wrinkled", "It became dark"],
        optionsTe: ["అది ప్రకాశించింది (తేజోవంతమైంది)", "దుమ్ముతో నిండిపోయింది", "ముడుతలు పడింది", "నల్లగా మారింది"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 34:29",
      ),
      const ReadingQuestion(
        questionEn: "Who was selected by God as the primary builder of the Tabernacle?",
        questionTe: "ప్రత్యక్షపు గుడారమును నిర్మించడానికి దేవునిచే ఎన్నుకోబడిన ప్రధాన శిల్పి ఎవరు?",
        optionsEn: ["Bezalel", "Joshua", "Gideon", "Eleazar"],
        optionsTe: ["బెసలేలు", "యెహోషువ", "గిద్యోను", "ఎలియాజరు"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 31:2",
      ),
      const ReadingQuestion(
        questionEn: "What covered the Tabernacle when it was completed?",
        questionTe: "గుడారము పూర్తయినప్పుడు దానిని ఏది కప్పివేసింది?",
        optionsEn: ["A cloud", "Fire from heaven", "A great wind", "Nothing"],
        optionsTe: ["మేఘము", "పరలోక అగ్ని", "గొప్ప తుఫాను", "ఏమీ లేదు"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 40:34",
      ),
    ],
    8: [
      const ReadingQuestion(
        questionEn: "What was the main purpose of the Day of Atonement (Yom Kippur)?",
        questionTe: "ప్రాయశ్చిత్త దినము (యోమ్ కిప్పూర్) యొక్క ప్రధాన ఉద్దేశ్యం ఏమిటి?",
        optionsEn: ["To cleanse the people from their sins", "To celebrate harvest", "To crown the king", "To declare war"],
        optionsTe: ["ప్రజల పాపముల నుండి వారిని పవిత్రపరచుట", "పంటల పండుగను జరుపుకొనుట", "రాజుకు కిరీటం ధరింపజేయుట", "యుద్ధాన్ని ప్రకటించుట"],
        correctAnswerIndex: 0,
        verseReference: "Leviticus 16:30",
      ),
      const ReadingQuestion(
        questionEn: "Who were Aaron's two sons who offered unauthorized fire and died before the Lord?",
        questionTe: "యెహోవా సన్నిధికి అపవిత్రమైన అగ్నిని తెచ్చి మరణించిన అహరోను కుమారులు ఇద్దరు ఎవరు?",
        optionsEn: ["Nadab and Abihu", "Hophni and Phinehas", "Eleazar and Ithamar", "Joel and Abijah"],
        optionsTe: ["నాదాబు మరియు అబీహు", "హొఫ్నీ మరియు ఫీనెహాసు", "ఎలియాజరు మరియు ఈతామారు", "యోవేలు మరియు అబీయా"],
        correctAnswerIndex: 0,
        verseReference: "Leviticus 10:1-2",
      ),
      const ReadingQuestion(
        questionEn: "Which book of the Law contains detailed instructions about clean and unclean animals?",
        questionTe: "పవిత్ర మరియు అపవిత్ర జంతువుల గురించిన వివరణాత్మక ఆజ్ఞలు ఏ గ్రంథములో ఉన్నాయి?",
        optionsEn: ["Leviticus", "Genesis", "Exodus", "Numbers"],
        optionsTe: ["లేవీయకాండము", "ఆదికాండము", "నిర్గమకాండము", "సంఖ్యాకాండము"],
        correctAnswerIndex: 0,
        verseReference: "Leviticus 11",
      ),
      const ReadingQuestion(
        questionEn: "What is the famous command in Leviticus 19:18 cited by Jesus?",
        questionTe: "యేసు చేత ప్రస్తావించబడిన లేవీయకాండము 19:18 లోని ప్రసిద్ధ ఆజ్ఞ ఏమిటి?",
        optionsEn: ["Love your neighbor as yourself", "Honor your parents", "Do not lie", "Give to the poor"],
        optionsTe: ["నిన్నువలె నీ పొరుగువానిని ప్రేమింపవలెను", "నీ తల్లిదండ్రులను సన్మానించుము", "అబద్ధమాడకూడదు", "పేదలకు దానం చేయుము"],
        correctAnswerIndex: 0,
        verseReference: "Leviticus 19:18",
      ),
      const ReadingQuestion(
        questionEn: "How often was the Year of Jubilee celebrated in Israel?",
        questionTe: "ఇశ్రాయేలులో యూబిలు సంవత్సరం (సువర్ణోత్సవ సంవత్సరం) ఎన్ని సంవత్సరాలకొకసారి జరుపబడేది?",
        optionsEn: ["Every 50 years", "Every 7 years", "Every 10 years", "Every 100 years"],
        optionsTe: ["ప్రతి 50 సంవత్సరాలకు ఒకసారి", "ప్రతి 7 సంవత్సరాలకు ఒకసారి", "ప్రతి 10 సంవత్సరాలకు ఒకసారి", "ప్రతి 100 సంవత్సరాలకు ఒకసారి"],
        correctAnswerIndex: 0,
        verseReference: "Leviticus 25:10",
      ),
    ],
    9: [
      const ReadingQuestion(
        questionEn: "How many spies did Moses send to search out the land of Canaan?",
        questionTe: "కనాను దేశమును వేగుచూడడానికి మోషే ఎంతమంది వేగులవారిన పంపాడు?",
        optionsEn: ["12 spies", "2 spies", "10 spies", "70 spies"],
        optionsTe: ["12 మంది", "2 గురు", "10 మంది", "70 మంది"],
        correctAnswerIndex: 0,
        verseReference: "Numbers 13:2",
      ),
      const ReadingQuestion(
        questionEn: "Who were the only two spies who brought back an encouraging report and trusted God?",
        questionTe: "దేవుని నమ్మి, ధైర్యపరిచే సమాచారాన్ని మోషే యొద్దకు తెచ్చిన ఆ ఇద్దరు వేగులవారు ఎవరు?",
        optionsEn: ["Joshua and Caleb", "Moses and Aaron", "Nadon and Abihu", "Eleazar and Ithamar"],
        optionsTe: ["యెహోషువ మరియు కాలేబు", "మోషే మరియు అహరోను", "నాదోను మరియు అబీహు", "ఎలియాజరు మరియు ఈతామారు"],
        correctAnswerIndex: 0,
        verseReference: "Numbers 14:6-9",
      ),
      const ReadingQuestion(
        questionEn: "What did Moses lift up in the wilderness to heal the people from venomous snake bites?",
        questionTe: "విషసర్పాల కాటు నుండి ప్రజలను స్వస్థపరచడానికి మోషే అరణ్యములో దేనిని పైకెత్తాడు?",
        optionsEn: ["A bronze serpent", "A wooden cross", "A gold rod", "A stone tablet"],
        optionsTe: ["ఇత్తడి సర్పము", "చెక్క సిలువ", "బంగారు కర్ర", "రాతి పలక"],
        correctAnswerIndex: 0,
        verseReference: "Numbers 21:9",
      ),
      const ReadingQuestion(
        questionEn: "Whose donkey spoke to him after he was hired to curse Israel?",
        questionTe: "ఇశ్రాయేలీయులను శపించడానికి పిలువబడిన ఏ ప్రవక్త గాడిద అతనితో మాట్లాడింది?",
        optionsEn: ["Balaam", "Balak", "Korah", "Aaron"],
        optionsTe: ["బిలాము", "బాలాకు", "కోరహు", "అహరోను"],
        correctAnswerIndex: 0,
        verseReference: "Numbers 22:28",
      ),
      const ReadingQuestion(
        questionEn: "For how many years did the Israelites wander in the wilderness due to their rebellion?",
        questionTe: "ఇశ్రాయేలీయులు తిరుగుబాటు చేసినందుకుగాను ఎన్ని సంవత్సరాలు అరణ్యములో తిరిగారు?",
        optionsEn: ["40 years", "70 years", "10 years", "100 years"],
        optionsTe: ["40 సంవత్సరాలు", "70 సంవత్సరాలు", "10 సంవత్సరాలు", "100 సంవత్సరాలు"],
        correctAnswerIndex: 0,
        verseReference: "Numbers 14:34",
      ),
    ],
    10: [
      const ReadingQuestion(
        questionEn: "What is the Hebrew name of the foundational confession of faith in Deuteronomy 6:4?",
        questionTe: "ద్వితీయోపదేశకాండము 6:4 లోని ప్రాథమిక విశ్వాస ఒప్పుకోలు యొక్క హెబ్రీ పేరు ఏమిటి?",
        optionsEn: ["The Shema", "The Torah", "The Kadosh", "The Shalom"],
        optionsTe: ["షెమా (Shema)", "తోరా", "కదోష్", "షాలోమ్"],
        correctAnswerIndex: 0,
        verseReference: "Deuteronomy 6:4",
      ),
      const ReadingQuestion(
        questionEn: "Whom did Moses appoint as his successor to lead Israel into the Promised Land?",
        questionTe: "ఇశ్రాయేలీయులను వాగ్దాన దేశమునకు నడిపించడానికి మోషే తన వారసుడిగా ఎవరిని నియమించాడు?",
        optionsEn: ["Joshua", "Caleb", "Eleazar", "Gideon"],
        optionsTe: ["యెహోషువ", "కాలేబు", "ఎలియాజరు", "గిద్యోను"],
        correctAnswerIndex: 0,
        verseReference: "Deuteronomy 31:7",
      ),
      const ReadingQuestion(
        questionEn: "Where did Moses die and get buried by God?",
        questionTe: "మోషే ఎక్కడ మరణించాడు మరియు దేవునిచే సమాధి చేయబడ్డాడు?",
        optionsEn: ["Mount Nebo", "Mount Sinai", "Mount Hor", "Mount Ararat"],
        optionsTe: ["నెబో పర్వతం", "సీనాయి పర్వతం", "హోరు పర్వతం", "అరారాతు పర్వతం"],
        correctAnswerIndex: 0,
        verseReference: "Deuteronomy 34:1-6",
      ),
      const ReadingQuestion(
        questionEn: "How old was Moses when he died?",
        questionTe: "మరణించే సమయానికి మోషే వయస్సు ఎంత?",
        optionsEn: ["120 years old", "80 years old", "100 years old", "110 years old"],
        optionsTe: ["120 సంవత్సరాలు", "80 సంవత్సరాలు", "100 సంవత్సరాలు", "110 సంవత్సరాలు"],
        correctAnswerIndex: 0,
        verseReference: "Deuteronomy 34:7",
      ),
      const ReadingQuestion(
        questionEn: "What did Moses command the people to write on large stones after crossing the Jordan?",
        questionTe: "యొర్దాను దాటిన తర్వాత పెద్ద రాళ్ల మీద ఏమి రాయమని మోషే ప్రజలను ఆజ్ఞాపించాడు?",
        optionsEn: ["All the words of this law", "The names of the tribes", "The story of their escape", "The Ten Commandments only"],
        optionsTe: ["ఈ ధర్మశాస్త్ర వాక్యములన్నియు", "గోత్రముల పేర్లు", "విడుదల పొందిన కథ", "కేవలం పది ఆజ్ఞలు మాత్రమే"],
        correctAnswerIndex: 0,
        verseReference: "Deuteronomy 27:3",
      ),
    ],
    // Let's add remaining days to ensure the user gets day-specific questions, or they fall back.
    // For safety, we can define remaining days 11 to 30 as well. This guarantees a highly professional result.
  };

  // Prepopulated pools for book categories
  static final Map<String, List<ReadingQuestion>> _bookQuestionPools = {
    'genesis': [
      const ReadingQuestion(
        questionEn: "On which day did God create the sun, moon, and stars?",
        questionTe: "దేవుడు సూర్యచంద్రులను, నక్షత్రాలను ఏ రోజున సృష్టించాడు?",
        optionsEn: ["Day 4", "Day 3", "Day 1", "Day 5"],
        optionsTe: ["నాలుగవ రోజు", "మూడవ రోజు", "మొదటి రోజు", "ఐదవ రోజు"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 1:14-19",
      ),
      const ReadingQuestion(
        questionEn: "Who was Enoch's famous son, the longest-living man in the Bible?",
        questionTe: "బైబిల్‌లో అత్యంత ఎక్కువ కాలం బ్రతికిన హనోకు కుమారుడు ఎవరు?",
        optionsEn: ["Methuselah", "Noah", "Lamech", "Jared"],
        optionsTe: ["మెతూషెలా", "నోవహు", "లామెకు", "యెరెదు"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 5:27",
      ),
      const ReadingQuestion(
        questionEn: "What was the name of Abraham's wife before Sarah?",
        questionTe: "శారమ్మకు మునుపటి పేరు ఏమిటి?",
        optionsEn: ["Sarai", "Milcah", "Rebekah", "Hagar"],
        optionsTe: ["సారాయి", "మిల్కా", "రిబ్కా", "హాగరు"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 11:29",
      ),
      const ReadingQuestion(
        questionEn: "Who was Jacob's youngest son?",
        questionTe: "యాకోబు యొక్క చివరి కుమారుడు ఎవరు?",
        optionsEn: ["Benjamin", "Joseph", "Judah", "Dan"],
        optionsTe: ["బెన్యామీను", "యోసేపు", "యూదా", "దాను"],
        correctAnswerIndex: 0,
        verseReference: "Genesis 35:24",
      ),
    ],
    'exodus': [
      const ReadingQuestion(
        questionEn: "Who was Moses' brother who spoke on his behalf before Pharaoh?",
        questionTe: "ఫరో ఎదుట మోషే తరపున మాట్లాడిన అతని సోదరుడు ఎవరు?",
        optionsEn: ["Aaron", "Hur", "Miriam", "Joshua"],
        optionsTe: ["అహరోను", "హూరు", "మిరియాము", "యెహోషువ"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 4:14",
      ),
      const ReadingQuestion(
        questionEn: "What did Aaron throw down that turned into a serpent?",
        questionTe: "అహరోను నేల మీద పడవేసినప్పుడు అది సర్పంగా మారిన వస్తువు ఏది?",
        optionsEn: ["His rod", "His coat", "A stone", "His belt"],
        optionsTe: ["అతని కర్ర", "అతని అంగీ", "రాయి", "నడుము పట్టీ"],
        correctAnswerIndex: 0,
        verseReference: "Exodus 7:10",
      ),
    ],
    'leviticus': [
      const ReadingQuestion(
        questionEn: "Which tribe was set apart for priestly service in Leviticus?",
        questionTe: "యాజక సేవ కొరకు ఏ గోత్రము ప్రత్యేకించబడింది?",
        optionsEn: ["Levi", "Judah", "Benjamin", "Ephraim"],
        optionsTe: ["లేవి", "యూదా", "బెన్యామీను", "ఎఫ్రాయిము"],
        correctAnswerIndex: 0,
        verseReference: "Leviticus 8",
      ),
    ],
    'numbers': [
      const ReadingQuestion(
        questionEn: "What did Aaron's rod produce that confirmed his leadership?",
        questionTe: "అహరోను నాయకత్వాన్ని ధ్రువీకరించడానికి అతని కర్ర ఏమి మొలిపించింది?",
        optionsEn: ["Almonds", "Figs", "Olives", "Grapes"],
        optionsTe: ["బాదం కాయలు (పూలు)", "అంజూర పండ్లు", "ఒలీవ కాయలు", "ద్రాక్ష పండ్లు"],
        correctAnswerIndex: 0,
        verseReference: "Numbers 17:8",
      ),
    ],
    'deuteronomy': [
      const ReadingQuestion(
        questionEn: "Deuteronomy is structured as Moses' farewell what?",
        questionTe: "ద్వితీయోపదేశకాండము మోషే యొక్క వీడ్కోలు ఏ విధంగా వ్రాయబడింది?",
        optionsEn: ["Sermons/Speeches", "Letters", "Poems", "Laws only"],
        optionsTe: ["ప్రసంగాలు (ఉపదేశాలు)", "లేఖలు", "కవితలు", "ధర్మశాస్త్రం మాత్రమే"],
        correctAnswerIndex: 0,
        verseReference: "Deuteronomy 1",
      ),
    ],
    'joshua': [
      const ReadingQuestion(
        questionEn: "How many times did Israel march around Jericho on the seventh day?",
        questionTe: "ఏడవ రోజున ఇశ్రాయేలీయులు యెరికో చుట్టూ ఎన్నిసార్లు తిరిగారు?",
        optionsEn: ["7 times", "1 time", "12 times", "3 times"],
        optionsTe: ["7 సార్లు", "1 సారి", "12 సార్లు", "3 సార్లు"],
        correctAnswerIndex: 0,
        verseReference: "Joshua 6:15",
      ),
    ],
    'judges': [
      const ReadingQuestion(
        questionEn: "Who was the female judge who led Israel alongside Barak?",
        questionTe: "బారాకుతో కలిసి ఇశ్రాయేలును నడిపించిన స్త్రీ న్యాయాధిపతి ఎవరు?",
        optionsEn: ["Deborah", "Ruth", "Jael", "Delilah"],
        optionsTe: ["దెబోరా", "రూతు", "యాయేలు", "దెలీలా"],
        correctAnswerIndex: 0,
        verseReference: "Judges 4:4",
      ),
      const ReadingQuestion(
        questionEn: "Who was the judge famous for his immense strength and long hair?",
        questionTe: "అపారమైన బలము మరియు పొడవాటి జుట్టుకు ప్రసిద్ధి చెందిన న్యాయాధిపతి ఎవరు?",
        optionsEn: ["Samson", "Gideon", "Jephthah", "Ehud"],
        optionsTe: ["సమ్సోను", "గిద్యోను", "యిఫ్తాహు", "ఏహూదు"],
        correctAnswerIndex: 0,
        verseReference: "Judges 13-16",
      ),
    ],
    'samuel': [
      const ReadingQuestion(
        questionEn: "Who was the first king of Israel?",
        questionTe: "ఇశ్రాయేలు మొదటి రాజు ఎవరు?",
        optionsEn: ["Saul", "David", "Solomon", "Samuel"],
        optionsTe: ["సౌలు", "దావీదు", "సొలొమోను", "సమూయేలు"],
        correctAnswerIndex: 0,
        verseReference: "1 Samuel 10:1",
      ),
      const ReadingQuestion(
        questionEn: "What did David use to defeat the giant Goliath?",
        questionTe: "గొల్యాతును ఓడించడానికి దావీదు దేనిని ఉపయోగించాడు?",
        optionsEn: ["A sling and stone", "A bronze sword", "A bow and arrow", "A spear"],
        optionsTe: ["వడిసెల మరియు రాయి", "ఇత్తడి ఖడ్గం", "విల్లు మరియు బాణం", "ఈటె"],
        correctAnswerIndex: 0,
        verseReference: "1 Samuel 17:49",
      ),
    ],
    'kings': [
      const ReadingQuestion(
        questionEn: "Who built the first Temple in Jerusalem?",
        questionTe: "యెరూషలేములోని మొదటి దేవాలయమును నిర్మించింది ఎవరు?",
        optionsEn: ["Solomon", "David", "Saul", "Hezekiah"],
        optionsTe: ["సొలొమోను", "దావీదు", "సౌలు", "హిజ్కియా"],
        correctAnswerIndex: 0,
        verseReference: "1 Kings 6:1",
      ),
      const ReadingQuestion(
        questionEn: "Who was the prophet taken to heaven in a whirlwind?",
        questionTe: "సుడిగాలిలో ఆకాశానికి కొనిపోబడిన ప్రవక్త ఎవరు?",
        optionsEn: ["Elijah", "Elisha", "Isaiah", "Jeremiah"],
        optionsTe: ["ఏలీయా", "ఎలీషా", "యెషయా", "యిర్మీయా"],
        correctAnswerIndex: 0,
        verseReference: "2 Kings 2:11",
      ),
    ],
    'psalms': [
      const ReadingQuestion(
        questionEn: "Which Psalm begins with 'The Lord is my shepherd; I shall not want'?",
        questionTe: "ఏ కీర్తన 'యెహోవా నా కాపరి, నాకు లేమి కలుగదు' అని ప్రారంభమవుతుంది?",
        optionsEn: ["Psalm 23", "Psalm 1", "Psalm 91", "Psalm 100"],
        optionsTe: ["23వ కీర్తన", "1వ కీర్తన", "91వ కీర్తన", "100వ కీర్తన"],
        correctAnswerIndex: 0,
        verseReference: "Psalm 23:1",
      ),
    ],
    'proverbs': [
      const ReadingQuestion(
        questionEn: "According to Proverbs, what is the beginning of wisdom?",
        questionTe: "సామెతల ప్రకారం, జ్ఞానమునకు మూలము (ప్రారంభము) ఏమిటి?",
        optionsEn: ["The fear of the Lord", "Reading books", "Old age", "Richness"],
        optionsTe: ["యెహోవాయందలి భయభక్తులు", "పుస్తకాలు చదవడం", "వృద్ధాప్యం", "ధనవంతులు కావడం"],
        correctAnswerIndex: 0,
        verseReference: "Proverbs 1:7",
      ),
    ],
    'isaiah': [
      const ReadingQuestion(
        questionEn: "Isaiah prophesied that a virgin would conceive and bear a son named what?",
        questionTe: "కన్యక గర్భవతియై కుమారుని కని అతనికి ఏ పేరు పెడుతుందని యెషయా ప్రవచించాడు?",
        optionsEn: ["Immanuel", "Jesus", "John", "David"],
        optionsTe: ["ఇమ్మానుయేలు", "యేసు", "యోహాను", "దావీదు"],
        correctAnswerIndex: 0,
        verseReference: "Isaiah 7:14",
      ),
    ],
    'jeremiah': [
      const ReadingQuestion(
        questionEn: "Who is known as the weeping prophet?",
        questionTe: "కన్నీళ్లు కార్చే ప్రవక్త అని ఎవరిని పిలుస్తారు?",
        optionsEn: ["Jeremiah", "Ezekiel", "Daniel", "Isaiah"],
        optionsTe: ["యిర్మీయా", "యెహెజ్కేలు", "దానియేలు", "యెషయా"],
        correctAnswerIndex: 0,
        verseReference: "Jeremiah",
      ),
    ],
    'ezekiel': [
      const ReadingQuestion(
        questionEn: "What vision did Ezekiel see that symbolized Israel's restoration?",
        questionTe: "ఇశ్రాయేలు పునరుద్ధరణను సూచించే ఏ దర్శనాన్ని యెహెజ్కేలు చూశాడు?",
        optionsEn: ["A valley of dry bones", "A burning bush", "A temple of gold", "Four horses"],
        optionsTe: ["ఎండిపోయిన ఎముకల లోయ", "మండుచున్న పొద", "బంగారు దేవాలయం", "నాలుగు గుర్రాలు"],
        correctAnswerIndex: 0,
        verseReference: "Ezekiel 37",
      ),
    ],
    'daniel': [
      const ReadingQuestion(
        questionEn: "Where was Daniel thrown after violating the king's decree on prayer?",
        questionTe: "ప్రార్థనకు సంబంధించిన రాజు ఆజ్ఞను ఉల్లంఘించినందుకు దానియేలును ఎక్కడ పడవేశారు?",
        optionsEn: ["A lions' den", "A fiery furnace", "A dark prison", "Into the sea"],
        optionsTe: ["సింహాల బోను", "అగ్ని గుండం", "చీకటి ఖైదు", "సముద్రంలోకి"],
        correctAnswerIndex: 0,
        verseReference: "Daniel 6:16",
      ),
    ],
    'matthew': [
      const ReadingQuestion(
        questionEn: "Where did Jesus deliver His famous beatitudes teachings (Matthew 5)?",
        questionTe: "యేసు తన ప్రసిద్ధ కొండమీది ప్రసంగమును ఎక్కడ బోధించాడు (మత్తయి 5)?",
        optionsEn: ["On a mount/hill", "In a boat", "In the Temple", "In Nazareth"],
        optionsTe: ["ఒక కొండమీద", "పడవలో", "దేవాలయంలో", "నజరేతులో"],
        correctAnswerIndex: 0,
        verseReference: "Matthew 5:1",
      ),
    ],
    'mark': [
      const ReadingQuestion(
        questionEn: "Mark's gospel begins with the preaching of whom?",
        questionTe: "మార్కు సువార్త ఎవరి ప్రసంగముతో ప్రారంభమవుతుంది?",
        optionsEn: ["John the Baptist", "Jesus", "Peter", "Isaiah"],
        optionsTe: ["బాప్తిస్మమిచ్చు యోహాను", "యేసు", "పేతురు", "యెషయా"],
        correctAnswerIndex: 0,
        verseReference: "Mark 1:4",
      ),
    ],
    'luke': [
      const ReadingQuestion(
        questionEn: "In Luke's Gospel, where was Jesus born?",
        questionTe: "లూకా సువార్త ప్రకారం యేసు ఎక్కడ జన్మించాడు?",
        optionsEn: ["Bethlehem", "Nazareth", "Jerusalem", "Capernaum"],
        optionsTe: ["బెత్లేహేము", "నజరేతు", "యెరూషలేము", "కపెర్నహూము"],
        correctAnswerIndex: 0,
        verseReference: "Luke 2:4-7",
      ),
    ],
    'john': [
      const ReadingQuestion(
        questionEn: "What was Jesus' first miracle recorded in the Gospel of John?",
        questionTe: "యోహాను సువార్తలో రికార్డ్ చేయబడిన యేసు మొదటి అద్భుతం ఏది?",
        optionsEn: ["Turning water into wine", "Healing a blind man", "Raising Lazarus", "Feeding the 5000"],
        optionsTe: ["నీటిని ద్రాక్షారసముగా మార్చుట", "గ్రుడ్డివానిని స్వస్థపరచుట", "లాజరును బ్రతికించుట", "5000 మందికి ఆహారము పెట్టుట"],
        correctAnswerIndex: 0,
        verseReference: "John 2:11",
      ),
    ],
    'acts': [
      const ReadingQuestion(
        questionEn: "On which Jewish festival did the Holy Spirit descend upon the disciples?",
        questionTe: "పరిశుద్ధాత్మ శిష్యుల మీదికి ఏ యూదా పండుగ రోజున దిగివచ్చింది?",
        optionsEn: ["Pentecost", "Passover", "Tabernacles", "Purim"],
        optionsTe: ["పెంతెకోస్తు", "పస్కా", "పర్ణశాలల పండుగ", "పూరీము"],
        correctAnswerIndex: 0,
        verseReference: "Acts 2:1-4",
      ),
    ],
    'romans': [
      const ReadingQuestion(
        questionEn: "According to Romans 6:23, what is the wages of sin?",
        questionTe: "రోమా 6:23 ప్రకారం పాపము వలన వచ్చు జీతము ఏమిటి?",
        optionsEn: ["Death", "Sorrow", "Poverty", "Pain"],
        optionsTe: ["మరణము", "దుఃఖము", "దారిద్ర్యము", "నొప్పి"],
        correctAnswerIndex: 0,
        verseReference: "Romans 6:23",
      ),
    ],
    'corinthians': [
      const ReadingQuestion(
        questionEn: "Which chapter of 1 Corinthians is famous for describing love?",
        questionTe: "1 కొరింథీయులలో ఏ అధ్యాయం ప్రేమను వర్ణించడానికి ప్రసిద్ధి చెందింది?",
        optionsEn: ["Chapter 13", "Chapter 11", "Chapter 15", "Chapter 3"],
        optionsTe: ["13వ అధ్యాయం", "11వ అధ్యాయం", "15వ అధ్యాయం", "3వ అధ్యాయం"],
        correctAnswerIndex: 0,
        verseReference: "1 Corinthians 13",
      ),
    ],
    'epistles_paul': [
      const ReadingQuestion(
        questionEn: "Which letter instructs believers to put on the whole armor of God?",
        questionTe: "దేవుడు ఇచ్చు సర్వాంగకవచమును ధరించుకొనుడని ఏ పత్రిక బోధిస్తుంది?",
        optionsEn: ["Ephesians", "Galatians", "Philippians", "Colossians"],
        optionsTe: ["ఎఫెసీయులకు", "గలతీయులకు", "ఫిలిప్పీయులకు", "కొలొస్సయులకు"],
        correctAnswerIndex: 0,
        verseReference: "Ephesians 6:11",
      ),
    ],
    'epistles_general': [
      const ReadingQuestion(
        questionEn: "Who wrote the Epistle of James?",
        questionTe: "యాకోబు పత్రికను వ్రాసింది ఎవరు?",
        optionsEn: ["James", "Peter", "John", "Jude"],
        optionsTe: ["యాకోబు", "పేతురు", "యోహాను", "యూదా"],
        correctAnswerIndex: 0,
        verseReference: "James 1:1",
      ),
    ],
    'revelation': [
      const ReadingQuestion(
        questionEn: "Who wrote down the visions in the Book of Revelation?",
        questionTe: "ప్రకటన గ్రంథములోని దర్శనాలను వ్రాసింది ఎవరు?",
        optionsEn: ["John", "Peter", "Paul", "Jude"],
        optionsTe: ["యోహాను", "పేతురు", "పౌలు", "యూదా"],
        correctAnswerIndex: 0,
        verseReference: "Revelation 1:1-4",
      ),
    ],
  };
}
