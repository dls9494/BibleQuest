with open('/home/david/Documents/telugu_bible_2017.xml', 'r', encoding='utf-8') as f:
    xml_content = f.read()

import re
# Find <book id="Matthew" ...> ... </book>
book_match = re.search(r'<book id="Matthew"[^>]*>(.*?)</book>', xml_content, re.DOTALL)
if book_match:
    book_text = book_match.group(1)
    # Find <chapter id="1"> ... </chapter>
    chap_match = re.search(r'<chapter id="1">(.*?)</chapter>', book_text, re.DOTALL)
    if chap_match:
        chap_text = chap_match.group(1)
        print("Matthew 1 verses in XML:")
        print(chap_text)
    else:
        print("Matthew 1 chapter not found in Matthew book.")
else:
    print("Matthew book not found in XML.")
