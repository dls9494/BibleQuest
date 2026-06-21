import zipfile
import re

zip_path = "/home/david/Music/Bible Quiz/scratch/tel2017_usfm.zip"
extract_file = "46-MATtel2017.usfm"

with zipfile.ZipFile(zip_path, 'r') as zip_ref:
    content = zip_ref.read(extract_file).decode('utf-8')

# Search for Chapter 1
chapters = re.split(r'\\c\s+\d+', content)
if len(chapters) > 1:
    matt1 = chapters[1] # Chapter 1 content
    # Print the lines around verse 20 to 25
    lines = matt1.split('\n')
    print("Matthew 1 lines from USFM:")
    for line in lines:
        if any(f"\\v {i}" in line or f"\\v {i}-" in line for i in range(18, 26)):
            print(line)
else:
    print("Could not split chapters.")
