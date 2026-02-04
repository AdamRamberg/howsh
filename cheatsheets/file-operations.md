# File Operations

## Finding Files

- `find . -name "*.txt"` - Find files by name
- `find . -type f -mtime -7` - Files modified in last 7 days
- `find . -size +100M` - Files larger than 100MB
- `find . -empty` - Find empty files and directories
- `find . -name "*.log" -delete` - Find and delete files

## Listing Files

- `ls -la` - List all files with details
- `ls -lh` - Human-readable file sizes
- `ls -lt` - Sort by modification time
- `ls -lS` - Sort by size
- `tree -L 2` - Directory tree (2 levels deep)

## Copying and Moving

- `cp file.txt backup.txt` - Copy file
- `cp -r dir/ backup/` - Copy directory recursively
- `mv file.txt newname.txt` - Rename file
- `mv file.txt /path/to/dir/` - Move file
- `rsync -av src/ dest/` - Sync directories

## Creating and Deleting

- `touch newfile.txt` - Create empty file
- `mkdir -p path/to/dir` - Create nested directories
- `rm file.txt` - Delete file
- `rm -r directory/` - Delete directory
- `rmdir empty_dir` - Delete empty directory

## Permissions

- `chmod 755 script.sh` - Make executable
- `chmod +x script.sh` - Add execute permission
- `chmod -R 644 *.txt` - Recursive permission change
- `chown user:group file` - Change owner

## Disk Usage

- `du -sh *` - Size of each item in current dir
- `du -sh */ | sort -h` - Directories sorted by size
- `df -h` - Disk space usage
- `ncdu` - Interactive disk usage viewer

## Compression

- `tar -czvf archive.tar.gz dir/` - Create tar.gz
- `tar -xzvf archive.tar.gz` - Extract tar.gz
- `zip -r archive.zip dir/` - Create zip
- `unzip archive.zip` - Extract zip
- `gzip file.txt` - Compress file
