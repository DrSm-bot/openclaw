---
name: rimworld-gm
description: Control a local or LAN-exposed Rimworld Game Master mod over HTTP for MVP gameplay testing. Use when asked to check colony status, trigger events, or send in-game messages via the Rimworld API endpoints (/health, /state, /event, /message), including LAN mode with Bearer token authentication.
---

# Rimworld GM Skill

## Status

✅ Tested end-to-end and working:
- VM (OpenClaw host) -> Steam Deck over LAN (no SSH tunnel)
- Token auth in LAN mode verified (`401 UNAUTHORIZED` without token)
- Health/state reads and in-game message delivery confirmed

Use the bundled CLI wrapper:

```bash
./scripts/rimworld-gm.sh <command> [args...]
```

## Setup Modes

### Local mode (default, safest)

```bash
RIMWORLD_GM_URL=http://localhost:18800
```

No token required in local-only mode.

### LAN mode (Phase 3a)

In mod `Settings.xml`:
- `bindAddress=0.0.0.0`
- `allowLan=true`
- set strong `authToken`

In shell:

```bash
export RIMWORLD_GM_URL="http://<deck-ip>:18800"
export RIMWORLD_GM_TOKEN="<authToken>"
```

## Commands

```bash
# health
./scripts/rimworld-gm.sh status

# state (optional flags: true/false)
./scripts/rimworld-gm.sh state [include_colonists] [include_resources]

# trigger event
./scripts/rimworld-gm.sh event <event_type> [points]

# send in-game message
./scripts/rimworld-gm.sh message <text> [type]
```

## LAN examples (with token)

```bash
export RIMWORLD_GM_URL="http://192.168.178.42:18800"
export RIMWORLD_GM_TOKEN="your_secret_token"

./scripts/rimworld-gm.sh status
./scripts/rimworld-gm.sh state
./scripts/rimworld-gm.sh event cargo_pod
./scripts/rimworld-gm.sh message "Clawd is watching..." dramatic
```

## Troubleshooting

- **`UNAUTHORIZED`**
  - LAN mode requires token.
  - Check `RIMWORLD_GM_TOKEN` and token value in mod config.
- **`MOD_NOT_READY`**
  - Game paused/loading or no active colony map.
  - Resume game and retry.
- **No connection / timeout**
  - Verify Deck IP and firewall/network reachability.
  - Confirm mod is running and bound to expected interface.
- **Build/deploy mismatch**
  - Ensure latest `RimworldGM.dll` was copied to Deck mod folder.

## Common Commands (Quick Reference)

```bash
# Local mode
RIMWORLD_GM_URL=http://localhost:18800 ./scripts/rimworld-gm.sh status

# LAN mode
RIMWORLD_GM_URL=http://<deck-ip>:18800 RIMWORLD_GM_TOKEN=<token> ./scripts/rimworld-gm.sh status

# Safe checks
./scripts/rimworld-gm.sh state
./scripts/rimworld-gm.sh message "RimworldGM test" info
```

## "Läuft alles?" Checkliste

- [ ] Rimworld running with active colony
- [ ] Mod config set correctly (local or LAN)
- [ ] In LAN mode: token set in env + config
- [ ] `status` returns `game_running: true`
- [ ] `state` returns colony data
- [ ] `message` visible in game

## Known limitations

- `/state`, `/event`, `/message` need active colony map.
- Dangerous events can be blocked by server policy (`enableDangerousEvents=false`).
- CIDR allowlist is not yet enforced in v1.
