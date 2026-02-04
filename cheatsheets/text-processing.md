# Text Processing

## Viewing Files

- `cat file.txt` - Display entire file
- `head -n 20 file.txt` - First 20 lines
- `tail -n 20 file.txt` - Last 20 lines
- `tail -f logfile.log` - Follow log in real-time
- `less file.txt` - Paginated view

## Searching Text

- `grep "pattern" file.txt` - Search for pattern
- `grep -r "pattern" .` - Recursive search
- `grep -i "pattern" file.txt` - Case insensitive
- `grep -n "pattern" file.txt` - Show line numbers
- `grep -v "pattern" file.txt` - Invert match
- `grep -E "regex" file.txt` - Extended regex

## Counting

- `wc -l file.txt` - Count lines
- `wc -w file.txt` - Count words
- `wc -c file.txt` - Count bytes
- `grep -c "pattern" file.txt` - Count matches

## Transforming Text

- `sort file.txt` - Sort lines
- `sort -n file.txt` - Numeric sort
- `sort -r file.txt` - Reverse sort
- `uniq file.txt` - Remove duplicates
- `sort file.txt | uniq -c` - Count occurrences
- `tr 'a-z' 'A-Z' < file.txt` - Uppercase

## Cutting and Joining

- `cut -d',' -f1 file.csv` - First column (comma-delimited)
- `cut -c1-10 file.txt` - First 10 characters
- `paste file1.txt file2.txt` - Merge files side-by-side
- `join file1.txt file2.txt` - Join on common field

## sed (Stream Editor)

- `sed 's/old/new/' file.txt` - Replace first match
- `sed 's/old/new/g' file.txt` - Replace all matches
- `sed -i 's/old/new/g' file.txt` - Edit in place
- `sed -n '5,10p' file.txt` - Print lines 5-10
- `sed '/pattern/d' file.txt` - Delete matching lines

## awk

- `awk '{print $1}' file.txt` - Print first column
- `awk -F',' '{print $2}' file.csv` - CSV second column
- `awk 'NR==5' file.txt` - Print line 5
- `awk '{sum+=$1} END {print sum}'` - Sum first column
- `awk 'length > 80' file.txt` - Lines > 80 chars

## Comparing Files

- `diff file1.txt file2.txt` - Show differences
- `diff -u file1.txt file2.txt` - Unified diff
- `comm file1.txt file2.txt` - Compare sorted files
- `vimdiff file1.txt file2.txt` - Visual diff
