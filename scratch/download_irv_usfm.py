import urllib.request
import zipfile
import os
import ssl

ssl_ctx = ssl.create_default_context()
ssl_ctx.check_hostname = False
ssl_ctx.verify_mode = ssl.CERT_NONE

url = "https://eBible.org/Scriptures/tel2017_usfm.zip"
dest_path = "/home/david/Music/Bible Quiz/scratch/tel2017_usfm.zip"
extract_path = "/home/david/Music/Bible Quiz/scratch/tel2017_usfm"

print(f"Downloading {url} to {dest_path}...")
try:
    req = urllib.request.Request(
        url,
        headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
    )
    with urllib.request.urlopen(req, context=ssl_ctx) as response:
        with open(dest_path, 'wb') as out_file:
            out_file.write(response.read())
            
    print("Download completed successfully.")
    
    # List zip contents
    with zipfile.ZipFile(dest_path, 'r') as zip_ref:
        files = zip_ref.namelist()
        print(f"Zip contains {len(files)} files.")
        print("First 15 files:")
        for f in files[:15]:
            print(f"  {f}")
            
except Exception as e:
    print(f"Error downloading or extracting: {e}")
