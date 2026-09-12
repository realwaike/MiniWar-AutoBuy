# Changelog

All notable development milestones for MiniWar AutoBuy are tracked here.

## v3.4.0-fast-strict-test

- Significantly reduced visual-check overhead during purchase bursts.
- Added strict cycle accounting so incomplete runs are never reported as complete.
- Added per-item retries with category reset/reposition recovery.
- Increased reliable purchase burst speed while retaining redundant clicks.
- Preserved calibrated Factory/Houses/Military scroll positioning.

## v3.3.0-button-lock-test

- Added local visual detection of the green cash button near the calculated item position.
- Added fine alignment correction for small scroll overshoot/undershoot.
- Increased purchase redundancy for multi-stock items.

## v3.2.0-calibrated-scroll-test

- Replaced open-ended scrolling with measured category ranges.
- Factory calibrated to 61 wheel steps.
- Houses calibrated to 30 wheel steps.
- Military calibrated to 61 wheel steps.
- Category tab clicks used as deterministic reset-to-top behavior.

## v3.1.0-shopkeeper-recovery-test

- Corrected recovery routing to use **Buy → Shopkeeper → E**.
- Removed recovery through the left-side premium Shop button.
- Added verification for the specific rotating Shopkeeper interface.

## v3.0.0-self-healing-test

- Introduced visual state verification and recovery concepts.
- Added protection against falsely continuing through unrelated Roblox menus.

## v2.x

- Expanded support to the complete current shop catalog.
- Added bulk category purchasing.
- Added search, status counters, settings persistence, per-category controls, and shop guarding.
- Reworked the interface into dedicated Shop and Settings pages.

## v1.x

- Initial AutoHotkey v2 implementation.
- Basic GUI item selection.
- F1 start/stop and F2 exit.
- Proven keyboard navigation for the first supported Factory, Houses, and Military items.
