# MiniWar AutoBuy

A Windows AutoHotkey v2 macro for automating repeated purchases from the rotating **Shopkeeper** shop in the Roblox game **Mini War**.

> **Current status:** `v3.4.0-fast-strict-test` — active test build. The project is functional, but the visual positioning/recovery system is still being tuned for long unattended sessions.

## What it does

MiniWar AutoBuy lets you select the exact shop items you want and automatically works through the Factory, Houses, and Military sections. The current build combines calibrated scrolling with visual cash-button detection so it can recover from small positioning errors instead of relying only on fixed keyboard sequences.

### Current features

- AutoHotkey v2
- Complete support for the current **63-item** Shopkeeper catalog
- Factory, Houses, and Military section filtering
- Searchable item list
- Per-category Select All / Clear controls
- Separate **Shop** and **Settings** pages
- `F1` start/stop hotkey
- `F2` immediate exit hotkey
- Roblox process/focus checks
- Shopkeeper recovery through the correct **Buy → Shopkeeper → E** path
- Calibrated category scrolling
  - Factory: 61 wheel steps top-to-bottom
  - Houses: 30 wheel steps top-to-bottom
  - Military: 61 wheel steps top-to-bottom
- Visual green cash-button locking near the calculated item position
- Fast redundant purchase bursts for multi-stock items
- Strict cycle completion: a cycle is not reported complete unless every selected item succeeds
- Item retry/recovery logic
- Runtime counters and current-item progress
- Persistent selections/settings through `MiniWar-AutoBuy.ini`

## Requirements

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/)
- Roblox desktop client
- Mini War

## Installation

1. Install AutoHotkey v2.
2. Download or clone this repository.
3. Run `MiniWar-AutoBuy.ahk`.
4. Select the items you want to purchase.
5. Configure the purchase timing/settings if needed.
6. Start Roblox and enter Mini War.
7. Click **Start AutoBuy** or press `F1`.

## Controls

| Control | Action |
| --- | --- |
| `F1` | Start / request stop |
| `F2` | Exit immediately |
| Start AutoBuy | Starts the selected purchase cycle |

## How the current automation works

The macro does **not** use the red basket button on the left side of the Mini War HUD for recovery. That button opens the premium/crate shop.

The rotating build-item shop is reached through:

```text
Buy (top button)
→ teleport to Shopkeeper
→ press E
→ rotating Shopkeeper shop
```

For each selected category, the macro resets the category to the top, calculates the approximate scroll position for each selected item, then visually searches near that position for the green cash button before clicking.

If an item cannot be purchased successfully, the macro retries that item instead of silently skipping it. A cycle is only counted as complete when all selected items have completed successfully.

## Shop coverage

### Factories — 25 items

Wheat Farm through Anomaly Facility.

### Houses — 13 items

Farm House through Grand Hotel.

### Military — 25 items

Border Tower through War Machine Facility.

The item order in the script matches the current in-game order used during development.

## Settings

Important runtime settings include:

- repeat interval
- between-item delay
- maximum stock attempts
- purchase press delay
- shop-open delay
- shop guard
- saved selections/settings

The current default purchase logic uses redundant click attempts to improve reliability for multi-stock items. This is intentionally more than the expected stock count because Roblox can occasionally drop rapid inputs.

## Safety / recovery behavior

The macro verifies that Roblox is active and that the expected Shopkeeper shop is visible before critical actions. It is designed to stop or retry rather than continue clicking blindly when the expected shop state is lost.

No screen automation can be guaranteed against every possible Roblox update, lag spike, disconnect, UI scale change, or game-side menu change. Treat unattended/AFK use as experimental until the current test build has been validated for your setup.

## Known work in progress

- further improve item-position accuracy across long categories
- reduce missed cash-button clicks
- improve full-stock reliability while keeping purchase bursts fast
- add a true **wait-for-restock** repeat mode instead of repeatedly running on a fixed timer
- validate long unattended sessions
- package the first stable release after the test build is proven reliable

See [`ROADMAP.md`](ROADMAP.md) and [`TESTING.md`](TESTING.md) for current development targets.

## Project files

- `MiniWar-AutoBuy.ahk` — main application
- `README.md` — project overview
- `CHANGELOG.md` — version history
- `ROADMAP.md` — planned work
- `TESTING.md` — current test checklist and calibration notes
- `LICENSE` — MIT License

## Disclaimer

This is an independent community project and is not affiliated with Roblox or the developers of Mini War. Game UI changes can break screen automation. Use the project in accordance with the applicable game/platform rules.

## License

MIT License. See [`LICENSE`](LICENSE).
