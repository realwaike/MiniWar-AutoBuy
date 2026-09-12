# Testing Guide

The current build is a test build. Please test small sections before trusting a long AFK run.

## Current calibrated scroll ranges

| Category | Top → bottom wheel steps |
| --- | ---: |
| Factory | 61 |
| Houses | 30 |
| Military | 61 |

Clicking the category tab resets that section back to the top.

## Recommended test order

### 1. Spread-out Factory test

Select:

- Wheat Farm
- Library
- Data Center
- Anomaly Facility

Verify that the macro reaches each item and locks onto the green cash button.

### 2. Full Factory test

Select all Factory items and record:

- completion time
- skipped/incorrect items
- missed clicks
- multi-stock items that remain in stock
- any recovery messages

### 3. Cross-category test

Select several items from Factory, Houses, and Military and verify that each category resets to the top correctly.

### 4. Full selected-catalog test

Only after the previous tests pass, select all desired items and test against one complete shop restock window.

## Important observations to report

When reporting a failure, include:

- item name
- category
- whether it overshot or undershot
- what item was actually visible/clicked
- whether the green cash button was detected
- whether stock remained after the click burst
- current Roblox resolution/window mode
- screenshot if practical

## Current expected behavior

- A failed item should be retried.
- A failed item should prevent the cycle from being marked complete.
- The macro should recover through **Buy → Shopkeeper → E**, never through the premium red basket Shop button.
- The macro should stop rather than continue blindly if the expected Shopkeeper UI is lost.
