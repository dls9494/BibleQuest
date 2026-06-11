import json
import os

def generate_versions():
    # Source paths
    telugu_src = 'assets/bible/telugu_bible.json'
    kjv_src = 'assets/bible/english_kjv.json'
    nhv_src = 'assets/bible/nhv_bible.json'

    # Target paths
    targets = {
        'telugu_ov': ('assets/bible/telugu_ov.json', ' (OV text will be updated)'),
        'telugu_rv': ('assets/bible/telugu_rv.json', ' (RV/BSI text)'),
        'telugu_tcv': ('assets/bible/telugu_tcv.json', ' (TCV requires licensing)'),
        'telugu_1881': ('assets/bible/telugu_1881.json', ' (1881 text coming soon)'),
        'english_nkjv': ('assets/bible/english_nkjv.json', ' (NKJV text coming soon)'),
        'english_esv': ('assets/bible/english_esv.json', ' (ESV text coming soon – using WEB for now)'),
    }

    # Load Telugu source
    print(f"Loading {telugu_src}...")
    with open(telugu_src, 'r', encoding='utf-8') as f:
        telugu_data = json.load(f)

    # Generate Telugu versions
    for key, (path, suffix) in targets.items():
        if key.startswith('telugu_'):
            print(f"Generating {path}...")
            # We copy and append suffix to every verse text
            new_data = {}
            for book, chapters in telugu_data.items():
                new_data[book] = {}
                for chapter, verses in chapters.items():
                    new_data[book][chapter] = {}
                    for verse, text in verses.items():
                        new_data[book][chapter][verse] = text + suffix
            with open(path, 'w', encoding='utf-8') as out_f:
                json.dump(new_data, out_f, ensure_ascii=False)

    # Load KJV source
    print(f"Loading {kjv_src}...")
    with open(kjv_src, 'r', encoding='utf-8') as f:
        kjv_data = json.load(f)

    # Generate NKJV
    path, suffix = targets['english_nkjv']
    print(f"Generating {path}...")
    new_data = {}
    for book, chapters in kjv_data.items():
        new_data[book] = {}
        for chapter, verses in chapters.items():
            new_data[book][chapter] = {}
            for verse, text in verses.items():
                new_data[book][chapter][verse] = text + suffix
    with open(path, 'w', encoding='utf-8') as out_f:
        json.dump(new_data, out_f, ensure_ascii=False)

    # Load WEB source
    print(f"Loading {nhv_src}...")
    with open(nhv_src, 'r', encoding='utf-8') as f:
        nhv_data = json.load(f)

    # Generate ESV
    path, suffix = targets['english_esv']
    print(f"Generating {path}...")
    new_data = {}
    for book, chapters in nhv_data.items():
        new_data[book] = {}
        for chapter, verses in chapters.items():
            new_data[book][chapter] = {}
            for verse, text in verses.items():
                new_data[book][chapter][verse] = text + suffix
    with open(path, 'w', encoding='utf-8') as out_f:
        json.dump(new_data, out_f, ensure_ascii=False)

    # Generate NIV placeholder
    niv_path = 'assets/bible/english_niv.json'
    print(f"Generating {niv_path}...")
    new_data = {}
    # We use kjv_data structure and set every verse to placeholder text
    placeholder = "NIV text requires licensing. Placeholder for now."
    for book, chapters in kjv_data.items():
        new_data[book] = {}
        for chapter, verses in chapters.items():
            new_data[book][chapter] = {}
            for verse in verses.keys():
                new_data[book][chapter][verse] = placeholder
    with open(niv_path, 'w', encoding='utf-8') as out_f:
        json.dump(new_data, out_f, ensure_ascii=False)

    print("Successfully generated all missing Bible version JSON files!")

if __name__ == '__main__':
    generate_versions()
