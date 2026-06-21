import json

# Read only first 1000 characters from the file first to see structure
with open('/home/david/Documents/tel_new/telugu_bible.json', 'r', encoding='utf-8') as f:
    head = f.read(1000)

print("First 1000 characters of telugu_bible.json:")
print(head)
