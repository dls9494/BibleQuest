#!/usr/bin/env python3
import json
import os

def get_level_info(level):
    if 1 <= level <= 10:
        return "Genesis", "Genesis", "ఆదికాండము"
    elif 11 <= level <= 20:
        return "Exodus & Law", "Exodus", "నిర్గమకాండము"
    elif 21 <= level <= 30:
        return "Historical Books", "Joshua", "యెహోషువ"
    elif 31 <= level <= 40:
        return "Wisdom & Poetry", "Psalms", "కీర్తనలు"
    elif 41 <= level <= 50:
        return "Major Prophets", "Isaiah", "యెషయా"
    elif 51 <= level <= 60:
        return "Minor Prophets", "Hosea", "హోషేయ"
    elif 61 <= level <= 70:
        return "Gospels - Life of Jesus", "Matthew", "మత్తయి"
    elif 71 <= level <= 80:
        return "Gospels - Passion & Resurrection", "John", "యోహాను"
    elif 81 <= level <= 90:
        return "Acts & Early Church", "Acts", "అపొస్తలుల కార్యములు"
    elif 91 <= level <= 100:
        return "Epistles & Revelation", "Revelation", "ప్రకటన గ్రంథము"
    return "Bible Knowledge", "Genesis", "ఆదికాండము"

def main():
    levels = {}

    # Define Level 1 Questions (Genesis Chapters 1-11)
    levels["1"] = {
        "A": [
            {
                "id": "level_1_q1_A",
                "order": 1,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "What did God create on the first day?",
                "questionTe": "దేవుడు మొదటి రోజున ఏమి సృష్టించాడు?",
                "options": [
                    {"id": "level_1_q1_A_opt1", "order": 1, "isCorrect": True, "textEn": "Light", "textTe": "వెలుగు"},
                    {"id": "level_1_q1_A_opt2", "order": 2, "isCorrect": False, "textEn": "Sky", "textTe": "ఆకాశము"},
                    {"id": "level_1_q1_A_opt3", "order": 3, "isCorrect": False, "textEn": "Dry land", "textTe": "పొడి నేల"},
                    {"id": "level_1_q1_A_opt4", "order": 4, "isCorrect": False, "textEn": "Plants", "textTe": "మొక్కలు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 1:3",
                "verseReferenceTe": "ఆదికాండము 1:3",
                "explanationEn": "God created light on the first day.",
                "explanationTe": "దేవుడు మొదటి రోజున వెలుగును సృష్టించాడు."
            },
            {
                "id": "level_1_q2_A",
                "order": 2,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "Who was Adam's wife, created to be his helper?",
                "questionTe": "ఆదాముకు సహాయకారిగా సృష్టించబడిన అతని భార్య ఎవరు?",
                "options": [
                    {"id": "level_1_q2_A_opt1", "order": 1, "isCorrect": True, "textEn": "Eve", "textTe": "హవ్వ"},
                    {"id": "level_1_q2_A_opt2", "order": 2, "isCorrect": False, "textEn": "Sarah", "textTe": "శారమ్మ"},
                    {"id": "level_1_q2_A_opt3", "order": 3, "isCorrect": False, "textEn": "Rebekah", "textTe": "రిబ్కా"},
                    {"id": "level_1_q2_A_opt4", "order": 4, "isCorrect": False, "textEn": "Rachel", "textTe": "రాహేలు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 2:22",
                "verseReferenceTe": "ఆదికాండము 2:22",
                "explanationEn": "God made Eve from Adam's rib.",
                "explanationTe": "దేవుడు ఆదాము పక్కటెముక నుండి హవ్వను చేసెను."
            },
            {
                "id": "level_1_q3_A",
                "order": 3,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "Which tree's fruit did God command Adam not to eat?",
                "questionTe": "ఏ వృక్ష ఫలమును తినవద్దని దేవుడు ఆదామును ఆజ్ఞాపించాడు?",
                "options": [
                    {"id": "level_1_q3_A_opt1", "order": 1, "isCorrect": True, "textEn": "Tree of Knowledge of Good and Evil", "textTe": "మంచి చెడ్డల తెలివినిచ్చు వృక్షము"},
                    {"id": "level_1_q3_A_opt2", "order": 2, "isCorrect": False, "textEn": "Tree of Life", "textTe": "జీవ వృక్షము"},
                    {"id": "level_1_q3_A_opt3", "order": 3, "isCorrect": False, "textEn": "Tree of Wisdom", "textTe": "జ్ఞాన వృక్షము"},
                    {"id": "level_1_q3_A_opt4", "order": 4, "isCorrect": False, "textEn": "Tree of Truth", "textTe": "సత్య వృక్షము"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 2:17",
                "verseReferenceTe": "ఆదికాండము 2:17",
                "explanationEn": "God forbade eating from the tree of knowledge of good and evil.",
                "explanationTe": "మంచి చెడ్డల తెలివినిచ్చు వృక్ష ఫలమును తినవద్దని దేవుడు నిషేధించాడు."
            },
            {
                "id": "level_1_q4_A",
                "order": 4,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "Who killed his brother Abel out of jealousy?",
                "questionTe": "అసూయతో తన తమ్ముడైన హేబెలును చంపింది ఎవరు?",
                "options": [
                    {"id": "level_1_q4_A_opt1", "order": 1, "isCorrect": True, "textEn": "Cain", "textTe": "కయీను"},
                    {"id": "level_1_q4_A_opt2", "order": 2, "isCorrect": False, "textEn": "Seth", "textTe": "షేతు"},
                    {"id": "level_1_q4_A_opt3", "order": 3, "isCorrect": False, "textEn": "Lamech", "textTe": "లామెకు"},
                    {"id": "level_1_q4_A_opt4", "order": 4, "isCorrect": False, "textEn": "Enoch", "textTe": "హనోకు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 4:8",
                "verseReferenceTe": "ఆదికాండము 4:8",
                "explanationEn": "Cain killed Abel, committing the first murder.",
                "explanationTe": "కయీను హేబెలును చంపి, మొదటి నరహత్య చేశాడు."
            },
            {
                "id": "level_1_q5_A",
                "order": 5,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "How many of each clean animal did God command Noah to take into the ark?",
                "questionTe": "పవిత్రమైన జంతువులలో ప్రతిదానిని ఎన్ని చొప్పున ఓడలోనికి తీసుకొనిపొమ్మని దేవుడు నోవహుకు ఆజ్ఞాపించాడు?",
                "options": [
                    {"id": "level_1_q5_A_opt1", "order": 1, "isCorrect": True, "textEn": "Seven pairs", "textTe": "ఏడేసి జతలు"},
                    {"id": "level_1_q5_A_opt2", "order": 2, "isCorrect": False, "textEn": "Two pairs", "textTe": "రెండేసి జతలు"},
                    {"id": "level_1_q5_A_opt3", "order": 3, "isCorrect": False, "textEn": "One pair", "textTe": "ఒక జత"},
                    {"id": "level_1_q5_A_opt4", "order": 4, "isCorrect": False, "textEn": "Twelve pairs", "textTe": "పన్నెండేసి జతలు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 7:2",
                "verseReferenceTe": "ఆదికాండము 7:2",
                "explanationEn": "God commanded to take seven pairs of clean animals.",
                "explanationTe": "పవిత్ర జంతువులలో ఏడేసి జతలను తీసుకొనిపొమ్మని దేవుడు ఆజ్ఞాపించాడు."
            },
            {
                "id": "level_1_q6_A",
                "order": 6,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "What sign did God give to show that He would never destroy the earth with a flood again?",
                "questionTe": "మళ్లీ ఎన్నడూ భూమిని జలప్రళయంతో నాశనం చేయనని నిబంధనకు దేవుడు ఇచ్చిన గుర్తు ఏమిటి?",
                "options": [
                    {"id": "level_1_q6_A_opt1", "order": 1, "isCorrect": True, "textEn": "Rainbow", "textTe": "మేఘధనుస్సు"},
                    {"id": "level_1_q6_A_opt2", "order": 2, "isCorrect": False, "textEn": "Pillar of cloud", "textTe": "మేఘస్తంభము"},
                    {"id": "level_1_q6_A_opt3", "order": 3, "isCorrect": False, "textEn": "Burning bush", "textTe": "పొద రగులుట"},
                    {"id": "level_1_q6_A_opt4", "order": 4, "isCorrect": False, "textEn": "Dove with olive leaf", "textTe": "ఒలీవ ఆకు పట్టుకున్న పావురం"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 9:13",
                "verseReferenceTe": "ఆదికాండము 9:13",
                "explanationEn": "God set the rainbow in the cloud as a sign.",
                "explanationTe": "నిబంధనకు సూచనగా దేవుడు మేఘములో ధనుస్సును ఉంచాడు."
            },
            {
                "id": "level_1_q7_A",
                "order": 7,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1010,
                "questionEn": "Methuselah lived for 969 years before he died.",
                "questionTe": "మెతూషెలా మరణించే ముందు 969 సంవత్సరాలు జీవించాడు.",
                "options": [],
                "correctAnswerEn": "True",
                "correctAnswerTe": "నిజం",
                "verseReferenceEn": "Genesis 5:27",
                "verseReferenceTe": "ఆదికాండము 5:27",
                "explanationEn": "Methuselah is the oldest recorded person in the Bible.",
                "explanationTe": "బైబిలులో అత్యంత ఎక్కువ వయస్సు జీవించిన వ్యక్తి మెతూషెలా."
            },
            {
                "id": "level_1_q8_A",
                "order": 8,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1010,
                "questionEn": "Cain was a keeper of sheep, and Abel was a tiller of the ground.",
                "questionTe": "కయీను గొర్రెల కాపరి, మరియు హేబెలు భూమిని సేద్యపరచువాడు.",
                "options": [],
                "correctAnswerEn": "False",
                "correctAnswerTe": "తప్పు",
                "verseReferenceEn": "Genesis 4:2",
                "verseReferenceTe": "ఆదికాండము 4:2",
                "explanationEn": "Abel was a keeper of sheep, and Cain was a tiller of the ground.",
                "explanationTe": "హేబెలు గొర్రెల కాపరి, కయీను భూమిని సేద్యపరచువాడు."
            },
            {
                "id": "level_1_q9_A",
                "order": 9,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1010,
                "questionEn": "What was the name of the garden where Adam and Eve lived?",
                "questionTe": "ఆదాము హవ్వలు నివసించిన తోట పేరు ఏమిటి?",
                "options": [],
                "correctAnswerEn": "Eden",
                "correctAnswerTe": "ఏదేను",
                "verseReferenceEn": "Genesis 2:15",
                "verseReferenceTe": "ఆదికాండము 2:15",
                "explanationEn": "God placed man in the Garden of Eden.",
                "explanationTe": "దేవుడు నరుని ఏదెను తోటలో ఉంచెను."
            },
            {
                "id": "level_1_q10_A",
                "order": 10,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1010,
                "questionEn": "What city was the tower built in to reach the sky?",
                "questionTe": "ఆకాశమును తాకే గోపురమును ఏ నగరములో నిర్మించారు?",
                "options": [],
                "correctAnswerEn": "Babel",
                "correctAnswerTe": "బాబెలు",
                "verseReferenceEn": "Genesis 11:9",
                "verseReferenceTe": "ఆదికాండము 11:9",
                "explanationEn": "The tower was built at Babel, where God confused languages.",
                "explanationTe": "గోపురము బాబెలు వద్ద నిర్మించబడింది, అక్కడ దేవుడు భాషలను తారుమారు చేశాడు."
            },
            {
                "id": "level_1_q11_A",
                "order": 11,
                "type": "mixed_format",
                "timeLimitSeconds": 45,
                "points": 1010,
                "questionEn": "What was the name of Noah's three sons?",
                "questionTe": "నోవహు ముగ్గురు కుమారుల పేర్లు ఏమిటి?",
                "options": [
                    {"id": "level_1_q11_A_opt1", "order": 1, "isCorrect": True, "textEn": "Shem, Ham, Japheth", "textTe": "షేము, హాము, యాపెతు"},
                    {"id": "level_1_q11_A_opt2", "order": 2, "isCorrect": False, "textEn": "Cain, Abel, Seth", "textTe": "కయీను, హేబెలు, షేతు"},
                    {"id": "level_1_q11_A_opt3", "order": 3, "isCorrect": False, "textEn": "Abraham, Isaac, Jacob", "textTe": "ఆబ్రాహాము, ఇస్సాకు, యాకోబు"},
                    {"id": "level_1_q11_A_opt4", "order": 4, "isCorrect": False, "textEn": "Reuben, Simeon, Levi", "textTe": "రూబేను, షిమ్యోను, లేవి"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 5:32",
                "verseReferenceTe": "ఆదికాండము 5:32",
                "explanationEn": "Noah's sons were Shem, Ham, and Japheth.",
                "explanationTe": "నోవహు కుమారులు షేము, హాము, యాపెతు."
            },
            {
                "id": "level_1_q12_A",
                "order": 12,
                "type": "skills_application",
                "timeLimitSeconds": 60,
                "points": 1010,
                "questionEn": "According to Genesis 6, what type of wood did Noah use to build the ark?",
                "questionTe": "ఆదికాండము 6 ప్రకారం, ఓడను నిర్మించడానికి నోవహు ఏ కర్రను ఉపయోగించాడు?",
                "options": [],
                "correctAnswerEn": "Gopher",
                "correctAnswerTe": "గోఫెరు",
                "verseReferenceEn": "Genesis 6:14",
                "verseReferenceTe": "ఆదికాండము 6:14",
                "explanationEn": "God commanded Noah to make the ark of gopher wood.",
                "explanationTe": "గోఫెరు కర్రతో ఓడను చేసుకొనవలెనని దేవుడు ఆజ్ఞాపించాడు."
            }
        ],
        "B": [
            {
                "id": "level_1_q1_B",
                "order": 1,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "What did God create on the second day?",
                "questionTe": "దేవుడు రెండవ రోజున ఏమి సృష్టించాడు?",
                "options": [
                    {"id": "level_1_q1_B_opt1", "order": 1, "isCorrect": True, "textEn": "Firmament (Sky)", "textTe": "ఆకాశము"},
                    {"id": "level_1_q1_B_opt2", "order": 2, "isCorrect": False, "textEn": "Light", "textTe": "వెలుగు"},
                    {"id": "level_1_q1_B_opt3", "order": 3, "isCorrect": False, "textEn": "Dry land", "textTe": "పొడి నేల"},
                    {"id": "level_1_q1_B_opt4", "order": 4, "isCorrect": False, "textEn": "Sun and moon", "textTe": "సూర్య చంద్రులు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 1:7-8",
                "verseReferenceTe": "ఆదికాండము 1:7-8",
                "explanationEn": "God created the sky on the second day.",
                "explanationTe": "దేవుడు రెండవ రోజున ఆకాశమును సృష్టించాడు."
            },
            {
                "id": "level_1_q2_B",
                "order": 2,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "How did God create Adam?",
                "questionTe": "దేవుడు ఆదామును ఎలా సృష్టించాడు?",
                "options": [
                    {"id": "level_1_q2_B_opt1", "order": 1, "isCorrect": True, "textEn": "From the dust of the ground", "textTe": "నేల మంటి నుండి"},
                    {"id": "level_1_q2_B_opt2", "order": 2, "isCorrect": False, "textEn": "From a rib of Eve", "textTe": "హవ్వ పక్కటెముక నుండి"},
                    {"id": "level_1_q2_B_opt3", "order": 3, "isCorrect": False, "textEn": "By speaking him into existence", "textTe": "మాట సెలవిచ్చి"},
                    {"id": "level_1_q2_B_opt4", "order": 4, "isCorrect": False, "textEn": "From water and mud", "textTe": "నీరు మరియు బురద నుండి"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 2:7",
                "verseReferenceTe": "ఆదికాండము 2:7",
                "explanationEn": "God formed Adam from the dust of the ground.",
                "explanationTe": "దేవుడు నేల మంటితో ఆదామును నిర్మించెను."
            },
            {
                "id": "level_1_q3_B",
                "order": 3,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "What did the serpent tell Eve she would become if she ate the forbidden fruit?",
                "questionTe": "నిషేధించబడిన ఫలమును తింటే తాము ఎలా అవుతామని సర్పము హవ్వతో చెప్పింది?",
                "options": [
                    {"id": "level_1_q3_B_opt1", "order": 1, "isCorrect": True, "textEn": "Like God, knowing good and evil", "textTe": "దేవతలవలె మంచిచెడ్డలను ఎరిగినవారవుతారు"},
                    {"id": "level_1_q3_B_opt2", "order": 2, "isCorrect": False, "textEn": "Immortal beings", "textTe": "మరణము లేనివారు"},
                    {"id": "level_1_q3_B_opt3", "order": 3, "isCorrect": False, "textEn": "Rulers of Eden", "textTe": "ఏదెను పాలకులు"},
                    {"id": "level_1_q3_B_opt4", "order": 4, "isCorrect": False, "textEn": "Angels of light", "textTe": "వెలుగు దూతలు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 3:5",
                "verseReferenceTe": "ఆదికాండము 3:5",
                "explanationEn": "The serpent deceived Eve by promising godlike knowledge.",
                "explanationTe": "సర్పము హవ్వతో మీరు దేవతలవలె అవుతారని చెప్పి మోసగించింది."
            },
            {
                "id": "level_1_q4_B",
                "order": 4,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "Who was the father of Methuselah, who walked with God and was taken by Him?",
                "questionTe": "దేవునితో నడిచి, దేవునిచే కొనిపోబడిన మెతూషెలా తండ్రి ఎవరు?",
                "options": [
                    {"id": "level_1_q4_B_opt1", "order": 1, "isCorrect": True, "textEn": "Enoch", "textTe": "హనోకు"},
                    {"id": "level_1_q4_B_opt2", "order": 2, "isCorrect": False, "textEn": "Jared", "textTe": "యెరెదు"},
                    {"id": "level_1_q4_B_opt3", "order": 3, "isCorrect": False, "textEn": "Lamech", "textTe": "లామెకు"},
                    {"id": "level_1_q4_B_opt4", "order": 4, "isCorrect": False, "textEn": "Noah", "textTe": "నోవహు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 5:21-24",
                "verseReferenceTe": "ఆదికాండము 5:21-24",
                "explanationEn": "Enoch was the father of Methuselah and was translated to heaven.",
                "explanationTe": "హనోకు మెతూషెలా తండ్రి, దేవుడతనిని పరలోకమునకు తీసుకొనిపోయెను."
            },
            {
                "id": "level_1_q5_B",
                "order": 5,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "What was the length of Noah's ark in cubits?",
                "questionTe": "నోవహు ఓడ పొడవు ఎన్ని మూరలు?",
                "options": [
                    {"id": "level_1_q5_B_opt1", "order": 1, "isCorrect": True, "textEn": "300 cubits", "textTe": "300 మూరలు"},
                    {"id": "level_1_q5_B_opt2", "order": 2, "isCorrect": False, "textEn": "150 cubits", "textTe": "150 మూరలు"},
                    {"id": "level_1_q5_B_opt3", "order": 3, "isCorrect": False, "textEn": "50 cubits", "textTe": "50 మూరలు"},
                    {"id": "level_1_q5_B_opt4", "order": 4, "isCorrect": False, "textEn": "500 cubits", "textTe": "500 మూరలు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 6:15",
                "verseReferenceTe": "ఆదికాండము 6:15",
                "explanationEn": "The length of the ark was 300 cubits.",
                "explanationTe": "ఓడ పొడవు 300 మూరలు."
            },
            {
                "id": "level_1_q6_B",
                "order": 6,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "What bird did Noah send out of the ark second, which returned with an olive leaf?",
                "questionTe": "నోవహు ఓడ నుండి రెండవసారి పంపిన ఏ పక్షి ఒలీవ ఆకుతో తిరిగి వచ్చింది?",
                "options": [
                    {"id": "level_1_q6_B_opt1", "order": 1, "isCorrect": True, "textEn": "Dove", "textTe": "పావురము"},
                    {"id": "level_1_q6_B_opt2", "order": 2, "isCorrect": False, "textEn": "Raven", "textTe": "కాకి"},
                    {"id": "level_1_q6_B_opt3", "order": 3, "isCorrect": False, "textEn": "Eagle", "textTe": "డేగ"},
                    {"id": "level_1_q6_B_opt4", "order": 4, "isCorrect": False, "textEn": "Sparrow", "textTe": "పిచ్చుక"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 8:10-11",
                "verseReferenceTe": "ఆదికాండము 8:10-11",
                "explanationEn": "The dove returned with an olive leaf.",
                "explanationTe": "పావురము ఒలీవ ఆకు పట్టుకొని తిరిగి వచ్చింది."
            },
            {
                "id": "level_1_q7_B",
                "order": 7,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1010,
                "questionEn": "Eve was tempted by the serpent while she was alone.",
                "questionTe": "హవ్వ ఒంటరిగా ఉన్నప్పుడు సర్పము చేత శోధించబడింది.",
                "options": [],
                "correctAnswerEn": "True",
                "correctAnswerTe": "నిజం",
                "verseReferenceEn": "Genesis 3:1-6",
                "verseReferenceTe": "ఆదికాండము 3:1-6",
                "explanationEn": "The serpent spoke to Eve alone before Adam partook.",
                "explanationTe": "ఆదాముతో కాకుండా సర్పము హవ్వతో ఒంటరిగా ఉన్నప్పుడు మాట్లాడెను."
            },
            {
                "id": "level_1_q8_B",
                "order": 8,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1010,
                "questionEn": "Noah's Ark rested on the mountains of Sinai.",
                "questionTe": "నోవహు ఓడ సీనాయి పర్వతాలపై నిలిచింది.",
                "options": [],
                "correctAnswerEn": "False",
                "correctAnswerTe": "తప్పు",
                "verseReferenceEn": "Genesis 8:4",
                "verseReferenceTe": "ఆదికాండము 8:4",
                "explanationEn": "The Ark rested on the mountains of Ararat.",
                "explanationTe": "నోవహు ఓడ అరరాతు పర్వతములపై నిలిచింది."
            },
            {
                "id": "level_1_q9_B",
                "order": 9,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1010,
                "questionEn": "Who was the third son of Adam and Eve, born after Abel's death?",
                "questionTe": "హేబెలు మరణం తర్వాత జన్మించిన ఆదాము హవ్వల మూడవ కుమారుడి పేరు ఏమిటి?",
                "options": [],
                "correctAnswerEn": "Seth",
                "correctAnswerTe": "షేతు",
                "verseReferenceEn": "Genesis 4:25",
                "verseReferenceTe": "ఆదికాండము 4:25",
                "explanationEn": "Seth was born after Abel's death to continue the godly line.",
                "explanationTe": "హేబెలు మరణం తరువాత దేవుడు ఆదాము హవ్వలకు షేతును ఇచ్చెను."
            },
            {
                "id": "level_1_q10_B",
                "order": 10,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1010,
                "questionEn": "What did Noah build to the Lord immediately after leaving the Ark?",
                "questionTe": "ఓడ నుండి దిగిన వెంటనే నోవహు యెహోవాకు ఏమి నిర్మించాడు?",
                "options": [],
                "correctAnswerEn": "Altar",
                "correctAnswerTe": "బలిపీఠము",
                "verseReferenceEn": "Genesis 8:20",
                "verseReferenceTe": "ఆదికాండము 8:20",
                "explanationEn": "Noah built an altar to offer clean animal sacrifices.",
                "explanationTe": "నోవహు యెహోవా నామమున ఒక బలిపీఠము నిర్మించెను."
            },
            {
                "id": "level_1_q11_B",
                "order": 11,
                "type": "mixed_format",
                "timeLimitSeconds": 45,
                "points": 1010,
                "questionEn": "Which of these was NOT one of Noah's sons?",
                "questionTe": "వీరిలో నోవహు కుమారుడు కానిది ఎవరు?",
                "options": [
                    {"id": "level_1_q11_B_opt1", "order": 1, "isCorrect": True, "textEn": "Lot", "textTe": "లోతు"},
                    {"id": "level_1_q11_B_opt2", "order": 2, "isCorrect": False, "textEn": "Shem", "textTe": "షేము"},
                    {"id": "level_1_q11_B_opt3", "order": 3, "isCorrect": False, "textEn": "Ham", "textTe": "హాము"},
                    {"id": "level_1_q11_B_opt4", "order": 4, "isCorrect": False, "textEn": "Japheth", "textTe": "యాపెతు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 5:32",
                "verseReferenceTe": "ఆదికాండము 5:32",
                "explanationEn": "Lot was Abraham's nephew, not Noah's son.",
                "explanationTe": "లోతు అబ్రాహాము సహోదరుని కుమారుడు, నోవహు కుమారుడు కాడు."
            },
            {
                "id": "level_1_q12_B",
                "order": 12,
                "type": "skills_application",
                "timeLimitSeconds": 60,
                "points": 1010,
                "questionEn": "What was the name of the first city built by Cain, named after his son?",
                "questionTe": "కయీను నిర్మించిన మొదటి పట్టణం పేరు ఏమిటి, దానికి తన కుమారుని పేరు పెట్టాడు?",
                "options": [],
                "correctAnswerEn": "Enoch",
                "correctAnswerTe": "హనోకు",
                "verseReferenceEn": "Genesis 4:17",
                "verseReferenceTe": "ఆదికాండము 4:17",
                "explanationEn": "Cain built a city and called it Enoch after his son.",
                "explanationTe": "కయీను ఒక పట్టణము కట్టి దానికి తన కుమారుడైన హనోకు పేరు పెట్టెను."
            }
        ],
        "C": [
            {
                "id": "level_1_q1_C",
                "order": 1,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "What did God create on the third day?",
                "questionTe": "దేవుడు మూడవ రోజున ఏమి సృష్టించాడు?",
                "options": [
                    {"id": "level_1_q1_C_opt1", "order": 1, "isCorrect": True, "textEn": "Dry land and vegetation", "textTe": "పొడి నేల మరియు వృక్షములు"},
                    {"id": "level_1_q1_C_opt2", "order": 2, "isCorrect": False, "textEn": "Sun, moon, and stars", "textTe": "సూర్యుడు, చంద్రుడు మరియు నక్షత్రాలు"},
                    {"id": "level_1_q1_C_opt3", "order": 3, "isCorrect": False, "textEn": "Birds and sea creatures", "textTe": "పక్షులు మరియు జలచరాలు"},
                    {"id": "level_1_q1_C_opt4", "order": 4, "isCorrect": False, "textEn": "Land animals and man", "textTe": "భూజంతువులు మరియు నరుడు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 1:9-13",
                "verseReferenceTe": "ఆదికాండము 1:9-13",
                "explanationEn": "God gathered the waters, created dry land, and grass on the third day.",
                "explanationTe": "దేవుడు మూడవ రోజున పొడి నేలను మరియు వృక్షములను కలుగజేసెను."
            },
            {
                "id": "level_1_q2_C",
                "order": 2,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "Which rivers dividing out of Eden are mentioned in Genesis?",
                "questionTe": "తోటను తడుపుటకు ఏదెను నుండి ప్రవహించి, నాలుగు పాయలుగా విడిపోయిన నదులలో భాగమైనవి ఏవి?",
                "options": [
                    {"id": "level_1_q2_C_opt1", "order": 1, "isCorrect": True, "textEn": "Pishon, Gihon, Tigris, Euphrates", "textTe": "పిషోను, గిహోను, హిద్దెకెలు, యూఫ్రటీసు"},
                    {"id": "level_1_q2_C_opt2", "order": 2, "isCorrect": False, "textEn": "Jordan and Nile", "textTe": "యోర్దాను మరియు నైలు నది"},
                    {"id": "level_1_q2_C_opt3", "order": 3, "isCorrect": False, "textEn": "Kishon and Tigris", "textTe": "కీషోను మరియు హిద్దెకెలు"},
                    {"id": "level_1_q2_C_opt4", "order": 4, "isCorrect": False, "textEn": "Abana and Pharpar", "textTe": "అబానా మరియు ఫర్పారు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 2:10-14",
                "verseReferenceTe": "ఆదికాండము 2:10-14",
                "explanationEn": "A river went out of Eden and parted into four heads.",
                "explanationTe": "ఏదెనులో నుండి ఒక నది బయలుదేరి నాలుగు నదులుగా ఆయెను."
            },
            {
                "id": "level_1_q3_C",
                "order": 3,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "What punishment did God give to the serpent?",
                "questionTe": "దేవుడు సర్పమునకు ఇచ్చిన శిక్ష ఏమిటి?",
                "options": [
                    {"id": "level_1_q3_C_opt1", "order": 1, "isCorrect": True, "textEn": "To crawl on its belly and eat dust", "textTe": "కడుపుతో నడుచుచు మన్ను తినుట"},
                    {"id": "level_1_q3_C_opt2", "order": 2, "isCorrect": False, "textEn": "To be cast out of the earth", "textTe": "భూమి నుండి వెలివేయబడుట"},
                    {"id": "level_1_q3_C_opt3", "order": 3, "isCorrect": False, "textEn": "To lose its voice forever", "textTe": "దాని స్వరాన్ని కోల్పోవుట"},
                    {"id": "level_1_q3_C_opt4", "order": 4, "isCorrect": False, "textEn": "To be destroyed by fire", "textTe": "అగ్ని చేత నశించుట"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 3:14",
                "verseReferenceTe": "ఆదికాండము 3:14",
                "explanationEn": "The serpent was cursed to crawl on its belly and eat dust.",
                "explanationTe": "నీవు నీ కడుపుతో నడుచుచు నీవు బ్రతుకు దినములన్నియు మన్ను తిందువు అని సర్పము శపించబడింది."
            },
            {
                "id": "level_1_q4_C",
                "order": 4,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "Who was the father of Noah?",
                "questionTe": "నోవహు తండ్రి ఎవరు?",
                "options": [
                    {"id": "level_1_q4_C_opt1", "order": 1, "isCorrect": True, "textEn": "Lamech", "textTe": "లామెకు"},
                    {"id": "level_1_q4_C_opt2", "order": 2, "isCorrect": False, "textEn": "Methuselah", "textTe": "మెతూషెలా"},
                    {"id": "level_1_q4_C_opt3", "order": 3, "isCorrect": False, "textEn": "Enoch", "textTe": "హనోకు"},
                    {"id": "level_1_q4_C_opt4", "order": 4, "isCorrect": False, "textEn": "Jared", "textTe": "యెరెదు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 5:28-29",
                "verseReferenceTe": "ఆదికాండము 5:28-29",
                "explanationEn": "Lamech was the father of Noah and named him hoping for rest.",
                "explanationTe": "లామెకు కుమారుని కని అతనికి నోవహు అని పేరు పెట్టెను."
            },
            {
                "id": "level_1_q5_C",
                "order": 5,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "How old was Noah when the floodwaters came upon the earth?",
                "questionTe": "భూమిమీదకు జలప్రళయం వచ్చినప్పుడు నోవహు వయస్సు ఎంత?",
                "options": [
                    {"id": "level_1_q5_C_opt1", "order": 1, "isCorrect": True, "textEn": "600 years old", "textTe": "600 సంవత్సరాలు"},
                    {"id": "level_1_q5_C_opt2", "order": 2, "isCorrect": False, "textEn": "500 years old", "textTe": "500 సంవత్సరాలు"},
                    {"id": "level_1_q5_C_opt3", "order": 3, "isCorrect": False, "textEn": "950 years old", "textTe": "950 సంవత్సరాలు"},
                    {"id": "level_1_q5_C_opt4", "order": 4, "isCorrect": False, "textEn": "120 years old", "textTe": "120 సంవత్సరాలు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 7:6",
                "verseReferenceTe": "ఆదికాండము 7:6",
                "explanationEn": "Noah was 600 years old when the flood occurred.",
                "explanationTe": "జలప్రళయము భూమిమీదకు వచ్చినప్పుడు నోవహు ఆరువందల సంవత్సరముల వాడు."
            },
            {
                "id": "level_1_q6_C",
                "order": 6,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1010,
                "questionEn": "What did the people of Babel want to make for themselves?",
                "questionTe": "బాబెలు ప్రజలు తమ కొరకు ఏమి సంపాదించుకోవాలనుకున్నారు?",
                "options": [
                    {"id": "level_1_q6_C_opt1", "order": 1, "isCorrect": True, "textEn": "A name (reputation)", "textTe": "ఒక నామము (కీర్తి)"},
                    {"id": "level_1_q6_C_opt2", "order": 2, "isCorrect": False, "textEn": "Great wealth", "textTe": "గొప్ప సంపద"},
                    {"id": "level_1_q6_C_opt3", "order": 3, "isCorrect": False, "textEn": "An army", "textTe": "ఒక సైన్యము"},
                    {"id": "level_1_q6_C_opt4", "order": 4, "isCorrect": False, "textEn": "A collection of gods", "textTe": "దేవతల సమూహము"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 11:4",
                "verseReferenceTe": "ఆదికాండము 11:4",
                "explanationEn": "The builders at Babel built the tower to make a name for themselves.",
                "explanationTe": "వారు తాము భూమిమీద చెదిరిపోకుండా నామము సంపాదించుకొనవలెనని గోపురము కట్టారు."
            },
            {
                "id": "level_1_q7_C",
                "order": 7,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1010,
                "questionEn": "God saw that the wickedness of man was great on the earth before the flood.",
                "questionTe": "జలప్రళయానికి ముందు నరుల చెడుతనము భూమిమీద గొప్పదని దేవుడు చూశాడు.",
                "options": [],
                "correctAnswerEn": "True",
                "correctAnswerTe": "నిజం",
                "verseReferenceEn": "Genesis 6:5",
                "verseReferenceTe": "ఆదికాండము 6:5",
                "explanationEn": "The wickedness of man was great, prompting God's judgment.",
                "explanationTe": "నరుల చెడుతనము భూమిమీద గొప్పదని యెహోవా చూసెను."
            },
            {
                "id": "level_1_q8_C",
                "order": 8,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1010,
                "questionEn": "Noah was the first person to plant a vineyard.",
                "questionTe": "నోవహు ద్రాక్షతోట వేసిన మొదటి వ్యక్తి.",
                "options": [],
                "correctAnswerEn": "True",
                "correctAnswerTe": "నిజం",
                "verseReferenceEn": "Genesis 9:20",
                "verseReferenceTe": "ఆదికాండము 9:20",
                "explanationEn": "Noah began to be a husbandman and planted a vineyard.",
                "explanationTe": "నోవహు సేద్యము చేయనారంభించి ద్రాక్షతోట వేసెను."
            },
            {
                "id": "level_1_q9_C",
                "order": 9,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1010,
                "questionEn": "What did Adam name the woman because she was the mother of all living?",
                "questionTe": "జీవముగల ప్రతివానికిని తల్లి అయినందున ఆదాము తన భార్యకు ఏ పేరు పెట్టాడు?",
                "options": [],
                "correctAnswerEn": "Eve",
                "correctAnswerTe": "హవ్వ",
                "verseReferenceEn": "Genesis 3:20",
                "verseReferenceTe": "ఆదికాండము 3:20",
                "explanationEn": "Adam named his wife Eve because she was the mother of all living.",
                "explanationTe": "ఆదాము తన భార్యకు హవ్వ అని పేరు పెట్టెను, ఏలయనగా ఆమె జీవముగల ప్రతివానికిని తల్లి."
            },
            {
                "id": "level_1_q10_C",
                "order": 10,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1010,
                "questionEn": "How many years did Noah live after the flood?",
                "questionTe": "జలప్రళయం తర్వాత నోవహు ఎన్ని సంవత్సరాలు జీవించాడు?",
                "options": [],
                "correctAnswerEn": "350",
                "correctAnswerTe": "350",
                "verseReferenceEn": "Genesis 9:28",
                "verseReferenceTe": "ఆదికాండము 9:28",
                "explanationEn": "Noah lived 350 years after the flood, dying at age 950.",
                "explanationTe": "జలప్రళయము జరిగిన తరువాత నోవహు మూడువందల ఏబది సంవత్సరములు బ్రతికెను."
            },
            {
                "id": "level_1_q11_C",
                "order": 11,
                "type": "mixed_format",
                "timeLimitSeconds": 45,
                "points": 1010,
                "questionEn": "Which of the following was NOT one of Adam's sons?",
                "questionTe": "క్రిందివారిలో ఆదాము కుమారుడు కానిది ఎవరు?",
                "options": [
                    {"id": "level_1_q11_C_opt1", "order": 1, "isCorrect": True, "textEn": "Enoch", "textTe": "హనోకు"},
                    {"id": "level_1_q11_C_opt2", "order": 2, "isCorrect": False, "textEn": "Cain", "textTe": "కయీను"},
                    {"id": "level_1_q11_C_opt3", "order": 3, "isCorrect": False, "textEn": "Abel", "textTe": "హేబెలు"},
                    {"id": "level_1_q11_C_opt4", "order": 4, "isCorrect": False, "textEn": "Seth", "textTe": "షేతు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 4 & 5",
                "verseReferenceTe": "ఆదికాండము 4 & 5",
                "explanationEn": "Enoch was a descendant of Seth, not a direct son of Adam.",
                "explanationTe": "హనోకు షేతు సంతతివాడు, ఆదాము ప్రత్యక్ష కుమారుడు కాడు."
            },
            {
                "id": "level_1_q12_C",
                "order": 12,
                "type": "skills_application",
                "timeLimitSeconds": 60,
                "points": 1010,
                "questionEn": "What was the name of Cain's wife's father-in-law?",
                "questionTe": "కయీను భార్య యొక్క మామగారి పేరు ఏమిటి?",
                "options": [],
                "correctAnswerEn": "Adam",
                "correctAnswerTe": "ఆదాము",
                "verseReferenceEn": "Genesis 4:1-17",
                "verseReferenceTe": "ఆదికాండము 4:1-17",
                "explanationEn": "Cain's father is Adam, who is the father-in-law of Cain's wife.",
                "explanationTe": "కయీను తండ్రి ఆదాము, అతడు కయీను భార్యకు మామగారు."
            }
        ]
    }

    # Define Level 2 Questions (Genesis Chapters 12-25: Abraham & Sarah)
    levels["2"] = {
        "A": [
            {
                "id": "level_2_q1_A",
                "order": 1,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "Where did God call Abram to leave, to go to a land He would show him?",
                "questionTe": "దేవుడు అబ్రామును ఏ స్థలమును విడిచి, తాను చూపించు देशమునకు వెళ్ళమని పిలిచాడు?",
                "options": [
                    {"id": "level_2_q1_A_opt1", "order": 1, "isCorrect": True, "textEn": "Haran", "textTe": "హారాను"},
                    {"id": "level_2_q1_A_opt2", "order": 2, "isCorrect": False, "textEn": "Ur", "textTe": "ఊరు"},
                    {"id": "level_2_q1_A_opt3", "order": 3, "isCorrect": False, "textEn": "Egypt", "textTe": "ఐగుప్తు"},
                    {"id": "level_2_q1_A_opt4", "order": 4, "isCorrect": False, "textEn": "Sodom", "textTe": "సొదొమ"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 12:1-4",
                "verseReferenceTe": "ఆదికాండము 12:1-4",
                "explanationEn": "God told Abram to leave Haran after his father Terah died.",
                "explanationTe": "తండ్రి తెరహు చనిపోయిన తర్వాత దేవుడు అబ్రామును హారాను విడిచి వెళ్ళమనెను."
            },
            {
                "id": "level_2_q2_A",
                "order": 2,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "Who was Abram's nephew who traveled with him?",
                "questionTe": "అబ్రాముతో పాటు ప్రయాణించిన అతని సహోదరుని కుమారుడు (మేనల్లుడు) ఎవరు?",
                "options": [
                    {"id": "level_2_q2_A_opt1", "order": 1, "isCorrect": True, "textEn": "Lot", "textTe": "లోతు"},
                    {"id": "level_2_q2_A_opt2", "order": 2, "isCorrect": False, "textEn": "Nahor", "textTe": "నాහోరు"},
                    {"id": "level_2_q2_A_opt3", "order": 3, "isCorrect": False, "textEn": "Ishmael", "textTe": "ఇష్మాయేలు"},
                    {"id": "level_2_q2_A_opt4", "order": 4, "isCorrect": False, "textEn": "Isaac", "textTe": "ఇస్సాకు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 12:5",
                "verseReferenceTe": "ఆదికాండము 12:5",
                "explanationEn": "Lot, Haran's son, went along with his uncle Abram.",
                "explanationTe": "అబ్రాము తన సహోదరుని కుమారుడైన లోతును తనతో కూడా తీసుకొనిపోయెను."
            },
            {
                "id": "level_2_q3_A",
                "order": 3,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "What did God promise to make Abram's descendants like in number?",
                "questionTe": "అబ్రాము సంతానమును దేనివలె లెక్కింపలేనంతగా చేస్తానని దేవుడు వాగ్దానం చేశాడు?",
                "options": [
                    {"id": "level_2_q3_A_opt1", "order": 1, "isCorrect": True, "textEn": "Dust of the earth and stars", "textTe": "భూమి ధూళి మరియు నక్షత్రములు"},
                    {"id": "level_2_q3_A_opt2", "order": 2, "isCorrect": False, "textEn": "Trees of the forest", "textTe": "అడవి వృక్షములు"},
                    {"id": "level_2_q3_A_opt3", "order": 3, "isCorrect": False, "textEn": "Fish of the sea", "textTe": "సముద్రపు చేపలు"},
                    {"id": "level_2_q3_A_opt4", "order": 4, "isCorrect": False, "textEn": "Clouds in the sky", "textTe": "ఆకాశ మేఘములు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 13:16",
                "verseReferenceTe": "ఆదికాండము 13:16",
                "explanationEn": "God promised Abram descendants as numerous as the dust of the earth.",
                "explanationTe": "నేను నీ సంతానమును భూమి ధూళివలె విస్తరింపజేసెదనని దేవుడు వాగ్దానము చేసెను."
            },
            {
                "id": "level_2_q4_A",
                "order": 4,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "Who was Melchizedek, who blessed Abram after the rescue of Lot?",
                "questionTe": "లోతును విడిపించిన తర్వాత అబ్రామును ఆశీర్వదించిన మెల్కీసెదెకు ఎవరు?",
                "options": [
                    {"id": "level_2_q4_A_opt1", "order": 1, "isCorrect": True, "textEn": "King of Salem and Priest of Most High God", "textTe": "శాలేము రాజు మరియు సర్వోన్నతుడైన దేవుని యాజకుడు"},
                    {"id": "level_2_q4_A_opt2", "order": 2, "isCorrect": False, "textEn": "King of Sodom", "textTe": "సొదొమ రాజు"},
                    {"id": "level_2_q4_A_opt3", "order": 3, "isCorrect": False, "textEn": "Ruler of Egypt", "textTe": "ఐగుప్తు పాలకుడు"},
                    {"id": "level_2_q4_A_opt4", "order": 4, "isCorrect": False, "textEn": "General of Haran", "textTe": "హారాను సేనాధిపతి"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 14:18",
                "verseReferenceTe": "ఆదికాండము 14:18",
                "explanationEn": "Melchizedek was the king of Salem and a priest of God Most High.",
                "explanationTe": "మెల్కీసెదెకు శాలేము రాజును సర్వోన్నతుడైన దేవుని యాజకుడునై యుండెను."
            },
            {
                "id": "level_2_q5_A",
                "order": 5,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "What was the name of Sarah's handmaid, who bore Abraham's first son, Ishmael?",
                "questionTe": "అబ్రాహాము ప్రథమ కుమారుడైన ఇష్మాయేలును కనిన శారా దాసి పేరు ఏమిటి?",
                "options": [
                    {"id": "level_2_q5_A_opt1", "order": 1, "isCorrect": True, "textEn": "Hagar", "textTe": "హాగరు"},
                    {"id": "level_2_q5_A_opt2", "order": 2, "isCorrect": False, "textEn": "Keturah", "textTe": "కెతూరా"},
                    {"id": "level_2_q5_A_opt3", "order": 3, "isCorrect": False, "textEn": "Rebekah", "textTe": "రిబ్కా"},
                    {"id": "level_2_q5_A_opt4", "order": 4, "isCorrect": False, "textEn": "Bilhah", "textTe": "బిల్హా"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 16:1-3",
                "verseReferenceTe": "ఆదికాండము 16:1-3",
                "explanationEn": "Hagar, an Egyptian maidservant, was given to Abram by Sarai.",
                "explanationTe": "శారయి తన ఐగుప్తు దాసియైన హాగరును అబ్రామునకు భార్యగా ఇచ్చెను."
            },
            {
                "id": "level_2_q6_A",
                "order": 6,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "How old was Abraham when his son Isaac was born?",
                "questionTe": "తన కుమారుడైన ఇస్సాకు జన్మించినప్పుడు అబ్రాహాము వయస్సు ఎంత?",
                "options": [
                    {"id": "level_2_q6_A_opt1", "order": 1, "isCorrect": True, "textEn": "100 years old", "textTe": "100 సంవత్సరాలు"},
                    {"id": "level_2_q6_A_opt2", "order": 2, "isCorrect": False, "textEn": "99 years old", "textTe": "99 సంవత్సరాలు"},
                    {"id": "level_2_q6_A_opt3", "order": 3, "isCorrect": False, "textEn": "86 years old", "textTe": "86 సంవత్సరాలు"},
                    {"id": "level_2_q6_A_opt4", "order": 4, "isCorrect": False, "textEn": "75 years old", "textTe": "75 సంవత్సరాలు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 21:5",
                "verseReferenceTe": "ఆదికాండము 21:5",
                "explanationEn": "Abraham was 100 years old when his covenant heir Isaac was born.",
                "explanationTe": "తన కుమారుడైన ఇస్సాకు పుట్టినప్పుడు అబ్రాహాము నూరేండ్ల వాడు."
            },
            {
                "id": "level_2_q7_A",
                "order": 7,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1020,
                "questionEn": "God changed Abram's name to Abraham, meaning 'father of many nations'.",
                "questionTe": "దేవుడు అబ్రాము పేరును అబ్రాహాముగా మార్చాడు, దీని అర్థం 'అనేక జనములకు తండ్రి'.",
                "options": [],
                "correctAnswerEn": "True",
                "correctAnswerTe": "నిజం",
                "verseReferenceEn": "Genesis 17:5",
                "verseReferenceTe": "ఆదికాండము 17:5",
                "explanationEn": "Abram's name was changed to Abraham to reflect the covenant promise.",
                "explanationTe": "నీవు అనేక జనములకు తండ్రివగుదువు గనుక నీ పేరు అబ్రాహాము అనబడును."
            },
            {
                "id": "level_2_q8_A",
                "order": 8,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1020,
                "questionEn": "Abraham's wife Sarah laughed when the Lord said she would have a son.",
                "questionTe": "తనకు కుమారుడు కలుగుతాడని యెహోవా చెప్పినప్పుడు అబ్రాహాము భార్య శారా నవ్వింది.",
                "options": [],
                "correctAnswerEn": "True",
                "correctAnswerTe": "నిజం",
                "verseReferenceEn": "Genesis 18:12",
                "verseReferenceTe": "ఆదికాండము 18:12",
                "explanationEn": "Sarah laughed within herself because she and Abraham were of advanced age.",
                "explanationTe": "శారా వయస్సు మళ్ళినది గనుక తనలో తాను నవ్వుకొనెను."
            },
            {
                "id": "level_2_q9_A",
                "order": 9,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1020,
                "questionEn": "What was the city Lot escaped to before Sodom and Gomorrah were destroyed?",
                "questionTe": "సొదొమ గొమొఱ్ఱాల నాశనానికి ముందు లోతు తప్పించుకొని పారిపోయిన చిన్న పట్టణము పేరు ఏమిటి?",
                "options": [],
                "correctAnswerEn": "Zoar",
                "correctAnswerTe": "సోయరు",
                "verseReferenceEn": "Genesis 19:22-23",
                "verseReferenceTe": "ఆదికాండము 19:22-23",
                "explanationEn": "Lot requested to flee to a nearby small city, which God spared and named Zoar.",
                "explanationTe": "లోతు నాశనము నుండి తప్పించుకొని పారిపోయిన చిన్న పట్టణమునకు సోయరు అని పేరు."
            },
            {
                "id": "level_2_q10_A",
                "order": 10,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1020,
                "questionEn": "What did Lot's wife turn into when she looked back at Sodom?",
                "questionTe": "సొదొమ వైపు వెనుతిరిగి చూసినప్పుడు లోతు భార్య దేనిగా మారిపోయింది?",
                "options": [],
                "correctAnswerEn": "Pillar of salt",
                "correctAnswerTe": "ఉప్పుస్తంభము",
                "verseReferenceEn": "Genesis 19:26",
                "verseReferenceTe": "ఆదికాండము 19:26",
                "explanationEn": "Lot's wife disobeyed the command not to look back and became a pillar of salt.",
                "explanationTe": "లోతు భార్య అతని వెనుకనుండి వెనుతిరిగి చూచి ఉప్పుస్తంభమాయెను."
            },
            {
                "id": "level_2_q11_A",
                "order": 11,
                "type": "mixed_format",
                "timeLimitSeconds": 45,
                "points": 1020,
                "questionEn": "Where did Abraham build an altar to sacrifice his son Isaac as a test from God?",
                "questionTe": "దేవుడు అబ్రాహామును పరీక్షించినప్పుడు తన కుమారుడైన ఇస్సాకును బలి అర్పించుటకు ఏ ప్రాంతానికి వెళ్ళాడు?",
                "options": [
                    {"id": "level_2_q11_A_opt1", "order": 1, "isCorrect": True, "textEn": "Land of Moriah", "textTe": "మోరియా దేశము"},
                    {"id": "level_2_q11_A_opt2", "order": 2, "isCorrect": False, "textEn": "Mount Sinai", "textTe": "సీనాయి పర్వతం"},
                    {"id": "level_2_q11_A_opt3", "order": 3, "isCorrect": False, "textEn": "Mount Ararat", "textTe": "అరరాతు పర్వతం"},
                    {"id": "level_2_q11_A_opt4", "order": 4, "isCorrect": False, "textEn": "Mount Nebo", "textTe": "నెబో పర్వతం"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 22:2",
                "verseReferenceTe": "ఆదికాండము 22:2",
                "explanationEn": "God commanded Abraham to offer Isaac as a burnt offering in the land of Moriah.",
                "explanationTe": "దేవుడు అబ్రాహాముతో నీకు ప్రియుడైన ఇస్సాకును మోరియా దేశమునకు తీసికొనిపొమ్ము అని ఆజ్ఞాపించెను."
            },
            {
                "id": "level_2_q12_A",
                "order": 12,
                "type": "skills_application",
                "timeLimitSeconds": 60,
                "points": 1020,
                "questionEn": "What animal did Abraham find caught in a thicket to sacrifice instead of Isaac?",
                "questionTe": "ఇస్సాకుకు బదులుగా బలి అర్పించడానికి పొదలో కొమ్ములు తగులుకొనిన ఏ జంతువును అబ్రాహాము కనుగొన్నాడు?",
                "options": [],
                "correctAnswerEn": "Ram",
                "correctAnswerTe": "పొట్టేలు",
                "verseReferenceEn": "Genesis 22:13",
                "verseReferenceTe": "ఆదికాండము 22:13",
                "explanationEn": "God provided a ram caught in the thicket as a substitute sacrifice.",
                "explanationTe": "పొదలో కొమ్ములు తగులుకొనియున్న ఒక పొట్టేలును అబ్రాహాము చూచి దానిని బలి అర్పించెను."
            }
        ],
        "B": [
            {
                "id": "level_2_q1_B",
                "order": 1,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "Who was Abram's father?",
                "questionTe": "అబ్రాము తండ్రి ఎవరు?",
                "options": [
                    {"id": "level_2_q1_B_opt1", "order": 1, "isCorrect": True, "textEn": "Terah", "textTe": "తెరహు"},
                    {"id": "level_2_q1_B_opt2", "order": 2, "isCorrect": False, "textEn": "Nahor", "textTe": "నాహోరు"},
                    {"id": "level_2_q1_B_opt3", "order": 3, "isCorrect": False, "textEn": "Haran", "textTe": "హారాను"},
                    {"id": "level_2_q1_B_opt4", "order": 4, "isCorrect": False, "textEn": "Lot", "textTe": "లోతు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 11:27",
                "verseReferenceTe": "ఆదికాండము 11:27",
                "explanationEn": "Terah was the father of Abram, Nahor, and Haran.",
                "explanationTe": "తెరహు అబ్రామును నాహోరును హారానును కనెను."
            },
            {
                "id": "level_2_q2_B",
                "order": 2,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "Why did Abram go down to Egypt soon after arriving in Canaan?",
                "questionTe": "కనానుకు వచ్చిన కొద్ది కాలానికే అబ్రాము ఐగుప్తుకు ఎందుకు వెళ్ళాడు?",
                "options": [
                    {"id": "level_2_q2_B_opt1", "order": 1, "isCorrect": True, "textEn": "Famine in the land", "textTe": "ఆ దేశంలో కరవు వచ్చినందున"},
                    {"id": "level_2_q2_B_opt2", "order": 2, "isCorrect": False, "textEn": "To trade goods", "textTe": "వ్యాపారము చేయుటకు"},
                    {"id": "level_2_q2_B_opt3", "order": 3, "isCorrect": False, "textEn": "To buy land", "textTe": "భూమిని కొనుటకు"},
                    {"id": "level_2_q2_B_opt4", "order": 4, "isCorrect": False, "textEn": "To escape war", "textTe": "యుద్ధము తప్పించుకొనుటకు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 12:10",
                "verseReferenceTe": "ఆదికాండము 12:10",
                "explanationEn": "A severe famine in Canaan forced Abram to temporarily move to Egypt.",
                "explanationTe": "ఆ దేశములో కరవు భారముగా ఉన్నందున అబ్రాము కాపురముండుటకు ఐగుప్తునకు వెళ్ళెను."
            },
            {
                "id": "level_2_q3_B",
                "order": 3,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "What area did Lot choose when he and Abram separated due to their large herds?",
                "questionTe": "మందలు ఎక్కువగా ఉన్నందున అబ్రాము లోతు విడిపోయినప్పుడు లోతు ఏ ప్రాంతాన్ని ఎన్నుకున్నాడు?",
                "options": [
                    {"id": "level_2_q3_B_opt1", "order": 1, "isCorrect": True, "textEn": "Plain of Jordan", "textTe": "యోర్దాను మైదానము"},
                    {"id": "level_2_q3_B_opt2", "order": 2, "isCorrect": False, "textEn": "Land of Canaan", "textTe": "కనాను దేశము"},
                    {"id": "level_2_q3_B_opt3", "order": 3, "isCorrect": False, "textEn": "Hill country of Hebron", "textTe": "హెబ్రోను కొండ దేశము"},
                    {"id": "level_2_q3_B_opt4", "order": 4, "isCorrect": False, "textEn": "Desert of Shur", "textTe": "షూరు అరణ్యము"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 13:10-11",
                "verseReferenceTe": "ఆదికాండము 13:10-11",
                "explanationEn": "Lot selected the well-watered valley of the Jordan River.",
                "explanationTe": "లోతు యోర్దాను మైదానమంతటిని చూచి దానిని ఎన్నుకొనెను."
            },
            {
                "id": "level_2_q4_B",
                "order": 4,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "What covenant sign did God command Abraham and his male descendants to undergo?",
                "questionTe": "అబ్రాహాము మరియు అతని పురుష సంతతి అంతా చేయించుకోవలసిన నిబంధన గుర్తు ఏది?",
                "options": [
                    {"id": "level_2_q4_B_opt1", "order": 1, "isCorrect": True, "textEn": "Circumcision", "textTe": "సున్నతి"},
                    {"id": "level_2_q4_B_opt2", "order": 2, "isCorrect": False, "textEn": "Wearing phylacteries", "textTe": "రక్ష రేకులు ధరించుట"},
                    {"id": "level_2_q4_B_opt3", "order": 3, "isCorrect": False, "textEn": "Anointing with oil", "textTe": "నూనెతో అభిషేకించుట"},
                    {"id": "level_2_q4_B_opt4", "order": 4, "isCorrect": False, "textEn": "Foot washing", "textTe": "పాదములు కడుగుట"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 17:10",
                "verseReferenceTe": "ఆదికాండము 17:10",
                "explanationEn": "God commanded circumcision as a sign of the covenant.",
                "explanationTe": "మీలో ప్రతి పురుషుడును సున్నతి చేయించుకొనవలెను; ఇదే నా నిబంధన."
            },
            {
                "id": "level_2_q5_B",
                "order": 5,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "How many righteous people did Abraham eventually ask God to spare Sodom for?",
                "questionTe": "సొదొమను నాశనము చేయకుండా ఉండుటకు ఎంతమంది నీతిమంతుల వరకు అబ్రాహాము దేవుడిని బ్రతిమలాడాడు?",
                "options": [
                    {"id": "level_2_q5_B_opt1", "order": 1, "isCorrect": True, "textEn": "10", "textTe": "10 మంది"},
                    {"id": "level_2_q5_B_opt2", "order": 2, "isCorrect": False, "textEn": "50", "textTe": "50 మంది"},
                    {"id": "level_2_q5_B_opt3", "order": 3, "isCorrect": False, "textEn": "20", "textTe": "20 మంది"},
                    {"id": "level_2_q5_B_opt4", "order": 4, "isCorrect": False, "textEn": "5", "textTe": "5 మంది"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 18:32",
                "verseReferenceTe": "ఆదికాండము 18:32",
                "explanationEn": "Abraham bargained with God, ending at a request for ten righteous people.",
                "explanationTe": "అక్కడ పదిమంది నీతిమంతులు కనబడినయెడల పదిమందిని బట్టి నాశనము చేయనని యెహోవా చెప్పెను."
            },
            {
                "id": "level_2_q6_B",
                "order": 6,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "Who was Abraham's second wife, whom he married after Sarah's death?",
                "questionTe": "శారా మరణం తర్వాత అబ్రాహాము వివాహం చేసుకున్న అతని రెండవ భార్య ఎవరు?",
                "options": [
                    {"id": "level_2_q6_B_opt1", "order": 1, "isCorrect": True, "textEn": "Keturah", "textTe": "కెతూరా"},
                    {"id": "level_2_q6_B_opt2", "order": 2, "isCorrect": False, "textEn": "Hagar", "textTe": "హాగరు"},
                    {"id": "level_2_q6_B_opt3", "order": 3, "isCorrect": False, "textEn": "Rebekah", "textTe": "రిబ్కా"},
                    {"id": "level_2_q6_B_opt4", "order": 4, "isCorrect": False, "textEn": "Bilhah", "textTe": "బిల్హా"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 25:1",
                "verseReferenceTe": "ఆదికాండము 25:1",
                "explanationEn": "Abraham married Keturah later in life, and she bore him several sons.",
                "explanationTe": "అబ్రాహాము కెతూరా అను ఒక స్త్రీని వివాహము చేసికొనెను."
            },
            {
                "id": "level_2_q7_B",
                "order": 7,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1020,
                "questionEn": "Ishmael was Abraham's younger son, born after Isaac.",
                "questionTe": "ఇష్మాయేలు అబ్రాహాము యొక్క చిన్న కుమారుడు, ఇస్సాకు తర్వాత జన్మించాడు.",
                "options": [],
                "correctAnswerEn": "False",
                "correctAnswerTe": "తప్పు",
                "verseReferenceEn": "Genesis 16:16 & 21:5",
                "verseReferenceTe": "ఆదికాండము 16:16 & 21:5",
                "explanationEn": "Ishmael was Abraham's firstborn son, born 14 years before Isaac.",
                "explanationTe": "ఇష్మాయేలు అబ్రాహామునకు మొదట పుట్టిన కుమారుడు, ఇస్సాకు కంటే పెద్దవాడు."
            },
            {
                "id": "level_2_q8_B",
                "order": 8,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1020,
                "questionEn": "Melchizedek offered bread and wine to Abram.",
                "questionTe": "మెల్కీసెదెకు అబ్రాముకు రొట్టెను ద్రాక్షారసమును ఇచ్చాడు.",
                "options": [],
                "correctAnswerEn": "True",
                "correctAnswerTe": "నిజం",
                "verseReferenceEn": "Genesis 14:18",
                "verseReferenceTe": "ఆదికాండము 14:18",
                "explanationEn": "Melchizedek brought out bread and wine to refresh Abram and his men.",
                "explanationTe": "శాలేము రాజైన మెల్కీసెదెకు రొట్టెను ద్రాక్షారసమును తీసికొనివచ్చెను."
            },
            {
                "id": "level_2_q9_B",
                "order": 9,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1020,
                "questionEn": "What was Sarah's name before God changed it?",
                "questionTe": "దేవుడు పేరు మార్చకముందు శారా పేరు ఏమిటి?",
                "options": [],
                "correctAnswerEn": "Sarai",
                "correctAnswerTe": "సారయి",
                "verseReferenceEn": "Genesis 17:15",
                "verseReferenceTe": "ఆదికాండము 17:15",
                "explanationEn": "God changed her name from Sarai to Sarah as part of the covenant.",
                "explanationTe": "దేవుడు అబ్రాహాముతో నీ భార్యయైన సారయి పేరు సారయి అనవద్దు; ఆమె పేరు శారా."
            },
            {
                "id": "level_2_q10_B",
                "order": 10,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1020,
                "questionEn": "Where was Sarah buried, in a cave purchased by Abraham?",
                "questionTe": "అబ్రాహాము కొనుగోలు చేసిన గుహలో శారా సమాధి చేయబడింది, ఆ స్థలము పేరు ఏమిటి?",
                "options": [],
                "correctAnswerEn": "Machpelah",
                "correctAnswerTe": "మక్పేలా",
                "verseReferenceEn": "Genesis 23:19",
                "verseReferenceTe": "ఆదికాండము 23:19",
                "explanationEn": "Sarah was buried in the cave of the field of Machpelah near Hebron.",
                "explanationTe": "అబ్రాహాము తన భార్యయైన శారాను మక్పేలా పొలము గుహలో సమాధి చేసెను."
            },
            {
                "id": "level_2_q11_B",
                "order": 11,
                "type": "mixed_format",
                "timeLimitSeconds": 45,
                "points": 1020,
                "questionEn": "What was the name of Abraham's chief servant who was sent to find a wife for Isaac?",
                "questionTe": "ఇస్సాకుకు భార్యను వెతకడానికి పంపబడిన అబ్రాహాము ప్రధాన దాసుడు ఎవరు?",
                "options": [
                    {"id": "level_2_q11_B_opt1", "order": 1, "isCorrect": True, "textEn": "Eliezer", "textTe": "ఎలీయెజెరు"},
                    {"id": "level_2_q11_B_opt2", "order": 2, "isCorrect": False, "textEn": "Lot", "textTe": "లోతు"},
                    {"id": "level_2_q11_B_opt3", "order": 3, "isCorrect": False, "textEn": "Ishmael", "textTe": "ఇష్మాయేలు"},
                    {"id": "level_2_q11_B_opt4", "order": 4, "isCorrect": False, "textEn": "Abimelech", "textTe": "అబీమెలెకు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 15:2 & 24",
                "verseReferenceTe": "ఆదికాండము 15:2 & 24",
                "explanationEn": "Eliezer of Damascus is widely believed to be the servant sent to Haran.",
                "explanationTe": "దమస్కు ఎలీయెజెరు అబ్రాహాము ఇంట పుట్టి అతని సమస్త ఆస్తికి అధికారియైన దాసుడు."
            },
            {
                "id": "level_2_q12_B",
                "order": 12,
                "type": "skills_application",
                "timeLimitSeconds": 60,
                "points": 1020,
                "questionEn": "At what well did the servant meet Rebekah, who offered water to him and his camels?",
                "questionTe": "దాసునికి మరియు అతని ఒంటెలకు నీరు పోసిన రిబ్కాను ఏ బావి వద్ద అతను కలుసుకున్నాడు?",
                "options": [],
                "correctAnswerEn": "Well of Nahor",
                "correctAnswerTe": "నాహోరు బావి",
                "verseReferenceEn": "Genesis 24:11-15",
                "verseReferenceTe": "ఆదికాండము 24:11-15",
                "explanationEn": "The servant met Rebekah at the well outside the city of Nahor in Mesopotamia.",
                "explanationTe": "అబ్రాహాము దాసుడు నాహోరు ఊరి వెలుపల ఉన్న నీళ్ల బావి వద్ద రిబ్కాను కలుసుకొనెను."
            }
        ],
        "C": [
            {
                "id": "level_2_q1_C",
                "order": 1,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "What did Abram ask Sarai to say to the Egyptians to protect his life?",
                "questionTe": "తన ప్రాణము దక్కించుకొనుటకు ఐగుప్తీయులతో తనను ఏమని పరిచయం చేసుకోమని అబ్రాము సారయితో చెప్పాడు?",
                "options": [
                    {"id": "level_2_q1_C_opt1", "order": 1, "isCorrect": True, "textEn": "She is his sister", "textTe": "ఆమె తన సహోదరి అని"},
                    {"id": "level_2_q1_C_opt2", "order": 2, "isCorrect": False, "textEn": "She is his mother", "textTe": "ఆమె తన తల్లి అని"},
                    {"id": "level_2_q1_C_opt3", "order": 3, "isCorrect": False, "textEn": "She is a traveler", "textTe": "ఆమె ఒక యాత్రికురాలు అని"},
                    {"id": "level_2_q1_C_opt4", "order": 4, "isCorrect": False, "textEn": "She is a queen", "textTe": "ఆమె ఒక రాణి అని"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 12:13",
                "verseReferenceTe": "ఆదికాండము 12:13",
                "explanationEn": "Abram feared he would be killed for Sarai's beauty, so he called her his sister.",
                "explanationTe": "ఐగుప్తీయులు నిన్ను చంపకుండా ఉండుటకు నా సహోదరివని చెప్పుమని అబ్రాము కోరెను."
            },
            {
                "id": "level_2_q2_C",
                "order": 2,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "What fraction of the spoils did Abram give Melchizedek?",
                "questionTe": "అబ్రాము తన యుద్ధ దోపుడు సొమ్ములో ఎంత భాగము మెల్కీసెదెకుకు ఇచ్చాడు?",
                "options": [
                    {"id": "level_2_q2_C_opt1", "order": 1, "isCorrect": True, "textEn": "A tenth", "textTe": "పదవ వంతు"},
                    {"id": "level_2_q2_C_opt2", "order": 2, "isCorrect": False, "textEn": "A half", "textTe": "సగ భాగము"},
                    {"id": "level_2_q2_C_opt3", "order": 3, "isCorrect": False, "textEn": "A third", "textTe": "మూడవ వంతు"},
                    {"id": "level_2_q2_C_opt4", "order": 4, "isCorrect": False, "textEn": "A fifth", "textTe": "ఐదవ వంతు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 14:20",
                "verseReferenceTe": "ఆదికాండము 14:20",
                "explanationEn": "Abram paid a tithe (one-tenth) of all his goods to Melchizedek.",
                "explanationTe": "అప్పుడు అబ్రాము అన్నిటిలోను పదియవ వంతు అతనికిచ్చెను."
            },
            {
                "id": "level_2_q3_C",
                "order": 3,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "What was the name given to Hagar's son, meaning 'God hears'?",
                "questionTe": "దేవుడు ఆలకించెను అని అర్థం వచ్చేలా హాగరు కుమారునికి ఏ పేరు పెట్టబడింది?",
                "options": [
                    {"id": "level_2_q3_C_opt1", "order": 1, "isCorrect": True, "textEn": "Ishmael", "textTe": "ఇష్మాయేలు"},
                    {"id": "level_2_q3_C_opt2", "order": 2, "isCorrect": False, "textEn": "Isaac", "textTe": "ఇస్సాకు"},
                    {"id": "level_2_q3_C_opt3", "order": 3, "isCorrect": False, "textEn": "Israel", "textTe": "ఇశ్రాయేలు"},
                    {"id": "level_2_q3_C_opt4", "order": 4, "isCorrect": False, "textEn": "Esau", "textTe": "ఏశావు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 16:11",
                "verseReferenceTe": "ఆదికాండము 16:11",
                "explanationEn": "The angel of the Lord told Hagar to name her son Ishmael, meaning 'God hears'.",
                "explanationTe": "యెహోవా నీ బాధను వినెను గనుక నీ కుమారునికి ఇష్మాయేలు అని పేరు పెట్టుము."
            },
            {
                "id": "level_2_q4_C",
                "order": 4,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "Who were the three visitors Abraham hosted under the trees of Mamre?",
                "questionTe": "మమ్రే దేవదారు వృక్షముల క్రింద అబ్రాహాము ఆతిథ్యమిచ్చిన ముగ్గురు అతిథులు ఎవరు?",
                "options": [
                    {"id": "level_2_q4_C_opt1", "order": 1, "isCorrect": True, "textEn": "The Lord and two angels", "textTe": "యెహోవా మరియు ఇద్దరు దూతలు"},
                    {"id": "level_2_q4_C_opt2", "order": 2, "isCorrect": False, "textEn": "Kings of Canaan", "textTe": "కనాను రాజులు"},
                    {"id": "level_2_q4_C_opt3", "order": 3, "isCorrect": False, "textEn": "Eliezer and servants", "textTe": "ఎలీయెజెరు మరియు దాసులు"},
                    {"id": "level_2_q4_C_opt4", "order": 4, "isCorrect": False, "textEn": "Melchizedek and priests", "textTe": "మెల్కీసెదెకు మరియు యాజకులు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 18:1-2",
                "verseReferenceTe": "ఆదికాండము 18:1-2",
                "explanationEn": "The Lord appeared to Abraham along with two angels in human form.",
                "explanationTe": "మమ్రే దేవదారు వనములో అబ్రాహామునకు ముగ్గురు మనుష్యులు కనబడిరి, వారిలో యెహోవా ఒకడు."
            },
            {
                "id": "level_2_q5_C",
                "order": 5,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "What did Sarah demand Abraham do with Hagar and Ishmael after Isaac was weaned?",
                "questionTe": "ఇస్సాకు పాలు విడిచిన తర్వాత హాగరును ఇష్మాయేలును ఏమి చేయమని శారా అబ్రాహామును కోరింది?",
                "options": [
                    {"id": "level_2_q5_C_opt1", "order": 1, "isCorrect": True, "textEn": "Cast them out", "textTe": "వారిని వెలివేయమని"},
                    {"id": "level_2_q5_C_opt2", "order": 2, "isCorrect": False, "textEn": "Make them rulers", "textTe": "వారిని పాలకులుగా చేయమని"},
                    {"id": "level_2_q5_C_opt3", "order": 3, "isCorrect": False, "textEn": "Put them in prison", "textTe": "వారిని జైలులో ఉంచమని"},
                    {"id": "level_2_q5_C_opt4", "order": 4, "isCorrect": False, "textEn": "Give them double portion", "textTe": "వారికి రెట్టింపు భాగమివ్వమని"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 21:10",
                "verseReferenceTe": "ఆదికాండము 21:10",
                "explanationEn": "Sarah wanted Ishmael sent away so he would not inherit with Isaac.",
                "explanationTe": "శారా ఇస్సాకుతో ఈ దాసి కుమారుడు వారసుడు కాకూడదు గనుక వీరిని వెళ్లగొట్టుమని కోరెను."
            },
            {
                "id": "level_2_q6_C",
                "order": 6,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1020,
                "questionEn": "Where did Abraham buy the burial plot from Ephron the Hittite?",
                "questionTe": "హిత్తీయుడైన ఎఫ్రోను నుండి అబ్రాహాము కొన్న సమాధి పొలము ఎక్కడ ఉంది?",
                "options": [
                    {"id": "level_2_q6_C_opt1", "order": 1, "isCorrect": True, "textEn": "Hebron", "textTe": "హెబ్రోను"},
                    {"id": "level_2_q6_C_opt2", "order": 2, "isCorrect": False, "textEn": "Bethel", "textTe": "బేతేలు"},
                    {"id": "level_2_q6_C_opt3", "order": 3, "isCorrect": False, "textEn": "Beersheba", "textTe": "బెయేర్షెబా"},
                    {"id": "level_2_q6_C_opt4", "order": 4, "isCorrect": False, "textEn": "Shechem", "textTe": "షెకెము"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 23:16-19",
                "verseReferenceTe": "ఆదికాండము 23:16-19",
                "explanationEn": "Abraham purchased the cave of Machpelah in Hebron from the Hittites.",
                "explanationTe": "అబ్రాహాము హెబ్రోను వద్దనున్న మక్పేలా గుహను ఎఫ్రోను నుండి వెండి ఇచ్చి కొనెను."
            },
            {
                "id": "level_2_q7_C",
                "order": 7,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1020,
                "questionEn": "Rebekah was the sister of Laban.",
                "questionTe": "రిబ్కా లాబాను సహోదరి.",
                "options": [],
                "correctAnswerEn": "True",
                "correctAnswerTe": "నిజం",
                "verseReferenceEn": "Genesis 24:29",
                "verseReferenceTe": "ఆదికాండము 24:29",
                "explanationEn": "Laban was Rebekah's brother, who welcomed Abraham's servant.",
                "explanationTe": "రిబ్కాకు లాబాను అను సహోదరుడు ఉండెను; అతడు దాసుని ఎదుర్కొనెను."
            },
            {
                "id": "level_2_q8_C",
                "order": 8,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1020,
                "questionEn": "Abraham died at the age of 175 years.",
                "questionTe": "అబ్రాహాము 175 సంవత్సరాల వయస్సులో మరణించాడు.",
                "options": [],
                "correctAnswerEn": "True",
                "correctAnswerTe": "నిజం",
                "verseReferenceEn": "Genesis 25:7",
                "verseReferenceTe": "ఆదికాండము 25:7",
                "explanationEn": "Abraham lived to a good old age and died at 175.",
                "explanationTe": "అబ్రాహాము బ్రతికిన సంవత్సరముల సంఖ్య నూట డెబ్బది ఐదు."
            },
            {
                "id": "level_2_q9_C",
                "order": 9,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1020,
                "questionEn": "What did God instruct Abraham to divide in half to seal the covenant in Genesis 15?",
                "questionTe": "ఆదికాండము 15 లో నిబంధనను స్థిరపరచడానికి వేటిని సగానికి నరకాలని దేవుడు అబ్రాహాముకు ఆజ్ఞాపించాడు?",
                "options": [],
                "correctAnswerEn": "Animals",
                "correctAnswerTe": "జੰతువులు",
                "verseReferenceEn": "Genesis 15:9-10",
                "verseReferenceTe": "ఆదికాండము 15:9-10",
                "explanationEn": "Abraham was commanded to cut several animals in half as part of the covenant ritual.",
                "explanationTe": "దేవుడు అర్పించిన జంతువులను అబ్రాహాము మధ్యకు ఖండించి ఒకదానికెదురుగా ఒకదానిని ఉంచెను."
            },
            {
                "id": "level_2_q10_C",
                "order": 10,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1020,
                "questionEn": "What is the meaning of the name Isaac?",
                "questionTe": "ఇస్సాకు అనే పేరుకు అర్థం ఏమిటి?",
                "options": [],
                "correctAnswerEn": "Laughter",
                "correctAnswerTe": "నవ్వు",
                "verseReferenceEn": "Genesis 21:6",
                "verseReferenceTe": "ఆదికాండము 21:6",
                "explanationEn": "Sarah named her son Isaac, meaning laughter, because God brought her joy.",
                "explanationTe": "శారా దేవుడు నాకు నవ్వు కలుగజేసెనని చెప్పి తన కుమారునికి ఇస్సాకు అని పేరు పెట్టెను."
            },
            {
                "id": "level_2_q11_C",
                "order": 11,
                "type": "mixed_format",
                "timeLimitSeconds": 45,
                "points": 1020,
                "questionEn": "Which city did Abraham save Lot from when he defeated the four eastern kings?",
                "questionTe": "తూర్పు రాజులను ఓడించి అబ్రాహాము లోతును ఏ నగరము నుండి రక్షించాడు?",
                "options": [
                    {"id": "level_2_q11_C_opt1", "order": 1, "isCorrect": True, "textEn": "Sodom", "textTe": "సొదొమ"},
                    {"id": "level_2_q11_C_opt2", "order": 2, "isCorrect": False, "textEn": "Salem", "textTe": "శాలేము"},
                    {"id": "level_2_q11_C_opt3", "order": 3, "isCorrect": False, "textEn": "Ur", "textTe": "ఊరు"},
                    {"id": "level_2_q11_C_opt4", "order": 4, "isCorrect": False, "textEn": "Haran", "textTe": "హారాను"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 14:12-16",
                "verseReferenceTe": "ఆదికాండము 14:12-16",
                "explanationEn": "Abraham rescued Lot and his goods from the kings who plundered Sodom.",
                "explanationTe": "సొదొమలో కాపురమున్న లోతును అతని ఆస్తిని అబ్రాహాము విడిపించి తీసికొనివచ్చెను."
            },
            {
                "id": "level_2_q12_C",
                "order": 12,
                "type": "skills_application",
                "timeLimitSeconds": 60,
                "points": 1020,
                "questionEn": "Who was the father of Rebekah?",
                "questionTe": "రిబ్కా తండ్రి ఎవరు?",
                "options": [],
                "correctAnswerEn": "Bethuel",
                "correctAnswerTe": "బెతూయేలు",
                "verseReferenceEn": "Genesis 24:15",
                "verseReferenceTe": "ఆదికాండము 24:15",
                "explanationEn": "Rebekah was the daughter of Bethuel, son of Milcah and Nahor.",
                "explanationTe": "రిబ్కా అబ్రాహాము సోదరుడైన నాహోరు కుమారుడగు బెతూయేలు కుమార్తె."
            }
        ]
    }

    # Define Level 3 Questions (Genesis Chapters 26-50: Jacob & Joseph)
    levels["3"] = {
        "A": [
            {
                "id": "level_3_q1_A",
                "order": 1,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "Who were the twin sons of Isaac and Rebekah?",
                "questionTe": "ఇస్సాకు రిబ్కాల కవల కుమారులు ఎవరు?",
                "options": [
                    {"id": "level_3_q1_A_opt1", "order": 1, "isCorrect": True, "textEn": "Esau and Jacob", "textTe": "ఏశావు మరియు యాకోబు"},
                    {"id": "level_3_q1_A_opt2", "order": 2, "isCorrect": False, "textEn": "Cain and Abel", "textTe": "కయీను మరియు హేబెలు"},
                    {"id": "level_3_q1_A_opt3", "order": 3, "isCorrect": False, "textEn": "Ephraim and Manasseh", "textTe": "ఎఫ్రాయిము మరియు మనష్షే"},
                    {"id": "level_3_q1_A_opt4", "order": 4, "isCorrect": False, "textEn": "Pharez and Zerah", "textTe": "పెరేసు మరియు జెరహు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 25:24-26",
                "verseReferenceTe": "ఆదికాండము 25:24-26",
                "explanationEn": "Rebekah gave birth to twins, Esau (first) and Jacob (holding Esau's heel).",
                "explanationTe": "ఇస్సాకు భార్యయైన రిబ్కా కవల పిల్లలను కనెను, వారికి ఏశావు మరియు యాకోబు అని పేర్లు పెట్టిరి."
            },
            {
                "id": "level_3_q2_A",
                "order": 2,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "What did Esau sell his birthright to Jacob for?",
                "questionTe": "యాకోబుకు తన జ్యేష్ఠత్వపు హక్కును ఏశావు దేని కోసం అమ్ముకున్నాడు?",
                "options": [
                    {"id": "level_3_q2_A_opt1", "order": 1, "isCorrect": True, "textEn": "A stew of red lentils", "textTe": "ఎర్రటి పప్పుకూడు"},
                    {"id": "level_3_q2_A_opt2", "order": 2, "isCorrect": False, "textEn": "Silver coins", "textTe": "వెండి నాణేలు"},
                    {"id": "level_3_q2_A_opt3", "order": 3, "isCorrect": False, "textEn": "Sheep and goats", "textTe": "గొర్రెలు మరియు మేకలు"},
                    {"id": "level_3_q2_A_opt4", "order": 4, "isCorrect": False, "textEn": "A golden ring", "textTe": "బంగారు ఉంగరము"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 25:29-34",
                "verseReferenceTe": "ఆదికాండము 25:29-34",
                "explanationEn": "Faint from hunger, Esau sold his birthright for Jacob's red lentil stew.",
                "explanationTe": "ఆకలితో అలసిపోయిన ఏశావు కొద్దిపాటి ఎర్రటి పప్పుకూటి కొరకు తన జ్యేష్ఠత్వమును యాకోబుకు అమ్మెను."
            },
            {
                "id": "level_3_q3_A",
                "order": 3,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "How did Jacob deceive his blind father Isaac to get the blessing?",
                "questionTe": "ఆశీర్వాదం పొందుటకు గ్రుడ్డివాడైన తన తండ్రి ఇస్సాకును యాకోబు ఎలా మోసగించాడు?",
                "options": [
                    {"id": "level_3_q3_A_opt1", "order": 1, "isCorrect": True, "textEn": "By wearing Esau's clothes and goat skins on his hands", "textTe": "ఏశావు బట్టలు ధరించి, చేతులకు మేక చర్మములను కట్టుకొని"},
                    {"id": "level_3_q3_A_opt2", "order": 2, "isCorrect": False, "textEn": "By changing his voice", "textTe": "తన స్వరాన్ని మార్చుకొని"},
                    {"id": "level_3_q3_A_opt3", "order": 3, "isCorrect": False, "textEn": "By offering gold", "textTe": "బంగారము ఇచ్చి"},
                    {"id": "level_3_q3_A_opt4", "order": 4, "isCorrect": False, "textEn": "By telling him Esau had died", "textTe": "ఏశావు చనిపోయాడని చెప్పి"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 27:15-16",
                "verseReferenceTe": "ఆదికాండము 27:15-16",
                "explanationEn": "Jacob disguised himself using Esau's clothes and hairy goat skins.",
                "explanationTe": "యాకోబు తన చేతులకు మేక చర్మములను కట్టుకొని తండ్రిని తాకించి మోసగించెను."
            },
            {
                "id": "level_3_q4_A",
                "order": 4,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "What did Jacob see in his dream at Bethel?",
                "questionTe": "బేతేలు వద్ద యాకోబు తన కలలో ఏమి చూశాడు?",
                "options": [
                    {"id": "level_3_q4_A_opt1", "order": 1, "isCorrect": True, "textEn": "A ladder reaching to heaven with angels ascending and descending", "textTe": "భూమి నుండి ఆకాశమునకు ఉన్న నిచ్చెనను, దానిపై దేవదూతలు ఎక్కుట దిగుట"},
                    {"id": "level_3_q4_A_opt2", "order": 2, "isCorrect": False, "textEn": "Seven fat cows", "textTe": "ఏడు బలిసిన ఆవులు"},
                    {"id": "level_3_q4_A_opt3", "order": 3, "isCorrect": False, "textEn": "Burning bush", "textTe": "రగులుతున్న పొద"},
                    {"id": "level_3_q4_A_opt4", "order": 4, "isCorrect": False, "textEn": "A chariot of fire", "textTe": "అగ్ని రథము"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 28:12",
                "verseReferenceTe": "ఆదికాండము 28:12",
                "explanationEn": "Jacob dreamed of a ladder set on earth reaching to heaven with angels ascending and descending.",
                "explanationTe": "యాకోబు కలలో ఒక నిచ్చెన భూమిమీద నిలపబడియుండెను, దాని కొన ఆకాశమునంటెను, దేవదూతలు దానిపై ఎక్కుచు దిగుచునుండిరి."
            },
            {
                "id": "level_3_q5_A",
                "order": 5,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "How many years in total did Jacob work for Laban to marry Rachel?",
                "questionTe": "రాహేలును వివాహం చేసుకోవడానికి యాకోబు లాబాను వద్ద మొత్తం ఎన్ని సంవత్సరాలు పనిచేశాడు?",
                "options": [
                    {"id": "level_3_q5_A_opt1", "order": 1, "isCorrect": True, "textEn": "14 years", "textTe": "14 సంవత్సరాలు"},
                    {"id": "level_3_q5_A_opt2", "order": 2, "isCorrect": False, "textEn": "7 years", "textTe": "7 సంవత్సరాలు"},
                    {"id": "level_3_q5_A_opt3", "order": 3, "isCorrect": False, "textEn": "20 years", "textTe": "20 సంవత్సరాలు"},
                    {"id": "level_3_q5_A_opt4", "order": 4, "isCorrect": False, "textEn": "10 years", "textTe": "10 సంవత్సరాలు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 29:18-30",
                "verseReferenceTe": "ఆదికాండము 29:18-30",
                "explanationEn": "Jacob worked 7 years for Leah (tricked) and another 7 years for Rachel.",
                "explanationTe": "యాకోబు రాహేలు కొరకు మొదటి ఏడేండ్లును, తరువాత మరియొక ఏడేండ్లును లాబాను వద్ద పనిచేసెను."
            },
            {
                "id": "level_3_q6_A",
                "order": 6,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "What new name did the angel give to Jacob after wrestling with him?",
                "questionTe": "దూతతో పోరాడిన తర్వాత యాకోబుకు దూత ఇచ్చిన కొత్త పేరు ఏమిటి?",
                "options": [
                    {"id": "level_3_q6_A_opt1", "order": 1, "isCorrect": True, "textEn": "Israel", "textTe": "ఇశ్రాయేలు"},
                    {"id": "level_3_q6_A_opt2", "order": 2, "isCorrect": False, "textEn": "Abraham", "textTe": "అబ్రాహాము"},
                    {"id": "level_3_q6_A_opt3", "order": 3, "isCorrect": False, "textEn": "Isaac", "textTe": "ఇస్సాకు"},
                    {"id": "level_3_q6_A_opt4", "order": 4, "isCorrect": False, "textEn": "Judah", "textTe": "యూదా"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 32:28",
                "verseReferenceTe": "ఆదికాండము 32:28",
                "explanationEn": "Jacob was named Israel because he struggled with God and humans and overcame.",
                "explanationTe": "నీవు దేవునితోను మనుష్యులతోను పోరాడి గెలిచితివి గనుక ఇకమీదట నీ పేరు ఇశ్రాయేలు అనబడును."
            },
            {
                "id": "level_3_q7_A",
                "order": 7,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1030,
                "questionEn": "Joseph was Jacob's eldest son.",
                "questionTe": "యోసేపు యాకోబు యొక్క జ్యేష్ఠ కుమారుడు.",
                "options": [],
                "correctAnswerEn": "False",
                "correctAnswerTe": "తప్పు",
                "verseReferenceEn": "Genesis 29:32 & 30:24",
                "verseReferenceTe": "ఆదికాండము 29:32 & 30:24",
                "explanationEn": "Reuben was Jacob's firstborn; Joseph was the eleventh son.",
                "explanationTe": "యాకోబు జ్యేష్ఠ కుమారుడు రూబేను; యోసేపు రాహేలుకు పుట్టిన పదకొండవ వాడు."
            },
            {
                "id": "level_3_q8_A",
                "order": 8,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1030,
                "questionEn": "Joseph's brothers sold him to Midianite traders for 20 pieces of silver.",
                "questionTe": "యోసేపు సహోదరులు అతనిని మిద్యానీయులైన వర్తకులకు 20 వెండి నాణేలకు అమ్మేశారు.",
                "options": [],
                "correctAnswerEn": "True",
                "correctAnswerTe": "నిజం",
                "verseReferenceEn": "Genesis 37:28",
                "verseReferenceTe": "ఆదికాండము 37:28",
                "explanationEn": "Joseph's brothers pulled him out of the pit and sold him for 20 shekels of silver.",
                "explanationTe": "సహోదరులు యోసేపును గుంటలో నుండి పైకితీసి ఇరువది వెండి నాణేలకు అమ్మేసిరి."
            },
            {
                "id": "level_3_q9_A",
                "order": 9,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1030,
                "questionEn": "Who was Joseph's master in Egypt, whose wife falsely accused him?",
                "questionTe": "ఐగుప్తులో యోసేపు యజమాని ఎవరు, అతని భార్య యోసేపుపై అబద్ధపు నేరం మోపింది?",
                "options": [],
                "correctAnswerEn": "Potiphar",
                "correctAnswerTe": "పోతిఫరు",
                "verseReferenceEn": "Genesis 39:1",
                "verseReferenceTe": "ఆదికాండము 39:1",
                "explanationEn": "Potiphar, an officer of Pharaoh and captain of the guard, bought Joseph.",
                "explanationTe": "ఫరో అధికారియైన పోతిఫరు ఐగుప్తులో యోసేపును కొని తన ఇంట్లో ఉంచుకొనెను."
            },
            {
                "id": "level_3_q10_A",
                "order": 10,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1030,
                "questionEn": "What did Pharaoh appoint Joseph as, after he interpreted Pharaoh's dreams?",
                "questionTe": "ఫరో కలలకు భావము చెప్పిన తరువాత ఫరో యోసేపును ఐగుప్తుకు ఏ అధికారిగా నియమించాడు?",
                "options": [],
                "correctAnswerEn": "Ruler",
                "correctAnswerTe": "అధికారి",
                "verseReferenceEn": "Genesis 41:40-41",
                "verseReferenceTe": "ఆదికాండము 41:40-41",
                "explanationEn": "Pharaoh set Joseph over all the land of Egypt as second in command.",
                "explanationTe": "ఫరో యోసేపుతో నీవు నా ఇంటికి అధికారివై యుండుము; నా జనులందరు నీ నోటి మాట చొప్పున నడుచుకొందురు అనెను."
            },
            {
                "id": "level_3_q11_A",
                "order": 11,
                "type": "mixed_format",
                "timeLimitSeconds": 45,
                "points": 1030,
                "questionEn": "Which brother offered himself as a slave in place of Benjamin when the silver cup was found?",
                "questionTe": "వెండి గిన్నె దొరికినప్పుడు బెన్యామీనుకు బదులుగా తనను తాను దాసుడిగా అప్పగించుకోవడానికి సిద్ధపడిన సహోదరుడు ఎవరు?",
                "options": [
                    {"id": "level_3_q11_A_opt1", "order": 1, "isCorrect": True, "textEn": "Judah", "textTe": "యూదా"},
                    {"id": "level_3_q11_A_opt2", "order": 2, "isCorrect": False, "textEn": "Reuben", "textTe": "రూబేను"},
                    {"id": "level_3_q11_A_opt3", "order": 3, "isCorrect": False, "textEn": "Simeon", "textTe": "షిమ్యోను"},
                    {"id": "level_3_q11_A_opt4", "order": 4, "isCorrect": False, "textEn": "Levi", "textTe": "లేవి"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 44:33",
                "verseReferenceTe": "ఆదికాండము 44:33",
                "explanationEn": "Judah pleaded to stay as a slave instead of Benjamin to protect their father Jacob.",
                "explanationTe": "యూదా నా తండ్రి వద్దకుBenjamin వెళ్ళనిచ్చి అతనికి బదులుగా నన్ను నీకు దాసునిగా ఉంచుకొనుము అనెను."
            },
            {
                "id": "level_3_q12_A",
                "order": 12,
                "type": "skills_application",
                "timeLimitSeconds": 60,
                "points": 1030,
                "questionEn": "What was the name of the land in Egypt given to Jacob and his family to live in?",
                "questionTe": "యాకోబు మరియు అతని కుటుంబం నివసించడానికి ఐగుప్తులో ఇవ్వబడిన ప్రదేశము పేరు ఏమిటి?",
                "options": [],
                "correctAnswerEn": "Goshen",
                "correctAnswerTe": "గోషెను",
                "verseReferenceEn": "Genesis 47:11-27",
                "verseReferenceTe": "ఆదికాండము 47:11-27",
                "explanationEn": "Jacob and his family settled in the fertile land of Goshen in Egypt.",
                "explanationTe": "ఫరో ఆజ్ఞాపించినట్లు యోసేపు తన తండ్రికిని సహోదరులకును ఐగుప్తు దేశములోని గోషెనులో స్వాస్థ్యమిచ్చెను."
            }
        ],
        "B": [
            {
                "id": "level_3_q1_B",
                "order": 1,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "Which of Jacob's wives was the mother of Joseph?",
                "questionTe": "యాకోబు భార్యలలో యోసేపు తల్లి ఎవరు?",
                "options": [
                    {"id": "level_3_q1_B_opt1", "order": 1, "isCorrect": True, "textEn": "Rachel", "textTe": "రాహేలు"},
                    {"id": "level_3_q1_B_opt2", "order": 2, "isCorrect": False, "textEn": "Leah", "textTe": "లేయా"},
                    {"id": "level_3_q1_B_opt3", "order": 3, "isCorrect": False, "textEn": "Bilhah", "textTe": "బిల్హా"},
                    {"id": "level_3_q1_B_opt4", "order": 4, "isCorrect": False, "textEn": "Zilpah", "textTe": "జిల్పా"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 30:22-24",
                "verseReferenceTe": "ఆదికాండము 30:22-24",
                "explanationEn": "Rachel was the mother of Jacob's two youngest sons, Joseph and Benjamin.",
                "explanationTe": "దేవుడు రాహేలును జ్ఞాపకము చేసికొని ఆమె గర్భమును తెరిచెను, ఆమె యోసేపును కనెను."
            },
            {
                "id": "level_3_q2_B",
                "order": 2,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "What gift did Jacob give to Joseph that made his brothers jealous?",
                "questionTe": "యోసేపు సహోదరులకు అసూయ కలిగేలా యాకోబు అతనికి ఇచ్చిన కానుక ఏమిటి?",
                "options": [
                    {"id": "level_3_q2_B_opt1", "order": 1, "isCorrect": True, "textEn": "A coat of many colors", "textTe": "విచిత్రమైన నిలువుటంగీ"},
                    {"id": "level_3_q2_B_opt2", "order": 2, "isCorrect": False, "textEn": "A gold signet ring", "textTe": "బองారు ముద్ర ఉంగరము"},
                    {"id": "level_3_q2_B_opt3", "order": 3, "isCorrect": False, "textEn": "A silver cup", "textTe": "వెండి గిన్నె"},
                    {"id": "level_3_q2_B_opt4", "order": 4, "isCorrect": False, "textEn": "A double portion of sheep", "textTe": "రెట్టింపు గొర్రెలు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 37:3",
                "verseReferenceTe": "ఆదికాండము 37:3",
                "explanationEn": "Jacob loved Joseph more than all his children and made him a coat of many colors.",
                "explanationTe": "ఇశ్రాయేలు తన కుమారులందరికంటె యోసేపును ప్రేమించి అతని కొరకు విచిత్రమైన నిలువుటంగీ చేయించెను."
            },
            {
                "id": "level_3_q3_B",
                "order": 3,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "In Joseph's first dream, what were his brothers' sheaves doing to his sheaf?",
                "questionTe": "యోసేపు మొదటి కలలో, అతని సహోదరుల పనలు అతని పనకు ఏమి చేసాయి?",
                "options": [
                    {"id": "level_3_q3_B_opt1", "order": 1, "isCorrect": True, "textEn": "Bowing down to it", "textTe": "సాష్టాంగ నమస్కారం చేసాయి"},
                    {"id": "level_3_q3_B_opt2", "order": 2, "isCorrect": False, "textEn": "Burning it", "textTe": "కాల్చివేశాయి"},
                    {"id": "level_3_q3_B_opt3", "order": 3, "isCorrect": False, "textEn": "Stealing from it", "textTe": "దొంగిలించాయి"},
                    {"id": "level_3_q3_B_opt4", "order": 4, "isCorrect": False, "textEn": "Eating it", "textTe": "తినివేశాయి"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 37:7",
                "verseReferenceTe": "ఆదికాండము 37:7",
                "explanationEn": "In the dream, Joseph's sheaf stood upright and his brothers' sheaves bowed down to it.",
                "explanationTe": "కలలో నా పన నిలిచియుండగా మీ పనలు నా పన చుట్టును నిలిచి దానికి సాష్టాంగ నమస్కారము చేసెను."
            },
            {
                "id": "level_3_q4_B",
                "order": 4,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "Whose dreams did Joseph interpret while in prison?",
                "questionTe": "జైలులో ఉన్నప్పుడు యోసేపు ఎవరి కలలకు భావము చెప్పాడు?",
                "options": [
                    {"id": "level_3_q4_B_opt1", "order": 1, "isCorrect": True, "textEn": "The chief butler and the chief baker", "textTe": "పానదాయకుడు మరియు భక్ష్యకారుడు"},
                    {"id": "level_3_q4_B_opt2", "order": 2, "isCorrect": False, "textEn": "Pharaoh and the queen", "textTe": "ఫరో మరియు రాణి"},
                    {"id": "level_3_q4_B_opt3", "order": 3, "isCorrect": False, "textEn": "Potiphar and his wife", "textTe": "పోతిఫరు మరియు అతని భార్య"},
                    {"id": "level_3_q4_B_opt4", "order": 4, "isCorrect": False, "textEn": "Reuben and Judah", "textTe": "రూబేను మరియు యూదా"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 40:1-8",
                "verseReferenceTe": "ఆదికాండము 40:1-8",
                "explanationEn": "Joseph interpreted the prophetic dreams of Pharaoh's butler and baker in prison.",
                "explanationTe": "యోసేపు చెరసాలలో ఉన్నప్పుడు ఫరో పానదాయకునికి, భక్ష్యకారునికి వారి కలల భావము చెప్పెను."
            },
            {
                "id": "level_3_q5_B",
                "order": 5,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "How many years of famine did Pharaoh's dream predict?",
                "questionTe": "ఫరో కలలో ఎన్ని సంవత్సరాల కరవు వస్తుందని సూచించబడింది?",
                "options": [
                    {"id": "level_3_q5_B_opt1", "order": 1, "isCorrect": True, "textEn": "7 years", "textTe": "7 సంవత్సరాలు"},
                    {"id": "level_3_q5_B_opt2", "order": 2, "isCorrect": False, "textEn": "10 years", "textTe": "10 సంవత్సరాలు"},
                    {"id": "level_3_q5_B_opt3", "order": 3, "isCorrect": False, "textEn": "3 years", "textTe": "3 సంవత్సరాలు"},
                    {"id": "level_3_q5_B_opt4", "order": 4, "isCorrect": False, "textEn": "5 years", "textTe": "5 సంవత్సరాలు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 41:27",
                "verseReferenceTe": "ఆదికాండము 41:27",
                "explanationEn": "Pharaoh's dream predicted 7 years of great plenty followed by 7 years of famine.",
                "explanationTe": "ఏడు సన్నని ఆవులు, చెడ్డ పనలు రాబోవు ఏడు సంవత్సరముల కరవును సూచించును."
            },
            {
                "id": "level_3_q6_B",
                "order": 6,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "Which brother did Joseph keep in prison while the others returned to bring Benjamin?",
                "questionTe": "మిగిలిన సహోదరులు బెన్యామీనును తీసుకురావడానికి వెళ్ళినప్పుడు యోసేపు తన వద్ద బందీగా ఉంచుకున్న సహోదరుడు ఎవరు?",
                "options": [
                    {"id": "level_3_q6_B_opt1", "order": 1, "isCorrect": True, "textEn": "Simeon", "textTe": "షిమ్యోను"},
                    {"id": "level_3_q6_B_opt2", "order": 2, "isCorrect": False, "textEn": "Reuben", "textTe": "రూబేను"},
                    {"id": "level_3_q6_B_opt3", "order": 3, "isCorrect": False, "textEn": "Judah", "textTe": "యూదా"},
                    {"id": "level_3_q6_B_opt4", "order": 4, "isCorrect": False, "textEn": "Levi", "textTe": "లేవి"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 42:24",
                "verseReferenceTe": "ఆదికాండము 42:24",
                "explanationEn": "Joseph took Simeon from them and bound him before their eyes.",
                "explanationTe": "యోసేపు వారిలో నుండి షిమ్యోనును పట్టుకొని వారి కన్నుల యెదుట బంధించెను."
            },
            {
                "id": "level_3_q7_B",
                "order": 7,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1030,
                "questionEn": "Jacob wrestled with a man until the breaking of day.",
                "questionTe": "తెల్లవారేవరకు యాకోబు ఒక మనుష్యునితో పోరాడెను.",
                "options": [],
                "correctAnswerEn": "True",
                "correctAnswerTe": "నిజం",
                "verseReferenceEn": "Genesis 32:24",
                "verseReferenceTe": "ఆదికాండము 32:24",
                "explanationEn": "Jacob wrestled with a mysterious man (an angel/the Lord) until dawn.",
                "explanationTe": "యాకోబు ఒక్కడే మిగిలిపోయెను, తెల్లవారేవరకు ఒక మనుష్యుడు అతనితో పోరాడెను."
            },
            {
                "id": "level_3_q8_B",
                "order": 8,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1030,
                "questionEn": "Joseph's brothers immediately recognized him when they first arrived in Egypt.",
                "questionTe": "యోసేపు సహోదరులు ఐగుప్తుకు వచ్చినప్పుడు వెంటనే అతడిని గుర్తించారు.",
                "options": [],
                "correctAnswerEn": "False",
                "correctAnswerTe": "తప్పు",
                "verseReferenceEn": "Genesis 42:8",
                "verseReferenceTe": "ఆదికాండము 42:8",
                "explanationEn": "Joseph recognized his brothers, but they did not recognize him.",
                "explanationTe": "యోసేపు తన సహోదరులను గుర్తుపట్టెను గాని వారు అతనిని గుర్తుపట్టలేదు."
            },
            {
                "id": "level_3_q9_B",
                "order": 9,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1030,
                "questionEn": "Whose sack did Joseph hide his silver cup in?",
                "questionTe": "యోసేపు తన వెండి గిన్నెను ఎవరి సంచిలో దాచాడు?",
                "options": [],
                "correctAnswerEn": "Benjamin",
                "correctAnswerTe": "బెన్యామీను",
                "verseReferenceEn": "Genesis 44:1-2",
                "verseReferenceTe": "ఆదికాండము 44:1-2",
                "explanationEn": "Joseph commanded to put his personal silver cup in Benjamin's sack.",
                "explanationTe": "యోసేపు నా గిన్నెను, అనగా ఆ వెండి గిన్నెను ఆ చిన్నవాని (బెన్యామీను) సంచి మూతిలో ఉంచుమనెను."
            },
            {
                "id": "level_3_q10_B",
                "order": 10,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1030,
                "questionEn": "Who was Joseph's younger brother, the only other son of Rachel?",
                "questionTe": "రాహేలుకు జన్మించిన యోసేపు తమ్ముడి పేరు ఏమిటి?",
                "options": [],
                "correctAnswerEn": "Benjamin",
                "correctAnswerTe": "బెన్యామీను",
                "verseReferenceEn": "Genesis 35:18",
                "verseReferenceTe": "ఆదికాండము 35:18",
                "explanationEn": "Rachel died giving birth to Jacob's youngest son, Benjamin.",
                "explanationTe": "యాకోబుకు రాహేలు వల్ల జన్మించిన రెండవ కుమారుడు బెన్యామీను."
            },
            {
                "id": "level_3_q11_B",
                "order": 11,
                "type": "mixed_format",
                "timeLimitSeconds": 45,
                "points": 1030,
                "questionEn": "Who was the daughter of Laban that Jacob was tricked into marrying first?",
                "questionTe": "యాకోబు మోసగించబడి మొదట వివాహం చేసుకున్న లాబాను పెద్ద కుమార్తె ఎవరు?",
                "options": [
                    {"id": "level_3_q11_B_opt1", "order": 1, "isCorrect": True, "textEn": "Leah", "textTe": "లేయా"},
                    {"id": "level_3_q11_B_opt2", "order": 2, "isCorrect": False, "textEn": "Rachel", "textTe": "రాహేలు"},
                    {"id": "level_3_q11_B_opt3", "order": 3, "isCorrect": False, "textEn": "Bilhah", "textTe": "బిల్హా"},
                    {"id": "level_3_q11_B_opt4", "order": 4, "isCorrect": False, "textEn": "Zilpah", "textTe": "జిల్పా"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 29:23-25",
                "verseReferenceTe": "ఆదికాండము 29:23-25",
                "explanationEn": "Laban switched Leah for Rachel on the wedding night.",
                "explanationTe": "లాబాను యాకోబును మోసగించి రాహేలుకు బదులుగా లేయాను అతని యొద్దకు తీసుకొనివచ్చెను."
            },
            {
                "id": "level_3_q12_B",
                "order": 12,
                "type": "skills_application",
                "timeLimitSeconds": 60,
                "points": 1030,
                "questionEn": "Who was the priest of On, whose daughter Asenath married Joseph?",
                "questionTe": "యోసేపు వివాహం చేసుకున్న ఆసెనతు యొక్క తండ్రి మరియు ఓను పట్టణపు యాజకుడు ఎవరు?",
                "options": [],
                "correctAnswerEn": "Potipherah",
                "correctAnswerTe": "పోతిఫెర",
                "verseReferenceEn": "Genesis 41:45",
                "verseReferenceTe": "ఆదికాండము 41:45",
                "explanationEn": "Pharaoh gave Joseph Asenath, the daughter of Potipherah priest of On, as a wife.",
                "explanationTe": "ఫరో ఓను పట్టణపు యాజకుడైన పోతిఫెర కుమార్తెయైన ఆసెనతును యోసేపునకు భార్యగా ఇచ్చెను."
            }
        ],
        "C": [
            {
                "id": "level_3_q1_C",
                "order": 1,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "What did Esau plan to do to Jacob after Jacob stole the blessing?",
                "questionTe": "యాకోబు తన ఆశీర్వాదమును దొంగిలించినందుకు ఏశావు ఏమి చేయాలని అనుకున్నాడు?",
                "options": [
                    {"id": "level_3_q1_C_opt1", "order": 1, "isCorrect": True, "textEn": "Kill him", "textTe": "చంపాలని"},
                    {"id": "level_3_q1_C_opt2", "order": 2, "isCorrect": False, "textEn": "Make him a servant", "textTe": "తన దాసునిగా చేసుకోవాలని"},
                    {"id": "level_3_q1_C_opt3", "order": 3, "isCorrect": False, "textEn": "Exile him", "textTe": "వెలివేయాలని"},
                    {"id": "level_3_q1_C_opt4", "order": 4, "isCorrect": False, "textEn": "Forgive him", "textTe": "క్షమించాలని"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 27:41",
                "verseReferenceTe": "ఆదికాండము 27:41",
                "explanationEn": "Esau hated Jacob and planned to kill him after Isaac's mourning period.",
                "explanationTe": "ఏశావు నా తండ్రి కొరకు ఏడ్చు దినములు సమీపముగా ఉన్నవి; అప్పుడు నా తమ్ముడైన యాకోబును చంపెదననుకొనెను."
            },
            {
                "id": "level_3_q2_C",
                "order": 2,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "Where did Jacob flee to escape Esau's anger?",
                "questionTe": "ఏశావు కోపం నుండి తప్పించుకోవడానికి యాకోబు ఎక్కడికి పారిపోయాడు?",
                "options": [
                    {"id": "level_3_q2_C_opt1", "order": 1, "isCorrect": True, "textEn": "Haran (to Laban)", "textTe": "హారాను (లాబాను వద్దకు)"},
                    {"id": "level_3_q2_C_opt2", "order": 2, "isCorrect": False, "textEn": "Egypt", "textTe": "ఐగుప్తు"},
                    {"id": "level_3_q2_C_opt3", "order": 3, "isCorrect": False, "textEn": "Sodom", "textTe": "సొదొమ"},
                    {"id": "level_3_q2_C_opt4", "order": 4, "isCorrect": False, "textEn": "Beersheba", "textTe": "బెయేర్షెబా"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 27:43",
                "verseReferenceTe": "ఆదికాండము 27:43",
                "explanationEn": "Rebekah warned Jacob to flee to her brother Laban in Haran.",
                "explanationTe": "నీవు లేచి హారానులోనున్న నా సహోదరుడైన లాబాను వద్దకు పారిపోవుము."
            },
            {
                "id": "level_3_q3_C",
                "order": 3,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "Which of Jacob's sons was born on the way to Ephrath, where Rachel died?",
                "questionTe": "రాహేలు మరణించిన ఎఫ్రాతా మార్గములో జన్మించిన యాకోబు కుమారుడు ఎవరు?",
                "options": [
                    {"id": "level_3_q3_C_opt1", "order": 1, "isCorrect": True, "textEn": "Benjamin", "textTe": "బెన్యామీను"},
                    {"id": "level_3_q3_C_opt2", "order": 2, "isCorrect": False, "textEn": "Joseph", "textTe": "యోసేపు"},
                    {"id": "level_3_q3_C_opt3", "order": 3, "isCorrect": False, "textEn": "Judah", "textTe": "యూదా"},
                    {"id": "level_3_q3_C_opt4", "order": 4, "isCorrect": False, "textEn": "Simeon", "textTe": "షిమ్యోను"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 35:16-18",
                "verseReferenceTe": "ఆదికాండము 35:16-18",
                "explanationEn": "Benjamin was born near Ephrath, and his mother Rachel died during childbirth.",
                "explanationTe": "ఎఫ్రాతాకు వెళ్ళు మార్గములో రాహేలు ప్రసవవేదనపడి మరణించుచు అతనికి బెన్యామీను అని పేరు పెట్టెను."
            },
            {
                "id": "level_3_q4_C",
                "order": 4,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "In Joseph's second dream, what did the sun, moon, and eleven stars bow down to?",
                "questionTe": "యోసేపు రెండవ కలలో, సూర్య చంద్రులు మరియు పదకొండు నక్షత్రాలు దేనికి నమస్కరించాయి?",
                "options": [
                    {"id": "level_3_q4_C_opt1", "order": 1, "isCorrect": True, "textEn": "Joseph", "textTe": "యోసేపుకు"},
                    {"id": "level_3_q4_C_opt2", "order": 2, "isCorrect": False, "textEn": "A crown", "textTe": "ఒక కిరీటమునకు"},
                    {"id": "level_3_q4_C_opt3", "order": 3, "isCorrect": False, "textEn": "An altar", "textTe": "ఒక బలిపీఠమునకు"},
                    {"id": "level_3_q4_C_opt4", "order": 4, "isCorrect": False, "textEn": "A tree", "textTe": "ఒక చెట్టుకు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 37:9",
                "verseReferenceTe": "ఆదికాండము 37:9",
                "explanationEn": "In Joseph's second dream, the sun, moon, and eleven stars bowed down to him.",
                "explanationTe": "సూర్యుడును చంద్రుడును పదకొండు నక్షత్రములును నాకు సాష్టాంగ నమస్కారము చేయుట చూచితిని."
            },
            {
                "id": "level_3_q5_C",
                "order": 5,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "How many members of Jacob's family came down to Egypt in total?",
                "questionTe": "యాకోబు కుటుంబ సభ్యులు మొత్తం ఎంతమంది ఐగుప్తుకు వచ్చారు?",
                "options": [
                    {"id": "level_3_q5_C_opt1", "order": 1, "isCorrect": True, "textEn": "70", "textTe": "70 మంది"},
                    {"id": "level_3_q5_C_opt2", "order": 2, "isCorrect": False, "textEn": "12", "textTe": "12 మంది"},
                    {"id": "level_3_q5_C_opt3", "order": 3, "isCorrect": False, "textEn": "50", "textTe": "50 మంది"},
                    {"id": "level_3_q5_C_opt4", "order": 4, "isCorrect": False, "textEn": "120", "textTe": "120 మంది"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 46:27",
                "verseReferenceTe": "ఆదికాండము 46:27",
                "explanationEn": "All the souls of the house of Jacob that came into Egypt were seventy.",
                "explanationTe": "ఐగుప్తుకు వచ్చిన యాకోబు కుటుంబపు వారందరి సంఖ్య డెబ్బది."
            },
            {
                "id": "level_3_q6_C",
                "order": 6,
                "type": "multiple_choice",
                "timeLimitSeconds": 35,
                "points": 1030,
                "questionEn": "Where did Jacob make his sons promise to bury him after his death?",
                "questionTe": "యాకోబు మరణించిన తరువాత తనను ఎక్కడ సమాధి చేయాలని కుమారుల చేత ప్రమాణము చేయించుకున్నాడు?",
                "options": [
                    {"id": "level_3_q6_C_opt1", "order": 1, "isCorrect": True, "textEn": "Cave of Machpelah", "textTe": "మక్పేలా గుహ"},
                    {"id": "level_3_q6_C_opt2", "order": 2, "isCorrect": False, "textEn": "Goshen", "textTe": "గోషెను"},
                    {"id": "level_3_q6_C_opt3", "order": 3, "isCorrect": False, "textEn": "Bethel", "textTe": "బేతేలు"},
                    {"id": "level_3_q6_C_opt4", "order": 4, "isCorrect": False, "textEn": "Egypt", "textTe": "ఐగుప్తు"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 49:29-30",
                "verseReferenceTe": "ఆదికాండము 49:29-30",
                "explanationEn": "Jacob commanded to be buried in the cave of Machpelah with his fathers.",
                "explanationTe": "నన్ను హెబ్రోనులోనున్న మక్పేలా గుహలో నా పితరులతో కూడ సమాధి చేయుడి."
            },
            {
                "id": "level_3_q7_C",
                "order": 7,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1030,
                "questionEn": "Leah had tender (weak) eyes, but Rachel was beautiful and well-favored.",
                "questionTe": "లేయా నయనములు మెత్తనవి, కానీ రాహేలు రూపవతియు సుందరియునై యుండెను.",
                "options": [],
                "correctAnswerEn": "True",
                "correctAnswerTe": "నిజం",
                "verseReferenceEn": "Genesis 29:17",
                "verseReferenceTe": "ఆదికాండము 29:17",
                "explanationEn": "Leah's eyes were delicate, but Rachel had a lovely figure and beautiful face.",
                "explanationTe": "లేయా నయనములు మెత్తనవి, రాహేలు రూపవతియు సుందరియునై యుండెను."
            },
            {
                "id": "level_3_q8_C",
                "order": 8,
                "type": "true_false",
                "timeLimitSeconds": 25,
                "points": 1030,
                "questionEn": "Joseph's bones were carried out of Egypt and buried in Canaan.",
                "questionTe": "యోసేపు ఎముకలు ఐగుప్తు నుండి తీసుకుపోబడి కనానులో సమాధి చేయబడ్డాయి.",
                "options": [],
                "correctAnswerEn": "True",
                "correctAnswerTe": "నిజం",
                "verseReferenceEn": "Genesis 50:25 & Joshua 24:32",
                "verseReferenceTe": "ఆదికాండము 50:25 & యెహోషువ 24:32",
                "explanationEn": "The Israelites kept Joseph's promise and buried his bones in Shechem.",
                "explanationTe": "ఇశ్రాయేలీయులు యోసేపు ఎముకలను ఐగుప్తు నుండి తెచ్చి షెకెములో సమాధి చేసిరి."
            },
            {
                "id": "level_3_q9_C",
                "order": 9,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1030,
                "questionEn": "What did Joseph name his firstborn son, meaning 'God has made me forget all my toil'?",
                "questionTe": "దేవుడు నా ప్రయాసనంతటిని మరచిపోవునట్లు చేసెను అని అర్థం వచ్చేలా యోసేపు తన జ్యేష్ఠ కుమారునికి ఏ పేరు పెట్టాడు?",
                "options": [],
                "correctAnswerEn": "Manasseh",
                "correctAnswerTe": "మనష్షే",
                "verseReferenceEn": "Genesis 41:51",
                "verseReferenceTe": "ఆదికాండము 41:51",
                "explanationEn": "Joseph named his firstborn Manasseh because God made him forget his hardships.",
                "explanationTe": "దేవుడు నా ప్రయాసనంతటిని నా తండ్రి యిల్లింతటిని మరచిపోవునట్లు చేసెనని తన జ్యేష్ఠ కుమారునికి మనష్షే అని పేరు పెట్టెను."
            },
            {
                "id": "level_3_q10_C",
                "order": 10,
                "type": "type_answer",
                "timeLimitSeconds": 60,
                "points": 1030,
                "questionEn": "What did Joseph name his second son, meaning 'God has caused me to be fruitful in the land of my affliction'?",
                "questionTe": "నేను బాధపడిన దేశములో దేవుడు నన్ను అభివృద్ధి పొందించెను అని అర్థం వచ్చేలా యోసేపు తన రెండవ కుమారునికి ఏ పేరు పెట్టాడు?",
                "options": [],
                "correctAnswerEn": "Ephraim",
                "correctAnswerTe": "ఎఫ్రాయిము",
                "verseReferenceEn": "Genesis 41:52",
                "verseReferenceTe": "ఆదికాండము 41:52",
                "explanationEn": "Joseph named his second son Ephraim because God made him fruitful in his suffering.",
                "explanationTe": "నేను బాధపడిన దేశములో దేవుడు నన్ను అభివృద్ధి పొందించెనని తన రెండవ కుమారునికి ఎఫ్రాయిము అని పేరు పెట్టెను."
            },
            {
                "id": "level_3_q11_C",
                "order": 11,
                "type": "mixed_format",
                "timeLimitSeconds": 45,
                "points": 1030,
                "questionEn": "Which of Jacob's sons did NOT receive a specific blessing in Genesis 49 due to his unstable nature, but was the firstborn?",
                "questionTe": "ఆదికాండము 49 లో నీటివలె చంచలుడవైనందున ఆశీర్వాద శ్రేష్ఠత్వమును పోగొట్టుకున్న యాకోబు జ్యేష్ఠ కుమారుడు ఎవరు?",
                "options": [
                    {"id": "level_3_q11_C_opt1", "order": 1, "isCorrect": True, "textEn": "Reuben", "textTe": "రూబేను"},
                    {"id": "level_3_q11_C_opt2", "order": 2, "isCorrect": False, "textEn": "Simeon", "textTe": "షిమ్యోను"},
                    {"id": "level_3_q11_C_opt3", "order": 3, "isCorrect": False, "textEn": "Levi", "textTe": "లేవి"},
                    {"id": "level_3_q11_C_opt4", "order": 4, "isCorrect": False, "textEn": "Judah", "textTe": "యూదా"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": "Genesis 49:3-4",
                "verseReferenceTe": "ఆదికాండము 49:3-4",
                "explanationEn": "Reuben lost his birthright blessing due to instability and defiling his father's bed.",
                "explanationTe": "రూబేను నీవు నీటివలె చంచలుడవైనందున శ్రేష్ఠత్వమును పొందవు అని యాకోబు చెప్పెను."
            },
            {
                "id": "level_3_q12_C",
                "order": 12,
                "type": "skills_application",
                "timeLimitSeconds": 60,
                "points": 1030,
                "questionEn": "Who was the mother of Ephraim and Manasseh?",
                "questionTe": "ఎఫ్రాయిము మనష్షేల తల్లి పేరు ఏమిటి?",
                "options": [],
                "correctAnswerEn": "Asenath",
                "correctAnswerTe": "ఆసెనతు",
                "verseReferenceEn": "Genesis 41:50",
                "verseReferenceTe": "ఆదికాండము 41:50",
                "explanationEn": "Asenath, daughter of Potipherah priest of On, bore Manasseh and Ephraim to Joseph.",
                "explanationTe": "ఓను యాజకుడైన పోతిఫెర కుమార్తెయైన ఆసెనతు యోసేపునకు ఎఫ్రాయిమును మనష్షేను కనెను."
            }
        ]
    }

    # Generate Templated Questions for Levels 4-100
    for level in range(4, 101):
        level_str = str(level)
        levels[level_str] = {}
        
        topic_name_en, book_en, book_te = get_level_info(level)
        
        for set_id in ["A", "B", "C"]:
            questions = []
            
            # Q1-Q6: multiple_choice
            for q_num in range(1, 7):
                questions.append({
                    "id": f"level_{level}_q{q_num}_{set_id}",
                    "order": q_num,
                    "type": "multiple_choice",
                    "timeLimitSeconds": 35,
                    "points": 1000 + level * 10,
                    "questionEn": f"Level {level} Set {set_id} - {topic_name_en}: Templated Multiple Choice Question {q_num}?",
                    "questionTe": f"స్థాయి {level} సెట్ {set_id} - {book_te}: టెంప్లేట్ బహుళైచ్ఛిక ప్రశ్న {q_num}?",
                    "options": [
                        {"id": f"level_{level}_q{q_num}_{set_id}_opt1", "order": 1, "isCorrect": True, "textEn": f"Correct Option for Q{q_num}", "textTe": f"Q{q_num} కొరకు సరైన ఎంపిక"},
                        {"id": f"level_{level}_q{q_num}_{set_id}_opt2", "order": 2, "isCorrect": False, "textEn": f"Incorrect Option 1 for Q{q_num}", "textTe": f"Q{q_num} కొరకు తప్పు ఎంపిక 1"},
                        {"id": f"level_{level}_q{q_num}_{set_id}_opt3", "order": 3, "isCorrect": False, "textEn": f"Incorrect Option 2 for Q{q_num}", "textTe": f"Q{q_num} కొరకు తప్పు ఎంపిక 2"},
                        {"id": f"level_{level}_q{q_num}_{set_id}_opt4", "order": 4, "isCorrect": False, "textEn": f"Incorrect Option 3 for Q{q_num}", "textTe": f"Q{q_num} కొరకు తప్పు ఎంపిక 3"}
                    ],
                    "correctAnswerEn": None,
                    "correctAnswerTe": None,
                    "verseReferenceEn": f"{book_en} 1:1",
                    "verseReferenceTe": f"{book_te} 1:1",
                    "explanationEn": f"This is a templated explanation for Level {level} Q{q_num} Set {set_id}.",
                    "explanationTe": f"ఇది స్థాయి {level} ప్రశ్న {q_num} సెట్ {set_id} కొరకు టెంప్లేట్ వివరణ."
                })
                
            # Q7-Q8: true_false
            for q_num in range(7, 9):
                questions.append({
                    "id": f"level_{level}_q{q_num}_{set_id}",
                    "order": q_num,
                    "type": "true_false",
                    "timeLimitSeconds": 25,
                    "points": 1000 + level * 10,
                    "questionEn": f"Level {level} Set {set_id} - {topic_name_en}: Templated True/False Question {q_num}?",
                    "questionTe": f"స్థాయి {level} సెట్ {set_id} - {book_te}: టెంప్లేట్ నిజమా/తప్పా ప్రశ్న {q_num}?",
                    "options": [],
                    "correctAnswerEn": "True",
                    "correctAnswerTe": "నిజం",
                    "verseReferenceEn": f"{book_en} 1:1",
                    "verseReferenceTe": f"{book_te} 1:1",
                    "explanationEn": f"This is a templated explanation for Level {level} Q{q_num} Set {set_id}.",
                    "explanationTe": f"ఇది స్థాయి {level} ప్రశ్న {q_num} సెట్ {set_id} కొరకు టెంప్లేట్ వివరణ."
                })
                
            # Q9-Q10: type_answer
            for q_num in range(9, 11):
                questions.append({
                    "id": f"level_{level}_q{q_num}_{set_id}",
                    "order": q_num,
                    "type": "type_answer",
                    "timeLimitSeconds": 60,
                    "points": 1000 + level * 10,
                    "questionEn": f"Level {level} Set {set_id} - {topic_name_en}: Templated Short Answer Question {q_num}?",
                    "questionTe": f"స్థాయి {level} సెట్ {set_id} - {book_te}: టెంప్లేట్ సంక్షిప్త సమాధాన ప్రశ్న {q_num}?",
                    "options": [],
                    "correctAnswerEn": "Amen",
                    "correctAnswerTe": "ఆమేన్",
                    "verseReferenceEn": f"{book_en} 1:1",
                    "verseReferenceTe": f"{book_te} 1:1",
                    "explanationEn": f"This is a templated explanation for Level {level} Q{q_num} Set {set_id}.",
                    "explanationTe": f"ఇది స్థాయి {level} ప్రశ్న {q_num} సెట్ {set_id} కొరకు టెంప్లేట్ వివరణ."
                })
                
            # Q11: mixed_format
            q_num = 11
            questions.append({
                "id": f"level_{level}_q{q_num}_{set_id}",
                "order": q_num,
                "type": "mixed_format",
                "timeLimitSeconds": 45,
                "points": 1000 + level * 10,
                "questionEn": f"Level {level} Set {set_id} - {topic_name_en}: Templated Mixed Question {q_num}?",
                "questionTe": f"స్థాయి {level} సెట్ {set_id} - {book_te}: టెంప్లేట్ మిశ్రమ ప్రశ్న {q_num}?",
                "options": [
                    {"id": f"level_{level}_q{q_num}_{set_id}_opt1", "order": 1, "isCorrect": True, "textEn": f"Correct Option for Q{q_num}", "textTe": f"Q{q_num} కొరకు సరైన ఎంపిక"},
                    {"id": f"level_{level}_q{q_num}_{set_id}_opt2", "order": 2, "isCorrect": False, "textEn": f"Incorrect Option 1 for Q{q_num}", "textTe": f"Q{q_num} కొరకు తప్పు ఎంపిక 1"},
                    {"id": f"level_{level}_q{q_num}_{set_id}_opt3", "order": 3, "isCorrect": False, "textEn": f"Incorrect Option 2 for Q{q_num}", "textTe": f"Q{q_num} కొరకు తప్పు ఎంపిక 2"},
                    {"id": f"level_{level}_q{q_num}_{set_id}_opt4", "order": 4, "isCorrect": False, "textEn": f"Incorrect Option 3 for Q{q_num}", "textTe": f"Q{q_num} కొరకు తప్పు ఎంపిక 3"}
                ],
                "correctAnswerEn": None,
                "correctAnswerTe": None,
                "verseReferenceEn": f"{book_en} 1:1",
                "verseReferenceTe": f"{book_te} 1:1",
                "explanationEn": f"This is a templated explanation for Level {level} Q{q_num} Set {set_id}.",
                "explanationTe": f"ఇది స్థాయి {level} ప్రశ్న {q_num} సెట్ {set_id} కొరకు టెంప్లేట్ వివరణ."
            })
            
            # Q12: skills_application
            q_num = 12
            questions.append({
                "id": f"level_{level}_q{q_num}_{set_id}",
                "order": q_num,
                "type": "skills_application",
                "timeLimitSeconds": 60,
                "points": 1000 + level * 10,
                "questionEn": f"Level {level} Set {set_id} - {topic_name_en}: Templated Skills Question {q_num}?",
                "questionTe": f"స్థాయి {level} సెట్ {set_id} - {book_te}: టెంప్లేట్ నైపుణ్యాల అన్వయ ప్రశ్న {q_num}?",
                "options": [],
                "correctAnswerEn": "Jesus",
                "correctAnswerTe": "యేసు",
                "verseReferenceEn": f"{book_en} 1:1",
                "verseReferenceTe": f"{book_te} 1:1",
                "explanationEn": f"This is a templated explanation for Level {level} Q{q_num} Set {set_id}.",
                "explanationTe": f"ఇది స్థాయి {level} ప్రశ్న {q_num} సెట్ {set_id} కొరకు టెంప్లేట్ వివరణ."
            })
            
            levels[level_str][set_id] = questions

    # Final Output Structure
    output_data = {
        "levels": levels
    }

    # Save to file
    output_path = "/home/david/Desktop/Bible Quiz/assets/real_questions.json"
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(output_data, f, ensure_ascii=False, indent=2)

    # Report results
    total_questions = 0
    for lvl, sets in levels.items():
        for s_id, qs in sets.items():
            total_questions += len(qs)
            
    print(f"Generated {total_questions} questions across {len(levels)} levels.")
    print(f"Output saved to {output_path}")
    print(f"File size: {os.path.getsize(output_path) / 1024 / 1024:.2f} MB")

if __name__ == "__main__":
    main()
