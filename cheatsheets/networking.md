# Networking

## HTTP Requests

- `curl https://example.com` - GET request
- `curl -o file.zip URL` - Download file
- `curl -X POST -d "data" URL` - POST request
- `curl -H "Auth: token" URL` - Custom header
- `curl -I URL` - Headers only
- `wget URL` - Download file
- `wget -r URL` - Recursive download

## Network Information

- `ifconfig` - Network interfaces (macOS/older Linux)
- `ip addr` - Network interfaces (modern Linux)
- `hostname` - Show hostname
- `hostname -I` - Show IP address

## DNS

- `nslookup domain.com` - DNS lookup
- `dig domain.com` - Detailed DNS query
- `dig +short domain.com` - Just the IP
- `host domain.com` - Simple DNS lookup

## Connectivity

- `ping google.com` - Test connectivity
- `ping -c 5 google.com` - Ping 5 times
- `traceroute google.com` - Trace route
- `mtr google.com` - Interactive traceroute

## Ports and Connections

- `lsof -i :3000` - What's using port 3000
- `netstat -tuln` - All listening ports
- `ss -tuln` - Modern netstat alternative
- `nc -zv host 80` - Test if port is open

## SSH

- `ssh user@host` - Connect to remote
- `ssh -p 2222 user@host` - Custom port
- `ssh-keygen -t ed25519` - Generate key pair
- `ssh-copy-id user@host` - Copy key to server
- `scp file.txt user@host:/path/` - Copy file to remote
- `scp user@host:/path/file.txt .` - Copy from remote

## Firewall (Linux)

- `ufw status` - Firewall status
- `ufw allow 80` - Allow port 80
- `ufw deny 22` - Deny port 22
- `iptables -L` - List rules

## Transferring Files

- `rsync -avz src/ user@host:dest/` - Sync to remote
- `rsync -avz user@host:src/ dest/` - Sync from remote
- `sftp user@host` - Interactive file transfer
- `ftp host` - FTP connection
