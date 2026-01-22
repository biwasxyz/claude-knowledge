# VM Inventory

## Static IP Assignments

| IP | Hostname | VirtualBox Name | User | Status |
|----|----------|-----------------|------|--------|
| 192.168.1.10 | test-dev | test-dev | (testing) | pending setup |
| 192.168.1.11 | user1-dev | user1-dev | TBD | pending setup |
| 192.168.1.12 | user2-dev | user2-dev | TBD | pending setup |
| 192.168.1.13 | user3-dev | user3-dev | TBD | pending setup |
| 192.168.1.14 | user4-dev | user4-dev | TBD | pending setup |
| 192.168.1.15 | user5-dev | user5-dev | TBD | pending setup |

## Current State

<!-- Update this section as VMs are configured -->

### Clones Created
- [ ] test-dev
- [ ] user1-dev
- [ ] user2-dev
- [ ] user3-dev
- [ ] user4-dev
- [ ] user5-dev

### Setup Completed
- [ ] test-dev - hostname, sudo, static IP, pre-setup, post-setup
- [ ] user1-dev
- [ ] user2-dev
- [ ] user3-dev
- [ ] user4-dev
- [ ] user5-dev

## Network Info

- **Gateway**: 192.168.1.1 (Starlink router)
- **DNS**: 8.8.8.8, 8.8.4.4
- **Host machine**: 192.168.1.157

## Cloudflare Tunnels

| Hostname | URL | Status |
|----------|-----|--------|
| test-dev | https://test.team.aibtc.com | pending |
| user1-dev | https://<github-user>.team.aibtc.com | pending |
| ... | ... | ... |

## Notes

- Base image snapshot: `clean-base`
- Default user: `dev`
- SSH key access configured for admin
