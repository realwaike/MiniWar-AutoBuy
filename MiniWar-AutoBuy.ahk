#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================================================
; MiniWar AutoBuy
; Version 2
;
; AutoHotkey v2 utility for repeated Mini War shop purchases.
; =============================================================================

; -----------------------------------------------------------------------------
; Configuration
; -----------------------------------------------------------------------------

Settings := {
    robloxWindow: "ahk_exe RobloxPlayerBeta.exe",
    cycleDelay: 20000,
    betweenItemsDelay: 1000,
    menuEntryDelay: 1000,
    menuOpenDelay: 4000,
    navigationDelay: 100,
    categoryNavigationDelay: 500
}

; Shop positions are based on the current Mini War shop order.
;
; Position conventions are preserved from the working v1 navigation:
;   Factories = displayed item number + 1
;   Houses   = displayed item number + 1
;   Military = displayed item number
;
; If Mini War changes its shop order, only this table should need updating.

Items := [
    ; -------------------------------------------------------------------------
    ; Factories
    ; -------------------------------------------------------------------------
    {name: "Wheat Farm",               category: "Factories", position: 2},
    {name: "Corn Farm",                category: "Factories", position: 3},
    {name: "Coal Cave",                category: "Factories", position: 4},
    {name: "Tree Farm",                category: "Factories", position: 5},
    {name: "Windmill",                 category: "Factories", position: 6},
    {name: "Carrot Farm",              category: "Factories", position: 7},
    {name: "Library",                  category: "Factories", position: 8},
    {name: "Oil Rig",                  category: "Factories", position: 9},
    {name: "Wood Plant",               category: "Factories", position: 10},
    {name: "Iron Cave",                category: "Factories", position: 11},
    {name: "Cement Plant",             category: "Factories", position: 12},
    {name: "Gold Cave",                category: "Factories", position: 13},
    {name: "Bank",                     category: "Factories", position: 14},
    {name: "Research Labs",            category: "Factories", position: 15},
    {name: "Diamond Cave",             category: "Factories", position: 16},
    {name: "Uranium Cave",             category: "Factories", position: 17},
    {name: "Nuclear Reactor",          category: "Factories", position: 18},
    {name: "Data Center",              category: "Factories", position: 19},
    {name: "Blackhole Generator",      category: "Factories", position: 20},
    {name: "Area 51 Lab",              category: "Factories", position: 21},
    {name: "Antimatter Reactor",       category: "Factories", position: 22},
    {name: "Quantum Core Generator",   category: "Factories", position: 23},
    {name: "Supernova Accelerator",    category: "Factories", position: 24},
    {name: "Gamma Ray Generator",      category: "Factories", position: 25},
    {name: "Anomaly Facility",         category: "Factories", position: 26},

    ; -------------------------------------------------------------------------
    ; Houses
    ; -------------------------------------------------------------------------
    {name: "Farm House",               category: "Houses", position: 2},
    {name: "Small House",              category: "Houses", position: 3},
    {name: "House",                    category: "Houses", position: 4},
    {name: "Villa",                    category: "Houses", position: 5},
    {name: "Apartment Building",       category: "Houses", position: 6},
    {name: "Modern Block",             category: "Houses", position: 7},
    {name: "Skyscraper",               category: "Houses", position: 8},
    {name: "Helix Tower",              category: "Houses", position: 9},
    {name: "The Manor",                category: "Houses", position: 10},
    {name: "Hotel",                    category: "Houses", position: 11},
    {name: "Giant Skyscraper",         category: "Houses", position: 12},
    {name: "Double Turbo Tower",       category: "Houses", position: 13},
    {name: "Grand Hotel",              category: "Houses", position: 14},

    ; -------------------------------------------------------------------------
    ; Military
    ; -------------------------------------------------------------------------
    {name: "Border Tower",             category: "Military", position: 1},
    {name: "Barracks",                 category: "Military", position: 2},
    {name: "Sniper Tower",             category: "Military", position: 3},
    {name: "Vehicle Base",             category: "Military", position: 4},
    {name: "Tank Base",                category: "Military", position: 5},
    {name: "Heli Pad",                 category: "Military", position: 6},
    {name: "Special Force",            category: "Military", position: 7},
    {name: "Missile Hangar",           category: "Military", position: 8},
    {name: "Hangar",                   category: "Military", position: 9},
    {name: "Drone Facility",           category: "Military", position: 10},
    {name: "Big Tank Base",            category: "Military", position: 11},
    {name: "Big Hangar",               category: "Military", position: 12},
    {name: "Missile Launcher",         category: "Military", position: 13},
    {name: "Military Hospital",        category: "Military", position: 14},
    {name: "General's Base",           category: "Military", position: 15},
    {name: "Air Base",                 category: "Military", position: 16},
    {name: "Artillery Depot",          category: "Military", position: 17},
    {name: "Laser Drone Hive",         category: "Military", position: 18},
    {name: "Rocket Bunker",            category: "Military", position: 19},
    {name: "Mech Station",             category: "Military", position: 20},
    {name: "Spider Base",              category: "Military", position: 21},
    {name: "Air Fortress",             category: "Military", position: 22},
    {name: "Plasma Rocket",            category: "Military", position: 23},
    {name: "Plasma Hangar",            category: "Military", position: 24},
    {name: "War Machine Facility",     category: "Military", position: 25}
]

; -----------------------------------------------------------------------------
; Runtime State
; -----------------------------------------------------------------------------

IsRunning := false
IsCycleActive := false
IsStopRequested := false

; -----------------------------------------------------------------------------
; GUI
; -----------------------------------------------------------------------------

MainGui := Gui("+MinSize540x530")
MainGui.Title := "MiniWar AutoBuy"

MainGui.SetFont("s10", "Segoe UI")
MainGui.Add("Text", "xm w500", "Select the shop items you want purchased automatically.")
MainGui.Add("Text", "xm y+4 w500", "F1 = Start / Stop     F2 = Exit")

ShopTabs := MainGui.Add("Tab3", "xm y+14 w500 h350", ["Factories", "Houses", "Military"])

BuildCategoryTab("Factories")
BuildCategoryTab("Houses")
BuildCategoryTab("Military")

ShopTabs.UseTab()

MainGui.Add("Text", "xm y+12 w500 0x10")

SelectAllButton := MainGui.Add("Button", "xm y+12 w105 h30", "Select All")
ClearAllButton := MainGui.Add("Button", "x+8 w105 h30", "Clear All")
StartStopButton := MainGui.Add("Button", "x+8 w150 h30 Default", "Start AutoBuy")

StatusLabel := MainGui.Add("Text", "xm y+16 w500", "Status: Stopped")
FocusLabel := MainGui.Add("Text", "xm y+5 w500", "Roblox focus required before starting.")

SelectAllButton.OnEvent("Click", SelectAllItems)
ClearAllButton.OnEvent("Click", ClearAllItems)
StartStopButton.OnEvent("Click", ToggleAutoBuy)
MainGui.OnEvent("Close", (*) => ExitApp())

MainGui.Show("w540 h530")

BuildCategoryTab(Category) {
    global MainGui, ShopTabs, Items

    ShopTabs.UseTab(Category)

    CategoryItems := []

    for Item in Items {
        if Item.category = Category {
            CategoryItems.Push(Item)
        }
    }

    LeftColumnCount := Ceil(CategoryItems.Length / 2)

    for Index, Item in CategoryItems {
        if Index <= LeftColumnCount {
            XPosition := "xm+24"
            YPosition := Index = 1 ? "yp+44" : "y+8"
        } else {
            RightColumnIndex := Index - LeftColumnCount
            XPosition := "xm+270"
            YPosition := RightColumnIndex = 1 ? "yp+44" : "y+8"
        }

        Checkbox := MainGui.Add(
            "Checkbox",
            XPosition " " YPosition " w220",
            Item.name
        )

        Item.checkbox := Checkbox
    }
}

; -----------------------------------------------------------------------------
; Hotkeys
; -----------------------------------------------------------------------------

F1::ToggleAutoBuy()
F2::ExitApp()

; -----------------------------------------------------------------------------
; Controller
; -----------------------------------------------------------------------------

ToggleAutoBuy(*) {
    global IsRunning, IsCycleActive

    if IsRunning {
        RequestStop()
        return
    }

    if IsCycleActive {
        return
    }

    StartAutoBuy()
}

StartAutoBuy() {
    global IsRunning, IsStopRequested, Settings

    if !HasSelectedItems() {
        UpdateStatus("Select at least one item first.")
        return
    }

    if !WinActive(Settings.robloxWindow) {
        UpdateStatus("Roblox is not focused.")
        return
    }

    IsRunning := true
    IsStopRequested := false

    UpdateStartStopButton()
    UpdateStatus("Running")

    ; Launch separately so the F1 hotkey remains responsive.
    SetTimer(RunPurchaseCycle, -1)
}

RequestStop() {
    global IsRunning, IsCycleActive, IsStopRequested

    ; Cancel a future scheduled cycle.
    SetTimer(RunPurchaseCycle, 0)

    if IsCycleActive {
        IsStopRequested := true
        UpdateStatus("Stopping after current item...")
        return
    }

    IsRunning := false
    IsStopRequested := false

    UpdateStartStopButton()
    UpdateStatus("Stopped")
}

StopImmediatelyWithStatus(Message) {
    global IsRunning, IsStopRequested

    SetTimer(RunPurchaseCycle, 0)

    IsRunning := false
    IsStopRequested := false

    UpdateStartStopButton()
    UpdateStatus(Message)
}

RunPurchaseCycle() {
    global IsRunning, IsCycleActive, IsStopRequested, Items, Settings

    if !IsRunning || IsCycleActive {
        return
    }

    IsCycleActive := true
    DidPurchaseItem := false

    for Item in Items {
        if !IsRunning || IsStopRequested {
            break
        }

        if !Item.checkbox.Value {
            continue
        }

        DidPurchaseItem := true
        UpdateStatus("Buying " Item.name "...")

        if !PurchaseItem(Item) {
            break
        }

        if IsStopRequested {
            break
        }

        Sleep(Settings.betweenItemsDelay)
    }

    IsCycleActive := false

    if IsStopRequested {
        IsRunning := false
        IsStopRequested := false

        UpdateStartStopButton()
        UpdateStatus("Stopped")
        return
    }

    if !IsRunning {
        return
    }

    if !DidPurchaseItem {
        StopImmediatelyWithStatus("No items are selected.")
        return
    }

    UpdateStatus("Running - next cycle in " Round(Settings.cycleDelay / 1000) "s")
    SetTimer(RunPurchaseCycle, -Settings.cycleDelay)
}

; -----------------------------------------------------------------------------
; Purchase Engine
; -----------------------------------------------------------------------------

PurchaseItem(Item) {
    if !OpenShop() {
        return false
    }

    if !SelectCategory(Item.category) {
        return false
    }

    if !SelectShopItem(Item.position) {
        return false
    }

    if !ConfirmPurchase() {
        return false
    }

    return true
}

OpenShop() {
    global Settings

    if !SendToRoblox("\") {
        return false
    }

    if !SendRepeatedToRoblox("{Left}", 3, Settings.navigationDelay) {
        return false
    }

    if !SendToRoblox("{Enter}", Settings.menuEntryDelay) {
        return false
    }

    if !SendToRoblox("e", Settings.menuOpenDelay) {
        return false
    }

    return SendToRoblox("{Down}", Settings.navigationDelay)
}

SelectCategory(Category) {
    global Settings

    switch Category {
        case "Factories":
            return SendToRoblox("{Enter}", Settings.navigationDelay)

        case "Houses":
            if !SendToRoblox("{Right}", Settings.categoryNavigationDelay) {
                return false
            }

            return SendToRoblox("{Enter}", Settings.categoryNavigationDelay)

        case "Military":
            if !SendRepeatedToRoblox("{Right}", 2, Settings.categoryNavigationDelay) {
                return false
            }

            return SendToRoblox("{Enter}", Settings.categoryNavigationDelay)

        default:
            StopImmediatelyWithStatus("Unknown category: " Category)
            return false
    }
}

SelectShopItem(Position) {
    global Settings

    if !SendRepeatedToRoblox("{Down}", Position, Settings.navigationDelay) {
        return false
    }

    if !SendToRoblox("{Right}", Settings.navigationDelay) {
        return false
    }

    return SendToRoblox("{Enter}", Settings.navigationDelay)
}

ConfirmPurchase() {
    global Settings

    if !SendToRoblox("{Right}", Settings.navigationDelay) {
        return false
    }

    if !SendRepeatedToRoblox("{Up}", 3, Settings.navigationDelay) {
        return false
    }

    if !SendRepeatedToRoblox("{Left}", 2, Settings.navigationDelay) {
        return false
    }

    if !SendToRoblox("{Down}", Settings.navigationDelay) {
        return false
    }

    if !SendToRoblox("{Enter}", Settings.navigationDelay) {
        return false
    }

    if !SendToRoblox("{Left}", Settings.navigationDelay) {
        return false
    }

    if !SendToRoblox("{Enter}", Settings.navigationDelay) {
        return false
    }

    return SendToRoblox("\")
}

; -----------------------------------------------------------------------------
; Input Safety
; -----------------------------------------------------------------------------

SendToRoblox(Keys, DelayAfter := 0) {
    global IsRunning, Settings

    if !IsRunning {
        return false
    }

    if !WinActive(Settings.robloxWindow) {
        StopImmediatelyWithStatus("Stopped - Roblox lost focus.")
        return false
    }

    Send(Keys)

    if DelayAfter > 0 {
        Sleep(DelayAfter)
    }

    return true
}

SendRepeatedToRoblox(Keys, Count, DelayAfterEach := 0) {
    Loop Count {
        if !SendToRoblox(Keys, DelayAfterEach) {
            return false
        }
    }

    return true
}

; -----------------------------------------------------------------------------
; Selection Helpers
; -----------------------------------------------------------------------------

SelectAllItems(*) {
    global Items

    for Item in Items {
        Item.checkbox.Value := 1
    }
}

ClearAllItems(*) {
    global Items, IsRunning

    if IsRunning {
        UpdateStatus("Stop AutoBuy before clearing the selection.")
        return
    }

    for Item in Items {
        Item.checkbox.Value := 0
    }
}

HasSelectedItems() {
    global Items

    for Item in Items {
        if Item.checkbox.Value {
            return true
        }
    }

    return false
}

; -----------------------------------------------------------------------------
; Status Helpers
; -----------------------------------------------------------------------------

UpdateStartStopButton() {
    global IsRunning, StartStopButton

    StartStopButton.Text := IsRunning ? "Stop AutoBuy" : "Start AutoBuy"
}

UpdateStatus(Message) {
    global StatusLabel

    StatusLabel.Text := "Status: " Message
}
