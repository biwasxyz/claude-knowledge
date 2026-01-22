# VM Inventory

## Team VMs

| Hostname | User | Status |
|----------|------|--------|
| aibtc-team-publius | publius | pending setup |
| aibtc-team-cedar | cedar | pending setup |
| aibtc-team-biwas | biwas | pending setup |
| aibtc-team-cca | cca | pending setup |
| aibtc-team-base | (base image) | do not modify |

## Network Info

- Static IPs configured via netplan on each VM
- Hostnames resolve via `/etc/hosts` on host machine
- Gateway: router at .1
- DNS: router, Cloudflare (1.1.1.1)

## Setup Checklist

### Per-VM Setup
- [ ] aibtc-team-publius - hostname, sudo, static IP, pre-setup, post-setup
- [ ] aibtc-team-cedar
- [ ] aibtc-team-biwas
- [ ] aibtc-team-cca

### Host Machine
- [ ] /etc/hosts updated with VM hostnames
- [ ] SSH key access verified

## Cloudflare Tunnels

| Hostname | URL | Status |
|----------|-----|--------|
| aibtc-team-publius | https://publius.team.aibtc.com | pending |
| aibtc-team-cedar | https://cedar.team.aibtc.com | pending |
| aibtc-team-biwas | https://biwas.team.aibtc.com | pending |
| aibtc-team-cca | https://cca.team.aibtc.com | pending |

## Notes

- Base image: `aibtc-team-base` - keep clean, don't modify
- Default user: `dev`
- SSH key access configured for admin
- IPs managed locally, not tracked in docs
