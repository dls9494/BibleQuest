import pypdf

pdf_path = "/home/david/Documents/tel2017_a4.pdf"
reader = pypdf.PdfReader(pdf_path)

search_terms = ["ఇమ్మానుయేలు", "కన్యక", "ఇమ్మానుయేలను", "ఇదిగో కన్యక"]

found = False
for idx, page in enumerate(reader.pages):
    text = page.extract_text()
    if not text:
        continue
    for term in search_terms:
        if term in text:
            print(f"Found term '{term}' on page {idx}:")
            # Print around where it was found
            pos = text.find(term)
            start = max(0, pos - 200)
            end = min(len(text), pos + 200)
            print(text[start:end])
            print("-"*50)
            found = True

if not found:
    print("Search terms not found in the entire PDF.")
