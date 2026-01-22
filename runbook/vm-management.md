# VM Management Runbook

Managing Ubuntu Server VMs for the Claude team environment.

## Overview

- **Hypervisor**: VirtualBox on local host
- **Guest OS**: Ubuntu Server 24.04
- **Network**: Bridged adapter, 192.168.1.x
- **User**: `dev` with passwordless sudo
- **Tunnel**: Cloudflare to `<github-user>.team.aibtc.com`

## Inventory

See: [vm-inventory.md](./vm-inventory.md)

## Initial Clone Setup

After cloning a new VM from base image:

### 1. Boot and Find IP

```bash
# From VirtualBox, start VM headless
VBoxManage startvm "clone-name" --type headless

# Wait ~30s, then find IP (check router or use VBox console)
# Or scan local network from host:
nmap -sn 192.168.1.0/24
```

### 2. SSH In and Set Hostname

```bash
ssh dev@<discovered-ip>
sudo hostnamectl set-hostname <name>-dev
```

### 3. Configure Passwordless Sudo

```bash
echo "dev ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/dev
sudo chmod 440 /etc/sudoers.d/dev
```

### 4. Set Static IP

Check interface name first:
```bash
ip link show
# Usually enp0s3 for VirtualBox
```

Create netplan config:
```bash
sudo tee /etc/netplan/01-static.yaml << 'EOF'
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 192.168.1.XX/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
EOF
```

Replace `XX` with assigned IP from inventory.

Test before applying:
```bash
sudo netplan try
# Press ENTER to accept if it works
# Auto-reverts after 120s if you lose connection
```

### 5. Update Host's /etc/hosts

On your host machine:
```bash
echo "192.168.1.XX <name>-dev" | sudo tee -a /etc/hosts
```

### 6. Reconnect and Run Pre-Setup

```bash
ssh dev@<name>-dev
git clone https://github.com/whoabuddy/claude-team-starter.git
cd claude-team-starter
sudo ./scripts/pre-setup.sh dev
```

### 7. User Runs Post-Setup

```bash
~/post-setup.sh
~/verify.sh
```

## Day-to-Day Operations

### Start All VMs

```bash
for vm in test-dev user1-dev user2-dev; do
  VBoxManage startvm "$vm" --type headless
done
```

### Stop All VMs

```bash
for vm in test-dev user1-dev user2-dev; do
  VBoxManage controlvm "$vm" acpipowerbutton
done
```

### Check VM Status

```bash
VBoxManage list runningvms
```

### SSH to a VM

```bash
ssh dev@<name>-dev
```

### Run Command on All VMs

```bash
for host in test-dev user1-dev user2-dev; do
  echo "=== $host ==="
  ssh dev@$host "command here"
done
```

## Troubleshooting

### Can't SSH

1. Is VM running? `VBoxManage list runningvms`
2. Can you ping it? `ping 192.168.1.XX`
3. Is port 22 open? `nc -zv 192.168.1.XX 22`
4. Check VM console directly in VirtualBox

### Lost Network After Netplan Change

If you used `netplan apply` and lost connection:
- Access via VirtualBox console
- Check `ip addr` - may have reverted or have no IP
- Fix netplan config and try again

### VM Has Wrong IP

DHCP may have assigned different IP. Either:
- Find new IP via router admin or `nmap -sn 192.168.1.0/24`
- Configure static IP to prevent future changes

### Clone Has Same Hostname

```bash
sudo hostnamectl set-hostname unique-name
```

### Permission Denied on sudo

Sudoers file not set up:
```bash
# Need to enter password once to set this up
echo "dev ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/dev
sudo chmod 440 /etc/sudoers.d/dev
```

## Maintenance

### Update All VMs

```bash
for host in test-dev user1-dev user2-dev; do
  echo "=== Updating $host ==="
  ssh dev@$host "sudo apt update && sudo apt upgrade -y"
done
```

### Re-run Pre-Setup (updates tools)

```bash
ssh dev@<name>-dev
cd ~/claude-team-starter && git pull
sudo ./scripts/pre-setup.sh dev
```

### Take Snapshot

From host, with VM stopped:
```bash
VBoxManage snapshot "vm-name" take "description" --description "Before major change"
```

### Restore Snapshot

```bash
VBoxManage snapshot "vm-name" restore "snapshot-name"
```
