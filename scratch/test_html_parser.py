import os
from bs4 import BeautifulSoup

def parse_html_chapter(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        html_content = f.read()
    
    soup = BeautifulSoup(html_content, "html.parser")
    text_body = soup.find(id="textBody")
    if not text_body:
        # Fallback to search class textBody
        text_body = soup.find(class_="textBody")
    
    if not text_body:
        print(f"Error: Could not find textBody in {file_path}")
        return {}
    
    verses = {}
    verse_spans = text_body.find_all("span", class_="verse")
    
    for i, span in enumerate(verse_spans):
        try:
            v_num = int(span.get("id") or span.text.strip())
        except ValueError:
            continue
        
        # Gather all text content between this span and the next span
        parts = []
        curr = span.next_sibling
        while curr and curr not in verse_spans:
            # Check if this node has text
            if hasattr(curr, "text"):
                # If it's a child element, get its text
                parts.append(curr.get_text())
            elif isinstance(curr, str):
                parts.append(curr)
            curr = curr.next_sibling
        
        # Join and clean up text
        verse_text = "".join(parts)
        # Clean extra spaces, newlines, and non-breaking spaces
        verse_text = verse_text.replace("\xa0", " ")
        # Replace multiple spaces with a single space
        verse_text = " ".join(verse_text.split())
        verses[v_num] = verse_text.strip()
        
    return verses

if __name__ == "__main__":
    test_path = "/home/david/Music/tel_new/01/1.htm"
    res = parse_html_chapter(test_path)
    for v, t in sorted(res.items())[:5]:
        print(f"Verse {v}: {t}")
