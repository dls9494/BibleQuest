class DailyVerse {
  final String referenceEn;
  final String referenceTe;
  final String verseEn;
  final String verseTe;
  final String topic;

  const DailyVerse({
    required this.referenceEn,
    required this.referenceTe,
    required this.verseEn,
    required this.verseTe,
    required this.topic,
  });
}

class VerseOfTheDayService {
  static const List<DailyVerse> verses = [
    // Day 1-5: Love & Grace
    DailyVerse(
      referenceEn: "John 3:16",
      referenceTe: "యోహాను 3:16",
      verseEn: "For God so loved the world that He gave His only begotten Son, that whoever believes in Him should not perish but have everlasting life.",
      verseTe: "దేవుడు లోకమును ఎంతో ప్రేమించెను, ఆయన తన అద్వితీయకుమారునిగా పుట్టిన వానియందు విశ్వాసముంచు ప్రతివాడును నశింపక నిత్యజీవము పొందునట్లు ఆయనను అనుగ్రహించెను.",
      topic: "Love",
    ),
    DailyVerse(
      referenceEn: "Romans 8:38-39",
      referenceTe: "రోమీయులకు 8:38-39",
      verseEn: "For I am persuaded that neither death nor life, nor angels nor principalities nor powers, nor things present nor things to come, nor height nor depth, nor any other created thing, shall be able to separate us from the love of God which is in Christ Jesus our Lord.",
      verseTe: "మరణమైనను జీవమైనను దేవదూతలైనను ప్రధానులైనను ఉన్నవియైనను రాబోవునవియైనను अधिकारियोंలైనను ఎత్తయినను లోతైనను సృష్టింపబడిన మరి ఏదోకటైనను మన ప్రభువైన క్రీస్తుయేసునందలి దేవుని ప్రేమనుండి మనలను ఎడబాపనేరవని రూఢిగా నమ్ముచున్నాను.",
      topic: "Grace",
    ),
    DailyVerse(
      referenceEn: "1 Corinthians 13:4-7",
      referenceTe: "1 కోరింథీయులకు 13:4-7",
      verseEn: "Love suffers long and is kind; love does not envy; love does not parade itself, is not puffed up; does not behave rudely, does not seek its own, is not provoked, thinks no evil; does not rejoice in iniquity, but rejoices in the truth; bears all things, believes all things, hopes all things, endures all things.",
      verseTe: "ప్రేమ దీర్ఘకాలము సహించును, అది దయ చూపించును. ప్రేమ మత్సరపడదు, ప్రేమ డంబముగా ప్రవర్తింపదు, అది ఉప్పొంగదు; అమర్యాదగా నడువదు, స్వప్రయోజనమును విచారించుకొనదు, త్వరగా కోపపడదు, అపకారమును మనస్సున ఉంచుకొనదు; దుర్నీతియందు సంతోషింపక సత్యమునందు సంతోషించును; అన్నిటికి తాళుకొనును, అన్నిటిని నమ్మును, అన్నిటిని నిరీక్షించును, అన్నిటిని ఓర్చును.",
      topic: "Love",
    ),
    DailyVerse(
      referenceEn: "Ephesians 2:8",
      referenceTe: "ఎఫెసీయులకు 2:8",
      verseEn: "For by grace you have been saved through faith, and that not of yourselves; it is the gift of God.",
      verseTe: "ఏలయనగా మీరు విశ్వాసముద్వారా కృపచేతనే రక్షింపబడియున్నారు; ఇది మీవలన కలిగినది కాదు, దేవుని వరమే.",
      topic: "Grace",
    ),
    DailyVerse(
      referenceEn: "1 John 4:19",
      referenceTe: "1 యోహాను 4:19",
      verseEn: "We love Him because He first loved us.",
      verseTe: "ఆయనే మొదట మనలను ప్రేమించెను గనుక మనము ప్రేమించుచుాము.",
      topic: "Love",
    ),

    // Day 6-10: Faith & Trust
    DailyVerse(
      referenceEn: "Proverbs 3:5-6",
      referenceTe: "సామెతలు 3:5-6",
      verseEn: "Trust in the Lord with all your heart, and lean not on your own understanding; in all your ways acknowledge Him, and He shall direct your paths.",
      verseTe: "నీ స్వబుద్ధిని ఆధారము చేసికొనక నీ పూర్ణహృదయముతో యెహోవాయందు నమ్మకముంచుము. నీ ప్రవర్తన అంతటియందు ఆయన అధికారమును ఒప్పుకొనుము అప్పుడు ఆయన నీ త్రోవలను సరళము చేయును.",
      topic: "Trust",
    ),
    DailyVerse(
      referenceEn: "Hebrews 11:1",
      referenceTe: "హెబ్రీయులకు 11:1",
      verseEn: "Now faith is the substance of things hoped for, the evidence of things not seen.",
      verseTe: "విశ్వాసమనునది నిరీక్షింపబడువాటియొక్క నిజస్వరూపమును, అదృశ్యమైనవి యున్నవనుటకు రుజువునై యున్నది.",
      topic: "Faith",
    ),
    DailyVerse(
      referenceEn: "Matthew 17:20",
      referenceTe: "మత్తయి 17:20",
      verseEn: "If you have faith as a mustard seed, you will say to this mountain, 'Move from here to there,' and it will move; and nothing will be impossible for you.",
      verseTe: "మీకు ఆవగింజంత విశ్వాసముండినయెడల ఈ కొండను చూచి—ఇక్కడనుండి అక్కడికి పొమ్మనగానే అది పోవును; మీకు అసాధ్యమైనది ఏదియు ఉండదని నిశ్చయముగా మీతో చెప్పుచున్నాను.",
      topic: "Faith",
    ),
    DailyVerse(
      referenceEn: "Romans 10:17",
      referenceTe: "రోమీయులకు 10:17",
      verseEn: "So then faith comes by hearing, and hearing by the word of God.",
      verseTe: "కాగా వినుటవలన విశ్వాసము కలుగును, వినుట క్రీస్తునుగూర్చిన మాటవలన కలుగును.",
      topic: "Faith",
    ),
    DailyVerse(
      referenceEn: "James 1:6",
      referenceTe: "యాకోబు 1:6",
      verseEn: "But let him ask in faith, with no doubting, for he who doubts is like a wave of the sea driven and tossed by the wind.",
      verseTe: "అయితే అతడు ఏమాత్రమును సందేహింపక విశ్వాసముతో అడుగవలెను; సందేహించువాడు గాలిచేత కొట్టుకొనిపోవుచు ఎగిరిపడు సముద్రపు తరంగమును పోలియుండును.",
      topic: "Trust",
    ),

    // Day 11-15: Hope & Encouragement
    DailyVerse(
      referenceEn: "Jeremiah 29:11",
      referenceTe: "యిర్మీయా 29:11",
      verseEn: "For I know the thoughts that I think toward you, says the Lord, thoughts of peace and not of evil, to give you a future and a hope.",
      verseTe: "నేను మిమ్మునుగూర్చి ఉద్దేశించిన సంగతులను నేనెరుగుదును, అవి సమాధానకరమైన ఉద్దేశములేగాని హానికరమైనవి కావు; మీకు నిరీక్షణతోకూడిన భావికాలము కలుగజేయుటకై యెహోవా వాక్కు.",
      topic: "Hope",
    ),
    DailyVerse(
      referenceEn: "Isaiah 40:31",
      referenceTe: "యెషయా 40:31",
      verseEn: "But those who wait on the Lord shall renew their strength; they shall mount up with wings like eagles, they shall run and not be weary, they shall walk and not faint.",
      verseTe: "యెహోవాకొరకు ఎదురుచూచువారు నూతన బలము పొందుదురు, వారు పక్షిరాజులవలె రెక్కలు చాపి పైకి ఎగురుదురు, అలయక పరుగెత్తుదురు, సొమ్మసిల్లక నడిచిపోవుదురు.",
      topic: "Hope",
    ),
    DailyVerse(
      referenceEn: "Psalm 23:4",
      referenceTe: "కీర్తనలు 23:4",
      verseEn: "Yea, though I walk through the valley of the shadow of death, I will fear no evil; for You are with me; Your rod and Your staff, they comfort me.",
      verseTe: "గాఢాంధకారపు లోయలో నేను సంచరించినను ఏ అపాయమునకు భయపడను, నీవు నాకు తోడైయుందువు; నీ దుడ్డుకఱ్ఱయు నీ ఊతకోలయు నన్ను ఆదరించును.",
      topic: "Encouragement",
    ),
    DailyVerse(
      referenceEn: "Romans 15:13",
      referenceTe: "రోమీయులకు 15:13",
      verseEn: "Now may the God of hope fill you with all joy and peace in believing, that you may abound in hope by the power of the Holy Spirit.",
      verseTe: "దేవునియందు మీరు విశ్వాసముంచుటవలన పరిశుద్ధాత్మ शक्तिచేత నిరీక్షణతో అభ్యుదయము పొందునట్లు నిరీక్షణకర్తయగు దేవుడు సమస్తానందముతోను సమాధానముతోను మిమ్మును నింపును గాక.",
      topic: "Hope",
    ),
    DailyVerse(
      referenceEn: "Psalm 42:11",
      referenceTe: "కీర్తనలు 42:11",
      verseEn: "Why are you cast down, O my soul? And why are you disquieted within me? Hope in God; for I shall yet praise Him, the help of my countenance and my God.",
      verseTe: "నా ప్రాణమా, నీవు ఏల కృంగియున్నావు? నాలో నీవు ఏల తొందరపడుచున్నావు? దేవునియందు నిరీక్షణ యుంచుము, ఆయనే నా రక్షణకర్త, నా దేవుడు; నేనింకను ఆయనను స్తుతించెదను.",
      topic: "Encouragement",
    ),

    // Day 16-20: Strength & Courage
    DailyVerse(
      referenceEn: "Joshua 1:9",
      referenceTe: "యెహోషువ 1:9",
      verseEn: "Have I not commanded you? Be strong and of good courage; do not be afraid, nor be dismayed, for the Lord your God is with you wherever you go.",
      verseTe: "నేను నీకు ఆజ్ఞ ఇచ్చియున్నాను గదా, నిబ్బరము కలిగి ధైర్యముగా నుండుము, దిగులుపడకుము జడియకుము, నీవు నడుచు మార్గమంతటిలో నీ దేవుడైన యెహోవా నీకు తోడైయుండును.",
      topic: "Courage",
    ),
    DailyVerse(
      referenceEn: "Philippians 4:13",
      referenceTe: "ఫిలిప్పీయులకు 4:13",
      verseEn: "I can do all things through Christ who strengthens me.",
      verseTe: "నన్ను బలపరచువానియందే నేను సమస్తమును చేయగలను.",
      topic: "Strength",
    ),
    DailyVerse(
      referenceEn: "Isaiah 41:10",
      referenceTe: "యెషయా 41:10",
      verseEn: "Fear not, for I am with you; be not dismayed, for I am your God. I will strengthen you, yes, I will help you, I will uphold you with My righteous right hand.",
      verseTe: "నీవు భయపడకుము నేను నీకు తోడైయున్నాను, సంశయింపకుము నేను నీ దేవుడనై యున్నాను. నేను నిన్ను బలపరచుదును, నీకు సహాయము చేయుదును, నా నీతియను దక్షిణహస్తముతో నిన్ను ఆదుకొందును.",
      topic: "Strength",
    ),
    DailyVerse(
      referenceEn: "2 Timothy 1:7",
      referenceTe: "2 తిమోతికి 1:7",
      verseEn: "For God has not given us a spirit of fear, but of power and of love and of a sound mind.",
      verseTe: "దేవుడు మనకు शक्तिయు ప్రేమయు ఇంద్రియ నిగ్రహమునుగల ఆత్మనే యిచ్చెను గాని పిరికితనముగల ఆత్మ నియ్యలేదు.",
      topic: "Courage",
    ),
    DailyVerse(
      referenceEn: "Psalm 27:1",
      referenceTe: "కీర్తనలు 27:1",
      verseEn: "The Lord is my light and my salvation; whom shall I fear? The Lord is the strength of my life; of whom shall I be afraid?",
      verseTe: "యెహోవా నాకు వెలుగును నా రక్షణయునై యున్నాడు, నేను ఎవరికి భయపడుదును? యెహోవా నా ప్రాణ దుర్గము, నేను ఎవరికి వెరతును?",
      topic: "Strength",
    ),

    // Day 21-25: Wisdom & Guidance
    DailyVerse(
      referenceEn: "Proverbs 9:10",
      referenceTe: "సామెతలు 9:10",
      verseEn: "The fear of the Lord is the beginning of wisdom, and the knowledge of the Holy One is understanding.",
      verseTe: "యెహోవాయందు భయభక్తులు కలిగియుండుటయే జ్ఞానమునకు మూలము, పరిశుద్ధునిగూర్చిన విజ్ఞానమే వివేచన.",
      topic: "Wisdom",
    ),
    DailyVerse(
      referenceEn: "James 1:5",
      referenceTe: "యాకోబు 1:5",
      verseEn: "If any of you lacks wisdom, let him ask of God, who gives to all liberally and without reproach, and it will be given to him.",
      verseTe: "మీలో ఎవనికైనను జ్ఞానము కొరతగా ఉన్నయెడల అతడు దేవుని అడుగవలెను, అప్పుడది అతనికి అనుగ్రహింపబడును. ఆయన ఎవరిని గద్దింపక అందరికిని ధారాళముగా దయచేయువాడు.",
      topic: "Wisdom",
    ),
    DailyVerse(
      referenceEn: "Psalm 119:105",
      referenceTe: "కీర్తనలు 119:105",
      verseEn: "Your word is a lamp to my feet and a light to my path.",
      verseTe: "నీ వాక్యము నా పాదములకు దీపమును నా త్రోవకు వెలుగునై యున్నది.",
      topic: "Guidance",
    ),
    DailyVerse(
      referenceEn: "Proverbs 16:3",
      referenceTe: "సామెతలు 16:3",
      verseEn: "Commit your works to the Lord, and your thoughts will be established.",
      verseTe: "నీ పనుల భారము యెహోవామీద ఉంచుము అప్పుడు నీ సంకల్పములు సఫలమగును.",
      topic: "Guidance",
    ),
    DailyVerse(
      referenceEn: "Colossians 3:16",
      referenceTe: "కొలొస్సయులకు 3:16",
      verseEn: "Let the word of Christ dwell in you richly in all wisdom, teaching and admonishing one another in psalms and hymns and spiritual songs, singing with grace in your hearts to the Lord.",
      verseTe: "సంగీతములతోను కీర్తనలతోను ఆత్మసంబంధమైన పద్యములతోను ఒకనికి ఒకడు బోధించుచు, బుద్ధి చెప్పుచు, కృపాసహితముగా మీ హృదయములలో దేవునిగూర్చి గానము చేయుచు, సమస్త జ్ఞానముతో క్రీస్తు వాక్యము మీలో సమృద్ధిగా నివсиంపనీయుడి.",
      topic: "Wisdom",
    ),

    // Day 26-30: Peace & Rest
    DailyVerse(
      referenceEn: "Matthew 11:28",
      referenceTe: "మత్తయి 11:28",
      verseEn: "Come to Me, all you who labor and are heavy laden, and I will give you rest.",
      verseTe: "ప్రయాసపడి భారము మోసికొనుచున్న సమస్త జనులారా, నాయొద్దకు రండి, నేను మీకు విశ్రాంతి కలుగజేతును.",
      topic: "Rest",
    ),
    DailyVerse(
      referenceEn: "John 14:27",
      referenceTe: "యోహాను 14:27",
      verseEn: "Peace I leave with you, My peace I give to you; not as the world gives do I give to you. Let not your heart be troubled, neither let it be afraid.",
      verseTe: "శాంతి మీకనుగ్రహించి వెళ్లుచున్నాను; నా శాంతినే మీకనుగ్రహించుచున్నాను; లోకమిచ్చునట్టుగా నేను మీకనుగ్రహించుటలేదు. మీ హృదయమును కలవరపడనీయకుడి, భయపడనీయకుడి.",
      topic: "Peace",
    ),
    DailyVerse(
      referenceEn: "Psalm 46:10",
      referenceTe: "కీర్తనలు 46:10",
      verseEn: "Be still, and know that I am God; I will be exalted among the nations, I will be exalted in the earth!",
      verseTe: "ఊరకుండుడి, నేనే దేవుడనని తెలిసికొనుడి, అన్యజనులలో నేను మహోన్నతుడనవుదును భూమిమీద నేను మహోన్నతుడనవుదును.",
      topic: "Peace",
    ),
    DailyVerse(
      referenceEn: "Philippians 4:6-7",
      referenceTe: "ఫిలిప్పీయులకు 4:6-7",
      verseEn: "Be anxious for nothing, but in everything by prayer and supplication, with thanksgiving, let your requests be made known to God; and the peace of God, which surpasses all understanding, will guard your hearts and minds through Christ Jesus.",
      verseTe: "దేనినిగూర్చియు చింతపడకుడి గాని ప్రతి విషయములోను ప్రార్థన విజ్ఞాపనములచేత కృతజ్ఞతాపూర్వకముగా మీ విన్నపములు దేవునికి తెలియజేయుడి. అప్పుడు సమస్త జ్ఞానమునకు మించిన దేవుని సమాధానము యేసుక్రీస్తువలన మీ హృదయములకును మీ తలంపులకును కావలియుండును.",
      topic: "Peace",
    ),
    DailyVerse(
      referenceEn: "Isaiah 26:3",
      referenceTe: "యెషయా 26:3",
      verseEn: "You will keep him in perfect peace, whose mind is stayed on You, because he trusts in You.",
      verseTe: "ఎవని మనస్సు నీమీద ఆనుకొనునో వానిని నీవు పూర్ణశాంతిగలవానిగా కాపాడుదువు, ఏలయనగా అతడు నీయందు విశ్వాసముంచియున్నాడు.",
      topic: "Trust",
    ),
  ];

  static DailyVerse getVerseOfTheDay() {
    final now = DateTime.now();
    final beginningOfYear = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(beginningOfYear).inDays + 1;
    final index = dayOfYear % 30; // Modulo 30 gives a value in the range [0, 29]
    return verses[index];
  }
}
