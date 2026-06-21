import zipfile
import re

zip_path = "/home/david/Music/Bible Quiz/scratch/tel2017_usfm.zip"
extract_file = "46-MATtel2017.usfm"

with zipfile.ZipFile(zip_path, 'r') as zip_ref:
    content = zip_ref.read(extract_file).decode('utf-8')

def clean_chapter_headings(ch_text):
    lines = ch_text.split('\n')
    cleaned_lines = []
    for line in lines:
        line_strip = line.strip()
        if not line_strip:
            continue
        # Remove lines starting with heading/title tags: \s, \r, \d, \mt, \ms, \ip
        # E.g., \s1 Section Name, \r (Parallel passages)
        if re.match(r'\\(s|r|d|mt|ms|ip|cl|cd|toc)\d?\b', line_strip):
            continue
        cleaned_lines.append(line)
    return '\n'.join(cleaned_lines)

def clean_verse_text(text):
    # Remove footnotes
    text = re.sub(r'\\f\s+.*?\\f\*', '', text, flags=re.DOTALL)
    # Remove cross-references
    text = re.sub(r'\\x\s+.*?\\x\*', '', text, flags=re.DOTALL)
    
    # Remove inline tags but keep their contents
    # E.g., \add words\add* -> words
    # E.g., \wj words\wj* -> words
    text = re.sub(r'\\\+?[a-zA-Z]+(?:\*|\b)', '', text)
    
    # Remove any word attributes (e.g. |strong="H123")
    text = re.sub(r'\|[a-zA-Z0-9_-]+="[^"]*"', '', text)
    
    # Remove extra spaces and newlines
    text = ' '.join(text.split())
    return text.strip()

# Split into chapters
chapters = re.split(r'\\c\s+(\d+)', content)

ch1_text = chapters[2]
# Pre-clean headings
ch1_text_clean = clean_chapter_headings(ch1_text)

# Split chapter text by \v
verses = re.split(r'\\v\s+(\d+(?:-\d+)?)\s+', ch1_text_clean)

print("\nParsed verses:")
for idx in range(1, len(verses), 2):
    v_num_str = verses[idx]
    v_text = verses[idx+1]
    
    cleaned_text = clean_verse_text(v_text)
    print(f"Verse {v_num_str} -> '{cleaned_text}'")
