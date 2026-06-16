import os
import re
import json

def clean_usfm(text):
    text = re.sub(r'\\f\s+.*?\\f\*', '', text, flags=re.DOTALL)
    text = re.sub(r'\|strong=\"[^\"]*\"', '', text)
    text = re.sub(r'\\\+?[a-zA-Z*]+', '', text)
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

with open('assets/bible/english_kjv.json', 'r', encoding='utf-8') as f:
    json_data = json.load(f)

path = 'scratch/kjv_usfm/70-MATeng-kjv2006.usfm'
with open(path, 'r', encoding='utf-8') as f:
    usfm_text = f.read()

chapters = re.split(r'\\c\s+\d+', usfm_text)
mismatch_count = 0

for ch_idx, ch_text in enumerate(chapters[1:], 1):
    verses = re.split(r'\\v\s+(\d+)\s+', ch_text)
    if len(verses) < 3:
        continue
    for i in range(1, len(verses), 2):
        v_num = verses[i]
        v_text = verses[i+1]
        
        # Clean both KJV texts for comparison
        usfm_clean = clean_usfm(v_text)
        
        # Get from JSON
        ch_str = str(ch_idx)
        json_verse = json_data['Matthew'].get(ch_str, {}).get(v_num, '')
        
        # Normalize whitespace and clean comparison
        u_norm = re.sub(r'\s+', ' ', usfm_clean).strip().lower()
        j_norm = re.sub(r'\s+', ' ', json_verse).strip().lower()
        
        # Remove punctuation for comparison
        u_comp = re.sub(r'[^\w\s]', '', u_norm)
        j_comp = re.sub(r'[^\w\s]', '', j_norm)
        
        if u_comp != j_comp:
            mismatch_count += 1
            if mismatch_count <= 5:
                print(f'Mismatch Matthew {ch_idx}:{v_num}:')
                print('  USFM:', repr(usfm_clean))
                print('  JSON:', repr(json_verse))

print('Total mismatched verses in Matthew:', mismatch_count)
