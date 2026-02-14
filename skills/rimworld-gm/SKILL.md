---
name: rimworld-gm
description: Control a local Rimworld Game Master mod over HTTP for MVP gameplay testing. Use when asked to check colony status, trigger events, or send in-game messages via the Rimworld API endpoints (/health, /state, /event, /message), especially during Steam Deck + SSH tunnel dev workflows.
---

# Rimworld GM Skill

## Status

✅ Tested end-to-end and working:
- VM (OpenClaw host) -> SSH tunnel -> Steam Deck -> Rimworld mod
- Health/state reads confirmed
- In-game message delivery confirmed

Use the bundled CLI wrapper:

```bash
./scripts/rimworld-gm.sh <command> [args...]
```

## Steam Deck Setup Guide

1. Enable SSH on Deck and confirm IP.
2. Keep Rimworld running with the RimworldGM mod enabled.
3. On VM, open tunnel:

```bash
ssh -N -L 18800:localhost:18800 deck@<deck-ip>
```

4. Optional endpoint override:

```bash
RIMWORLD_GM_URL=http://localhost:18800
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

## Event examples

```bash
./scripts/rimworld-gm.sh event cargo_pod
./scripts/rimworld-gm.sh event solar_flare 400
./scripts/rimworld-gm.sh event raid 500
```

## Message examples

```bash
./scripts/rimworld-gm.sh message "Hello colonists" info
./scripts/rimworld-gm.sh message "Brace yourselves" dramatic
```

## Example `/state` output (truncated)

```json
{
  "colony": {
    "name": "Colony",
    "wealth": 262000,
    "day": 37,
    "season": "Summer",
    "quadrum": "Jugust"
  },
  "colonists": [
    { "name": "PsychoBell", "mood": 92, "health": 100 },
    { "name": "CookWare", "mood": 100, "health": 100 }
  ],
  "resources": {
    "silver": 0,
    "food": 45,
    "medicine": 12,
    "components": 8
  },
  "threats": {
    "active_raids": 0,
    "nearby_enemies": false,
    "toxic_fallout": false
  }
}
```

## Troubleshooting

- **`MOD_NOT_READY`**
  - Game is paused/loading or map not active.
  - Resume game and retry `status`/`state`.
- **Tunnel not working**
  - Reopen tunnel: `ssh -N -L 18800:localhost:18800 deck@<deck-ip>`
  - Validate from VM: `curl http://localhost:18800/health`
- **Build/deploy mismatch**
  - Ensure latest `RimworldGM.dll` is in Deck mod folder after rebuild.

## Common Commands (Quick Reference)

```bash
# Check health
./scripts/rimworld-gm.sh status

# Full colony snapshot
./scripts/rimworld-gm.sh state

# Safe event
./scripts/rimworld-gm.sh event cargo_pod

# In-game message
./scripts/rimworld-gm.sh message "Clawd is watching..." dramatic
```

## "Läuft alles?" Checkliste

- [ ] Rimworld running with active colony
- [ ] SSH tunnel active on VM
- [ ] `status` returns `game_running: true`
- [ ] `state` returns colony data
- [ ] `message` is visible in game

## Known limitations

- Game must be running with an active colony map loaded for `/state`, `/event`, and `/message`.
- If the game is paused/loading, API can return `MOD_NOT_READY`.
- `scripts/test-api.py --base-url ...` can trigger non-harmless events (including raids) depending on parameters.
- Tunnel must stay active for remote Deck control from VM.
