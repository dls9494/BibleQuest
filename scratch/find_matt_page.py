import pypdf

pdf_path = "/home/david/Documents/tel2017_a4.pdf"
reader = pypdf.PdfReader(pdf_path)

found_page = -1
for idx in range(3, len(reader.pages)):
    text = reader.pages[idx].extract_text()
    if not text:
        continue
    if "మతత్యిరాసినసువార" in text or "మతత్యి" in text:
        found_page = idx
        print(f"Found Matthew on page {idx}:")
        print(text[:1500])
        print("="*50)
        break

if found_page == -1:
    print("Could not find Matthew header after page 2.")
