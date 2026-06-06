
class ThisDayOption {
  final String textEn;
  final String textTe;
  final bool isCorrect;

  const ThisDayOption({
    required this.textEn,
    required this.textTe,
    required this.isCorrect,
  });
}

class ThisDayQuizQuestion {
  final String id;
  final String questionEn;
  final String questionTe;
  final List<ThisDayOption> options;

  const ThisDayQuizQuestion({
    required this.id,
    required this.questionEn,
    required this.questionTe,
    required this.options,
  });
}

class BibleEvent {
  final int day;
  final int month;
  final String titleEn;
  final String titleTe;
  final String descriptionEn;
  final String descriptionTe;
  final String verseReferenceEn;
  final String verseReferenceTe;
  final List<ThisDayQuizQuestion> quizQuestions;

  const BibleEvent({
    required this.day,
    required this.month,
    required this.titleEn,
    required this.titleTe,
    required this.descriptionEn,
    required this.descriptionTe,
    required this.verseReferenceEn,
    required this.verseReferenceTe,
    required this.quizQuestions,
  });
}

class ThisDayDataService {
  static final List<BibleEvent> _predefinedEvents = [
    BibleEvent(
      day: 1,
      month: 1,
      titleEn: "Covenant of Circumcision",
      titleTe: "సున్నతి నిబంధన",
      descriptionEn: "God establishes the covenant of circumcision with Abraham, changing his name from Abram to Abraham.",
      descriptionTe: "దేవుడు అబ్రాహాముతో సున్నతి నిబంధనను స్థాపిస్తాడు, అతని పేరును అబ్రాము నుండి అబ్రాహాముగా మారుస్తాడు.",
      verseReferenceEn: "Genesis 17:10",
      verseReferenceTe: "ఆదికాండము 17:10",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_1_1_q1",
          questionEn: "Whose name was changed to Abraham?",
          questionTe: "ఎవరి పేరు అబ్రాహాముగా మార్చబడింది?",
          options: [
            ThisDayOption(textEn: "Abram", textTe: "అబ్రాము", isCorrect: true),
            ThisDayOption(textEn: "Lot", textTe: "లోతు", isCorrect: false),
            ThisDayOption(textEn: "Nahor", textTe: "నాహోరు", isCorrect: false),
            ThisDayOption(textEn: "Terah", textTe: "తెరహు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_1_1_q2",
          questionEn: "What was the sign of the covenant?",
          questionTe: "నిబంధన యొక్క సూచన ఏమిటి?",
          options: [
            ThisDayOption(textEn: "Circumcision", textTe: "సున్నతి", isCorrect: true),
            ThisDayOption(textEn: "Rainbow", textTe: "మేఘధనుస్సు", isCorrect: false),
            ThisDayOption(textEn: "Pillar of fire", textTe: "అగ్నిస్తంభం", isCorrect: false),
            ThisDayOption(textEn: "Altar", textTe: "బలిపీఠము", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_1_1_q3",
          questionEn: "How old was Abraham when he was circumcised?",
          questionTe: "సున్నతి చేయించుకున్నప్పుడు అబ్రాహాము వయస్సు ఎంత?",
          options: [
            ThisDayOption(textEn: "99", textTe: "99 సంవత్సరాలు", isCorrect: true),
            ThisDayOption(textEn: "100", textTe: "100 సంవత్సరాలు", isCorrect: false),
            ThisDayOption(textEn: "75", textTe: "75 సంవత్సరాలు", isCorrect: false),
            ThisDayOption(textEn: "80", textTe: "80 సంవత్సరాలు", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 15,
      month: 1,
      titleEn: "Abraham Offers Isaac",
      titleTe: "ఇస్సాకును అర్పించిన అబ్రాహాము",
      descriptionEn: "God tests Abraham's faith by asking him to offer his only son Isaac as a burnt offering on Mount Moriah.",
      descriptionTe: "దేవుడు అబ్రాహాము విశ్వాసాన్ని శోధించడానికి, అతని ఒక్కగానొక్క కుమారుడైన ఇస్సాకును మోరియా పర్వతంపై దహనబలిగా అర్పించమని అడుగుతాడు.",
      verseReferenceEn: "Genesis 22:2",
      verseReferenceTe: "ఆదికాండము 22:2",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_1_15_q1",
          questionEn: "On which mountain was Abraham asked to offer Isaac?",
          questionTe: "ఇస్సాకును అర్పించమని అబ్రాహామును ఏ పర్వతంపై అడిగారు?",
          options: [
            ThisDayOption(textEn: "Moriah", textTe: "మోరియా", isCorrect: true),
            ThisDayOption(textEn: "Sinai", textTe: "సీనాయి", isCorrect: false),
            ThisDayOption(textEn: "Ararat", textTe: "అరరాతు", isCorrect: false),
            ThisDayOption(textEn: "Carmel", textTe: "కర్మెలు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_1_15_q2",
          questionEn: "What did God provide as a replacement for Isaac?",
          questionTe: "ఇస్సాకుకు బదులుగా దేవుడు ఏమి సిద్ధపరిచాడు?",
          options: [
            ThisDayOption(textEn: "A Ram", textTe: "ఒక పొట్టేలు", isCorrect: true),
            ThisDayOption(textEn: "A Lamb", textTe: "ఒక గొర్రెపిల్ల", isCorrect: false),
            ThisDayOption(textEn: "A Bull", textTe: "ఒక ఎద్దు", isCorrect: false),
            ThisDayOption(textEn: "A Dove", textTe: "ఒక పావురం", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_1_15_q3",
          questionEn: "Who stopped Abraham from slaying his son?",
          questionTe: "అబ్రాహాము తన కుమారుడిని చంపకుండా ఎవరు ఆపారు?",
          options: [
            ThisDayOption(textEn: "The Angel of the Lord", textTe: "యెహోవా దూత", isCorrect: true),
            ThisDayOption(textEn: "Sarah", textTe: "శారా", isCorrect: false),
            ThisDayOption(textEn: "Isaac himself", textTe: "ఇస్సాకు స్వయంగా", isCorrect: false),
            ThisDayOption(textEn: "An Egyptian servant", textTe: "ఐగుప్తు దాసుడు", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 25,
      month: 1,
      titleEn: "Joseph Sold into Egypt",
      titleTe: "ఐగుప్తుకు అమ్మబడిన యోసేపు",
      descriptionEn: "Joseph's brothers, jealous of his dreams and their father's favor, sell him to Ishmaelite merchants.",
      descriptionTe: "యోసేపు కలలు మరియు అతని తండ్రి ప్రేమపై అసూయపడిన అతని సహోదరులు, అతనిని ఇష్మాయేలీయుల వర్తకులకు అమ్ముతారు.",
      verseReferenceEn: "Genesis 37:28",
      verseReferenceTe: "ఆదికాండము 37:28",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_1_25_q1",
          questionEn: "Who suggested selling Joseph instead of killing him?",
          questionTe: "యోసేపును చంపడానికి బదులుగా అమ్మేయాలని ఎవరు సూచించారు?",
          options: [
            ThisDayOption(textEn: "Judah", textTe: "యూదా", isCorrect: true),
            ThisDayOption(textEn: "Reuben", textTe: "రూబేను", isCorrect: false),
            ThisDayOption(textEn: "Simeon", textTe: "షిమ్యోను", isCorrect: false),
            ThisDayOption(textEn: "Levi", textTe: "లేవి", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_1_25_q2",
          questionEn: "For how many pieces of silver was Joseph sold?",
          questionTe: "యోసేపు ఎన్ని వెండి నాణేలకు అమ్మబడ్డాడు?",
          options: [
            ThisDayOption(textEn: "20", textTe: "20 వెండి నాణేలు", isCorrect: true),
            ThisDayOption(textEn: "30", textTe: "30 వెండి నాణేలు", isCorrect: false),
            ThisDayOption(textEn: "15", textTe: "15 వెండి నాణేలు", isCorrect: false),
            ThisDayOption(textEn: "50", textTe: "50 వెండి నాణేలు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_1_25_q3",
          questionEn: "Who bought Joseph when he arrived in Egypt?",
          questionTe: "ఐగుప్తుకు చేరుకున్నప్పుడు యోసేపును ఎవరు కొనుగోలు చేశారు?",
          options: [
            ThisDayOption(textEn: "Potiphar", textTe: "పోతీఫరు", isCorrect: true),
            ThisDayOption(textEn: "Pharaoh", textTe: "ఫరో", isCorrect: false),
            ThisDayOption(textEn: "The Chief Cupbearer", textTe: "పానదాయకుడు", isCorrect: false),
            ThisDayOption(textEn: "The Chief Baker", textTe: "వంటలవాడు", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 1,
      month: 2,
      titleEn: "Moses and the Burning Bush",
      titleTe: "మోషే మరియు పొద రగులుట",
      descriptionEn: "While shepherding in Midian, Moses encounters a burning bush that is not consumed and hears God's call to deliver Israel.",
      descriptionTe: "మిద్యానులో గొర్రెలను మేపుతుండగా, మోషే కాలిపోని ఒక పొదను చూసి, ఇశ్రాయేలీయులను విడిపించమని దేవుని పిలుపును వింటాడు.",
      verseReferenceEn: "Exodus 3:2",
      verseReferenceTe: "నిర్గమకాండము 3:2",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_2_1_q1",
          questionEn: "On which mountain did Moses see the burning bush?",
          questionTe: "మోషే ఏ పర్వతంపై పొద రగలడం చూశాడు?",
          options: [
            ThisDayOption(textEn: "Horeb (Sinai)", textTe: "హోరేబు (సీనాయి)", isCorrect: true),
            ThisDayOption(textEn: "Nebo", textTe: "నెబో", isCorrect: false),
            ThisDayOption(textEn: "Gerizim", textTe: "గెరిజీము", isCorrect: false),
            ThisDayOption(textEn: "Tabor", textTe: "తాబోరు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_2_1_q2",
          questionEn: "What was Moses told to do because the ground was holy?",
          questionTe: "ఆ నేల పరిశుద్ధమైనది గనుక మోషేను ఏమి చేయమని చెప్పారు?",
          options: [
            ThisDayOption(textEn: "Take off his sandals", textTe: "పాదరక్షలు విప్పాలి", isCorrect: true),
            ThisDayOption(textEn: "Build an altar", textTe: "బలిపీఠం కట్టాలి", isCorrect: false),
            ThisDayOption(textEn: "Fast for 40 days", textTe: "40 రోజులు ఉపవాసం ఉండాలి", isCorrect: false),
            ThisDayOption(textEn: "Wash his face", textTe: "ముఖం కడుక్కోవాలి", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_2_1_q3",
          questionEn: "What name did God reveal to Moses?",
          questionTe: "దేవుడు మోషేకు తన ఏ పేరును బయలుపరిచాడు?",
          options: [
            ThisDayOption(textEn: "I AM WHO I AM", textTe: "నేను ఉన్నవాడను అనువాడను", isCorrect: true),
            ThisDayOption(textEn: "El Shaddai", textTe: "ఎల్ షద్దై", isCorrect: false),
            ThisDayOption(textEn: "Elohim", textTe: "ఎలోహీమ్", isCorrect: false),
            ThisDayOption(textEn: "Adonai", textTe: "అదోనై", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 14,
      month: 2,
      titleEn: "The Passover Instituted",
      titleTe: "పస్కా పండుగ నియామకం",
      descriptionEn: "Israel is commanded to sacrifice a lamb and paint its blood on their doorposts so the plague of death passes over them.",
      descriptionTe: "మరణ తెగులు తమను దాటిపోవడానికి ఇశ్రాయేలీయులు ఒక గొర్రెపిల్లను బలి ఇచ్చి, దాని రక్తాన్ని తమ ద్వారబంధాలకు పూయాలని ఆజ్ఞాపించబడ్డారు.",
      verseReferenceEn: "Exodus 12:13",
      verseReferenceTe: "నిర్గమకాండము 12:13",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_2_14_q1",
          questionEn: "What kind of bread was eaten during the Passover?",
          questionTe: "పస్కా సమయంలో ఎలాంటి రొట్టెలను తిన్నారు?",
          options: [
            ThisDayOption(textEn: "Unleavened bread", textTe: "పులియని రొట్టెలు", isCorrect: true),
            ThisDayOption(textEn: "Manna bread", textTe: "మన్నా రొట్టె", isCorrect: false),
            ThisDayOption(textEn: "Barley bread", textTe: "యవల రొట్టె", isCorrect: false),
            ThisDayOption(textEn: "Honey cakes", textTe: "తేనె కారాలు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_2_14_q2",
          questionEn: "Where was the blood of the lamb sprinkled?",
          questionTe: "గొర్రెపిల్ల రక్తాన్ని ఎక్కడ చల్లారు?",
          options: [
            ThisDayOption(textEn: "Doorposts and lintel", textTe: "ద్వారబంధాలు మరియు పైకమ్ము", isCorrect: true),
            ThisDayOption(textEn: "On the altar only", textTe: "బలిపీఠం మీద మాత్రమే", isCorrect: false),
            ThisDayOption(textEn: "On the people's foreheads", textTe: "ప్రజల నొసళ్ల మీద", isCorrect: false),
            ThisDayOption(textEn: "On the garments", textTe: "వస్త్రాల మీద", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_2_14_q3",
          questionEn: "Which month of the Hebrew calendar was established as the first month?",
          questionTe: "హెబ్రీ క్యాలెండర్‌లో ఏ నెలను మొదటి నెలగా నిర్ణయించారు?",
          options: [
            ThisDayOption(textEn: "Abib (Nisan)", textTe: "అబీబు (నీసాన్)", isCorrect: true),
            ThisDayOption(textEn: "Tishrei", textTe: "తిష్రీ", isCorrect: false),
            ThisDayOption(textEn: "Adar", textTe: "అదారు", isCorrect: false),
            ThisDayOption(textEn: "Elul", textTe: "ఎలూలు", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 25,
      month: 2,
      titleEn: "Samson Destroys Philistine Temple",
      titleTe: "సమ్సోను ఫిలిష్తీయుల గుడిని నాశనం చేయడం",
      descriptionEn: "His hair having grown back, Samson prays to God for strength one last time, collapsing the pillars of the temple of Dagon.",
      descriptionTe: "తన జుట్టు మళ్లీ పెరిగిన తర్వాత, సమ్సోను చివరిసారిగా దేవునికి బలం కోసం ప్రార్థించి, దాగోను దేవాలయ స్తంభాలను కూల్చివేస్తాడు.",
      verseReferenceEn: "Judges 16:30",
      verseReferenceTe: "న్యాయాధిపతులు 16:30",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_2_25_q1",
          questionEn: "Which Philistine god was the temple dedicated to?",
          questionTe: "ఆ దేవాలయం ఏ ఫిలిష్తీయుల దేవతకు అంకితం చేయబడింది?",
          options: [
            ThisDayOption(textEn: "Dagon", textTe: "దాగోను", isCorrect: true),
            ThisDayOption(textEn: "Baal", textTe: "బాలు", isCorrect: false),
            ThisDayOption(textEn: "Ashtoreth", textTe: "అష్తారోతు", isCorrect: false),
            ThisDayOption(textEn: "Chemosh", textTe: "కెమోషు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_2_25_q2",
          questionEn: "Who betrayed Samson to find the secret of his strength?",
          questionTe: "సమ్సోను బలం యొక్క రహస్యాన్ని తెలుసుకోవడానికి అతనిని ఎవరు మోసం చేశారు?",
          options: [
            ThisDayOption(textEn: "Delilah", textTe: "దెలీలా", isCorrect: true),
            ThisDayOption(textEn: "Sarah", textTe: "శారా", isCorrect: false),
            ThisDayOption(textEn: "Jezebel", textTe: "యెజెబెలు", isCorrect: false),
            ThisDayOption(textEn: "Ruth", textTe: "రూతు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_2_25_q3",
          questionEn: "What did Samson say before he collapsed the pillars?",
          questionTe: "స్తంభాలను కూల్చే ముందు సమ్సోను ఏమన్నాడు?",
          options: [
            ThisDayOption(textEn: "Let me die with the Philistines", textTe: "ఫిలిష్తీయులతో కూడ నేను చనిపోదును గాక", isCorrect: true),
            ThisDayOption(textEn: "Lord forgive Delilah", textTe: "ప్రభువా, దెలీలాను క్షమించు", isCorrect: false),
            ThisDayOption(textEn: "Israel is victorious", textTe: "ఇశ్రాయేలు జయము పొందింది", isCorrect: false),
            ThisDayOption(textEn: "Praise be to Dagon", textTe: "దాగోనుకు స్తోత్రము", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 1,
      month: 3,
      titleEn: "Crossing the Red Sea",
      titleTe: "ఎర్రసముద్రము దాటడం",
      descriptionEn: "Pursued by Pharaoh's army, Moses stretches his staff over the Red Sea, parting the waters for Israel to cross on dry ground.",
      descriptionTe: "ఫరో సైన్యం వెెంబడిస్తుండగా, మోషే తన చేతి కర్రను ఎర్రసముద్రం వైపు చాచాడు, దేవుడు నీళ్లను విభజించి ఇశ్రాయేలీయులు ఆరిన నేలపై దాటేలా చేశాడు.",
      verseReferenceEn: "Exodus 14:21",
      verseReferenceTe: "నిర్గమకాండము 14:21",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_3_1_q1",
          questionEn: "What guided Israel by day in the wilderness?",
          questionTe: "అరణ్యంలో పగటివేళ ఇశ్రాయేలీయులకు ఏది మార్గదర్శకంగా నిలిచింది?",
          options: [
            ThisDayOption(textEn: "A pillar of cloud", textTe: "మేఘస్తంభము", isCorrect: true),
            ThisDayOption(textEn: "A pillar of fire", textTe: "అగ్నిస్తంభము", isCorrect: false),
            ThisDayOption(textEn: "The Ark of the Covenant", textTe: "నిబంధన మందసము", isCorrect: false),
            ThisDayOption(textEn: "Moses' staff", textTe: "మోషే కర్ర", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_3_1_q2",
          questionEn: "Who pursued Israel into the split sea?",
          questionTe: "చీలిపోయిన సముద్రంలోనికి ఇశ్రాయేలీయులను ఎవరు వెంబడించారు?",
          options: [
            ThisDayOption(textEn: "Egyptian army", textTe: "ఐగుప్తు సైన్యం", isCorrect: true),
            ThisDayOption(textEn: "Amalekites", textTe: "అమలేకీయులు", isCorrect: false),
            ThisDayOption(textEn: "Philistines", textTe: "ఫిలిష్తీయులు", isCorrect: false),
            ThisDayOption(textEn: "Midianites", textTe: "మిద్యానీయులు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_3_1_q3",
          questionEn: "What song did Miriam and the women sing to celebrate?",
          questionTe: "సంబరాలు చేసుకోవడానికి మిరియాము మరియు స్త్రీలు ఏ పాట పాడారు?",
          options: [
            ThisDayOption(textEn: "Sing to the Lord, for He has triumphed gloriously", textTe: "యెహోవాను కీర్తించుడి, ఆయన మహిమతో జయించియున్నాడు", isCorrect: true),
            ThisDayOption(textEn: "The Song of Moses only", textTe: "మోషే పాట మాత్రమే", isCorrect: false),
            ThisDayOption(textEn: "The Song of Hope", textTe: "నిరీక్షణ గీతం", isCorrect: false),
            ThisDayOption(textEn: "The Song of David", textTe: "దావీదు కీర్తన", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 15,
      month: 3,
      titleEn: "The Ten Commandments",
      titleTe: "పది ఆజ్ఞలు ఇవ్వడం",
      descriptionEn: "From Mount Sinai, amid thunder and lightning, God speaks the Ten Commandments directly to the gathered nation of Israel.",
      descriptionTe: "సీనాయి పర్వతం నుండి, ఉరుములు మెరుపుల మధ్య, దేవుడు కూడియున్న ఇశ్రాయేలు జనముతో పది ఆజ్ఞలను నేరుగా మాట్లాడాడు.",
      verseReferenceEn: "Exodus 20:1",
      verseReferenceTe: "నిర్గమకాండము 20:1",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_3_15_q1",
          questionEn: "On what were the Ten Commandments written?",
          questionTe: "పది ఆజ్ఞలు దేనిపై వ్రాయబడ్డాయి?",
          options: [
            ThisDayOption(textEn: "Two tablets of stone", textTe: "రెండు రాతి పలకలు", isCorrect: true),
            ThisDayOption(textEn: "Scrolls of parchment", textTe: "తోలు చుట్టలు", isCorrect: false),
            ThisDayOption(textEn: "Golden plates", textTe: "బంగారు రేకులు", isCorrect: false),
            ThisDayOption(textEn: "Wooden tablets", textTe: "చెక్క పలకలు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_3_15_q2",
          questionEn: "Which commandment requires honoring father and mother?",
          questionTe: "తల్లిదండ్రులను సన్మానించాలని ఏ ఆజ్ఞ చెప్తుంది?",
          options: [
            ThisDayOption(textEn: "Fifth", textTe: "ఐదవ ఆజ్ఞ", isCorrect: true),
            ThisDayOption(textEn: "Fourth", textTe: "నాల్గవ ఆజ్ఞ", isCorrect: false),
            ThisDayOption(textEn: "Sixth", textTe: "ఆరవ ఆజ్ఞ", isCorrect: false),
            ThisDayOption(textEn: "Third", textTe: "మూడవ ఆజ్ఞ", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_3_15_q3",
          questionEn: "What sin did the people commit while Moses was on the mountain?",
          questionTe: "మోషే కొండపై ఉన్నప్పుడు ప్రజలు ఏ పాపం చేశారు?",
          options: [
            ThisDayOption(textEn: "Worshipped a Golden Calf", textTe: "బంగారు దూడను పూజించారు", isCorrect: true),
            ThisDayOption(textEn: "Rebelled against Joshua", textTe: "యెహోషువపై తిరుగుబాటు చేశారు", isCorrect: false),
            ThisDayOption(textEn: "Tried to return to Egypt", textTe: "ఐగుప్తుకు తిరిగి వెళ్లడానికి ప్రయత్నించారు", isCorrect: false),
            ThisDayOption(textEn: "Stopped keeping Sabbath", textTe: "విశ్రాంతి దినాన్ని ఆచరించడం మానేశారు", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 25,
      month: 3,
      titleEn: "Elijah Taken up in a Whirlwind",
      titleTe: "ఏలీయా సుడిగాలిలో కొనిపోబడటం",
      descriptionEn: "As Elijah and Elisha walk together, a chariot of fire and horses of fire separate them, and Elijah ascends into heaven.",
      descriptionTe: "ఏలీయా మరియు ఎలీషా కలిసి నడుచుచుండగా, అగ్ని రథము మరియు అగ్ని గుర్రములు వారిని వేరు చేసాయి, ఏలీయా సుడిగాలిలో ఆకాశమునకు కొనిపోబడ్డాడు.",
      verseReferenceEn: "2 Kings 2:11",
      verseReferenceTe: "2 రాజులు 2:11",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_3_25_q1",
          questionEn: "Which river did Elijah and Elisha cross before Elijah was taken?",
          questionTe: "ఏలీయా కొనిపోబడక ముందు వారిద్దరూ ఏ నదిని దాటారు?",
          options: [
            ThisDayOption(textEn: "Jordan", textTe: "యొర్దాను", isCorrect: true),
            ThisDayOption(textEn: "Kishon", textTe: "కీషోను", isCorrect: false),
            ThisDayOption(textEn: "Nile", textTe: "నైలు నది", isCorrect: false),
            ThisDayOption(textEn: "Euphrates", textTe: "యూఫ్రటీస్", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_3_25_q2",
          questionEn: "What did Elisha inherit from Elijah?",
          questionTe: "ఎలీషా ఏలీయా నుండి ఏమి వారసత్వంగా పొందాడు?",
          options: [
            ThisDayOption(textEn: "His mantle", textTe: "అతని దుప్పటి", isCorrect: true),
            ThisDayOption(textEn: "His staff", textTe: "అతని కర్ర", isCorrect: false),
            ThisDayOption(textEn: "His chariot", textTe: "అతని రథము", isCorrect: false),
            ThisDayOption(textEn: "His house", textTe: "అతని ఇల్లు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_3_25_q3",
          questionEn: "What portion of Elijah's spirit did Elisha ask for?",
          questionTe: "ఏలీయా ఆత్మలో ఎంత భాగం కావాలని ఎలీషా అడిగాడు?",
          options: [
            ThisDayOption(textEn: "A double portion", textTe: "రెండంతల ఆత్మ", isCorrect: true),
            ThisDayOption(textEn: "An equal portion", textTe: "సమాన భాగం", isCorrect: false),
            ThisDayOption(textEn: "Sevenfold portion", textTe: "ఏడంతల ఆత్మ", isCorrect: false),
            ThisDayOption(textEn: "Triple portion", textTe: "మూడంతల ఆత్మ", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 1,
      month: 4,
      titleEn: "The Fall of Jericho",
      titleTe: "యెరికో గోడలు పడిపోవడం",
      descriptionEn: "After Israel marches around the city for seven days, the priests blow their trumpets, the people shout, and the walls collapse.",
      descriptionTe: "ఇశ్రాయేలీయులు ఏడు రోజులు పట్టణం చుట్టూ తిరిగిన తర్వాత, యాజకులు బూరలు ఊదారు, ప్రజలు కేకలు వేయగా యెరికో గోడలు కూలిపోయాయి.",
      verseReferenceEn: "Joshua 6:20",
      verseReferenceTe: "యెహోషువ 6:20",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_4_1_q1",
          questionEn: "How many times did they march around Jericho on the seventh day?",
          questionTe: "ఏడవ రోజున వారు యెరికో చుట్టూ ఎన్నిసార్లు తిరిగారు?",
          options: [
            ThisDayOption(textEn: "Seven times", textTe: "ఏడు సార్లు", isCorrect: true),
            ThisDayOption(textEn: "Once", textTe: "ఒక సారి", isCorrect: false),
            ThisDayOption(textEn: "Twelve times", textTe: "పన్నెండు సార్లు", isCorrect: false),
            ThisDayOption(textEn: "Three times", textTe: "మూడు సార్లు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_4_1_q2",
          questionEn: "Whose family was spared during the fall of Jericho?",
          questionTe: "యెరికో నాశనమైనప్పుడు ఎవరి కుటుంబం రక్షించబడింది?",
          options: [
            ThisDayOption(textEn: "Rahab the harlot", textTe: "బోగముదైన రాహాబు", isCorrect: true),
            ThisDayOption(textEn: "Achan", textTe: "ఆకాను", isCorrect: false),
            ThisDayOption(textEn: "Caleb", textTe: "కాలేబు", isCorrect: false),
            ThisDayOption(textEn: "Eleazar", textTe: "ఎలియాజరు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_4_1_q3",
          questionEn: "What sign did Rahab hang from her window to protect her family?",
          questionTe: "తన కుటుంబాన్ని రక్షించుకోవడానికి రాహాబు కిటికీ నుండి ఏ గుర్తును వేలాడదీసింది?",
          options: [
            ThisDayOption(textEn: "A scarlet cord", textTe: "ఎర్రని దారము", isCorrect: true),
            ThisDayOption(textEn: "A blue ribbon", textTe: "నీలి రంగు రిబ్బన్", isCorrect: false),
            ThisDayOption(textEn: "A golden plate", textTe: "బంగారు పలక", isCorrect: false),
            ThisDayOption(textEn: "A white sheet", textTe: "తెల్లటి గుడ్డ", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 15,
      month: 4,
      titleEn: "Gideon's Victory with 300 Men",
      titleTe: "గిద్యోను 300 మందితో సాధించిన విజయం",
      descriptionEn: "Using trumpets, jars, and torches, Gideon's small force of 300 defeats the massive Midianite army through confusion.",
      descriptionTe: "బూరలు, కుండలు మరియు దివిటీలను ఉపయోగించి, గిద్యోను 300 మంది సైన్యం కలవరపాటు ద్వారా మిద్యానీయుల భారీ సైన్యాన్ని ఓడించింది.",
      verseReferenceEn: "Judges 7:7",
      verseReferenceTe: "న్యాయาధిపతులు 7:7",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_4_15_q1",
          questionEn: "How did God choose Gideon's final 300 men?",
          questionTe: "గిద్యోను యొక్క చివరి 300 మందిని దేవుడు ఎలా ఎన్నుకున్నాడు?",
          options: [
            ThisDayOption(textEn: "By how they lapped water", textTe: "వారు నీళ్లు తాగిన విధానం ద్వారా", isCorrect: true),
            ThisDayOption(textEn: "By their sword fighting skills", textTe: "వారి ఖడ్గ నైపుణ్యం ద్వారా", isCorrect: false),
            ThisDayOption(textEn: "By their height and weight", textTe: "వారి పొడవు మరియు బరువు ద్వారా", isCorrect: false),
            ThisDayOption(textEn: "By their tribe", textTe: "వారి గోత్రము ద్వారా", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_4_15_q2",
          questionEn: "What did the men hold in their left hands?",
          questionTe: "ఆ మనుషులు తమ ఎడమ చేతుల్లో ఏమి పట్టుకున్నారు?",
          options: [
            ThisDayOption(textEn: "Torches inside jars", textTe: "కుండలలోని దివిటీలు", isCorrect: true),
            ThisDayOption(textEn: "Trumpets", textTe: "బూరలు", isCorrect: false),
            ThisDayOption(textEn: "Swords", textTe: "ఖడ్గములు", isCorrect: false),
            ThisDayOption(textEn: "Shields", textTe: "డాల్స్", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_4_15_q3",
          questionEn: "What did they shout when they blew their trumpets?",
          questionTe: "వారు బూరలు ఊదినప్పుడు ఏమని కేకలు వేశారు?",
          options: [
            ThisDayOption(textEn: "A sword for the Lord and for Gideon!", textTe: "యెహోవాకును గిద్యోనుకును ఖడ్గము!", isCorrect: true),
            ThisDayOption(textEn: "Victory to Israel!", textTe: "ఇశ్రాయేలుకు జయం!", isCorrect: false),
            ThisDayOption(textEn: "Down with Midian!", textTe: "మిద్యాను నశించు గాక!", isCorrect: false),
            ThisDayOption(textEn: "Praise the Lord!", textTe: "యెహోవాకు స్తోత్రము!", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 25,
      month: 4,
      titleEn: "Isaiah's Vision of the Lord",
      titleTe: "యెషయా దేవుని దర్శనమును చూడడం",
      descriptionEn: "Isaiah sees the Lord sitting on a throne, high and lifted up, surrounded by seraphim singing 'Holy, Holy, Holy'.",
      descriptionTe: "యెషయా మహోన్నతమైన సింహాసనంపై కూర్చున్న యెహోవాను చూస్తాడు, ఆయన చుట్టూ సేరాపులు 'పరిశుద్ధుడు, పరిశుద్ధుడు, పరిశుద్ధుడు' అని పాడుతున్నారు.",
      verseReferenceEn: "Isaiah 6:1",
      verseReferenceTe: "యెషయా 6:1",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_4_25_q1",
          questionEn: "In the year of which king's death did Isaiah see this vision?",
          questionTe: "ఏ రాజు మరణించిన సంవత్సరంలో యెషయా ఈ దర్శనాన్ని చూశాడు?",
          options: [
            ThisDayOption(textEn: "Uzziah", textTe: "ఉజ్జియా", isCorrect: true),
            ThisDayOption(textEn: "Hezekiah", textTe: "హిజ్కియా", isCorrect: false),
            ThisDayOption(textEn: "David", textTe: "దావీదు", isCorrect: false),
            ThisDayOption(textEn: "Solomon", textTe: "సొలొమోను", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_4_25_q2",
          questionEn: "What did a seraph use to cleanse Isaiah's lips?",
          questionTe: "యెషయా పెదవులను శుద్ధి చేయడానికి ఒక సేరాపు దేనిని ఉపయోగించింది?",
          options: [
            ThisDayOption(textEn: "A burning coal from the altar", textTe: "బలిపీఠం మీది నిప్పుకణము", isCorrect: true),
            ThisDayOption(textEn: "Pure water", textTe: "పవిత్ర జలము", isCorrect: false),
            ThisDayOption(textEn: "Anointing oil", textTe: "అభిషేక తైలము", isCorrect: false),
            ThisDayOption(textEn: "Hyssop branch", textTe: "హిస్సోపు కొమ్మ", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_4_25_q3",
          questionEn: "What did Isaiah answer when the Lord asked 'Whom shall I send?'",
          questionTe: "నన్ను పంపుటకు ఎవడు సిద్ధముగా ఉన్నాడని దేవుడు అడిగినప్పుడు యెషయా ఏమని సమాధానమిచ్చాడు?",
          options: [
            ThisDayOption(textEn: "Here am I. Send me!", textTe: "నేనున్నాను నన్ను పంపుము!", isCorrect: true),
            ThisDayOption(textEn: "Send my brother Aaron", textTe: "నా సహోదరుడైన అహరోనును పంపుము", isCorrect: false),
            ThisDayOption(textEn: "Lord, I am slow of speech", textTe: "ప్రభువా, నేను నోటి మాంద్యము గలవాడను", isCorrect: false),
            ThisDayOption(textEn: "I will go after forty days", textTe: "నేను నలభై రోజుల తర్వాత వెళ్తాను", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 1,
      month: 5,
      titleEn: "Ruth Pledges Loyalty to Naomi",
      titleTe: "నయోమితో రూతు విశ్వాస్యత ఒడంబడిక",
      descriptionEn: "Ruth refuses to leave her widowed mother-in-law Naomi, uttering the famous promise of lifelong devotion.",
      descriptionTe: "విధవరాలైన తన అత్త నయోమిని విడిచిపెట్టడానికి రూతు నిరాకరిస్తుంది, తన జీవితాంతం ఆమెతోనే ఉంటానని ప్రసిద్ధ వాగ్దానాన్ని చేస్తుంది.",
      verseReferenceEn: "Ruth 1:16",
      verseReferenceTe: "రూతు 1:16",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_5_1_q1",
          questionEn: "Where did Ruth come from?",
          questionTe: "రూతు ఎక్కడి నుండి వచ్చింది?",
          options: [
            ThisDayOption(textEn: "Moab", textTe: "మోయాబు దేశము", isCorrect: true),
            ThisDayOption(textEn: "Egypt", textTe: "ఐగుప్తు", isCorrect: false),
            ThisDayOption(textEn: "Edam", textTe: "ఎదోము", isCorrect: false),
            ThisDayOption(textEn: "Philistia", textTe: "ఫిలిష్తీయ", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_5_1_q2",
          questionEn: "What did Ruth say Naomi's God would be to her?",
          questionTe: "నయోమి దేవుడు తనకు ఏమవుతాడని రూతు చెప్పింది?",
          options: [
            ThisDayOption(textEn: "My God", textTe: "నా దేవుడు", isCorrect: true),
            ThisDayOption(textEn: "A helper", textTe: "సహాయకుడు", isCorrect: false),
            ThisDayOption(textEn: "A judge", textTe: "న్యాయాధిపతి", isCorrect: false),
            ThisDayOption(textEn: "A protector", textTe: "సంరక్షకుడు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_5_1_q3",
          questionEn: "Who was Naomi's husband who died in Moab?",
          questionTe: "మోయాబులో మరణించిన నయోమి భర్త ఎవరు?",
          options: [
            ThisDayOption(textEn: "Elimelek", textTe: "ఎలీమెలెకు", isCorrect: true),
            ThisDayOption(textEn: "Mahlon", textTe: "మహలోను", isCorrect: false),
            ThisDayOption(textEn: "Kilion", textTe: "కిల్యోను", isCorrect: false),
            ThisDayOption(textEn: "Boaz", textTe: "బోయాజు", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 15,
      month: 5,
      titleEn: "Samuel Hears God's Voice",
      titleTe: "సమూయేలు దేవుని స్వరాన్ని వినడం",
      descriptionEn: "While sleeping in the tabernacle, the young boy Samuel is called by name by the Lord, thinking it is the priest Eli calling him.",
      descriptionTe: "గుడారంలో పడుకుని ఉండగా, బాలుడైన సమూయేలును యెహోవా పేరు పెట్టి పిలుస్తాడు, యాజకుడైన ఏలి పిలుస్తున్నాడని సమూయేలు అనుకుంటాడు.",
      verseReferenceEn: "1 Samuel 3:10",
      verseReferenceTe: "1 సమూయేలు 3:10",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_5_15_q1",
          questionEn: "How many times did God call Samuel before Eli realized it was the Lord?",
          questionTe: "పిలుస్తున్నది దేవుడేనని ఏలి గ్రహించేసరికి యెహోవా సమూయేలును ఎన్నిసార్లు పిలిచాడు?",
          options: [
            ThisDayOption(textEn: "Three times", textTe: "మూడు సార్లు", isCorrect: true),
            ThisDayOption(textEn: "Once", textTe: "ఒక సారి", isCorrect: false),
            ThisDayOption(textEn: "Four times", textTe: "నాలుగు సార్లు", isCorrect: false),
            ThisDayOption(textEn: "Five times", textTe: "ఐదు సార్లు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_5_15_q2",
          questionEn: "What did Eli tell Samuel to say if called again?",
          questionTe: "మళ్లీ పిలిస్తే సమూయేలును ఏమని చెప్పమని ఏలి సలహా ఇచ్చాడు?",
          options: [
            ThisDayOption(textEn: "Speak, Lord, for your servant is listening", textTe: "యెహోవా, మాట్లాడుము నీ దాసుడు ఆలకించుచున్నాడు", isCorrect: true),
            ThisDayOption(textEn: "Here I am, Eli", textTe: "చిత్తము ఏలి, నేనున్నాను", isCorrect: false),
            ThisDayOption(textEn: "Praise be to God", textTe: "దేవునికి స్తోత్రము", isCorrect: false),
            ThisDayOption(textEn: "I am ready", textTe: "నేను సిద్ధంగా ఉన్నాను", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_5_15_q3",
          questionEn: "Who was Samuel's mother who dedicated him to the Tabernacle?",
          questionTe: "సమూయేలును దేవుని మందిరానికి అర్పించిన అతని తల్లి ఎవరు?",
          options: [
            ThisDayOption(textEn: "Hannah", textTe: "హన్నా", isCorrect: true),
            ThisDayOption(textEn: "Peninnah", textTe: "పెనిన్నా", isCorrect: false),
            ThisDayOption(textEn: "Elizabeth", textTe: "ఎలీసబెతు", isCorrect: false),
            ThisDayOption(textEn: "Leah", textTe: "లేయా", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 25,
      month: 5,
      titleEn: "The Conversion of Saul",
      titleTe: "సౌలు మార్పు చెందడం",
      descriptionEn: "Saul is blinded by a bright light on the road to Damascus, hearing the voice of Jesus asking, 'Saul, Saul, why do you persecute me?'",
      descriptionTe: "దమస్కు మార్గంలో సౌలు ఒక గొప్ప కాంతి ద్వారా గుడ్డివాడుగా మార్చబడ్డాడు, 'సౌలా, సౌలా, నీవేల నన్ను హింసించుచున్నావు?' అని యేసు స్వరాన్ని వింటాడు.",
      verseReferenceEn: "Acts 9:4",
      verseReferenceTe: "అపొస్తలుల కార్యములు 9:4",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_5_25_q1",
          questionEn: "What city was Saul travelling to when he saw the light?",
          questionTe: "సౌలు వెలుగును చూసినప్పుడు ఏ నగరానికి ప్రయాణమై వెళ్తున్నాడు?",
          options: [
            ThisDayOption(textEn: "Damascus", textTe: "దమస్కు", isCorrect: true),
            ThisDayOption(textEn: "Jerusalem", textTe: "యెరూషలేము", isCorrect: false),
            ThisDayOption(textEn: "Antioch", textTe: "అంతియొకయ", isCorrect: false),
            ThisDayOption(textEn: "Rome", textTe: "రోమా", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_5_25_q2",
          questionEn: "For how many days was Saul blind and did not eat or drink?",
          questionTe: "సౌలు ఎన్ని రోజులు చూపులేకుండా, అన్నపానములు తీసుకోకుండా ఉన్నాడు?",
          options: [
            ThisDayOption(textEn: "Three days", textTe: "మూడు రోజులు", isCorrect: true),
            ThisDayOption(textEn: "Seven days", textTe: "ఏడు రోజులు", isCorrect: false),
            ThisDayOption(textEn: "Forty days", textTe: "నలభై రోజులు", isCorrect: false),
            ThisDayOption(textEn: "Ten days", textTe: "పది రోజులు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_5_25_q3",
          questionEn: "Who was sent by God to restore Saul's sight?",
          questionTe: "సౌలుకు మరల చూపు రప్పించడానికి దేవుడు ఎవరిని పంపాడు?",
          options: [
            ThisDayOption(textEn: "Ananias", textTe: "అననీయ", isCorrect: true),
            ThisDayOption(textEn: "Peter", textTe: "పేతురు", isCorrect: false),
            ThisDayOption(textEn: "Barnabas", textTe: "బర్నబా", isCorrect: false),
            ThisDayOption(textEn: "Stephen", textTe: "స్తెఫను", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 1,
      month: 6,
      titleEn: "David Defeats Goliath",
      titleTe: "దావీదు గొలియాతును ఓడించడం",
      descriptionEn: "Armed with only a sling and five smooth stones, the young shepherd boy David slays the giant Philistine champion Goliath.",
      descriptionTe: "కేవలం ఒక వడిసెల మరియు ఐదు నునుపైన రాళ్లతో, గొర్రెల కాపరియైన దావీదు భారీ దేహము గల ఫిలిష్తీయ శూరుడైన గొలియాతును చంపేస్తాడు.",
      verseReferenceEn: "1 Samuel 17:50",
      verseReferenceTe: "1 సమూయేలు 17:50",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_6_1_q1",
          questionEn: "How many smooth stones did David gather from the brook?",
          questionTe: "దావీదు వాగు నుండి ఎన్ని నునుపైన రాళ్లను ఏరుకున్నాడు?",
          options: [
            ThisDayOption(textEn: "Five stones", textTe: "ఐదు రాళ్లు", isCorrect: true),
            ThisDayOption(textEn: "One stone", textTe: "ఒక రాయి", isCorrect: false),
            ThisDayOption(textEn: "Seven stones", textTe: "ఏడు రాళ్లు", isCorrect: false),
            ThisDayOption(textEn: "Three stones", textTe: "మూడు రాళ్లు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_6_1_q2",
          questionEn: "In whose name did David say he came to fight Goliath?",
          questionTe: "తాను ఎవరి నామమున యుద్ధమునకు వచ్చానని దావీదు గొలియాతుతో చెప్పాడు?",
          options: [
            ThisDayOption(textEn: "The Lord of Hosts", textTe: "సైన్యములకధిపతియగు యెహోవా నామమున", isCorrect: true),
            ThisDayOption(textEn: "King Saul", textTe: "సౌలు రాజు నామమున", isCorrect: false),
            ThisDayOption(textEn: "His father Jesse", textTe: "తన తండ్రి యెష్షయి నామమున", isCorrect: false),
            ThisDayOption(textEn: "The nation of Israel", textTe: "ఇశ్రాయేలు దేశము నామమున", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_6_1_q3",
          questionEn: "Which valley was the battle fought in?",
          questionTe: "ఏ లోయలో ఈ యుద్ధము జరిగింది?",
          options: [
            ThisDayOption(textEn: "Elah", textTe: "ఏలా లోయ", isCorrect: true),
            ThisDayOption(textEn: "Jezreel", textTe: "యెజ్రెయేలు", isCorrect: false),
            ThisDayOption(textEn: "Kidron", textTe: "కీద్రోను", isCorrect: false),
            ThisDayOption(textEn: "Jordan", textTe: "యొర్దాను లోయ", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 15,
      month: 6,
      titleEn: "Solomon Dedicates the Temple",
      titleTe: "దేవాలయ ప్రతిష్ఠ చేసిన సొలొమోను",
      descriptionEn: "King Solomon brings the Ark of the Covenant into the newly constructed Temple, and the glory of the Lord fills the house as a cloud.",
      descriptionTe: "సొలొమోను రాజు నిబంధన మందసమును కొత్తగా నిర్మించిన దేవాలయములోనికి తీసుకరాగా, యెహోవా తేజస్సు ఆ మందిరమును మేఘమువలె నింపెను.",
      verseReferenceEn: "1 Kings 8:1",
      verseReferenceTe: "1 రాజులు 8:1",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_6_15_q1",
          questionEn: "What was inside the Ark of the Covenant at this time?",
          questionTe: "ఈ సమయంలో నిబంధన మందసములో ఏముంది?",
          options: [
            ThisDayOption(textEn: "Only the two stone tablets", textTe: "రెండు రాతి పలకలు మాత్రమే", isCorrect: true),
            ThisDayOption(textEn: "Aaron's rod and manna", textTe: "అహరోను చిగురించిన కర్ర మరియు మన్నా", isCorrect: false),
            ThisDayOption(textEn: "The golden censor", textTe: "బంగారు ధూపకలశము", isCorrect: false),
            ThisDayOption(textEn: "Solomon's crown", textTe: "సొలొమోను కిరీటము", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_6_15_q2",
          questionEn: "How many years did it take Solomon to build the Temple?",
          questionTe: "దేవాలయాన్ని నిర్మించడానికి సొలొమోనుకు ఎన్ని సంవత్సరాలు పట్టింది?",
          options: [
            ThisDayOption(textEn: "Seven years", textTe: "ఏడు సంవత్సరాలు", isCorrect: true),
            ThisDayOption(textEn: "Thirteen years", textTe: "పదమూడు సంవత్సరాలు", isCorrect: false),
            ThisDayOption(textEn: "Forty years", textTe: "నలభై సంవత్సరాలు", isCorrect: false),
            ThisDayOption(textEn: "Ten years", textTe: "పది సంవత్సరాలు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_6_15_q3",
          questionEn: "Who did Solomon bless the assembly of Israel through?",
          questionTe: "సొలొమోను ఎవరి ద్వారా ఇశ్రాయేలు సమాజమును ఆశీర్వదించాడు?",
          options: [
            ThisDayOption(textEn: "A dedicated prayer", textTe: "ఒక ప్రతిష్ఠాపన ప్రార్థన ద్వారా", isCorrect: true),
            ThisDayOption(textEn: "Offering sacrifices only", textTe: "బలులు అర్పించడం ద్వారా మాత్రమే", isCorrect: false),
            ThisDayOption(textEn: "The high priest", textTe: "ప్రధాన యాజకుని ద్వారా", isCorrect: false),
            ThisDayOption(textEn: "A dramatic speech", textTe: "ఒక నాటకీయ ప్రసంగం ద్వారా", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 25,
      month: 6,
      titleEn: "Peter Walks on Water",
      titleTe: "నీటిపై నడిచిన పేతురు",
      descriptionEn: "Seeing Jesus walk on the stormy Galilean Sea, Peter steps out of the boat, walks on water, but sinks when he doubts.",
      descriptionTe: "గలిలయ సముద్రంలో తుఫాను సమయంలో యేసు నీటిపై నడవడం చూసి, పేతురు పడవలో నుండి దిగి నీటిపై నడిచాడు, కానీ సందేహించినప్పుడు మునిగిపోసాగాడు.",
      verseReferenceEn: "Matthew 14:29",
      verseReferenceTe: "మత్తయి 14:29",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_6_25_q1",
          questionEn: "What did Peter do when he began to sink?",
          questionTe: "మునిగిపోసాగుతున్నప్పుడు పేతురు ఏమి చేశాడు?",
          options: [
            ThisDayOption(textEn: "Cried out, 'Lord, save me!'", textTe: "'ప్రభువా, నన్ను రక్షించు' అని కేకలు వేశాడు", isCorrect: true),
            ThisDayOption(textEn: "Swam back to the boat", textTe: "పడవ వైపు ఈదాడు", isCorrect: false),
            ThisDayOption(textEn: "Asked John for help", textTe: "యోహానును సహాయం అడిగాడు", isCorrect: false),
            ThisDayOption(textEn: "Prayed silently", textTe: "నిశ్శబ్దంగా ప్రార్థించాడు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_6_25_q2",
          questionEn: "What did Jesus say to Peter as He caught him?",
          questionTe: "యేసు పేతురును పట్టుకొని ఏమన్నాడు?",
          options: [
            ThisDayOption(textEn: "You of little faith, why did you doubt?", textTe: "అల్పవిశ్వాసీ, ఏల సందేహపడితివి?", isCorrect: true),
            ThisDayOption(textEn: "Well done, faithful servant", textTe: "భేష్, నమ్మకమైన సేవకుడా", isCorrect: false),
            ThisDayOption(textEn: "Peace, be still", textTe: "నిమ్మళించుము, ఊరకుండుము", isCorrect: false),
            ThisDayOption(textEn: "Where is your courage?", isCorrect: false, textTe: "నీ ధైర్యం ఎక్కడ పోయింది?"),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_6_25_q3",
          questionEn: "At what time of night did Jesus walk out to the disciples?",
          questionTe: "రాత్రి ఏ జామున యేసు శిష్యుల వద్దకు నడుచుకుంటూ వచ్చాడు?",
          options: [
            ThisDayOption(textEn: "Fourth watch", textTe: "నాల్గవ జామున", isCorrect: true),
            ThisDayOption(textEn: "Second watch", textTe: "రెండవ జామున", isCorrect: false),
            ThisDayOption(textEn: "Midnight", textTe: "అర్ధరాత్రి వేళ", isCorrect: false),
            ThisDayOption(textEn: "First watch", textTe: "మొదటి జామున", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 1,
      month: 7,
      titleEn: "Elijah on Mount Carmel",
      titleTe: "కర్మెలు పర్వతంపై ఏలీయా",
      descriptionEn: "Elijah challenges 450 prophets of Baal to a contest, and God answers his prayer by consuming the altar with fire from heaven.",
      descriptionTe: "ఏలీయా 450 మంది బయలు ప్రవక్తలతో సవాలు చేసి పోటీ పెడతాడు, దేవుడు ఆకాశము నుండి అగ్నిని పంపి బలిపీఠమును దహించి ప్రార్థనకు జవాబిస్తాడు.",
      verseReferenceEn: "1 Kings 18:38",
      verseReferenceTe: "1 రాజులు 18:38",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_7_1_q1",
          questionEn: "How many prophets of Baal did Elijah challenge?",
          questionTe: "ఏలీయా ఎంతమంది బయలు ప్రవక్తలతో సవాలు చేశాడు?",
          options: [
            ThisDayOption(textEn: "450", textTe: "450 మంది", isCorrect: true),
            ThisDayOption(textEn: "300", textTe: "300 మంది", isCorrect: false),
            ThisDayOption(textEn: "850", textTe: "850 మంది", isCorrect: false),
            ThisDayOption(textEn: "150", textTe: "150 మంది", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_7_1_q2",
          questionEn: "What did Elijah pour over his altar before praying?",
          questionTe: "ప్రార్థన చేయడానికి ముందు ఏలీయా బలిపీఠముపై ఏమి పోయించాడు?",
          options: [
            ThisDayOption(textEn: "Water", textTe: "నీళ్లు", isCorrect: true),
            ThisDayOption(textEn: "Oil", textTe: "నూనె", isCorrect: false),
            ThisDayOption(textEn: "Wine", textTe: "ద్రాక్షారసము", isCorrect: false),
            ThisDayOption(textEn: "Blood", textTe: "రక్తము", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_7_1_q3",
          questionEn: "Where were the prophets of Baal executed after the victory?",
          questionTe: "విజయం సాధించిన తర్వాత బయలు ప్రవక్తలను ఏ వాగు వద్ద సంహరించారు?",
          options: [
            ThisDayOption(textEn: "Kishon Brook", textTe: "కీషోను వాగు", isCorrect: true),
            ThisDayOption(textEn: "Jordan River", textTe: "యొర్దాను నది", isCorrect: false),
            ThisDayOption(textEn: "Cherith Brook", textTe: "కీరీతు వాగు", isCorrect: false),
            ThisDayOption(textEn: "Kidron Valley", textTe: "కీద్రోను వాగు", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 15,
      month: 7,
      titleEn: "Elisha Multiplies Widow's Oil",
      titleTe: "విధవరాలి నూనెను విస్తరింపజేసిన ఎలీషా",
      descriptionEn: "To save a widow's sons from slavery, Elisha performs a miracle, multiplying a single jar of oil to fill many borrowed vessels.",
      descriptionTe: "ఒక విధవరాలి కుమారులు దాసత్వములోనికి పోకుండా కాపాడటానికి, ఎలీషా ఒక అద్భుతం చేసి, ఒకే ఒక నూనె బుడ్డి నుండి అనేక ఖాళీ పాత్రలను నింపుతాడు.",
      verseReferenceEn: "2 Kings 4:6",
      verseReferenceTe: "2 రాజులు 4:6",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_7_15_q1",
          questionEn: "What did the widow borrow from her neighbors?",
          questionTe: "విధవరాలు తన పొరుగువారి వద్ద నుండి ఏమి అడిగి తీసుకుంది?",
          options: [
            ThisDayOption(textEn: "Empty vessels", textTe: "ఖాళీ పాత్రలు", isCorrect: true),
            ThisDayOption(textEn: "Gold coins", textTe: "బంగారు నాణేలు", isCorrect: false),
            ThisDayOption(textEn: "Flour jars", textTe: "పిండి పాత్రలు", isCorrect: false),
            ThisDayOption(textEn: "Garments", textTe: "వస్త్రాలు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_7_15_q2",
          questionEn: "When did the oil stop flowing?",
          questionTe: "నూనె ప్రవహించడం ఎప్పుడు ఆగిపోయింది?",
          options: [
            ThisDayOption(textEn: "When there were no more vessels", textTe: "పాత్రలన్నీ నిండిపోయి ఇంక పాత్రలు లేనప్పుడు", isCorrect: true),
            ThisDayOption(textEn: "After she paid the debt", textTe: "ఆమె అప్పు చెల్లించిన తర్వాత", isCorrect: false),
            ThisDayOption(textEn: "At sunset", textTe: "సూర్యాస్తమయం వేళ", isCorrect: false),
            ThisDayOption(textEn: "When Elisha told it to stop", textTe: "ఎలీషా ఆపమని చెప్పినప్పుడు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_7_15_q3",
          questionEn: "What was she commanded to do with the oil?",
          questionTe: "ఆ నూనెతో ఆమెను ఏమి చేయమని ఎలీషా చెప్పాడు?",
          options: [
            ThisDayOption(textEn: "Sell it and pay her debt", textTe: "దానిని అమ్మి అప్పు తీర్చాలి", isCorrect: true),
            ThisDayOption(textEn: "Pour it on the altar", textTe: "బలిపీఠముపై పోయాలి", isCorrect: false),
            ThisDayOption(textEn: "Give it to Elisha", textTe: "ఎలీషాకు ఇవ్వాలి", isCorrect: false),
            ThisDayOption(textEn: "Store it for seven years", textTe: "ఏడు సంవత్సరాలు నిల్వ ఉంచాలి", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 25,
      month: 7,
      titleEn: "The Parable of the Good Samaritan",
      titleTe: "మంచి సమరయుని ఉపమానము",
      descriptionEn: "Jesus shares the parable of a Samaritan showing mercy to a beaten Jewish traveler after a priest and a Levite pass him by.",
      descriptionTe: "యాజకుడు, లేవీయుడు కొట్టబడిన యూదుని పట్టించుకోకుండా దాటిపోగా, ఒక సమరయుడు అతనిపై కరుణ చూపించాడని యేసు ఉపమానము చెప్తాడు.",
      verseReferenceEn: "Luke 10:33",
      verseReferenceTe: "లూకా 10:33",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_7_25_q1",
          questionEn: "Which road was the traveler walking down when he was attacked?",
          questionTe: "ఆ ప్రయాణికుడు ఏ మార్గంలో వెళ్తుండగా దొంగల చేతిలో దెబ్బలు తిన్నాడు?",
          options: [
            ThisDayOption(textEn: "Jerusalem to Jericho", textTe: "యెరూషలేము నుండి యెరికో మార్గం", isCorrect: true),
            ThisDayOption(textEn: "Nazareth to Jerusalem", textTe: "నజరేతు నుండి యెరూషలేము", isCorrect: false),
            ThisDayOption(textEn: "Damascus to Jerusalem", textTe: "దమస్కు నుండి యెరూషలేము", isCorrect: false),
            ThisDayOption(textEn: "Joppa to Jerusalem", textTe: "జొప్పా నుండి యెరూషలేము", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_7_25_q2",
          questionEn: "Who passed by first without helping the injured man?",
          questionTe: "గాయపడిన వ్యక్తిని చూసి కూడా సహాయం చేయకుండా మొదట ఎవరు దాటిపోయారు?",
          options: [
            ThisDayOption(textEn: "A Priest", textTe: "ఒక యాజకుడు", isCorrect: true),
            ThisDayOption(textEn: "A Levite", textTe: "ఒక లేవీయుడు", isCorrect: false),
            ThisDayOption(textEn: "A Pharisee", textTe: "ఒక పరిసయ్యుడు", isCorrect: false),
            ThisDayOption(textEn: "A Roman soldier", textTe: "ఒక రోమా సైనికుడు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_7_25_q3",
          questionEn: "What did the Samaritan give to the innkeeper to care for the man?",
          questionTe: "ఆ వ్యక్తిని చూసుకోవడానికి సమరయుడు సత్రపు యజమానికి ఏమి ఇచ్చాడు?",
          options: [
            ThisDayOption(textEn: "Two denarii", textTe: "రెండు దేనారములు", isCorrect: true),
            ThisDayOption(textEn: "A bag of gold", textTe: "ఒక బంగారు సంచి", isCorrect: false),
            ThisDayOption(textEn: "His own donkey", textTe: "తన స్వంత గాడిదను", isCorrect: false),
            ThisDayOption(textEn: "A ring", textTe: "ఒక ఉంగరము", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 1,
      month: 8,
      titleEn: "Esther Saves Her People",
      titleTe: "తన ప్రజలను కాపాడిన ఎస్తేరు",
      descriptionEn: "Risking her life, Queen Esther reveals Haman's plot to destroy the Jews to King Xerxes at a banquet.",
      descriptionTe: "తన ప్రాణాలను పణంగా పెట్టి, ఎస్తేరు రాణి యూదులను నాశనం చేయడానికి హామాను పన్నిన కుట్రను విందులో రాజైన అహష్వేరోషుకు బయలుపరుస్తుంది.",
      verseReferenceEn: "Esther 7:6",
      verseReferenceTe: "ఎస్తేరు 7:6",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_8_1_q1",
          questionEn: "Who was the cousin of Esther who raised her?",
          questionTe: "ఎస్తేరును పెంచి పెద్దచేసిన ఆమె మేనమామ/అన్న ఎవరు?",
          options: [
            ThisDayOption(textEn: "Mordecai", textTe: "మొర్దెకై", isCorrect: true),
            ThisDayOption(textEn: "Haman", textTe: "హామాను", isCorrect: false),
            ThisDayOption(textEn: "Memukan", textTe: "మెమూకాను", isCorrect: false),
            ThisDayOption(textEn: "Hegai", textTe: "హేగై", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_8_1_q2",
          questionEn: "What was Esther's Hebrew name?",
          questionTe: "ఎస్తేరు యొక్క హెబ్రీ పేరు ఏమిటి?",
          options: [
            ThisDayOption(textEn: "Hadassah", textTe: "హదస్సా", isCorrect: true),
            ThisDayOption(textEn: "Ruth", textTe: "రూతు", isCorrect: false),
            ThisDayOption(textEn: "Naomi", textTe: "నయోమి", isCorrect: false),
            ThisDayOption(textEn: "Vashti", textTe: "వష్తి", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_8_1_q3",
          questionEn: "On what day was the decree to destroy the Jews scheduled?",
          questionTe: "యూదులను సంహరించాలనే ఆజ్ఞ ఏ తేదీన అమలు కావాల్సి ఉంది?",
          options: [
            ThisDayOption(textEn: "13th of Adar", textTe: "అదారు నెల 13వ రోజు", isCorrect: true),
            ThisDayOption(textEn: "1st of Nisan", textTe: "నీసాన్ నెల 1వ రోజు", isCorrect: false),
            ThisDayOption(textEn: "10th of Tishrei", textTe: "తిష్రీ నెల 10వ రోజు", isCorrect: false),
            ThisDayOption(textEn: "25th of Kislev", textTe: "కిస్లేవు నెల 25వ రోజు", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 15,
      month: 8,
      titleEn: "Job's Restoration",
      titleTe: "యోబును దేవుడు మరల ఆశీర్వదించడం",
      descriptionEn: "After proving faithful through intense trials, Job is blessed by God with double his former wealth and new children.",
      descriptionTe: "తీవ్రమైన శోధనల ద్వారా విశ్వాసపాత్రుడిగా నిరూపించబడిన తర్వాత, యోబును దేవుడు అతని మునుపటి సంపదకు రెండింతలు ఇచ్చి కొత్త సంతానముతో ఆశీర్వదిస్తాడు.",
      verseReferenceEn: "Job 42:10",
      verseReferenceTe: "యోబు 42:10",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_8_15_q1",
          questionEn: "How much wealth did God give Job after his restoration compared to before?",
          questionTe: "యోబును మరల ఆశీర్వదించినప్పుడు దేవుడు అతని మునుపటి కంటే ఎంత సంపదను ఇచ్చాడు?",
          options: [
            ThisDayOption(textEn: "Double portion", textTe: "రెండింతలు", isCorrect: true),
            ThisDayOption(textEn: "Same amount", textTe: "సమానంగా", isCorrect: false),
            ThisDayOption(textEn: "Ten times more", textTe: "పది రెట్లు", isCorrect: false),
            ThisDayOption(textEn: "Triple portion", textTe: "మూడంతలు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_8_15_q2",
          questionEn: "How many daughters were born to Job after his trials?",
          questionTe: "యోబు శోధనల తర్వాత అతనికి ఎంతమంది కుమార్తెలు జన్మించారు?",
          options: [
            ThisDayOption(textEn: "Three daughters", textTe: "ముగ్గురు కుమార్తెలు", isCorrect: true),
            ThisDayOption(textEn: "Seven daughters", textTe: "ఏడుగురు కుమార్తెలు", isCorrect: false),
            ThisDayOption(textEn: "Two daughters", textTe: "ఇద్దరు కుమార్తెలు", isCorrect: false),
            ThisDayOption(textEn: "Five daughters", textTe: "ఐదుగురు కుమార్తెలు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_8_15_q3",
          questionEn: "What was the name of Job's oldest daughter born after his restoration?",
          questionTe: "పునరుద్ధరణ తర్వాత జన్మించిన యోబు పెద్ద కుమార్తె పేరు ఏమిటి?",
          options: [
            ThisDayOption(textEn: "Jemimah", textTe: "యెమీమా", isCorrect: true),
            ThisDayOption(textEn: "Keziah", textTe: "కెజీయా", isCorrect: false),
            ThisDayOption(textEn: "Keren-Happuch", textTe: "కెరన్హప్పుకు", isCorrect: false),
            ThisDayOption(textEn: "Dinah", textTe: "దీనా", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 25,
      month: 8,
      titleEn: "The Prodigal Son Returns",
      titleTe: "తప్పిపోయిన కుమారుని ఉపమానము",
      descriptionEn: "Jesus shares the parable of the lost son who squanders his inheritance but is welcomed back warmly by his compassionate father.",
      descriptionTe: "తన ఆస్తిని అంతా వృధా చేసిన తప్పిపోయిన కుమారుడికి, అతని దయగల తండ్రి ఎలా ఆదరముతో స్వాగతం పలికాడో యేసు ఉపమానము చెప్తాడు.",
      verseReferenceEn: "Luke 15:20",
      verseReferenceTe: "లూకా 15:20",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_8_25_q1",
          questionEn: "What job did the younger son take when he spent all his money?",
          questionTe: "తన డబ్బంతా ఖర్చయిపోయినప్పుడు ఆ చిన్న కుమారుడు ఏ పనిలో చేరాడు?",
          options: [
            ThisDayOption(textEn: "Feeding pigs", textTe: "పందులు మేపడం", isCorrect: true),
            ThisDayOption(textEn: "A shepherd", textTe: "గొర్రెల కాపరి", isCorrect: false),
            ThisDayOption(textEn: "A tax collector", textTe: "సుంకరి", isCorrect: false),
            ThisDayOption(textEn: "A fisherman", textTe: "జాలరి", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_8_25_q2",
          questionEn: "What did the father do when he saw his son from a distance?",
          questionTe: "తన కుమారుడిని ఇంకా దూరంలో చూసినప్పుడు తండ్రి ఏమి చేశాడు?",
          options: [
            ThisDayOption(textEn: "Ran and embraced him", textTe: "పరుగెత్తి అతనిని కౌగిలించుకున్నాడు", isCorrect: true),
            ThisDayOption(textEn: "Sent servants to welcome him", textTe: "స్వాగతించడానికి సేవకులను పంపాడు", isCorrect: false),
            ThisDayOption(textEn: "Waited at the gate", textTe: "ద్వారం వద్ద వేచి ఉన్నాడు", isCorrect: false),
            ThisDayOption(textEn: "Demanded an apology", textTe: "క్షమాపణ కోరాడు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_8_25_q3",
          questionEn: "What animal was slaughtered to celebrate the return?",
          questionTe: "తిరిగి రాకను సంబరాలు చేసుకోవడానికి ఏ జంతువును వధించారు?",
          options: [
            ThisDayOption(textEn: "Fattened calf", textTe: "క్రొవ్విన దూడ", isCorrect: true),
            ThisDayOption(textEn: "A sheep", textTe: "ఒక గొర్రెపిల్ల", isCorrect: false),
            ThisDayOption(textEn: "A goat", textTe: "ఒక మేక", isCorrect: false),
            ThisDayOption(textEn: "A bull", textTe: "ఒక ఎద్దు", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 1,
      month: 9,
      titleEn: "Daniel in the Lions' Den",
      titleTe: "సింహాల బోనులో దానియేలు",
      descriptionEn: "Because he prays to God contrary to the king's decree, Daniel is cast into a den of lions, but God shuts the lions' mouths.",
      descriptionTe: "రాజు శాసనానికి విరుద్ధంగా దేవునికి ప్రార్థన చేసినందున దానియేలును సింహాల బోనులో పడవేస్తారు, కానీ దేవుడు దానియేలును కాపాడటానికి సింహాల నోళ్లను మూసివేస్తాడు.",
      verseReferenceEn: "Daniel 6:22",
      verseReferenceTe: "దానియేలు 6:22",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_9_1_q1",
          questionEn: "Which king decreed that no one should pray to anyone except himself?",
          questionTe: "ముప్పై రోజుల వరకు తన వద్ద తప్ప ఎవరికీ ప్రార్థన చేయకూడదని ఏ రాజు ఆజ్ఞాపించాడు?",
          options: [
            ThisDayOption(textEn: "Darius", textTe: "దర్యావేషు", isCorrect: true),
            ThisDayOption(textEn: "Cyrus", textTe: "కోరెషు", isCorrect: false),
            ThisDayOption(textEn: "Nebuchadnezzar", textTe: "నెబుకద్నెజరు", isCorrect: false),
            ThisDayOption(textEn: "Belshazzar", textTe: "బెల్షస్సరు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_9_1_q2",
          questionEn: "How many times a day did Daniel pray facing Jerusalem?",
          questionTe: "దానియేలు యెరూషలేము వైపు తిరిగి రోజుకు ఎన్నిసార్లు ప్రార్థన చేసేవాడు?",
          options: [
            ThisDayOption(textEn: "Three times", textTe: "మూడు సార్లు", isCorrect: true),
            ThisDayOption(textEn: "Seven times", textTe: "ఏడు సార్లు", isCorrect: false),
            ThisDayOption(textEn: "Once", textTe: "ఒక సారి", isCorrect: false),
            ThisDayOption(textEn: "Twice", textTe: "రెండు సార్లు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_9_1_q3",
          questionEn: "Who shut the lions' mouths?",
          questionTe: "సింహాల నోళ్లను ఎవరు మూసివేశారు?",
          options: [
            ThisDayOption(textEn: "An angel sent by God", textTe: "దేవుడు పంపిన దూత", isCorrect: true),
            ThisDayOption(textEn: "Daniel's companions", textTe: "దానియేలు స్నేహితులు", isCorrect: false),
            ThisDayOption(textEn: "The king's guards", textTe: "రాజు కావలివారు", isCorrect: false),
            ThisDayOption(textEn: "The lions were not hungry", textTe: "సింహాలకు ఆకలి లేదు", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 15,
      month: 9,
      titleEn: "Jonah and the Great Fish",
      titleTe: "యోనా మరియు గొప్ప చేప",
      descriptionEn: "Fleeing from God's command to go to Nineveh, Jonah is swallowed by a great fish and prays for deliverance from its belly.",
      descriptionTe: "నినెవెకు వెళ్లాలనే దేవుని ఆజ్ఞ నుండి పారిపోతుండగా, యోనాను ఒక గొప్ప చేప మింగివేస్తుంది, దాని కడుపులో నుండి యోనా రక్షణ కోసం ప్రార్థిస్తాడు.",
      verseReferenceEn: "Jonah 2:1",
      verseReferenceTe: "యోనా 2:1",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_9_15_q1",
          questionEn: "How many days and nights was Jonah in the belly of the fish?",
          questionTe: "యోనా ఎన్ని పగళ్లు, ఎన్ని రాత్రులు చేప కడుపులో ఉన్నాడు?",
          options: [
            ThisDayOption(textEn: "Three days and three nights", textTe: "మూడు పగళ్లు మరియు మూడు రాత్రులు", isCorrect: true),
            ThisDayOption(textEn: "Seven days", textTe: "ఏడు రోజులు", isCorrect: false),
            ThisDayOption(textEn: "Forty days", textTe: "నలభై రోజులు", isCorrect: false),
            ThisDayOption(textEn: "One day", textTe: "ఒక రోజు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_9_15_q2",
          questionEn: "Where did Jonah try to flee to escape God's presence?",
          questionTe: "దేవుని సన్నిధి నుండి తప్పించుకోవడానికి యోనా ఎక్కడికి పారిపోవడానికి ప్రయత్నించాడు?",
          options: [
            ThisDayOption(textEn: "Tarshish", textTe: "తర్షీషు", isCorrect: true),
            ThisDayOption(textEn: "Joppa", textTe: "జొప్పా", isCorrect: false),
            ThisDayOption(textEn: "Babylon", textTe: "బాబెలు", isCorrect: false),
            ThisDayOption(textEn: "Egypt", textTe: "ఐగుప్తు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_9_15_q3",
          questionEn: "Where did the fish vomit Jonah out?",
          questionTe: "ఆ చేప యోనాను ఎక్కడ కక్కివేసింది?",
          options: [
            ThisDayOption(textEn: "On dry land", textTe: "పొడి నేల మీద", isCorrect: true),
            ThisDayOption(textEn: "Near Nineveh", textTe: "నినెవె సమీపంలో", isCorrect: false),
            ThisDayOption(textEn: "Back at Joppa port", textTe: "జొప్పా ఓడరేవు వద్ద", isCorrect: false),
            ThisDayOption(textEn: "In the middle of the sea", textTe: "మధ్య సముద్రంలో", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 25,
      month: 9,
      titleEn: "The Crucifixion of Jesus",
      titleTe: "యేసుక్రీస్తు సిలువ మరణం",
      descriptionEn: "Jesus is crucified at Golgotha, taking upon Himself the sins of the world and declaring, 'It is finished.'",
      descriptionTe: "యేసు గొల్గొతా వద్ద సిలువ వేయబడ్డాడు, లోక పాపాలను తనపై వేసుకుని 'సమాప్తమాయెను' అని ప్రకటించాడు.",
      verseReferenceEn: "John 19:18",
      verseReferenceTe: "యోహాను 19:18",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_9_25_q1",
          questionEn: "What does 'Golgotha' mean?",
          questionTe: "'గొల్గొతా' అనగా అర్థం ఏమిటి?",
          options: [
            ThisDayOption(textEn: "Place of a Skull", textTe: "కపాల స్థలము", isCorrect: true),
            ThisDayOption(textEn: "Place of Death", textTe: "మరణ స్థలం", isCorrect: false),
            ThisDayOption(textEn: "Holy Mount", textTe: "పరిశుద్ధ పర్వతం", isCorrect: false),
            ThisDayOption(textEn: "Garden of Sorrows", textTe: "దుఃఖాల తోట", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_9_25_q2",
          questionEn: "What inscription was written on the cross above Jesus' head?",
          questionTe: "సిలువపై యేసు తలపై ఏమని వ్రాయబడింది?",
          options: [
            ThisDayOption(textEn: "Jesus of Nazareth, King of the Jews", textTe: "నజరేయుడైన యేసు యూదుల రాజు", isCorrect: true),
            ThisDayOption(textEn: "The Son of God", textTe: "దేవుని కుమారుడు", isCorrect: false),
            ThisDayOption(textEn: "The King of Glory", textTe: "మహిమాన్వితుడైన రాజు", isCorrect: false),
            ThisDayOption(textEn: "Saviour of the World", textTe: "లోక రక్షకుడు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_9_25_q3",
          questionEn: "Who asked Pilate for the body of Jesus to bury Him?",
          questionTe: "యేసును సమాధి చేయడానికి పిలాతును ఆయన దేహాన్ని అడిగింది ఎవరు?",
          options: [
            ThisDayOption(textEn: "Joseph of Arimathea", textTe: "అరిమతైయ యోసేపు", isCorrect: true),
            ThisDayOption(textEn: "Nicodemus", textTe: "నికాయుదేము", isCorrect: false),
            ThisDayOption(textEn: "Mary Magdalene", textTe: "మరియా మగ్దలేనే", isCorrect: false),
            ThisDayOption(textEn: "Simon Peter", textTe: "సీమోను పేతురు", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 1,
      month: 10,
      titleEn: "Jerusalem's Walls Rebuilt",
      titleTe: "యెరూషలేము గోడల పునర్నిర్మాణం",
      descriptionEn: "Under Nehemiah's leadership, despite opposition from enemies, the walls of Jerusalem are completed in just 52 days.",
      descriptionTe: "శత్రువుల నుండి తీవ్ర వ్యతిరేకత వచ్చినప్పటికీ, నెహెమ్యా నాయకత్వంలో యెరూషలేము గోడల పునర్నిర్మాణం కేవలం 52 రోజుల్లోనే పూర్తవుతుంది.",
      verseReferenceEn: "Nehemiah 6:15",
      verseReferenceTe: "నెహెమ్యా 6:15",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_10_1_q1",
          questionEn: "How many days did it take to complete the wall?",
          questionTe: "యెరూషలేము గోడ పూర్తవడానికి ఎన్ని రోజులు పట్టింది?",
          options: [
            ThisDayOption(textEn: "52 days", textTe: "52 రోజులు", isCorrect: true),
            ThisDayOption(textEn: "40 days", textTe: "40 రోజులు", isCorrect: false),
            ThisDayOption(textEn: "120 days", textTe: "120 రోజులు", isCorrect: false),
            ThisDayOption(textEn: "7 days", textTe: "7 రోజులు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_10_1_q2",
          questionEn: "Who were the chief mockers/enemies of the rebuild?",
          questionTe: "గోడ నిర్మాణాన్ని ఎగతాళి చేసిన ప్రధాన శత్రువులు ఎవరు?",
          options: [
            ThisDayOption(textEn: "Sanballat and Tobiah", textTe: "సన్బల్లటు మరియు టోబీయా", isCorrect: true),
            ThisDayOption(textEn: "Haman and Mordecai", textTe: "హామాను మరియు మొర్దెకై", isCorrect: false),
            ThisDayOption(textEn: "Goliath and Saul", textTe: "గొలియాతు మరియు సౌలు", isCorrect: false),
            ThisDayOption(textEn: "Pharaoh and Potiphar", textTe: "ఫరో మరియు పోతీఫరు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_10_1_q3",
          questionEn: "What was Nehemiah's job before rebuilding Jerusalem?",
          questionTe: "గోడను కట్టడానికి ముందు నెహెమ్యా చేసిన పని ఏమిటి?",
          options: [
            ThisDayOption(textEn: "Cupbearer to the King", textTe: "రాజుకు గిన్నె అందించువాడు (పానదాయకుడు)", isCorrect: true),
            ThisDayOption(textEn: "Priest", textTe: "యాజకుడు", isCorrect: false),
            ThisDayOption(textEn: "Royal Guard", textTe: "రాజ కావలివాడు", isCorrect: false),
            ThisDayOption(textEn: "Scribe", textTe: "శాస్త్రి", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 15,
      month: 10,
      titleEn: "Birth of John the Baptist Foretold",
      titleTe: "బాప్తిస్మమిచ్చు యోహాను జననం గురించిన ప్రవచనం",
      descriptionEn: "The angel Gabriel appears to Zacharias in the temple, announcing that his wife Elizabeth will bear a son named John.",
      descriptionTe: "దేవాలయంలో జెకర్యాకు గబ్రియేలు దూత ప్రత్యక్షమై, అతని భార్యయైన ఎలీసబెతు యోహాను అను ఒక కుమారుని కంటుందని ప్రకటిస్తాడు.",
      verseReferenceEn: "Luke 1:13",
      verseReferenceTe: "లూకా 1:13",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_10_15_q1",
          questionEn: "What happened to Zacharias because he doubted the angel?",
          questionTe: "దూత మాటను నమ్మనందుకు జెకర్యాకు ఏమి సంభవించింది?",
          options: [
            ThisDayOption(textEn: "He became mute", textTe: "నోరు పడిపోయింది (మూగవాడయ్యాడు)", isCorrect: true),
            ThisDayOption(textEn: "He went blind", textTe: "గుడ్డివాడయ్యాడు", isCorrect: false),
            ThisDayOption(textEn: "He fell into a deep sleep", textTe: "గాఢ నిద్రలో పడిపోయాడు", isCorrect: false),
            ThisDayOption(textEn: "He was cast out", textTe: "మందిరం నుండి వెళ్లగొట్టబడ్డాడు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_10_15_q2",
          questionEn: "Which priestly division did Zacharias belong to?",
          questionTe: "జెకర్యా ఏ యాజక తరగతికి చెందినవాడు?",
          options: [
            ThisDayOption(textEn: "Abijah", textTe: "అబీయా తరగతి", isCorrect: true),
            ThisDayOption(textEn: "Eleazar", textTe: "ఎలియాజరు తరగతి", isCorrect: false),
            ThisDayOption(textEn: "Aaron", textTe: "అహరోను తరగతి", isCorrect: false),
            ThisDayOption(textEn: "Levi", textTe: "లేవి తరగతి", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_10_15_q3",
          questionEn: "What was John the Baptist's mother's name?",
          questionTe: "బాప్తిస్మమిచ్చు యోహాను తల్లి పేరు ఏమిటి?",
          options: [
            ThisDayOption(textEn: "Elizabeth", textTe: "ఎలీసబెతు", isCorrect: true),
            ThisDayOption(textEn: "Mary", textTe: "మరియ", isCorrect: false),
            ThisDayOption(textEn: "Hannah", textTe: "హన్నా", isCorrect: false),
            ThisDayOption(textEn: "Sarah", textTe: "శారా", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 25,
      month: 10,
      titleEn: "The Resurrection of Jesus",
      titleTe: "యేసుక్రీస్తు పునరుత్థానం",
      descriptionEn: "Early on the first day of the week, the women find the tomb empty and hear the angel declare: 'He is not here; He has risen!'",
      descriptionTe: "ఆదివారము తెల్లవారుజామున, స్త్రీలు సమాధి వద్దకు వెళ్లగా రాయి దొర్లింపబడి యుండటం చూసి 'ఆయన ఇక్కడ లేడు, లేచియున్నాడు' అని దేవదూత చెప్పడం వింటారు.",
      verseReferenceEn: "Matthew 28:6",
      verseReferenceTe: "మత్తయి 28:6",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_10_25_q1",
          questionEn: "Which woman was first to see the risen Jesus?",
          questionTe: "పునరుత్థానుడైన యేసును మొదట చూసిన స్త్రీ ఎవరు?",
          options: [
            ThisDayOption(textEn: "Mary Magdalene", textTe: "మరియా మగ్దలేనే", isCorrect: true),
            ThisDayOption(textEn: "Mary the mother of James", textTe: "యాకోబు తల్లియైన మరియ", isCorrect: false),
            ThisDayOption(textEn: "Salome", textTe: "సలోమే", isCorrect: false),
            ThisDayOption(textEn: "Joanna", textTe: "యూహన్న", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_10_25_q2",
          questionEn: "Who rolled away the stone from the tomb entrance?",
          questionTe: "సమాధి ద్వారము నుండి రాయిని ఎవరు దొర్లించారు?",
          options: [
            ThisDayOption(textEn: "An angel of the Lord", textTe: "యెహోవా దూత", isCorrect: true),
            ThisDayOption(textEn: "Peter and John", textTe: "పేతురు మరియు యోహాను", isCorrect: false),
            ThisDayOption(textEn: "Roman guards", textTe: "రోమా కావలివారు", isCorrect: false),
            ThisDayOption(textEn: "Joseph of Arimathea", textTe: "అరిమతైయ యోసేపు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_10_25_q3",
          questionEn: "What report did the guards spread after receiving money from priests?",
          questionTe: "యాజకుల వద్ద నుండి డబ్బు తీసుకున్న తర్వాత కావలివారు ఏ అబద్ధవార్తను ప్రచారం చేశారు?",
          options: [
            ThisDayOption(textEn: "His disciples stole the body while they slept", textTe: "తాము నిద్రపోతుండగా ఆయన శిష్యులు శవాన్ని దొంగిలించారు", isCorrect: true),
            ThisDayOption(textEn: "He rose indeed", textTe: "ఆయన నిజంగానే లేచాడు", isCorrect: false),
            ThisDayOption(textEn: "The body was eaten by beasts", textTe: "శవాన్ని మృగాలు తినివేసాయి", isCorrect: false),
            ThisDayOption(textEn: "Pilate moved the body", textTe: "పిలాతు శవాన్ని తరలించాడు", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 1,
      month: 11,
      titleEn: "The Birth of Jesus foretold to Mary",
      titleTe: "మరియకు యేసు జనన ప్రకటన",
      descriptionEn: "The angel Gabriel visits Mary in Nazareth, declaring she will conceive by the Holy Spirit and give birth to Jesus.",
      descriptionTe: "నజరేతులో మరియను గబ్రియేలు దూత సందర్శించి, ఆమె పరిశుద్ధాత్మ ద్వారా గర్భం ధరించి యేసుక్రీస్తుకు జన్మనిస్తుందని ప్రకటిస్తాడు.",
      verseReferenceEn: "Luke 1:31",
      verseReferenceTe: "లూకా 1:31",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_11_1_q1",
          questionEn: "What name did Gabriel say the child should be given?",
          questionTe: "ఆ బాలునికి ఏ పేరు పెట్టాలని గబ్రియేలు దూత చెప్పాడు?",
          options: [
            ThisDayOption(textEn: "Jesus", textTe: "యేసు", isCorrect: true),
            ThisDayOption(textEn: "Immanuel", textTe: "ఇమ్మానుయేలు", isCorrect: false),
            ThisDayOption(textEn: "John", textTe: "యోహాను", isCorrect: false),
            ThisDayOption(textEn: "Zacharias", textTe: "జెకర్యా", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_11_1_q2",
          questionEn: "What was Mary's response to the angel's announcement?",
          questionTe: "దూత మాటలకు మరియ ప్రతిస్పందన ఏమిటి?",
          options: [
            ThisDayOption(textEn: "Behold, the maidservant of the Lord", textTe: "ఇదిగో ప్రభువు దాసురాలను", isCorrect: true),
            ThisDayOption(textEn: "How can this be since I am married?", textTe: "నాకు వివాహం అయింది కదా ఇది ఎలా సాధ్యం?", isCorrect: false),
            ThisDayOption(textEn: "I do not believe this", textTe: "నేను దీనిని నమ్మను", isCorrect: false),
            ThisDayOption(textEn: "Tell Joseph first", textTe: "మొదట యోసేపుకు చెప్పు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_11_1_q3",
          questionEn: "What relation was Elizabeth to Mary?",
          questionTe: "ఎలీసబెతు మరియకు ఏ బంధువు అవుతుంది?",
          options: [
            ThisDayOption(textEn: "Relative (cousin)", textTe: "బంధువు (మేనకోడలు/అక్క)", isCorrect: true),
            ThisDayOption(textEn: "Sister", textTe: "సహోదరి", isCorrect: false),
            ThisDayOption(textEn: "Mother", textTe: "తల్లి", isCorrect: false),
            ThisDayOption(textEn: "Aunt", textTe: "పినతల్లి", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 15,
      month: 11,
      titleEn: "The Baptism of Jesus",
      titleTe: "యేసు బాప్తిస్మం పొందడం",
      descriptionEn: "Jesus is baptized by John in the Jordan River. As He rises, the heavens open, the Holy Spirit descends like a dove, and God speaks.",
      descriptionTe: "యొర్దాను నదిలో యోహాను చేత యేసు బాప్తిస్మం పొందుతాడు. ఆయన బయటకు రాగానే ఆకాశము తెరవబడి, పరిశుద్ధాత్మ పావురమువలె దిగివచ్చింది, తండ్రి స్వరం వినిపించింది.",
      verseReferenceEn: "Matthew 3:16",
      verseReferenceTe: "మత్తయి 3:16",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_11_15_q1",
          questionEn: "What voice was heard from heaven after Jesus' baptism?",
          questionTe: "యేసు బాప్తిస్మం పొందిన తర్వాత పరలోకం నుండి ఏ స్వరం వినిపించింది?",
          options: [
            ThisDayOption(textEn: "This is my beloved Son, in whom I am well pleased", textTe: "ఈయనే నా ప్రియ కుమారుడు, ఈయనయందు నేను ఆనందించుచున్నాను", isCorrect: true),
            ThisDayOption(textEn: "Hear Him!", textTe: "ఈయన మాట వినుడి!", isCorrect: false),
            ThisDayOption(textEn: "The Kingdom of God is at hand", textTe: "దేవుని రాజ్యం సమీపించియున్నది", isCorrect: false),
            ThisDayOption(textEn: "Repent and believe", textTe: "మారుమనస్సు పొంది నమ్ముడి", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_11_15_q2",
          questionEn: "What form did the Holy Spirit take during the descent?",
          questionTe: "దిగివచ్చునప్పుడు పరిశుద్ధాత్మ ఏ రూపాన్ని తీసుకుంది?",
          options: [
            ThisDayOption(textEn: "A dove", textTe: "పావురము", isCorrect: true),
            ThisDayOption(textEn: "Tongues of fire", textTe: "అగ్ని నాలుకలు", isCorrect: false),
            ThisDayOption(textEn: "A cloud", textTe: "మేఘము", isCorrect: false),
            ThisDayOption(textEn: "A rushing wind", textTe: "గొప్ప గాలి", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_11_15_q3",
          questionEn: "In which river was Jesus baptized?",
          questionTe: "యేసు ఏ నదిలో బాప్తిస్మం పొందాడు?",
          options: [
            ThisDayOption(textEn: "Jordan", textTe: "యొర్దాను", isCorrect: true),
            ThisDayOption(textEn: "Kishon", textTe: "కీషోను", isCorrect: false),
            ThisDayOption(textEn: "Nile", textTe: "నైలు", isCorrect: false),
            ThisDayOption(textEn: "Abana", textTe: "అబానా", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 25,
      month: 11,
      titleEn: "Pentecost and the Holy Spirit",
      titleTe: "పెంతుకోస్తు పండుగ మరియు పరిశుద్ధాత్మ",
      descriptionEn: "Gathered in Jerusalem, the disciples are filled with the Holy Spirit, speaking in other tongues as the Spirit gives utterance.",
      descriptionTe: "యెరూషలేములో శిష్యులందరూ కూడియుండగా, ఆత్మ వారికి వాక్శక్తి అనుగ్రహించిన కొలది అన్యభాషలతో మాట్లాడసాగారు.",
      verseReferenceEn: "Acts 2:4",
      verseReferenceTe: "అపొస్తలుల కార్యములు 2:4",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_11_25_q1",
          questionEn: "What sound was heard when the Holy Spirit descended?",
          questionTe: "పరిశుద్ధాత్మ దిగివచ్చినప్పుడు ఎలాంటి శబ్దం వినిపించింది?",
          options: [
            ThisDayOption(textEn: "A rushing mighty wind", textTe: "చండమారుతము వంటి శబ్దం", isCorrect: true),
            ThisDayOption(textEn: "Thunder", textTe: "ఉరుములు శబ్దం", isCorrect: false),
            ThisDayOption(textEn: "A trumpet blast", textTe: "బూర ధ్వని", isCorrect: false),
            ThisDayOption(textEn: "Angel songs", textTe: "దేవదూతల గానం", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_11_25_q2",
          questionEn: "What rested on each of the disciples' heads?",
          questionTe: "శిష్యులలో ప్రతి ఒక్కరి తలపై ఏమి నిలిచింది?",
          options: [
            ThisDayOption(textEn: "Divided tongues of fire", textTe: "విభాగింపబడిన అగ్ని నాలుకలు", isCorrect: true),
            ThisDayOption(textEn: "A halo of light", textTe: "వెలుగు వలయాలు", isCorrect: false),
            ThisDayOption(textEn: "Gold crowns", textTe: "బంగారు కిరీటాలు", isCorrect: false),
            ThisDayOption(textEn: "Water droplets", textTe: "నీటి చుక్కలు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_11_25_q3",
          questionEn: "Which apostle stood up and preached the main sermon on Pentecost?",
          questionTe: "పెంతుకోస్తు దినాన నిలబడి ప్రసంగించిన అపొస్తలుడు ఎవరు?",
          options: [
            ThisDayOption(textEn: "Peter", textTe: "పేతురు", isCorrect: true),
            ThisDayOption(textEn: "John", textTe: "యోహాను", isCorrect: false),
            ThisDayOption(textEn: "James", textTe: "యాకోబు", isCorrect: false),
            ThisDayOption(textEn: "Paul", textTe: "పౌలు", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 1,
      month: 12,
      titleEn: "The Sermon on the Mount Begins",
      titleTe: "కొండమీది ప్రసంగం ప్రారంభం",
      descriptionEn: "Seeing the crowds, Jesus goes up on a mountain and begins teaching the disciples, starting with the Beatitudes.",
      descriptionTe: "సమూహములను చూసి యేసు కొండపైకి వెళ్లి కూర్చున్నాడు, శిష్యులు ఆయన వద్దకు రాగా ధన్యవచనములతో బోధించడం ప్రారంభించాడు.",
      verseReferenceEn: "Matthew 5:1",
      verseReferenceTe: "మత్తయి 5:1",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_12_1_q1",
          questionEn: "Who are said to be blessed first in the Beatitudes?",
          questionTe: "ధన్యవచనములలో మొదట ఎవరు ధన్యులని చెప్పబడ్డారు?",
          options: [
            ThisDayOption(textEn: "The poor in spirit", textTe: "ఆత్మవిషయమై దీనులైనవారు", isCorrect: true),
            ThisDayOption(textEn: "The meek", textTe: "సాత్వికులు", isCorrect: false),
            ThisDayOption(textEn: "The peacemakers", textTe: "సమాధానపరచువారు", isCorrect: false),
            ThisDayOption(textEn: "The pure in heart", textTe: "హృదయశుద్ధి గలవారు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_12_1_q2",
          questionEn: "What did Jesus say the disciples are in relation to the world?",
          questionTe: "లోకానికి శిష్యులు ఏమైయున్నారని యేసు చెప్పాడు?",
          options: [
            ThisDayOption(textEn: "Salt and light", textTe: "ఉప్పు మరియు వెలుగు", isCorrect: true),
            ThisDayOption(textEn: "Kings and priests", textTe: "రాజులు మరియు యాజకులు", isCorrect: false),
            ThisDayOption(textEn: "Servants and masters", textTe: "దాసులు మరియు యజమానులు", isCorrect: false),
            ThisDayOption(textEn: "Sheep and wolves", textTe: "గొర్రెలు మరియు తోడేళ్లు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_12_1_q3",
          questionEn: "What did Jesus say he came to do with the Law and the Prophets?",
          questionTe: "ధర్మశాస్త్రమును ప్రవక్తలను యేసు ఏమి చేయడానికి వచ్చానని చెప్పాడు?",
          options: [
            ThisDayOption(textEn: "To fulfill them", textTe: "నెరవేర్చడానికి", isCorrect: true),
            ThisDayOption(textEn: "To abolish them", textTe: "కొట్టివేయడానికి", isCorrect: false),
            ThisDayOption(textEn: "To rewrite them", textTe: "తిరిగి వ్రాయడానికి", isCorrect: false),
            ThisDayOption(textEn: "To ignore them", textTe: "నిర్లక్ష్యం చేయడానికి", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 15,
      month: 12,
      titleEn: "Feeding of the Five Thousand",
      titleTe: "ఐదు వేల మందికి భోజనం పెట్టడం",
      descriptionEn: "Jesus takes five loaves of barley bread and two fish, blesses them, and feeds five thousand men plus women and children.",
      descriptionTe: "యేసు ఐదు యవల రొట్టెలను రెండు చేపలను తీసుకుని, ఆశీర్వదించి ఐదు వేల మంది పురుషులకు, స్త్రీలకు మరియు పిల్లలకు సమృద్ధిగా భోజనం పెట్టాడు.",
      verseReferenceEn: "Mark 6:41",
      verseReferenceTe: "మార్కు 6:41",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_12_15_q1",
          questionEn: "How many baskets of leftovers were gathered?",
          questionTe: "మిగిలిన ముక్కలను ఎన్ని గంపల నిండుగా ఎత్తుకున్నారు?",
          options: [
            ThisDayOption(textEn: "Twelve baskets", textTe: "పన్నెండు గంపలు", isCorrect: true),
            ThisDayOption(textEn: "Seven baskets", textTe: "ఏడు గంపలు", isCorrect: false),
            ThisDayOption(textEn: "Three baskets", textTe: "మూడు గంపలు", isCorrect: false),
            ThisDayOption(textEn: "Ten baskets", textTe: "పది గంపలు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_12_15_q2",
          questionEn: "Whose lunch did the disciples use for the miracle?",
          questionTe: "అద్భుతం చేయడానికి శిష్యులు ఎవరి ఆహారాన్ని తీసుకువచ్చారు?",
          options: [
            ThisDayOption(textEn: "A young boy's", textTe: "ఒక చిన్న బాలునిది", isCorrect: true),
            ThisDayOption(textEn: "Peter's", textTe: "పేతురుది", isCorrect: false),
            ThisDayOption(textEn: "Mary's", textTe: "మరియది", isCorrect: false),
            ThisDayOption(textEn: "They bought it", textTe: "వారు కొనుగోలు చేశారు", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_12_15_q3",
          questionEn: "What was the starting food supply?",
          questionTe: "ప్రారంభంలో వారి వద్ద ఉన్న ఆహారం ఎంత?",
          options: [
            ThisDayOption(textEn: "Five loaves and two fish", textTe: "ఐదు రొట్టెలు మరియు రెండు చేపలు", isCorrect: true),
            ThisDayOption(textEn: "Seven loaves and a few small fish", textTe: "ఏడు రొట్టెలు మరియు కొన్ని చిన్న చేపలు", isCorrect: false),
            ThisDayOption(textEn: "Twelve loaves", textTe: "పన్నెండు రొట్టెలు", isCorrect: false),
            ThisDayOption(textEn: "One loaf", textTe: "ఒక రొట్టె", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 25,
      month: 12,
      titleEn: "The Birth of Jesus",
      titleTe: "యేసుక్రీస్తు జననం",
      descriptionEn: "In Bethlehem, Mary gives birth to Jesus, wraps Him in swaddling clothes, and lays Him in a manger because there was no room in the inn.",
      descriptionTe: "యెరూషలేము ప్రక్కనున్న బేత్లెహేములో మరియ యేసును కని, పొత్తిగుడ్డలతో చుట్టి పశువుల తొట్టిలో పడుకోబెట్టింది, సత్రములో వారికి స్థలము లేకపోయెను.",
      verseReferenceEn: "Luke 2:7",
      verseReferenceTe: "లూకా 2:7",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_12_25_q1",
          questionEn: "Where did Mary lay the newborn Jesus?",
          questionTe: "నవజాత శిశువైన యేసును మరియ ఎక్కడ పడుకోబెట్టింది?",
          options: [
            ThisDayOption(textEn: "In a manger", textTe: "పశువుల తొట్టిలో", isCorrect: true),
            ThisDayOption(textEn: "In a cradle", textTe: "తొట్టిలో", isCorrect: false),
            ThisDayOption(textEn: "On a bed in the inn", textTe: "సత్రములోని మంచముపై", isCorrect: false),
            ThisDayOption(textEn: "On the ground", textTe: "నేలపై", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_12_25_q2",
          questionEn: "Who did the angels first announce the birth of Jesus to?",
          questionTe: "దేవదూతలు మొదట యేసు జనన వార్తను ఎవరికి ప్రకటించారు?",
          options: [
            ThisDayOption(textEn: "Shepherds keeping watch", textTe: "మందలను కాచుకొను గొర్రెల కాపరులకు", isCorrect: true),
            ThisDayOption(textEn: "The Wise Men", textTe: "జ్ఞానులకు", isCorrect: false),
            ThisDayOption(textEn: "King Herod", textTe: "హేరోదు రాజుకు", isCorrect: false),
            ThisDayOption(textEn: "The High Priest", textTe: "ప్రధాన యాజకునికి", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_12_25_q3",
          questionEn: "In which town was Jesus born?",
          questionTe: "యేసు ఏ ఊరిలో జన్మించాడు?",
          options: [
            ThisDayOption(textEn: "Bethlehem", textTe: "బేత్లెహేము", isCorrect: true),
            ThisDayOption(textEn: "Nazareth", textTe: "నజరేతు", isCorrect: false),
            ThisDayOption(textEn: "Jerusalem", textTe: "యెరూషలేము", isCorrect: false),
            ThisDayOption(textEn: "Capernaum", textTe: "కపెర్నహూము", isCorrect: false),
          ],
        ),
      ],
    ),
    BibleEvent(
      day: 31,
      month: 12,
      titleEn: "The New Heaven and New Earth",
      titleTe: "నూతన ఆకాశము మరియు నూతన భూమి",
      descriptionEn: "John sees a vision of the new heaven and new earth, where God dwells with man, wiping away every tear and ending death.",
      descriptionTe: "యోహాను నూతన ఆకాశమును నూతన భూమిని దర్శనంలో చూస్తాడు, అక్కడ దేవుడు నరులతో కాపురం ఉండును, వారి కన్నుల నుండి ప్రతి భాష్పబిందువును తుడిచివేయును, మరణముండదు.",
      verseReferenceEn: "Revelation 21:1",
      verseReferenceTe: "ప్రకటన 21:1",
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_12_31_q1",
          questionEn: "What holy city descends from heaven from God?",
          questionTe: "దేవుని వద్ద నుండి ఆకాశము నుండి దిగివచ్చే పరిశుద్ధ పట్టణము ఏది?",
          options: [
            ThisDayOption(textEn: "New Jerusalem", textTe: "నూతన యెరూషలేము", isCorrect: true),
            ThisDayOption(textEn: "New Babylon", textTe: "నూతన బాబెలు", isCorrect: false),
            ThisDayOption(textEn: "Zion", textTe: "సీయోను", isCorrect: false),
            ThisDayOption(textEn: "Bethlehem", textTe: "బేత్లెహేము", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_12_31_q2",
          questionEn: "What will God wipe away from their eyes?",
          questionTe: "దేవుడు వారి కన్నుల నుండి దేనిని తుడిచివేస్తాడు?",
          options: [
            ThisDayOption(textEn: "Every tear", textTe: "ప్రతి భాష్పబిందువును (కన్నీరు)", isCorrect: true),
            ThisDayOption(textEn: "Dust", textTe: "ధూళి", isCorrect: false),
            ThisDayOption(textEn: "Blood", textTe: "రక్తము", isCorrect: false),
            ThisDayOption(textEn: "Sleep", textTe: "నిద్ర", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_12_31_q3",
          questionEn: "What former things will pass away according to this passage?",
          questionTe: "ఈ వాక్యం ప్రకారం గతించిన పూర్వ సంగతులు ఏవి?",
          options: [
            ThisDayOption(textEn: "Death, mourning, crying, and pain", textTe: "మరణము, దుఃఖము, ఏడ్పు, వేదన", isCorrect: true),
            ThisDayOption(textEn: "Sun and moon only", textTe: "సూర్య చంద్రులు మాత్రమే", isCorrect: false),
            ThisDayOption(textEn: "The oceans only", textTe: "సముద్రములు మాత్రమే", isCorrect: false),
            ThisDayOption(textEn: "All plants and trees", textTe: "మొక్కలు మరియు చెట్లు", isCorrect: false),
          ],
        ),
      ],
    ),
  ];

  static BibleEvent getTodayEvent() {
    final now = DateTime.now();
    return getEventForDate(now.month, now.day);
  }

  static BibleEvent getEventForDate(int month, int day) {
    for (var event in _predefinedEvents) {
      if (event.month == month && event.day == day) {
        return event;
      }
    }
    return _generateTemplateEvent(month, day);
  }

  static BibleEvent _generateTemplateEvent(int month, int day) {
    final hash = (month * 31 + day) % 10;
    
    final titlesEn = [
      "The Calling of Abraham",
      "Moses Ascends Mount Sinai",
      "Joshua Crosses the Jordan",
      "Solomon Dedicates the Temple",
      "Nehemiah Rebuilds the Walls",
      "The Birth of Jesus foretold",
      "The Baptism of Jesus",
      "The Sermon on the Mount",
      "The Resurrection of Lazarus",
      "Paul's Conversion on Damascus Road"
    ];
    
    final titlesTe = [
      "అబ్రాహాము పిలుపు",
      "మోషే సీనాయి పర్వతం ఎక్కడం",
      "యెహోషువ యొర్దాను దాటడం",
      "సొలొమోను దేవాలయ ప్రతిష్ట",
      "నెహెమ్యా గోడల పునర్నిర్మాణం",
      "యేసు జననం గురించిన ప్రకటన",
      "యేసు బాప్తిస్మం",
      "కొండమీది ప్రసంగం",
      "లాజరు పునరుత్థానం",
      "దమస్కు మార్గంలో పౌలు మార్పు"
    ];

    final descEn = "Reflect on this biblical event on day $day of month $month. Let this remind us of God's faithful guidance throughout history.";
    final descTe = "ఈ $monthవ నెల $dayవ రోజున జరిగిన ఈ బైబిల్ సంఘటనను ధ్యానించండి. చరిత్ర అంతటా దేవుని నమ్మకమైన మార్గదర్శకత్వాన్ని ఇది మనకు గుర్తు చేయనివ్వండి.";
    
    final versesEn = ["Genesis 12:1", "Exodus 19:3", "Joshua 3:17", "1 Kings 8:1", "Nehemiah 2:17", "Luke 1:26", "Matthew 3:13", "Matthew 5:1", "John 11:43", "Acts 9:3"];
    final versesTe = ["ఆదికాండము 12:1", "నిర్గమకాండము 19:3", "యెహోషువ 3:17", "1 రాజులు 8:1", "నెహెమ్యా 2:17", "లూకా 1:26", "మత్తయి 3:13", "మత్తయి 5:1", "యోహాను 11:43", "అపొస్తలుల కార్యములు 9:3"];

    final index = hash;

    return BibleEvent(
      day: day,
      month: month,
      titleEn: titlesEn[index],
      titleTe: titlesTe[index],
      descriptionEn: descEn,
      descriptionTe: descTe,
      verseReferenceEn: versesEn[index],
      verseReferenceTe: versesTe[index],
      quizQuestions: [
        ThisDayQuizQuestion(
          id: "td_${month}_${day}_q1",
          questionEn: "Who was key in this event?",
          questionTe: "ఈ సంఘటనలో ముఖ్యమైన పాత్రధారి ఎవరు?",
          options: [
            ThisDayOption(textEn: "A faithful servant", textTe: "ఒక నమ్మకమైన సేవకుడు", isCorrect: true),
            ThisDayOption(textEn: "An earthly king", textTe: "ఒక ఐహిక రాజు", isCorrect: false),
            ThisDayOption(textEn: "A false prophet", textTe: "ఒక అబద్ధ ప్రవక్త", isCorrect: false),
            ThisDayOption(textEn: "An army general", textTe: "ఒక సైనికాధికారి", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_${month}_${day}_q2",
          questionEn: "Where did this happen?",
          questionTe: "ఇది ఎక్కడ జరిగింది?",
          options: [
            ThisDayOption(textEn: "In the Promised Land", textTe: "వాగ్దాన దేశములో", isCorrect: true),
            ThisDayOption(textEn: "In Egypt", textTe: "ఐగుప్తులో", isCorrect: false),
            ThisDayOption(textEn: "In Babylon", textTe: "బాబెలులో", isCorrect: false),
            ThisDayOption(textEn: "In Rome", textTe: "రోమాలో", isCorrect: false),
          ],
        ),
        ThisDayQuizQuestion(
          id: "td_${month}_${day}_q3",
          questionEn: "What is the key takeaway?",
          questionTe: "ముఖ్యమైన సందేశం ఏమిటి?",
          options: [
            ThisDayOption(textEn: "God is always faithful", textTe: "దేవుడు ఎల్లప్పుడూ నమ్మకమైనవాడు", isCorrect: true),
            ThisDayOption(textEn: "Trust in wealth", textTe: "ధనంపై నమ్మకం ఉంచండి", isCorrect: false),
            ThisDayOption(textEn: "Rely on physical strength", textTe: "శారీరక బలంపై ఆధారపడండి", isCorrect: false),
            ThisDayOption(textEn: "Follow own heart", textTe: "మీ స్వంత హృదయాన్ని అనుసరించండి", isCorrect: false),
          ],
        ),
      ],
    );
  }
}
