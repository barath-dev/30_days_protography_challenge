
import re
import os

def check_image_urls(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Regex to find id and imageUrls
    # Assuming standard formatting: 'id': '...', ... 'imageUrls': [ ... ]
    # We'll stick to a simple state machine or regex finding blocks
    
    # Let's find all 'id': '...' and 'imageUrls': ...
    # This is rough because we can't fully parse Dart/JSON with regex, but the file structure seems consistent.
    
    lessons = []
    # split by "id':" might be easier
    parts = content.split("'id':")
    
    for i, part in enumerate(parts):
        if i == 0: continue # header
        
        # Extract ID
        id_match = re.search(r"\s*'([^']+)'", part)
        if not id_match:
            continue
        lesson_id = id_match.group(1)
        
        # Extract imageUrls
        # It handles 'imageUrls': [ ... ]
        # We look for 'imageUrls': then capture the bracket content
        url_match = re.search(r"'imageUrls':\s*\[(.*?)\]", part, re.DOTALL)
        
        if url_match:
            content_inside = url_match.group(1).strip()
            if not content_inside: # Empty
                print(f"File: {os.path.basename(filepath)}, Lesson: {lesson_id} has EMPTY imageUrls")
            elif content_inside.isspace(): # Just whitespace
                print(f"File: {os.path.basename(filepath)}, Lesson: {lesson_id} has EMPTY imageUrls")
            else:
                # check if it contains actual strings
                if not re.search(r"['\"].+['\"]", content_inside):
                     print(f"File: {os.path.basename(filepath)}, Lesson: {lesson_id} has potentially EMPTY imageUrls (no strings found)")

files = [
    'lib/data/advancedLessons.dart',
    'lib/data/advancedLessons_clean.dart',
    'lib/data/beginnerlessons.dart',
    'lib/data/intermediateLessons.dart'
]

for file in files:
    if os.path.exists(file):
        check_image_urls(file)
