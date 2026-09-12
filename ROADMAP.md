# Roadmap

MiniWar AutoBuy is currently in active testing. Reliability is prioritized over adding unrelated features.

## Priority 0 — Stable purchase engine

- [ ] Complete all selected Factory items without skips.
- [ ] Complete all selected Houses items without skips.
- [ ] Complete all selected Military items without skips.
- [ ] Consistently lock onto the green cash purchase button.
- [ ] Reliably clear typical multi-stock items.
- [ ] Complete the full selected catalog inside one shop restock window where possible.
- [ ] Never report a cycle complete when an item failed.

## Priority 1 — AFK / long-session reliability

- [ ] Add **Wait for Restock** repeat mode.
- [ ] Detect restock without slowing active purchasing.
- [ ] Recover cleanly from a lost/closed Shopkeeper UI.
- [ ] Handle Roblox reconnect/session interruption states safely.
- [ ] Add clearer recovery/failure status messages.
- [ ] Validate multi-hour unattended runs.

## Priority 2 — Calibration and portability

- [ ] Add resolution/UI-scale calibration assistant.
- [ ] Store calibration profiles.
- [ ] Allow category scroll calibration from the Settings page.
- [ ] Detect when a Mini War UI update invalidates the saved calibration.

## Priority 3 — Release polish

- [ ] Stable semantic version release.
- [ ] GitHub release notes and downloadable build asset.
- [ ] Optional compiled executable distribution.
- [ ] Screenshots/GIFs in the README.
- [ ] Troubleshooting documentation.
