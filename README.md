# MiniWar AutoBuy

A lightweight AutoHotkey v2 utility for automating repeated shop purchases in the Roblox game **Mini War**.

MiniWar AutoBuy lets you select the items you want, toggle automation with a hotkey, and keeps keyboard input restricted to the Roblox client so the macro does not continue typing into another application.

## Features

- AutoHotkey v2
- Select exactly which shop items should be purchased
- `F1` toggles auto-buying on or off
- `F2` immediately exits the script
- Roblox-focused input protection
- Stops safely if Roblox loses focus during a purchase
- Configurable timing values in one place
- Data-driven item configuration instead of one function per item
- Visible runtime status in the GUI
- Select All and Clear All controls

## Supported items

### Military
- Air Base
- Artillery Depot
- Rocket Bunker
- Mech

### Factories
- Data Center
- Blackhole Generator
- Area 51

### Housing
- Giant Skyscraper
- Double Turbo Tower

## Requirements

1. Windows
2. [AutoHotkey v2](https://www.autohotkey.com/)
3. Roblox desktop client
4. Mini War

## Usage

1. Install AutoHotkey v2.
2. Download or clone this repository.
3. Run `MiniWar-AutoBuy.ahk`.
4. Check the items you want the macro to purchase.
5. Focus the Roblox window.
6. Press `F1` or click **Start AutoBuy**.
7. Press `F1` again to stop after the current purchase finishes.
8. Press `F2` to exit the script immediately.

## Safety behavior

MiniWar AutoBuy checks that `RobloxPlayerBeta.exe` is the active window before sending keyboard input. If Roblox loses focus during an active purchase, the macro stops instead of continuing to send keys to whichever application became active.

`F1` performs a controlled stop after the current purchase. `F2` is the immediate exit hotkey.

## Configuration

The main timing values are at the top of `MiniWar-AutoBuy.ahk`:

```ahk
Settings := {
    cycleDelay: 20000,
    betweenItemsDelay: 1000,
    menuOpenDelay: 4000,
    navigationDelay: 100
}
```

Shop locations are stored in the `Items` array:

```ahk
{name: "Air Base", category: "Military", position: 16}
```

This makes adding or adjusting shop items much easier than maintaining a separate purchase function for every item.

## Notes

The current navigation positions are based on the known-working Mini War shop sequence used when this project was created. If Mini War changes its menus or item order, the category or position values may need to be updated.

This project is not affiliated with Roblox or the developers of Mini War. Make sure your use complies with the applicable game and platform rules.

## License

MIT License. See [`LICENSE`](LICENSE).
