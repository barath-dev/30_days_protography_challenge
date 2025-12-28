import re

def analyze_lessons():
    file_path = 'lib/data/advancedLessons.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the start of the list
    start_marker = 'return ['
    start_idx = content.find(start_marker)
    
    # We want to parse the list content.
    # We will iterate lines from start_idx.
    
    lines = content.split('\n')
    
    start_line_idx = -1
    for i, line in enumerate(lines):
        if 'return [' in line:
            start_line_idx = i
            break
            
    if start_line_idx == -1:
        print("Could not find start of list")
        return

    lessons = []
    current_block = []
    in_block = False
    
    # Simple heuristic:
    # A lesson block starts with `      {` (6 or 8 spaces + {)
    # And ends with `      },`
    
    # Let's check indentation of the first block
    # line 4 is matched in view_file as: "        {"
    
    block_start_pattern = re.compile(r'^\s+\{$')
    block_end_pattern = re.compile(r'^\s+\},?$')
    
    for i in range(start_line_idx + 1, len(lines)):
        line = lines[i]
        stripped = line.strip()
        
        if not in_block:
            if stripped == '{':
                in_block = True
                current_block = [line]
            elif stripped == '];':
                # End of list
                break
        else:
            current_block.append(line)
            if stripped == '},' or stripped == '}':
                # Check indentation to be safe? 
                # Assuming standard formatting, a closing brace on its own line usually matches the opening.
                # But let's check if the brace count balances?
                # For safety, simplistic matching of `      },` is reasonably safe for this generated file.
                if line.strip() == '},':
                    in_block = False
                    lessons.append('\n'.join(current_block))
                    current_block = []
            
    print(f"Found {len(lessons)} lesson blocks.")
    
    valid_lessons = []
    garbage_lessons = []
    
    # Indices of blocks to remove (we will use this logic in the actual cleaner)
    
    for i, lesson in enumerate(lessons):
        is_garbage = False
        reason = ""
        
        # Check title
        if re.search(r"'title':\s*['\"](NOW FULLY )?COMPLETE.*['\"]", lesson):
             is_garbage = True
             reason = "Title is COMPLETE"
        elif re.search(r"'title':\s*['\"].*right away\?['\"]", lesson):
             is_garbage = True
             reason = "Title contains 'right away?'"
        elif re.search(r"'title':\s*['\"].*Lighting.*Dark vs Fair.*['\"]", lesson) and "You said:" in lesson:
             is_garbage = True
             reason = "Garbage duplicate title"
        
        # Check content/subtitle garbage
        if "ChatGPT said:" in lesson:
            is_garbage = True
            reason = "Contains ChatGPT log"
        if "You said:" in lesson:
            is_garbage = True
            reason = "Contains 'You said:'"
        if "Just say the word!" in lesson:
            is_garbage = True
            reason = "Garbage text"
        if "'title': 'Complete'" in lesson:
             is_garbage = True
             reason = "Title is Complete"

        # Parse day
        day_match = re.search(r"'day': (\d+),", lesson)
        day = day_match.group(1) if day_match else "Unknown"
        
        # Parse title
        title_match = re.search(r"'title':\s*(?:'''|')(.*?)(?:'''|'),", lesson, re.DOTALL)
        title_str = title_match.group(1) if title_match else "Unknown"
        title_str = title_str.replace('\n', ' ').strip()[:50]

        if is_garbage:
            garbage_lessons.append(f"Block {i} | Day {day}: {title_str} ({reason})")
        else:
            valid_lessons.append(f"Block {i} | Day {day}: {title_str}")
            
    print("\n--- Garbage Lessons (To Remove) ---")
    for l in garbage_lessons:
        print(l)
        
    print(f"\nFound {len(garbage_lessons)} garbage lessons.")
    
    print("\n--- Valid Lessons Sample (First 10) ---")
    for l in valid_lessons[:10]:
        print(l)

    print(f"\nTotal Valid: {len(valid_lessons)}")

if __name__ == "__main__":
    analyze_lessons()
