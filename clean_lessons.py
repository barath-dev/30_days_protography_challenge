import re

def clean_lessons():
    file_path = 'lib/data/advancedLessons.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    
    start_line_idx = -1
    for i, line in enumerate(lines):
        if 'return [' in line:
            start_line_idx = i
            break
            
    if start_line_idx == -1:
        print("Could not find start of list")
        return

    # Extract header and footer
    header = lines[:start_line_idx + 1]
    
    # Identify the end of the list
    # We will reconstruct the list items.
    
    # Parse blocks again
    lessons = []
    current_block = []
    in_block = False
    
    # We need to find where the list ENDS to preserve the footer.
    list_end_idx = -1
    
    # Re-using parsing logic but tracking original lines?
    # Actually, simpler to just parse the blocks and keep them as strings.
    # Then find the footer starting from the last block's end.
    
    block_strings = []
    raw_blocks = [] # for analysis
    
    current_block_lines = []
    in_block = False
    last_processed_line = start_line_idx
    
    for i in range(start_line_idx + 1, len(lines)):
        line = lines[i]
        stripped = line.strip()
        
        if not in_block:
            if stripped == '{':
                in_block = True
                current_block_lines = [line]
            elif stripped == '];':
                list_end_idx = i
                break
        else:
            current_block_lines.append(line)
            if stripped.startswith('}'):
                # End of block
                in_block = False
                block_content = '\n'.join(current_block_lines)
                raw_blocks.append(block_content)
                current_block_lines = []
                last_processed_line = i
                # print(f"Ended block at line {i}")

    footer = lines[list_end_idx:]
    
    print(f"Parsed {len(raw_blocks)} blocks.")
    
    cleaned_blocks = []
    seen_days = {}
    
    for block in raw_blocks:
        is_garbage = False
        
        # Checking garbage patterns
        if re.search(r"'title':\s*['\"](NOW FULLY )?COMPLETE.*['\"]", block) or \
           "'title': 'Complete'" in block:
            is_garbage = True
        elif "ChatGPT said:" in block or "You said:" in block or "Just say the word!" in block:
            is_garbage = True
        elif re.search(r"'title':\s*['\"].*right away\?['\"]", block):
             is_garbage = True

        if is_garbage:
            continue
            
        # Check for duplicates by DAY
        day_match = re.search(r"'day': (\d+),", block)
        if day_match:
            day = int(day_match.group(1))
            if day in seen_days:
                # Duplicate Day!
                # We need to decide which one to keep.
                # Strategy: Keep the longer one? Or check specific titles.
                existing_block = seen_days[day]
                # Compare lengths
                if len(block) > len(existing_block):
                    # Replace existing with this one
                    seen_days[day] = block
                    print(f"Replaced Day {day} with larger block.")
                else:
                    print(f"Skipped duplicate Day {day} (smaller or equal).")
            else:
                seen_days[day] = block
        else:
            # No day? Keep it I guess, or warn.
            print("Warning: Block with no day found.")
            # We add it to a list of unsorted? 
            # But we want to output sorted by day.
            pass

    # Sort days
    sorted_days = sorted(seen_days.keys())
    
    # Check for missing Day 75
    if 75 not in seen_days:
        print("Injecting missing Day 75...")
        day_75_block = r"""      {
        'id': 'lesson_075',
        'day': 75,
        'title': 'Post-Production Workflow & Selection (Culling to Editing)',
        'subtitle': 'Photography Lesson',
        'description': 'Learn how to select your best shots and prepare them for high-end retouching.',
        'content': '''Day 15: Post-Production Workflow & Selection
        
🎯 Objective: Learn the professional workflow for culling, rating, and selecting images before you start editing.

1. Import & Organization
2. The Culling Process (In/Out)
3. Rating System (1-5 Stars)
4. Preparing for Retouching''',
        'estimatedDuration': 30,
        'type': 'theory',
        'difficulty': 'advanced',
        'categories': ['Photography'],
        'objectives': ['Understand Post-Production Workflow'],
        'exercises': [],
        'imageUrls': [],
        'technicalDetails': {},
      },"""
        seen_days[75] = day_75_block
        sorted_days.append(75)
        sorted_days.sort()

    for d in sorted_days:
        cleaned_blocks.append(seen_days[d])
        
    print(f"Resulting valid blocks: {len(cleaned_blocks)}")
    
    # Reconstruct file
    new_content = '\n'.join(header) + '\n'
    new_content += '\n'.join(cleaned_blocks)
    new_content += '\n' + '\n'.join(footer)
    
    output_path = 'lib/data/advancedLessons_clean.dart'
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
        
    print(f"Written clean file to {output_path}")

if __name__ == "__main__":
    clean_lessons()
