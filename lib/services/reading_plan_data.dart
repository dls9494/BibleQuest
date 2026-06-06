class ReadingDay {
  final int day;
  final String titleEn;
  final String titleTe;
  final String versesEn;
  final String versesTe;
  final String summaryEn;
  final String summaryTe;

  const ReadingDay({
    required this.day,
    required this.titleEn,
    required this.titleTe,
    required this.versesEn,
    required this.versesTe,
    required this.summaryEn,
    required this.summaryTe,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'titleEn': titleEn,
      'titleTe': titleTe,
      'versesEn': versesEn,
      'versesTe': versesTe,
      'summaryEn': summaryEn,
      'summaryTe': summaryTe,
    };
  }
}

class ReadingPlanData {
  static List<ReadingDay> getPlanDays(String planType) {
    switch (planType) {
      case '30_day':
        return _plan30Days;
      case '90_day':
        return _plan90Days;
      case '365_day':
        return _plan365Days;
      default:
        return [];
    }
  }

  static final List<ReadingDay> _plan30Days = [
    const ReadingDay(
      day: 1,
      titleEn: "Genesis 1-11: Creation & Early History",
      titleTe: "ఆదికాండము 1-11: సృష్టి & ప్రారంభ చరిత్ర",
      versesEn: "Genesis 1-11",
      versesTe: "ఆదికాండము 1-11",
      summaryEn: "God creates the heavens and the earth. Humanity falls into sin. Cain kills Abel, the flood of Noah purges the earth, and languages are scattered at the Tower of Babel.",
      summaryTe: "దేవుడు భూమ్యాకాశాలను సృష్టిస్తాడు. మానవాళి పాపంలో పడిపోతుంది. కయీను హేబెలును చంపడం, నోవహు కాలపు జలప్రళయం, మరియు బాబెలు గోపురం వద్ద భాషలు తారుమారు కావడం జరుగుతుంది.",
    ),
    const ReadingDay(
      day: 2,
      titleEn: "Genesis 12-25: Abraham & the Covenant",
      titleTe: "ఆదికాండము 12-25: అబ్రాహాము & నిబంధన",
      versesEn: "Genesis 12-25",
      versesTe: "ఆదికాండము 12-25",
      summaryEn: "God calls Abram, promising to make him a great nation. God establishes His covenant. Isaac is born, and Abraham's faith is tested on Mount Moriah.",
      summaryTe: "దేవుడు అబ్రామును పిలిచి, అతనిని ఒక గొప్ప జనముగా చేస్తానని వాగ్దానం చేస్తాడు. దేవుడు తన నిబంధనను స్థాపిస్తాడు. ఇస్సాకు జన్మిస్తాడు, మరియు మోరియా కొండపై అబ్రాహాము విశ్వాసం పరీక్షించబడుతుంది.",
    ),
    const ReadingDay(
      day: 3,
      titleEn: "Genesis 26-36: Isaac, Jacob, & Esau",
      titleTe: "ఆదికాండము 26-36: ఇస్సాకు, యాకోబు, & ఏశావు",
      versesEn: "Genesis 26-36",
      versesTe: "ఆదికాండము 26-36",
      summaryEn: "Jacob receives Isaac's blessing by deception and flees to Laban. Jacob wrestles with God, his name is changed to Israel, and he reconciles with Esau.",
      summaryTe: "யாకోబు మోసంతో ఇస్సాకు ఆశీర్వాదాన్ని పొంది లాబాను వద్దకు పారిపోతాడు. యాకోబు దేవునితో పోరాడుతాడు, అతని పేరు ఇశ్రాయేలుగా మార్చబడుతుంది మరియు ఏశావుతో రాజీ పడతాడు.",
    ),
    const ReadingDay(
      day: 4,
      titleEn: "Genesis 37-50: Joseph's Faithfulness",
      titleTe: "ఆదికాండము 37-50: యోసేపు నమ్మకత్వం",
      versesEn: "Genesis 37-50",
      versesTe: "ఆదికాండము 37-50",
      summaryEn: "Joseph is sold into slavery by his brothers. Through God's providence, he rises to govern Egypt and saves his family from famine.",
      summaryTe: "యోసేపు తన సహోదరులచేత బానిసత్వానికి అమ్మబడుతాడు. దేవుని సంకల్పము ద్వారా, అతను ఐగుప్తును పరిపాలించే స్థాయికి ఎదుగుతాడు మరియు తన కుటుంబాన్ని కరువు నుండి రక్షిస్తాడు.",
    ),
    const ReadingDay(
      day: 5,
      titleEn: "Exodus 1-15: Moses & the Deliverance",
      titleTe: "నిర్గమకాండము 1-15: మోషే & విమోచన",
      versesEn: "Exodus 1-15",
      versesTe: "నిర్గమకాండము 1-15",
      summaryEn: "Moses is called by God at the burning bush. The ten plagues are sent upon Egypt, the Passover is instituted, and Israel crosses the Red Sea.",
      summaryTe: "మండుచున్న పొద వద్ద మోషే దేవునిచే పిలువబడతాడు. ఐగుప్తుపై పది తెగుళ్లు పంపబడతాయి, పస్కా పండుగ నియమించబడుతుంది మరియు ఇశ్రాయేలీయులు ఎర్రసముద్రమును దాటుతారు.",
    ),
    const ReadingDay(
      day: 6,
      titleEn: "Exodus 16-24: Law & Covenant at Sinai",
      titleTe: "నిర్గమకాండము 16-24: సీనాయి వద్ద ధర్మశాస్త్రం & నిబంధన",
      versesEn: "Exodus 16-24",
      versesTe: "నిర్గమకాండము 16-24",
      summaryEn: "God provides manna and water in the wilderness. The Ten Commandments are spoken by God at Mount Sinai, laying the foundation of Israel's law.",
      summaryTe: "అరణ్యములో దేవుడు మన్నాను, నీటిని అనుగ్రహిస్తాడు. సీనాయి పర్వతం వద్ద దేవునిచే పది ఆజ్ఞలు ఇవ్వబడతాయి, ఇది ఇశ్రాయేలు ధర్మశాస్త్రానికి పునాది వేస్తుంది.",
    ),
    const ReadingDay(
      day: 7,
      titleEn: "Exodus 25-40: Tabernacle & Worship",
      titleTe: "నిర్గమకాండము 25-40: ప్రత్యక్షపు గుడారం & ఆరాధన",
      versesEn: "Exodus 25-40",
      versesTe: "నిర్గమకాండము 25-40",
      summaryEn: "God gives instructions for building the Tabernacle. Israel sins with the golden calf, Moses intercedes, and the glory of God fills the completed Tabernacle.",
      summaryTe: "ప్రత్యక్షపు గుడారమును నిర్మించడానికి దేవుడు ఆజ్ఞలు ఇస్తాడు. ఇశ్రాయేలీయులు బంగారు దూడతో పాపం చేస్తారు, మోషే విజ్ఞాపన చేస్తాడు, మరియు గుడారము పూర్తయినప్పుడు దేవుని మహిమ దానిని నింపుతుంది.",
    ),
    const ReadingDay(
      day: 8,
      titleEn: "Leviticus 1-27: Holiness & Sacrifices",
      titleTe: "లేవీయకాండము 1-27: పరిశుద్ధత & బలులు",
      versesEn: "Leviticus 1-27",
      versesTe: "లేవీయకాండము 1-27",
      summaryEn: "Laws concerning sacrifices, the priesthood, clean and unclean food, the Day of Atonement, and practical guidelines for holy living.",
      summaryTe: "బలులు, యాజకత్వము, పవిత్ర మరియు అపవిత్ర ఆహారము, ప్రాయశ్చిత్త దినము మరియు పరిశుద్ధ జీవితానికి సంబంధించిన ఆచరణాత్మక మార్గదర్శకాలు.",
    ),
    const ReadingDay(
      day: 9,
      titleEn: "Numbers 1-36: Wilderness Wanderings",
      titleTe: "సంఖ్యాకాండము 1-36: అరణ్య ప్రయాణము",
      versesEn: "Numbers 1-36",
      versesTe: "సంఖ్యాకాండము 1-36",
      summaryEn: "Israel takes a census, spies out Canaan, rebels in unbelief, and is sentenced to wander in the wilderness for forty years.",
      summaryTe: "ఇశ్రాయేలీయులు జనాభాను లెక్కిస్తారు, కనానును వేగుచూస్తారు, అవిశ్వాసంతో తిరుగుబాటు చేస్తారు మరియు నలభై సంవత్సరాలు అరణ్యములో తిరగడానికి శిక్షించబడతారు.",
    ),
    const ReadingDay(
      day: 10,
      titleEn: "Deuteronomy 1-34: Moses' Farewell Sermons",
      titleTe: "ద్వితీయోపదేశకాండము 1-34: మోషే వీడ్కోలు ప్రసంగాలు",
      versesEn: "Deuteronomy 1-34",
      versesTe: "ద్వితీయోపదేశకాండము 1-34",
      summaryEn: "Moses reviews the covenant, repeats the law for the new generation, commissions Joshua as leader, and passes away on Mount Nebo.",
      summaryTe: "మోషే నిబంధనను సమీక్షిస్తాడు, నూతన తరానికి ధర్మశాస్త్రాన్ని పునరుద్ఘాటిస్తాడు, యెహోషువను నాయకుడిగా నియమిస్తాడు మరియు నెబో పర్వతంపై మరణిస్తాడు.",
    ),
    const ReadingDay(
      day: 11,
      titleEn: "Joshua & Judges: Conquest and Cycle of Sin",
      titleTe: "యెహోషువ & న్యాయాధిపతులు: జయం మరియు పాప చక్రం",
      versesEn: "Joshua 1-24, Judges 1-21",
      versesTe: "యెహోషువ 1-24, న్యాయాధిపతులు 1-21",
      summaryEn: "Joshua leads Israel across the Jordan to conquer Jericho. After Joshua's death, Israel falls into cycles of rebellion, oppression, and deliverance by Judges.",
      summaryTe: "యెహోషువ ఇశ్రాయేలీయులను యొర్దాను దాటించి యెరికోను జయించడానికి నడిపిస్తాడు. యెహోషువ మరణం తర్వాత, ఇశ్రాయేలీయులు తిరుగుబాటు, అణచివేత మరియు న్యాయాధిపతుల ద్వారా విమోచనల చక్రంలో పడతారు.",
    ),
    const ReadingDay(
      day: 12,
      titleEn: "Ruth & 1 Samuel: Faithfulness and First King",
      titleTe: "రూతు & 1 సమూయేలు: విశ్వాసము మరియు మొదటి రాజు",
      versesEn: "Ruth 1-4, 1 Samuel 1-31",
      versesTe: "రూతు 1-4, 1 సమూయేలు 1-31",
      summaryEn: "Ruth chooses Naomi's God. Samuel is called as a prophet. Israel demands a king, Saul is anointed, but his disobedience leads to the rise of young David.",
      summaryTe: "రూతు నయోమి దేవుణ్ణి ఎన్నుకుంటుంది. సమూయేలు ప్రవక్తగా పిలువబడతాడు. ఇశ్రాయేలీయులు రాజును కోరుకుంటారు, సౌలు అభిషేకించబడతాడు, కానీ అతని అవిధేయత యవ్వనస్థుడైన దావీదు ఎదుగుదలకు దారితీస్తుంది.",
    ),
    const ReadingDay(
      day: 13,
      titleEn: "2 Samuel & 1 Kings: Davidic Dynasty & Solomon",
      titleTe: "2 సమూయేలు & 1 రాజులు: దావీదు రాజవంశం & సొలొమోను",
      versesEn: "2 Samuel 1-24, 1 Kings 1-22",
      versesTe: "2 సమూయేలు 1-24, 1 రాజులు 1-22",
      summaryEn: "David reigns and establishes Jerusalem. Solomon builds the Temple. Following Solomon's death, the kingdom divides into Israel and Judah.",
      summaryTe: "దావీదు రాజుగా పరిపాలిస్తూ యెరూషలేమును స్థాపిస్తాడు. సొలొమోను దేవాలయమును నిర్మిస్తాడు. సొలొమోను మరణం తర్వాత, రాజ్యం ఇశ్రాయేలు మరియు యూదాగా విభజించబడుతుంది.",
    ),
    const ReadingDay(
      day: 14,
      titleEn: "2 Kings: Decline & Captivity of Israel and Judah",
      titleTe: "2 రాజులు: ఇశ్రాయేలు మరియు యూదాల పతనం & చెర",
      versesEn: "2 Kings 1-25",
      versesTe: "2 రాజులు 1-25",
      summaryEn: "Elisha performs miracles. The northern kingdom of Israel falls to Assyria. Later, Judah falls to Babylon, and the Temple is destroyed.",
      summaryTe: "ఎలీషా అద్భుతాలు చేస్తాడు. ఉత్తర ఇశ్రాయేలు రాజ్యం అష్షూరీయుల వశమవుతుంది. కాలక్రమేణా, యూదా బబులోను వశమవుతుంది మరియు దేవాలయము నాశనం చేయబడుతుంది.",
    ),
    const ReadingDay(
      day: 15,
      titleEn: "Psalms: Songs of Worship & Reflection",
      titleTe: "కీర్తనలు: ఆరాధన & ధ్యాన గీతాలు",
      versesEn: "Psalms 1-150 (Overview)",
      versesTe: "కీర్తనలు 1-150 (అవలోకనం)",
      summaryEn: "A collection of prayers, songs, and poems expressing praise, thanksgiving, sorrow, and faith in God's promises.",
      summaryTe: "దేవుని వాగ్దానాలపై స్తుతి, కృతజ్ఞత, దుఃఖం మరియు విశ్వాసాన్ని వ్యక్తపరిచే ప్రార్థనలు, గీతాలు మరియు కవితల సమాహారం.",
    ),
    const ReadingDay(
      day: 16,
      titleEn: "Proverbs, Ecclesiastes, & Song: Wisdom & Love",
      titleTe: "సామెతలు, ప్రసంగి, & పరమగీతము: జ్ఞానము & ప్రేమ",
      versesEn: "Proverbs, Ecclesiastes, Song of Solomon",
      versesTe: "సామెతలు, ప్రసంగి, పరమగీతము",
      summaryEn: "Wisdom for daily living. Ecclesiastes reflects on the meaning of life under the sun. Song of Solomon celebrates the beauty of marital love.",
      summaryTe: "రోజువారీ జీవితానికి అవసరమైన జ్ఞానము. ప్రసంగి సూర్యుని క్రింద జీవితం యొక్క అర్థాన్ని ధ్యానిస్తుంది. పరమగీతము వైవాహిక ప్రేమ యొక్క అందాన్ని కొనియాడుతుంది.",
    ),
    const ReadingDay(
      day: 17,
      titleEn: "Isaiah: Prophecies of the Messiah",
      titleTe: "యెషయా: మెస్సీయ గురించిన ప్రవచనాలు",
      versesEn: "Isaiah 1-66",
      versesTe: "యెషయా 1-66",
      summaryEn: "Isaiah calls Israel to repentance, foretells the Babylonian exile, and announces prophecies of the Messiah, the Suffering Servant.",
      summaryTe: "యెషయా ఇశ్రాయేలీయులను మారుమనస్సు పొందమని పిలుస్తాడు, బబులోను చెరను ముందుగానే తెలియజేస్తాడు మరియు బాధను అనుభవించే సేవకుడైన మెస్సీయ ప్రవచనాలను ప్రకటిస్తాడు.",
    ),
    const ReadingDay(
      day: 18,
      titleEn: "Jeremiah, Lamentations, & Ezekiel: Exile & Hope",
      titleTe: "యిర్మీయా, విలాపవాక్యములు, & యెహెజ్కేలు: చెర & నిరీక్షణ",
      versesEn: "Jeremiah, Lamentations, Ezekiel",
      versesTe: "యిర్మీయా, విలాపవాక్యములు, యెహెజ్కేలు",
      summaryEn: "Jeremiah warns of judgment and promises a New Covenant. Lamentations mourns Jerusalem's fall. Ezekiel sees visions of God's glory departing and returning.",
      summaryTe: "యిర్మీయా తీర్పు గురించి హెచ్చరిస్తూ ఒక నూతన నిబంధనను వాగ్దానం చేస్తాడు. విలాపవాక్యములు యెరూషలేము పతనాన్ని బట్టి విలపిస్తాయి. యెహెజ్కేలు దేవుని మహిమ వెళ్ళిపోవడం మరియు తిరిగి రావడం గురించిన దర్శనాలను చూస్తాడు.",
    ),
    const ReadingDay(
      day: 19,
      titleEn: "Daniel & Minor Prophets: Sovereignty and Mercy",
      titleTe: "దానియేలు & చిన్న ప్రవక్తలు: సార్వభౌమాధికారం మరియు కనికరం",
      versesEn: "Daniel 1-12, Hosea-Malachi",
      versesTe: "దానియేలు 1-12, హోషేయ-మలాకీ",
      summaryEn: "Daniel remains faithful in Babylon. The twelve Minor Prophets preach against injustice, warning of the Day of the Lord while promising restoration.",
      summaryTe: "దానియేలు బబులోనులో నమ్మకంగా ఉంటాడు. పన్నెండు మంది చిన్న ప్రవక్తలు అన్యాయానికి వ్యతిరేకంగా ప్రసంగిస్తూ, పునరుద్ధరణను వాగ్దానం చేస్తూనే ప్రభువు దినము గురించి హెచ్చరిస్తారు.",
    ),
    const ReadingDay(
      day: 20,
      titleEn: "Matthew & Mark: The Promised King & Servant",
      titleTe: "మత్తయి & మార్కు: వాగ్దానం చేయబడిన రాజు & సేవకుడు",
      versesEn: "Matthew 1-28, Mark 1-16",
      versesTe: "మత్తయి 1-28, మార్కు 1-16",
      summaryEn: "Matthew shows Jesus as the fulfillment of Messianic prophecy. Mark depicts Jesus as the active, serving Son of God who gave His life as a ransom.",
      summaryTe: "మత్తయి యేసును మెస్సీయ ప్రవచనాల నెరవేర్పుగా చూపిస్తాడు. మార్కు యేసును తన ప్రాణాన్ని విమోచన క్రయధనంగా ఇచ్చిన దేవుని క్రియాశీల, సేవ చేసే కుమారుడిగా చిత్రీకరిస్తాడు.",
    ),
    const ReadingDay(
      day: 21,
      titleEn: "Luke: The Savior of the Lost",
      titleTe: "లూకా: నశించినదానిని వెదకి రక్షించువాడు",
      versesEn: "Luke 1-24",
      versesTe: "లూకా 1-24",
      summaryEn: "Luke presents Jesus as the perfect Son of Man who came to seek and to save the lost, emphasizing His compassion for all people.",
      summaryTe: "లూకా యేసును నశించినదానిని వెదకి రక్షించడానికి వచ్చిన సంపూర్ణ మనుష్యకుమారుడిగా సమర్పిస్తూ, ప్రజలందరి పట్ల ఆయనకున్న కరుణను నొక్కి చెబుతాడు.",
    ),
    const ReadingDay(
      day: 22,
      titleEn: "John: The Divine Son of God",
      titleTe: "యోహాను: దైవిక దేవుని కుమారుడు",
      versesEn: "John 1-21",
      versesTe: "యోహాను 1-21",
      summaryEn: "John emphasizes the divinity of Jesus, presenting Him as the Word made flesh, the Light of the World, and the source of eternal life.",
      summaryTe: "యోహాను యేసు దైవత్వాన్ని నొక్కి చెబుతూ, ఆయనను శరీరధారియైన వాక్యంగా, లోకపు వెలుగుగా మరియు నిత్యజీవపు ఊటగా ప్రదర్శిస్తాడు.",
    ),
    const ReadingDay(
      day: 23,
      titleEn: "Acts 1-12: The Holy Spirit & Church Beginnings",
      titleTe: "అపొస్తలుల కార్యములు 1-12: పరిశుద్ధాత్మ & సంఘ ప్రారంభాలు",
      versesEn: "Acts 1-12",
      versesTe: "అపొస్తలుల కార్యములు 1-12",
      summaryEn: "Jesus ascends. The Holy Spirit fills the disciples at Pentecost. Peter preaches, the early church grows despite persecution, and Saul is converted.",
      summaryTe: "యేసు ఆరోహణమవుతాడు. పెంతెకోస్తు పండుగనాడు పరిశుద్ధాత్మ శిష్యులను నింపుతుంది. పేతురు ప్రసంగిస్తాడు, హింసలు ఎదురైనప్పటికీ ప్రారంభ సంఘము ఎదుగుతుంది మరియు సౌలు మారుమనస్సు పొందుతాడు.",
    ),
    const ReadingDay(
      day: 24,
      titleEn: "Acts 13-28: Paul's Missionary Journeys",
      titleTe: "అపొస్తలుల కార్యములు 13-28: పౌలు మిషనరీ ప్రయాణాలు",
      versesEn: "Acts 13-28",
      versesTe: "అపొస్తలుల కార్యములు 13-28",
      summaryEn: "Paul spreads the Gospel throughout the Roman Empire, establishes churches, defends his faith before governors, and is imprisoned in Rome.",
      summaryTe: "పౌలు రోమన్ సామ్రాజ్యమంతటా సువార్తను వ్యాప్తి చేస్తాడు, సంఘాలను స్థాపిస్తాడు, అధికారుల ఎదుట తన విశ్వాసాన్ని సమర్థించుకుంటాడు మరియు రోములో ఖైదు చేయబడతాడు.",
    ),
    const ReadingDay(
      day: 25,
      titleEn: "Romans & Galatians: Justification by Faith",
      titleTe: "రోమీయులకు & గలతీయులకు: విశ్వాసం ద్వారా నీతిమంతులుగా తీర్చబడుట",
      versesEn: "Romans, Galatians",
      versesTe: "రోమీయులకు, గలతీయులకు",
      summaryEn: "Paul explains that righteousness comes not by works of the law, but through faith in Jesus Christ, bringing freedom and life in the Spirit.",
      summaryTe: "నీతి ధర్మశాస్త్ర క్రియల వల్ల కాకుండా, యేసుక్రీస్తునందలి విశ్వాసం ద్వారానే లభిస్తుందని, ఇది ఆత్మలో స్వేచ్ఛను, జీవాన్ని ఇస్తుందని పౌలు వివరిస్తాడు.",
    ),
    const ReadingDay(
      day: 26,
      titleEn: "1 & 2 Corinthians: Church Order and Ministry",
      titleTe: "1 & 2 కొరింథీయులకు: సంఘ క్రమము మరియు పరిచర్య",
      versesEn: "1 & 2 Corinthians",
      versesTe: "1 & 2 కొరింథీయులకు",
      summaryEn: "Paul corrects divisions, addresses spiritual gifts and love, defends his apostolic ministry, and teaches about Christ's reconciliation.",
      summaryTe: "పౌలు విభేదాలను సరిదిద్దుతాడు, ఆత్మ వరాల గురించి మరియు ప్రేమ గురించి మాట్లాడుతాడు, తన అపొస్తలత్వ పరిచర్యను సమర్థించుకుంటాడు మరియు క్రీస్తు సమాధానపరచుట గురించి బోధిస్తాడు.",
    ),
    const ReadingDay(
      day: 27,
      titleEn: "Ephesians through Philemon: Prison & Pastoral Epistles",
      titleTe: "ఎఫెసీయులకు నుండి ఫిలేమోను వరకు: బంధీగా వ్రాసిన పత్రికలు & పాస్టరల్ పత్రికలు",
      versesEn: "Ephesians-Philemon",
      versesTe: "ఎఫెసీయులకు-ఫిలేమోను",
      summaryEn: "Letters detailing the armor of God, joy in suffering, the supremacy of Christ, pastoral instructions to Timothy and Titus, and forgiveness for Philemon.",
      summaryTe: "దేవుడు ఇచ్చు సర్వాంగకవచము, శ్రమలలో ఆనందము, క్రీస్తు సార్వభౌమాధికారము, తిమోతి మరియు తీతులకు పాస్టరల్ ఉపదేశాలు మరియు ఫిలేమోనుకు క్షమాపణను వివరించే పత్రికలు.",
    ),
    const ReadingDay(
      day: 28,
      titleEn: "Hebrews & James: Superiority of Christ and Living Faith",
      titleTe: "హెబ్రీయులకు & యాకోబు: క్రీస్తు శ్రేష్ఠత మరియు జీవముగల విశ్వాసము",
      versesEn: "Hebrews, James",
      versesTe: "హెబ్రీయులకు, యాకోబు",
      summaryEn: "Hebrews shows Christ as superior to the old covenant priesthood. James teaches that true saving faith will always produce good works and righteous actions.",
      summaryTe: "హెబ్రీయుల పత్రిక క్రీస్తు పూర్వ నిబంధన యాజకత్వము కంటే శ్రేష్ఠుడని చూపిస్తుంది. నిజమైన రక్షణ విశ్వాసం ఎల్లప్పుడూ మంచి క్రియలను, నీతియుక్తమైన పనులను ఉత్పత్తి చేస్తుందని యాకోబు బోధిస్తాడు.",
    ),
    const ReadingDay(
      day: 29,
      titleEn: "1 Peter through Jude: Standing Firm & Staying Alert",
      titleTe: "1 పేతురు నుండి యూదా వరకు: స్థిరముగా నిలబడుట & మెలకువగా ఉండుట",
      versesEn: "1 Peter-Jude",
      versesTe: "1 పేతురు-యూదా",
      summaryEn: "Believers are exhorted to endure suffering, love one another, test the spirits, stand against false teachers, and build themselves up in holy faith.",
      summaryTe: "విశ్వాసులు శ్రమలను ఓర్చుకోవాలని, ఒకరినొకరు ప్రేమించుకోవాలని, ఆత్మలను పరీక్షించాలని, అబద్ధ బోధకులను ఎదిరించాలని మరియు పరిశుద్ధ విశ్వాసములో తమను తాము నిర్మించుకోవాలని హెచ్చరించబడుతున్నారు.",
    ),
    const ReadingDay(
      day: 30,
      titleEn: "Revelation: The Ultimate Triumph of Christ",
      titleTe: "ప్రకటన గ్రంథము: క్రీస్తు అంతిమ విజయం",
      versesEn: "Revelation 1-22",
      versesTe: "ప్రకటన గ్రంథము 1-22",
      summaryEn: "John records visions of Christ's sovereignty, cosmic warfare, judgment of evil, the new heaven and new earth, and the glorious return of the King.",
      summaryTe: "యోహాను క్రీస్తు సార్వభౌమాధికారం, విశ్వ సంగ్రామం, చెడుకు తీర్పు, నూతన ఆకాశము మరియు నూతన భూమి మరియు రాజు యొక్క మహిమకరమైన పునరాగమనం గురించిన దర్శనాలను నమోదు చేస్తాడు.",
    ),
  ];

  static final List<ReadingDay> _plan90Days = List.generate(90, (index) {
    final day = index + 1;
    String titleEn = '';
    String titleTe = '';
    String versesEn = '';
    String versesTe = '';
    String summaryEn = '';
    String summaryTe = '';

    if (day <= 10) {
      final startCh = (day - 1) * 2 + 1;
      final endCh = day * 2 <= 28 ? day * 2 : 28;
      titleEn = "Matthew $startCh-$endCh: Teachings of the King";
      titleTe = "మత్తయి $startCh-$endCh: రాజు యొక్క బోధనలు";
      versesEn = "Matthew $startCh-$endCh";
      versesTe = "మత్తయి $startCh-$endCh";
      summaryEn = "Read chapters $startCh to $endCh of Matthew. Focus on the kingdom of heaven, Christ's authority, parables, and His miracles.";
      summaryTe = "మత్తయి $startCh నుండి $endCh అధ్యాయాలు చదవండి. పరలోక రాజ్యము, క్రీస్తు అధికారము, ఉపమానాలు మరియు ఆయన అద్భుతాలపై దృష్టి పెట్టండి.";
    } else if (day <= 18) {
      final markDay = day - 10;
      final startCh = (markDay - 1) * 2 + 1;
      final endCh = markDay * 2 <= 16 ? markDay * 2 : 16;
      titleEn = "Mark $startCh-$endCh: Servant Son of God";
      titleTe = "మార్కు $startCh-$endCh: సేవకుడైన దేవుని కుమారుడు";
      versesEn = "Mark $startCh-$endCh";
      versesTe = "మార్కు $startCh-$endCh";
      summaryEn = "Read chapters $startCh to $endCh of Mark. Observe Jesus' active service, healings, authority over unclean spirits, and obedience.";
      summaryTe = "మార్కు $startCh నుండి $endCh అధ్యాయాలు చదవండి. యేసు యొక్క క్రియాశీల సేవ, స్వస్థతలు, అపవిత్రాత్మలపై ఆయనకున్న అధికారం మరియు అవిధేయతను గమనించండి.";
    } else if (day <= 34) {
      final lukeDay = day - 18;
      final startCh = (lukeDay - 1) * 2 + 1;
      final endCh = lukeDay * 2 <= 24 ? lukeDay * 2 : 24;
      titleEn = "Luke $startCh-$endCh: Compassionate Savior";
      titleTe = "లూకా $startCh-$endCh: కరుణామయుడైన రక్షకుడు";
      versesEn = "Luke $startCh-$endCh";
      versesTe = "లూకా $startCh-$endCh";
      summaryEn = "Read chapters $startCh to $endCh of Luke. Follow the parables of mercy, compassion for the outcast, and details of Jesus' ministry.";
      summaryTe = "లూకా $startCh నుండి $endCh అధ్యాయాలు చదవండి. దయాగుణము గల ఉపమానాలను, బహిష్కరించబడిన వారి పట్ల కరుణను మరియు యేసు పరిచర్య వివరాలను అనుసరించండి.";
    } else if (day <= 50) {
      final johnDay = day - 34;
      final startCh = (johnDay - 1) * 2 + 1;
      final endCh = johnDay * 2 <= 21 ? johnDay * 2 : 21;
      titleEn = "John $startCh-$endCh: The Word Made Flesh";
      titleTe = "యోహాను $startCh-$endCh: శరీరధారియైన వాక్యము";
      versesEn = "John $startCh-$endCh";
      versesTe = "యోహాను $startCh-$endCh";
      summaryEn = "Read chapters $startCh to $endCh of John. Contemplate the divinity of Jesus Christ, His 'I Am' statements, and spiritual revelations.";
      summaryTe = "యోహాను $startCh నుండి $endCh అధ్యాయాలు చదవండి. యేసుక్రీస్తు దైవత్వాన్ని, ఆయన 'నేనే' అనే ప్రకటనలను మరియు ఆత్మీయ సత్యాలను ధ్యానించండి.";
    } else if (day <= 60) {
      final actsDay = day - 50;
      final startCh = (actsDay - 1) * 2 + 1;
      final endCh = actsDay * 2 <= 28 ? actsDay * 2 : 28;
      titleEn = "Acts $startCh-$endCh: Power of the Spirit";
      titleTe = "అపొస్తలుల కార్యములు $startCh-$endCh: ఆత్మ యొక్క శక్తి";
      versesEn = "Acts $startCh-$endCh";
      versesTe = "అపొస్తలుల కార్యములు $startCh-$endCh";
      summaryEn = "Read chapters $startCh to $endCh of Acts. See the Holy Spirit spreading the gospel through the apostles, establishing early churches.";
      summaryTe = "అపొస్తలుల కార్యములు $startCh నుండి $endCh అధ్యాయాలు చదవండి. అపొస్తలుల ద్వారా పరిశుద్ధాత్మ సువార్తను వ్యాప్తి చేయడం, ప్రారంభ సంఘాలను స్థాపించడం చూడండి.";
    } else if (day <= 75) {
      final epDay = day - 60;
      final books = ["Romans", "1 Corinthians", "2 Corinthians"];
      final book = books[(epDay - 1) % 3];
      titleEn = "$book: Pauline Doctrine";
      titleTe = "$book: పౌలు సిద్ధాంతం";
      versesEn = "$book (Part)";
      versesTe = "$book (భాగము)";
      summaryEn = "Read selected chapters from $book. Reflect on grace, order, reconciliation, and Christian conduct in local churches.";
      summaryTe = "$book నుండి ఎంపిక చేసిన అధ్యాయాలు చదవండి. కృప, క్రమము, సమాధానపడడం మరియు స్థానిక సంఘాలలో క్రైస్తవ ప్రవర్తనను ధ్యానించండి.";
    } else if (day <= 85) {
      final epDay = day - 75;
      final books = ["Galatians", "Ephesians", "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians"];
      final book = books[(epDay - 1) % 6];
      titleEn = "$book: Prison & Church Letters";
      titleTe = "$book: బందీగా వ్రాసిన & సంఘ పత్రికలు";
      versesEn = "$book (Overview)";
      versesTe = "$book (అవలోకనం)";
      summaryEn = "Read $book. Focus on unity, spiritual armor, joy in trials, Christ's supremacy, and alerts on Christ's return.";
      summaryTe = "$book చదవండి. ఐక్యత, ఆత్మీయ సర్వాంగకవచము, శ్రమలలో ఆనందము, క్రీస్తు సార్వభౌమాధికారము మరియు క్రీస్తు రాకడ గురించిన హెచ్చరికలపై దృష్టి పెట్టండి.";
    } else {
      final epDay = day - 85;
      final books = ["Hebrews", "James", "1 & 2 Peter", "1-3 John & Jude", "Revelation"];
      final book = books[(epDay - 1) % 5];
      titleEn = "$book: Final Instructions";
      titleTe = "$book: ముగింపు ఉపదేశాలు";
      versesEn = "$book (Overview)";
      versesTe = "$book (అవలోకనం)";
      summaryEn = "Read $book. Reflect on the superiority of faith, holy endurance, warnings against false teachers, and final victory in Christ.";
      summaryTe = "$book చదవండి. విశ్వాసం యొక్క శ్రేష్ఠత, పరిశుద్ధ సహనము, అబద్ధ బోధకులకు వ్యతిరేకంగా హెచ్చరికలు మరియు క్రీస్తులో అంతిమ విజయం గురించి ధ్యానించండి.";
    }

    return ReadingDay(
      day: day,
      titleEn: titleEn,
      titleTe: titleTe,
      versesEn: versesEn,
      versesTe: versesTe,
      summaryEn: summaryEn,
      summaryTe: summaryTe,
    );
  });

  static final List<ReadingDay> _plan365Days = List.generate(365, (index) {
    final day = index + 1;
    String titleEn = '';
    String titleTe = '';
    String versesEn = '';
    String versesTe = '';
    String summaryEn = '';
    String summaryTe = '';

    if (day <= 50) {
      titleEn = "Pentateuch - Day $day";
      titleTe = "ధర్మశాస్త్ర గ్రంథాలు - రోజు $day";
      final chStart = (day - 1) * 3 + 1;
      versesEn = "Genesis/Deuteronomy (Chapters $chStart-${chStart + 2})";
      versesTe = "ఆదికాండము/ద్వితీయోపదేశకాండము ($chStart-${chStart + 2} అధ్యాయాలు)";
      summaryEn = "Read early foundations, covenant law, priestly rules, and wilderness census details.";
      summaryTe = "ప్రారంభ పునాదులు, నిబంధన ధర్మశాస్త్రం, యాజక నియమాలు మరియు అరణ్య జనాభా లెక్కల వివరాలు చదవండి.";
    } else if (day <= 75) {
      titleEn = "Historical Books - Day $day";
      titleTe = "చరిత్ర గ్రంథాలు - రోజు $day";
      final chStart = (day - 51) * 4 + 1;
      versesEn = "Joshua to 2 Kings (Part $chStart)";
      versesTe = "యెహోషువ నుండి 2 రాజులు (భాగము $chStart)";
      summaryEn = "Read the conquest of Canaan, judges cycle, rise of David, and split of Israel's kingdom.";
      summaryTe = "కనాను విజయం, న్యాయాధిపతుల చక్రం, దావీదు ఎదుగుదల మరియు ఇశ్రాయేలు రాజ్య విభజన చదవండి.";
    } else if (day <= 100) {
      titleEn = "Chronicles & Job - Day $day";
      titleTe = "దినవృత్తాంతములు & యోబు - రోజు $day";
      versesEn = "1 Chronicles to Job (Part)";
      versesTe = "1 దినవృత్తాంతములు నుండి యోబు (భాగము)";
      summaryEn = "Read temple preparations, reforms, and Job's integrity during suffering.";
      summaryTe = "దేవాలయ సన్నాహాలు, సంస్కరణలు మరియు శ్రమల సమయంలో యోబు యథార్థత చదవండి.";
    } else if (day <= 150) {
      final pDay = day - 100;
      titleEn = "Psalms - Day $day";
      titleTe = "కీర్తనలు - రోజు $day";
      versesEn = "Psalms ${(pDay - 1) * 3 + 1}-${pDay * 3}";
      versesTe = "కీర్తనలు ${(pDay - 1) * 3 + 1}-${pDay * 3}";
      summaryEn = "Read songs of David and other writers expressing trust, praise, and repentance.";
      summaryTe = "నమ్మకాన్ని, స్తుతిని మరియు పశ్చాత్తాపాన్ని వ్యక్తపరిచే దావీదు మరియు ఇతర రచయితల కీర్తనలు చదవండి.";
    } else if (day <= 175) {
      titleEn = "Wisdom & Poetry - Day $day";
      titleTe = "జ్ఞాన & కావ్య గ్రంథాలు - రోజు $day";
      versesEn = "Proverbs to Song of Solomon (Part)";
      versesTe = "సామెతలు నుండి పరమగీతము (భాగము)";
      summaryEn = "Read practical wisdom, reflections on vanity, and love poetry.";
      summaryTe = "ఆచరణాత్మక జ్ఞానము, వ్యర్థత గురించిన ఆలోచనలు మరియు ప్రేమ కావ్యాలు చదవండి.";
    } else if (day <= 220) {
      titleEn = "Major Prophets - Day $day";
      titleTe = "పెద్ద ప్రవక్తలు - రోజు $day";
      versesEn = "Isaiah to Daniel (Part)";
      versesTe = "యెషయా నుండి దానియేలు (భాగము)";
      summaryEn = "Read warnings to nations, prophecies of the serving Messiah, and apocalyptic visions.";
      summaryTe = "అన్యజనులకు హెచ్చరికలు, సేవ చేసే మెస్సీయ ప్రవచనాలు మరియు అంత్యకాల దర్శనాలు చదవండి.";
    } else if (day <= 240) {
      titleEn = "Minor Prophets - Day $day";
      titleTe = "చిన్న ప్రవక్తలు - రోజు $day";
      versesEn = "Hosea to Malachi (Part)";
      versesTe = "హోషేయ నుండి మలాకీ (భాగము)";
      summaryEn = "Read calls for justice, divine mercy, and declarations of the Day of the Lord.";
      summaryTe = "న్యాయము కొరకైన పిలుపులు, దైవిక కనికరం మరియు ప్రభువు దినము గురించిన ప్రకటనలు చదవండి.";
    } else if (day <= 280) {
      titleEn = "Gospels - Day $day";
      titleTe = "సువార్త గ్రంథాలు - రోజు $day";
      versesEn = "Matthew to John (Part)";
      versesTe = "మత్తయి నుండి యోహాను (భాగము)";
      summaryEn = "Read the life, teachings, death, and resurrection of Jesus Christ.";
      summaryTe = "యేసుక్రీస్తు జీవితం, బోధనలు, మరణం మరియు పునరుత్థానం చదవండి.";
    } else if (day <= 300) {
      titleEn = "Early Church - Day $day";
      titleTe = "ప్రారంభ సంఘము - రోజు $day";
      versesEn = "Acts (Part)";
      versesTe = "అపొస్తలుల కార్యములు (భాగము)";
      summaryEn = "Read about the Holy Spirit's descent and Paul's missionary travels.";
      summaryTe = "పరిశుద్ధాత్మ దిగిరావడం మరియు పౌలు మిషనరీ ప్రయాణాల గురించి చదవండి.";
    } else if (day <= 330) {
      titleEn = "Paul's Epistles - Day $day";
      titleTe = "పౌలు పత్రికలు - రోజు $day";
      versesEn = "Romans to Philemon (Part)";
      versesTe = "రోమీయులకు నుండి ఫిలేమోను వరకు (భాగము)";
      summaryEn = "Read doctrine of justification by faith, church order, and pastoral letters.";
      summaryTe = "విశ్వాసం ద్వారా నీతిమంతులుగా తీర్చబడుట, సంఘ క్రమము మరియు పాస్టరల్ పత్రికలు చదవండి.";
    } else if (day <= 355) {
      titleEn = "General Epistles - Day $day";
      titleTe = "సాధారణ పత్రికలు - రోజు $day";
      versesEn = "Hebrews to Jude (Part)";
      versesTe = "హెబ్రీయులకు నుండి యూదా వరకు (భాగము)";
      summaryEn = "Read about the superior priesthood of Christ, living faith, and warnings against apostasy.";
      summaryTe = "క్రీస్తు శ్రేష్ఠమైన యాజకత్వం, జీవముగల విశ్వాసం మరియు ద్రోహానికి వ్యతిరేకంగా హెచ్చరికలు చదవండి.";
    } else {
      titleEn = "Revelation - Day $day";
      titleTe = "ప్రకటన గ్రంథము - రోజు $day";
      versesEn = "Revelation (Part)";
      versesTe = "ప్రకటన గ్రంథము (భాగము)";
      summaryEn = "Read John's prophetic visions of the end times and new creation.";
      summaryTe = "అంత్యకాలము మరియు నూతన సృష్టి గురించిన యోహాను ప్రవచన దర్శనాలు చదవండి.";
    }

    return ReadingDay(
      day: day,
      titleEn: titleEn,
      titleTe: titleTe,
      versesEn: versesEn,
      versesTe: versesTe,
      summaryEn: summaryEn,
      summaryTe: summaryTe,
    );
  });
}
