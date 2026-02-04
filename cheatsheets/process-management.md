# Process Management

## Viewing Processes

- `ps aux` - All processes
- `ps aux | grep node` - Find specific process
- `pgrep -f "pattern"` - Get PID by pattern
- `top` - Interactive process viewer
- `htop` - Better interactive viewer
- `pstree` - Process tree

## Killing Processes

- `kill PID` - Terminate process
- `kill -9 PID` - Force kill
- `killall node` - Kill by name
- `pkill -f "pattern"` - Kill by pattern
- `kill $(lsof -t -i:3000)` - Kill process on port

## Background Jobs

- `command &` - Run in background
- `jobs` - List background jobs
- `fg` - Bring to foreground
- `fg %1` - Bring job 1 to foreground
- `bg` - Resume in background
- `Ctrl+Z` - Suspend current process
- `nohup command &` - Keep running after logout
- `disown` - Detach from terminal

## System Information

- `uptime` - System uptime
- `whoami` - Current user
- `id` - User and group IDs
- `uname -a` - System information
- `lscpu` - CPU information
- `free -h` - Memory usage
- `vmstat` - Virtual memory stats

## Resource Usage

- `top -o %MEM` - Sort by memory
- `top -o %CPU` - Sort by CPU
- `iotop` - Disk I/O by process
- `lsof` - Open files and connections
- `lsof -p PID` - Files opened by process

## Scheduling

- `crontab -l` - List cron jobs
- `crontab -e` - Edit cron jobs
- `at now + 5 minutes` - Run once in 5 min
- `watch -n 5 command` - Run every 5 seconds

## Service Management (systemd)

- `systemctl status service` - Check status
- `systemctl start service` - Start service
- `systemctl stop service` - Stop service
- `systemctl restart service` - Restart service
- `systemctl enable service` - Enable on boot
- `journalctl -u service` - Service logs

## Service Management (macOS)

- `launchctl list` - List services
- `launchctl start service` - Start service
- `launchctl stop service` - Stop service
- `brew services list` - Homebrew services
- `brew services start service` - Start brew service

## Signals

- `kill -l` - List all signals
- `kill -SIGTERM PID` - Graceful termination
- `kill -SIGKILL PID` - Force kill (signal 9)
- `kill -SIGHUP PID` - Hangup (reload config)
- `kill -SIGUSR1 PID` - User-defined signal
