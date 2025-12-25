import os
import re

# Configuration
BEGINNER_ASSETS_DIR = 'assets/Beginner_Asset'
INTERMEDIATE_ASSETS_DIR = 'assets/Intermediate_Asset'
BEGINNER_FILE = 'lib/data/beginnerlessons.dart'
INTERMEDIATE_FILE = 'lib/data/intermediateLessons.dart'

def get_images_for_day(base_dir, day_num, is_intermediate=False):
    # Find folder starting with "Day {day_num}" (case insensitive)
    # Intermediate folders are "Day 1 comp" -> offset is handled by caller, here we look for "Day 1" etc
    
    # List all dirs
    try:
        dirs = os.listdir(base_dir)
    except FileNotFoundError:
        return []

    target_dir_name = None
    pattern = re.compile(f'^day {day_num}( |$)', re.IGNORECASE)
    
    for d in dirs:
        if not os.path.isdir(os.path.join(base_dir, d)):
            continue
            
        if pattern.match(d):
            target_dir_name = d
            print(f"DEBUG: Matched directory '{d}' for day {day_num}")
            break
    
    if not target_dir_name:
        print(f"DEBUG: No directory matched for day {day_num}")
        return []

    full_dir_path = os.path.join(base_dir, target_dir_name)
    images = []
    
    # Walk directory to find pngs
    print(f"DEBUG: Walking {full_dir_path}")
    for root, _, files in os.walk(full_dir_path):
        for f in files:
            # print(f"DEBUG: Checking file {f}")
            if f.lower().endswith('.png') or f.lower().endswith('.jpg') or f.lower().endswith('.jpeg'):
                # proper path relative to project root
                rel_path = os.path.join(root, f)
                images.append(rel_path)
    
    print(f"DEBUG: Found {len(images)} images in {full_dir_path}")
    # Sort images to ensure deterministic order
    images.sort()
    return images

def process_file(file_path, base_asset_dir, is_intermediate=False):
    print(f"Processing {file_path}...")
    with open(file_path, 'r') as f:
        lines = f.readlines()

    new_lines = []
    current_day = None
    
    day_pattern = re.compile(r"'day':\s*(\d+),")
    image_urls_pattern = re.compile(r"'imageUrls':\s*\[\s*\],")

    for line in lines:
        day_match = day_pattern.search(line)
        if day_match:
            current_day = int(day_match.group(1))
            new_lines.append(line)
            continue
        
        if current_day is not None and image_urls_pattern.search(line):
            # Found an empty imageUrls list for the current day
            
            # Determine folder day number
            folder_day = current_day
            if is_intermediate:
                folder_day = current_day - 30
            
            images = get_images_for_day(base_asset_dir, folder_day, is_intermediate)
            
            if images:
                print(f"  Day {current_day} (Folder Day {folder_day}): Found {len(images)} images")
                # Construct the new list
                images_dart_list = ["        '" + img + "'," for img in images]
                
                new_lines.append("        'imageUrls': [\n")
                new_lines.extend([f"{img}\n" for img in images_dart_list])
                new_lines.append("        ],\n")
            else:
                print(f"  Day {current_day} (Folder Day {folder_day}): No images found")
                new_lines.append(line)
            
            # Reset current day so we don't affect subsequent blocks incorrectly (though structure implies distinct blocks)
            # Keeping current_day until next match is safer but let's assume structure holds
        else:
            new_lines.append(line)

    with open(file_path, 'w') as f:
        f.writelines(new_lines)

if __name__ == "__main__":
    process_file(BEGINNER_FILE, BEGINNER_ASSETS_DIR, is_intermediate=False)
    process_file(INTERMEDIATE_FILE, INTERMEDIATE_ASSETS_DIR, is_intermediate=True)
