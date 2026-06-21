import os
import re
import sqlite3
import sys
import xml.etree.ElementTree as ET

DB_PATH = "/home/david/Music/Bible Quiz/assets/bible/telugu_ov.sqlite"
XML_PATH = "/tmp/bible_ref/Telugu Bible (BSI).xml"
BIBLE_SERVICE_PATH = "/home/david/Music/Bible Quiz/lib/services/bible_service.dart"

def load_books_metadata(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    pattern = r"BibleBook\(\s*id:\s*'([^']+)',\s*nameEn:\s*'([^']+)',\s*nameTe:\s*'([^']+)',\s*chapters:\s*(\d+),\s*testament:\s*'([^']+)'\s*\)"
    matches = re.findall(pattern, content)
    books = []
    for idx, m in enumerate(matches):
        books.append({
            'book_number': idx + 1,
            'id': m[0],
            'nameEn': m[1],
            'nameTe': m[2],
            'chapters': int(m[3])
        })
    return books

def fix_text(text):
    if not text:
        return text
        
    fixes = {
        "దేవునిదృష్టికనుకూలమై": "దేవుని దృష్టికనుకూలమై",
        "ఆజ్ఞాపించుముపాపపరిహారార్థబలిని": "ఆజ్ఞాపించుము పాపపరిహారార్థబలిని",
        "సంతోషించుచున్నానునావిరోధులమీద": "సంతోషించుచున్నాను నా విరోధులమీద",
        "ఓడిపోవుదురుతొట్రిల్లినవారు": "ఓడిపోవుదురు తొట్రిల్లినవారు",
        "నాశనమగుదురుపరమండలములోనుండి": "నాశనమగుదురు పరమండలములోనుండి",
        "నున్నాడనగాఒసౌలుయెష్షయియొద్దకు": "నున్నాడనగా సౌలు యెష్షయియొద్దకు",
        "నిష్కారణముగాచిందించినందుకేగాని": "నిష్కారణముగా చిందించినందుకేగాని",
        "యొద్దవిచారించినప్పుడుపొమ్ము": "యొద్ద విచారించినప్పుడు పొమ్ము",
        "నున్నామనిప్రత్యుత్తరమిచ్చి": "నున్నామని ప్రత్యుత్తరమిచ్చి",
        "లోపలికిపోయిమీరేలగొల్లుచేసి": "లోపలికిపోయి మీరేల గొల్లుచేసి",
        "ధర్మశాస్త్రోపదేశకుడొకడుబోధకుడా": "ధర్మశాస్త్రోపదేశకుడొకడు బోధకుడా",
        "బంట్రౌతులలొఒకడుప్రధానయాజకునికి": "బంట్రౌతులలో ఒకడు ప్రధానయాజకునికి",
        "వారుపరిశుద్ధాత్ముడున్నాడన్న": "వారు పరిశుద్ధాత్ముడున్నాడన్న",
        "సున్నతిలేనివారినిగూర్చికూడ": "సున్నతిలేనివారిని గూర్చికూడ",
        "ఎందుకనగాధర్మశాస్త్రగ్రంథమందు": "ఎందుకనగా ధర్మశాస్త్రగ్రంథమందు",
        "రూపకమైనవనియెంచబడుచున్నవేగాని": "రూపకమైనవని యెంచబడుచున్నవేగాని",
        "చెల్లించిపుచ్చుకొనునిమిత్తము": "చెల్లించి పుచ్చుకొనునిమిత్తము",
        "భిన్నమైనబోధనుపదేశించినయెడల": "భిన్నమైన బోధను ఉపదేశించినయెడల",
        "ఎవనినిగూర్చియైనయెప్పుడైనను": "ఎవనిని గూర్చియైన యెప్పుడైనను",
        "సింహాసనాసీనుడైయున్నవాడుఇదిగో": "సింహాసనాసీనుడైయున్నవాడు ఇదిగో",
        "సెలవిచ్చునదేమనగావధకేర్పడిన": "సెలవిచ్చునదేమనగా వధకేర్పడిన",
        "సెలవిచ్చునదేమనగానన్నుగూర్చి": "సెలవిచ్చునదేమనగా నన్నుగూర్చి",
        "కుటుంబమువారినందరినిగూర్చియు": "కుటుంబమువారినందరిని గూర్చియు",
        "ద్రాక్షారసమువంటివారైయెహోవా": "ద్రాక్షారసమువంటివారై యెహోవా",
        "బంట్రౌతులలొ": "బంట్రౌతులలో",
        "ఒసౌలు": "సౌలు",
        "ప్రత్యుత్తరమిచ్చువాడెవడును": "ప్రత్యుత్తరమిచ్చువాడు ఎవడును",
        "స్వస్థతకలుగవచ్చుననిచెప్పుము": "స్వస్థత కలుగవచ్చునని చెప్పుము",
        "ప్రత్యుత్తరమిచ్చెనుఇశ్రాయేలువారి": "ప్రత్యుత్తరమిచ్చెను ఇశ్రాయేలువారి",
        "కిర్యత్యారీముకుమారులెవరనగా": "కిర్యత్యారీము కుమారులెవరనగా",
        "అర్ధగోత్రవంశస్థానములోనుండి": "అర్ధగోత్ర వంశస్థానములోనుండి",
        "అర్ధగోత్రవంశస్థ": "అర్ధగోత్ర వంశస్థ",
        "ఆశ్చర్యకార్యములనుప్రచురించుడి": "ఆశ్చర్యకార్యములను ప్రచురించుడి",
        "ఆశ్చర్యకార్యముల": "ఆశ్చర్యకార్యముల",
        "ప్రతిష్ఠించుకొనకుండుటచేతను": "ప్రతిష్ఠించుకొనకుండుట చేతను",
        "ప్రత్యుత్తరమిచ్చెనురాణియైన": "ప్రత్యుత్తరమిచ్చెను రాణియైన",
        "బద్దలైపోవుదురుఎన్నికలేనివారై": "బద్దలైపోవుదురు ఎన్నికలేనివారై",
        "చేరునట్లుపూర్ణవయస్సుగలవాడవై": "చేరునట్లు పూర్ణవయస్సుగలవాడవై",
        "క్రుంగిపోయినవాడుసర్వశక్తుడగు": "క్రుంగిపోయినవాడు సర్వశక్తుడగు",
        "విశాలпороచువాడుసముద్రతరంగములమీద": "విశాలపరచువాడు సముద్రతరంగములమీద",
        "త్వరగాగతించుచున్నవిక్షేమము": "త్వరగా గతించుచున్నవి క్షేమము",
        "పుట్టిననాటికిగానిబుద్ధిహీనుడు": "పుట్టిననాటికిగాని బుద్ధిహీనుడు",
        "స్వభావలక్షణములుమోసపడువారును": "స్వభావలక్షణములు మోసపడువారును",
        "నిర్మూలముచేయునుసరిహద్దులను": "నిర్మూలము చేయును సరిహద్దులను",
        "తడబడుచుందురుమత్తుగొనినవాడు": "తడబడుచుందురు మత్తుగొనినవాడు",
        "రక్షణార్థమైనదగునుభక్తిహీనుడు": "రక్షణార్థమైనదగును భక్తిహీనుడు",
        "వస్త్రమువంటివానిచుట్టుగిఱిగీసి": "వస్త్రమువంటివాని చుట్టుగిఱిగీసి",
        "అప్పగించియున్నాడుభక్తిహీనుల": "అప్పగించియున్నాడు భక్తిహీనుల",
        "చుట్టుకొనుచున్నవికనికరములేక": "చుట్టుకొనుచున్నవి కనికరములేక",
        "విడువకప్రవర్తించుదురునిరపరాధులు": "విడువక ప్రవర్తించుదురు నిరపరాధులు",
        "శిక్షనుచూచివిస్మయమొందుదురుపూర్వముండినవారు": "శిక్షనుచూచి విస్మయమొందుదురు పూర్వముండినవారు",
        "కొట్టివేసియున్నాడుతలమీదనుండి": "కొట్టిвеసియున్నాడు తలమీదనుండి",
        "కొద్దికాలముండునుభక్తిహీనులకు": "కొద్దికాలముండును భక్తిహీనులకు",
        "ఇబ్బందిపడుదురుదురవస్థలోనుండు": "ఇబ్బందిపడుదురు దురవస్థలోనుండు",
        "అంధకారపూర్ణములగునుఊదనక్కరలేని": "అంధకారపూర్ణములగును ఊదనక్కరలేని",
        "నీళ్లియ్యవైతివిఆకలిగొనినవానికి": "నీళ్లియ్యవైతివి ఆకలిగొనినవానికి",
        "పంపివేసితివితండ్రిలేనివారి": "పంపివేసితివి తండ్రిలేనివారి",
        "తొలగిపొమ్మనియుసర్వశక్తుడగు": "తొలగిపొమ్మనియు సర్వశక్తుడగు",
        "కరిందిభాగములుకరుకైనచిల్లపెంకులవలె": "క్రిందిభాగములు కరుకైన చిల్లపెంకులవలె",
        "క్రిందిభాగములుకరుకైనచిల్లపెంకులవలె": "క్రిందిభాగములు కరుకైన చిల్లపెంకులవలె",
        "విస్తరించియున్నారునామీదికి": "విస్తరించియున్నారు నామీదికి",
        "మందిరములోప్రవేశించెదనునీయెడల": "మందిరములో ప్రవేశించెదను నీయెడల",
        "అంతరింద్రియములనుపరిశీలించు": "అంతరింద్రియములను పరిశీలించు",
        "సంతోషించిహర్షించుచున్నానునీ": "సంతోషించి హర్షించుచున్నాను నీ",
        "అప్పగించుకొందురుతండ్రిలేనివారికి": "అప్పగించుకొందురు తండ్రిలేనివారికి",
        "శరణుజొచ్చియున్నానుపక్షివలె": "శరణుజొచ్చియున్నాను పక్షివలె",
        "బలాత్కారమునుబట్టియుదరిద్రుల": "బలాత్కారమునుబట్టియు దరిద్రుల",
        "చెడియున్నారుమేలుచేయువారెవరును": "చెడియున్నారు మేలుచేయువారెవరును",
        "దురాలోచనయుకానరాలేదునోటిమాటచేత": "దురాలోచనయు కానరాలేదు నోటిమాటచేత",
        "గొట్టుముదుష్టునిచేతిలోనుండి": "గొట్టుము దుష్టుని చేతిలోనుండి",
        "అనుసరించుచున్నానుభక్తిహీనుడనై": "అనుసరించుచున్నాను భక్తిహీనుడనై",
        "నన్నుహెచ్చించుదువుబలాత్కారముచేయు": "నన్ను హెచ్చించుదువు బలాత్కారముచేయు",
        "దుష్టులబలాత్కారమునుబట్టియు": "దుష్టుల బలాత్కారమునుబట్టియు",
        "అన్నిటిమీదరాజ్యపరిపాలనచేయుచున్నాడు": "అన్నిటిమీద రాజ్యపరిపాలన చేయుచున్నాడు",
        "దుష్టమార్గములన్నిటిలోనుండి": "దుష్టమార్గములన్నిటిలో నుండి",
        "ముద్దుపెట్టుకొనినట్లుండును": "ముద్దు పెట్టుకొనినట్లుండును",
        "చూచికర్ణпиశాచిగలవారియొద్దకును": "చూచి కర్ణపిశాచిగలవారియొద్దకును",
        "చూచికర్ణపిశాచిగలవారియొద్దకును": "చూచి కర్ణపిశాచిగలవారియొద్దకును",
        "నేలనుపడవేసియున్నాడుముక్కముక్కలుగా": "నేలను పడవేసియున్నాడు ముక్కముక్కలుగా",
        "చీకటిలోనున్నవారితోనుచెప్పుచు": "చీకటిలోనున్నవారితోను చెప్పుచు",
        "ప్రోత్సాహపరచుకొనువాడొకడును": "ప్రోత్సాహపరచుకొనువాడు ఒకడును",
        "చూడనట్టియుదూరద్వీపవాసులయొద్దకు": "చూడనట్టియు దూరద్వీపవాసులయొద్దకు",
        "తప్పించుకొనిపోవుచున్నవారిని": "తప్పించుకొని పోవుచున్నవారిని",
        "ప్రార్థనచేసియొప్పుకొన్నదేమనగా": "ప్రార్థనచేసి యొప్పుకొన్నదేమనగా",
        "కూర్చుండబెట్టుకొనియున్నాడు": "కూర్చుండబెట్టుకొని యున్నాడు",
        "విస్తరించియున్నారునామీదికి": "విస్తరించియున్నారు నామీదికి",
        "నిర్మూలముచేయునుసరిహద్దులను": "నిర్మూలము చేయును సరిహద్దులను",
        "స్వభావలక్షణములుమోసపడువారును": "స్వభావలక్షణములు మోసపడువారును",
        "చెప్పునదేమనగావ్యభిచారకారణమునుబట్టి": "చెప్పునదేమనగా వ్యభిచారకారణమునుబట్టి",
        "చెప్పునదేమనగామనుష్యులుచేయు": "చెప్పునదేమనగా మనుష్యులుచేయు",
        "వారికాజ్ఞాపించినదేమనగామీరు": "వారికాజ్ఞాపించినదేమనగా మీరు",
        "చెప్పవలసినదేమనగానాసేవకుడైన": "చెప్పవలసినదేమనగా నా సేవకుడైన",
        "చెప్పవలసినదేమనగ": "చెప్పవలసినదేమనగ ",
        "ఇస్హారీయులనుగూర్చినది": "ఇస్హారీయులను గూర్చినది",
        "ఇస్హారీయులనుగూర": "ఇస్హారీయులను గూర్చి",
        "రూపకమైనవనియెంచబ": "రూపకమైనవని యెంచబ",
        "ఎగురగొట్టబడినవారము": "ఎగురగొట్టబడినవారము",
        "ఎగురగొట్టబడినవా": "ఎగురగొట్టబడినవా ",
        "సెలవిచ్చినదేమనగానరపుత్రుడా": "సెలవిచ్చినదేమనగా నరపుత్రుడా",
        "సెలవిచ్చునదేమనగాబబులోనురాజు": "సెలవిచ్చునదేమనగా బబులోనురాజు",
        "సెలవిచ్చునదేమనగాఫిలిష్తీయుల": "సెలవిచ్చునదేమనగా ఫిలిష్తీయుల",
        "సెలవిచ్చునదేమనగ": "సెలవిచ్చునదేమనగ ",
    }
    
    for old, new in fixes.items():
        text = text.replace(old, new)
        
    # Conjunctions/Adverbs
    text = re.sub(r'(మరియు)([\u0c00-\u0c7f])', r'\1 \2', text)
    text = re.sub(r'(అప్పుడు)([\u0c00-\u0c7f])', r'\1 \2', text)
    text = re.sub(r'(అందుకు)([\u0c00-\u0c7f])', r'\1 \2', text)
    text = re.sub(r'(ఇశ్రాయేలు)([\u0c00-\u0c7f])', r'\1 \2', text)

    # Nouns taking case suffixes
    text = re.sub(r'(దేవుడు|ప్రభువు)([అఆఇఈఉఊఎఏఐఒఓఔకగచజటడతదపబమరవశషసహ])', r'\1 \2', text)

    # Proper nouns
    text = re.sub(r'(యేసు|క్రీస్తు|మోషే|యెహోవా)([అఆఇఈఉఊఎఏఐఒఓఔగజడదపబమరవశషసహ])', r'\1 \2', text)

    # Speech verb spacing
    text = re.sub(r'(సెలవిచ్చుచున్నాడు|యిట్లనెను|ప్రత్యుత్తరమిచ్చెను|చెప్పినదేమనగా|యొప్పుకొన్నదేమనగా|సెలవిచ్చుచున్నాడు|విచ్చుచున్నాడు|సెలవిచ్చినదేమనగా)([\u0c00-\u0c7f])', r'\1 \2', text)
    
    # General regex patterns for common merges
    text = re.sub(r'([చేప్పున|సెలవిచ్చున|ఆజ్ఞాపించిన|వ్రాసిన|పలికిన]?దేమనగా)([\u0c00-\u0c7f])', r'\1 \2', text)
    text = re.sub(r'(ప్రత్యుత్తరమిచ్చి[రి|న|నది]?)([\u0c00-\u0c7f])', r'\1 \2', text)
    text = re.sub(r'([\u0c00-\u0c7f]+)(గూర్చి|గూర్చిన|గూర్చియు)', r'\1 \2', text)
    text = re.sub(r'([\u0c00-\u0c7f]+)(కూడ|కూడా)', r'\1 \2', text)

    # Clean double spaces
    text = re.sub(r'\s+', ' ', text).strip()
    return text

def main():
    if not os.path.exists(XML_PATH):
        print(f"Error: Reference XML not found at {XML_PATH}")
        sys.exit(1)
    if not os.path.exists(DB_PATH):
        print(f"Error: Local DB not found at {DB_PATH}")
        sys.exit(1)

    print("Loading book metadata...")
    books = load_books_metadata(BIBLE_SERVICE_PATH)
    book_num_map = {b['book_number']: b for b in books}

    print("Parsing reference XML...")
    tree = ET.parse(XML_PATH)
    root = tree.getroot()
    ref_data = {}
    for book in root.findall('.//BIBLEBOOK'):
        bnum_str = book.attrib.get('bnumber')
        if not bnum_str:
            continue
        bnum = int(bnum_str)
        if bnum < 1 or bnum > 66:
            continue
        ref_data[bnum] = {}
        for chapter in book.findall('.//CHAPTER'):
            cnum = int(chapter.attrib.get('cnumber'))
            ref_data[bnum][cnum] = {}
            for verse in chapter.findall('.//VERS'):
                vnum = int(verse.attrib.get('vnumber'))
                text = "".join(verse.itertext()).strip()
                ref_data[bnum][cnum][vnum] = text

    print("Connecting to local database...")
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Load all current local verses to detect deletions/omissions
    cursor.execute("SELECT book_number, chapter, verse, text FROM verses;")
    local_verses = {}
    for r in cursor.fetchall():
        bnum, ch, v, txt = int(r[0]), int(r[1]), int(r[2]), r[3] or ""
        local_verses[(bnum, ch, v)] = txt

    # Set of all coordinates in reference XML
    ref_coords = set()
    for bnum in ref_data:
        for ch in ref_data[bnum]:
            for v in ref_data[bnum][ch]:
                ref_coords.add((bnum, ch, v))

    # All unique coordinates to process
    all_coords = set(local_verses.keys()) | ref_coords

    print(f"Processing {len(all_coords)} verses...")
    updates_count = 0
    inserts_count = 0
    deletions_replaced_count = 0

    for coord in sorted(all_coords):
        bnum, ch, v = coord
        meta = book_num_map.get(bnum)
        if not meta:
            continue
        
        book_name = meta['nameEn']
        ref_text = ref_data.get(bnum, {}).get(ch, {}).get(v)
        local_text = local_verses.get(coord)

        # Normalize ref_text formatting
        if ref_text is not None:
            ref_text = fix_text(ref_text)

        if ref_text is not None:
            # Present in reference XML
            if local_text is not None:
                # Update if different or has formatting issues
                norm_local = fix_text(local_text)
                if norm_local != ref_text or local_text != ref_text:
                    cursor.execute(
                        "UPDATE verses SET text = ? WHERE book_number = ? AND chapter = ? AND verse = ?;",
                        (ref_text, bnum, ch, v)
                    )
                    updates_count += 1
            else:
                # Insert missing verse
                cursor.execute(
                    "INSERT INTO verses (book_number, book_name, chapter, verse, text) VALUES (?, ?, ?, ?, ?);",
                    (bnum, book_name, ch, v, ref_text)
                )
                inserts_count += 1
        else:
            # Legitimate omission in reference XML, but exists in local SQLite
            # Replace with proper Telugu placeholder: "ఈ వచనం ఈ అనువాదంలో లేదు"
            placeholder = "ఈ వచనం ఈ అనువాదంలో లేదు"
            if local_text != placeholder:
                cursor.execute(
                    "UPDATE verses SET text = ? WHERE book_number = ? AND chapter = ? AND verse = ?;",
                    (placeholder, bnum, ch, v)
                )
                deletions_replaced_count += 1

    print(f"Commit changes: updates={updates_count}, inserts={inserts_count}, placeholder_replacements={deletions_replaced_count}")
    conn.commit()

    # Integrity check: make sure we still have 66 books and correct chapter structure
    cursor.execute("SELECT count(distinct book_number) FROM verses;")
    book_count = cursor.fetchone()[0]
    if book_count != 66:
        print(f"Warning: book count is {book_count}, expected 66!")
        conn.rollback()
        conn.close()
        sys.exit(1)
        
    print("Database integrity check passed.")
    conn.close()
    print("Remediation of telugu_ov completed successfully.")

if __name__ == "__main__":
    main()
