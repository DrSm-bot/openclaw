---
name: rimworld-gm
description: Control a local Rimworld Game Master mod over HTTP for MVP gameplay testing. Use when asked to check colony status, trigger events, or send in-game messages via the Rimworld API endpoints (/health, /state, /event, /message), especially during Steam Deck + SSH tunnel dev workflows.
---

# Rimworld GM Skill

Use the bundled CLI wrapper:

```bash
./scripts/rimworld-gm.sh <command> [args...]
```

## Preconditions

- Ensure Rimworld is running with the RimworldGM mod enabled.
- Ensure API is reachable from this host (for remote Deck testing, keep SSH tunnel active):
  - `ssh -N -L 18800:localhost:18800 deck@<deck-ip>`
- Default API base URL is `http://localhost:18800`.
- Override endpoint via env var if needed:
  - `RIMWORLD_GM_URL=http://127.0.0.1:18800`

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

## Notes

- The contract test script may trigger non-harmless events depending on configuration.
- Prefer manual/safe endpoint checks in active gameplay sessions when needed.
