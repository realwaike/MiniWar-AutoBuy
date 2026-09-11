#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================================================
; MiniWar AutoBuy
; v2.1
;
; Restores the known-good v1 purchase sequence, adds the complete current
; Mini War shop list, and replaces the v2 checkbox layout with reliable
; category ListViews.
; =============================================================================

; -----------------------------------------------------------------------------
; Configuration
; -----------------------------------------------------------------------------

Settings := {
    robloxWindow: "ahk_exe RobloxPlayerBeta.exe",
    cycleDelay: 20000,
    betweenItemsDelay: 1000
}

; IMPORTANT:
; "downCount" is the number of Down presses used by the proven v1 navigation.
;
; Known v1 anchors:
;   Data Center            = 19
;   Blackhole Generator    = 20
;   Giant Skyscraper       = 12
;   Double Turbo Tower     = 13
;   Air Base               = 16
;   Artillery Depot        = 17
;
; The rest of the current shop is mapped from those confirmed positions.

Items := [
    ; Factories
    {name: "Wheat Farm",               category: "Factories", downCount: 2},
    {name: "Corn Farm",                category: "Factories", downCount: 3},
    {name: "Coal Cave",                category: "Factories", downCount: 4},
    {name: "Tree Farm",                category: "Factories", downCount: 5},
    {name: "Windmill",                 category: "Factories", downCount: 6},
    {name: "Carrot Farm",              category: "Factories", downCount: 7},
    {name: "Library",                  category: "Factories", downCount: 8},
    {name: "Oil Rig",                  category: "Factories", downCount: 9},
    {name: "Wood Plant",               category: "Factories", downCount: 10},
    {name: "Iron Cave",                category: "Factories", downCount: 11},
    {name: "Cement Plant",             category: "Factories", downCount: 12},
    {name: "Gold Cave",                category: "Factories", downCount: 13},
    {name: "Bank",                     category: "Factories", downCount: 14},
    {name: "Research Labs",            category: "Factories", downCount: 15},
    {name: "Diamond Cave",             category: "Factories", downCount: 16},
    {name: "Uranium Cave",             category: "Factories", downCount: 17},
    {name: "Nuclear Reactor",          category: "Factories", downCount: 18},
    {name: "Data Center",              category: "Factories", downCount: 19},
    {name: "Blackhole Generator",      category: "Factories", downCount: 20},
    {name: "Area 51 Lab",              category: "Factories", downCount: 21},
    {name: "Antimatter Reactor",       category: "Factories", downCount: 22},
    {name: "Quantum Core Generator",   category: "Factories", downCount: 23},
    {name: "Supernova Accelerator",    category: "Factories", downCount: 24},
    {name: "Gamma Ray Generator",      category: "Factories", downCount: 25},
    {name: "Anomaly Facility",         category: "Factories", downCount: 26},

    ; Houses
    {name: "Farm House",               category: "Houses", downCount: 2},
    {name: "Small House",              category: "Houses", downCount: 3},
    {name: "House",                    category: "Houses", downCount: 4},
    {name: "Villa",                    category: "Houses", downCount: 5},
    {name: "Apartment Building",       category: "Houses", downCount: 6},
    {name: "Modern Block",             category: "Houses", downCount: 7},
    {name: "Skyscraper",               category: "Houses", downCount: 8},
    {name: "Helix Tower",              category: "Houses", downCount: 9},
    {name: "The Manor",                category: "Houses", downCount: 10},
    {name: "Hotel",                    category: "Houses", downCount: 11},
    {name: "Giant Skyscraper",         category: "Houses", downCount: 12},
    {name: "Double Turbo Tower",       category: "Houses", downCount: 13},
    {name: "Grand Hotel",              category: "Houses", downCount: 14},

    ; Military
    {name: "Border Tower",             category: "Military", downCount: 1},
    {name: "Barracks",                 category: "Military", downCount: 2},
    {name: "Sniper Tower",             category: "Military", downCount: 3},
    {name: "Vehicle Base",             category: "Military", downCount: 4},
    {name: "Tank Base",                category: "Military", downCount: 5},
    {name: "Heli Pad",                 category: "Military", downCount: 6},
    {name: "Special Force",            category: "Military", downCount: 7},
    {name: "Missile Hangar",           category: "Military", downCount: 8},
    {name: "Hangar",                   category: "Military", downCount: 9},
    {name: "Drone Facility",           category: "Military", downCount: 10},
    {name: "Big Tank Base",            category: "Military", downCount: 11},
    {name: "Big Hangar",               category: "Military", downCount: 12},
    {name: "Missile Launcher",         category: "Military", downCount: 13},
    {name: "Military Hospital",        category: "Military", downCount: 14},
    {name: "General's Base",           category: "Military", downCount: 15},
    {name: "Air Base",                 category: "Military", downCount: 16},
    {name: "Artillery Depot",          category: "Military", downCount: 17},
    {name: "Laser Drone Hive",         category: "Military", downCount: 18},
    {name: "Rocket Bunker",            category: "Military", downCount: 19},
    {name: "Mech Station",             category: "Military", downCount: 20},
    {name: "Spider Base",              category: "Military", downCount: 21},
    {name: "Air Fortress",             category: "Military", downCount: 22},
    {name: "Plasma Rocket",            category: "Military", downCount: 23},
    {name: "Plasma Hangar",            category: "Military", downCount: 24},
    {name: "War Machine Facility",     category: "Military", downCount: 25}
]

; -----------------------------------------------------------------------------
; Runtime State
; -----------------------------------------------------------------------------

IsRunning := false
IsCycleActive := false
IsStopRequested := false

CategoryLists := Map()

; -----------------------------------------------------------------------------
; GUI
; -----------------------------------------------------------------------------

MainGui := Gui("+MinSize600x545")
MainGui.Title := "MiniWar AutoBuy"

MainGui.SetFont("s10", "Segoe UI")
MainGui.Add("Text", "xm w560", "Select the Mini War shop items you want to purchase automatically.")
MainGui.Add("Text", "xm y+4 w560", "F1 = Start / Stop     F2 = Exit")

ShopTabs := MainGui.Add(
    "Tab3",
    "xm y+14 w560 h365",
    ["Factories", "Houses", "Military"]
)

CreateShopList("Factories")
CreateShopList("Houses")
CreateShopList("Military")

ShopTabs.UseTab()

SelectAllButton := MainGui.Add("Button", "xm y+14 w105 h32", "Select All")
ClearAllButton := MainGui.Add("Button", "x+8 w105 h32", "Clear All")
StartStopButton := MainGui.Add("Button", "x+8 w155 h32 Default", "Start AutoBuy")

StatusLabel := MainGui.Add("Text", "xm y+16 w560", "Status: Stopped")
HintLabel := MainGui.Add(
    "Text",
    "xm y+5 w560",
    "Start AutoBuy will switch focus to Roblox automatically."
)

SelectAllButton.OnEvent("Click", SelectAllItems)
ClearAllButton.OnEvent("Click", ClearAllItems)
StartStopButton.OnEvent("Click", StartStopButtonClicked)
MainGui.OnEvent("Close", (*) => ExitApp())

MainGui.Show("w600 h545")

CreateShopList(Category) {
    global MainGui, ShopTabs, Items, CategoryLists

    ShopTabs.UseTab(Category)

    ShopList := MainGui.Add(
        "ListView",
        "x32 y102 w525 h310 Checked -Multi",
        ["Item"]
    )

    ShopList.ModifyCol(1, 490)

    for Item in Items {
        if Item.category != Category {
            continue
        }

        RowNumber := ShopList.Add("", Item.name)
        Item.listView := ShopList
        Item.rowNumber := RowNumber
    }

    CategoryLists[Category] := ShopList
}

; -----------------------------------------------------------------------------
; Hotkeys
; -----------------------------------------------------------------------------

F1::ToggleAutoBuyFromHotkey()
F2::ExitApp()

ToggleAutoBuyFromHotkey() {
    global IsRunning

    if IsRunning {
        RequestStop()
        return
    }

    StartAutoBuy(false)
}

StartStopButtonClicked(*) {
    global IsRunning

    if IsRunning {
        RequestStop()
        return
    }

    StartAutoBuy(true)
}

; -----------------------------------------------------------------------------
; Controller
; -----------------------------------------------------------------------------

StartAutoBuy(ShouldActivateRoblox) {
    global IsRunning, IsCycleActive, IsStopRequested, Settings

    if IsCycleActive {
        return
    }

    if !HasSelectedItems() {
        UpdateStatus("Select at least one item first.")
        return
    }

    if !WinExist(Settings.robloxWindow) {
        UpdateStatus("Roblox is not running.")
        return
    }

    if ShouldActivateRoblox {
        UpdateStatus("Switching to Roblox...")
        WinActivate(Settings.robloxWindow)

        if !WinWaitActive(Settings.robloxWindow, , 2) {
            UpdateStatus("Could not focus Roblox.")
            return
        }

        Sleep(250)
    } else if !WinActive(Settings.robloxWindow) {
        UpdateStatus("Press F1 while Roblox is focused.")
        return
    }

    IsRunning := true
    IsStopRequested := false

    UpdateStartStopButton()
    UpdateStatus("Running")

    ; Run outside the initiating hotkey/click thread.
    SetTimer(RunPurchaseCycle, -1)
}

RequestStop() {
    global IsRunning, IsCycleActive, IsStopRequested

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

StopImmediately(Message) {
    global IsRunning, IsStopRequested

    SetTimer(RunPurchaseCycle, 0)

    IsRunning := false
    IsStopRequested := false

    UpdateStartStopButton()
    UpdateStatus(Message)
}

RunPurchaseCycle() {
    global Items, Settings
    global IsRunning, IsCycleActive, IsStopRequested

    if !IsRunning || IsCycleActive {
        return
    }

    IsCycleActive := true
    PurchasedAnything := false

    for Item in Items {
        if !IsRunning || IsStopRequested {
            break
        }

        if !IsItemSelected(Item) {
            continue
        }

        PurchasedAnything := true
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

    if !PurchasedAnything {
        StopImmediately("No items are selected.")
        return
    }

    UpdateStatus(
        "Running - next cycle in "
        Round(Settings.cycleDelay / 1000)
        "s"
    )

    SetTimer(RunPurchaseCycle, -Settings.cycleDelay)
}

; -----------------------------------------------------------------------------
; Known-Good v1 Purchase Sequence
; -----------------------------------------------------------------------------

PurchaseItem(Item) {
    if !OpenShop() {
        return false
    }

    if !OpenCategory(Item.category) {
        return false
    }

    if !NavigateToItem(Item.downCount) {
        return false
    }

    return CompletePurchase()
}

OpenShop() {
    if !SendToRoblox("\") {
        return false
    }

    Loop 3 {
        if !SendToRoblox("{Left}") {
            return false
        }
    }

    if !SendToRoblox("{Enter}") {
        return false
    }

    Sleep(1000)

    if !SendToRoblox("e") {
        return false
    }

    Sleep(4000)

    return true
}

OpenCategory(Category) {
    switch Category {
        case "Factories":
            if !SendToRoblox("{Down}") {
                return false
            }

            Sleep(100)

            if !SendToRoblox("{Enter}") {
                return false
            }

            Sleep(100)
            return true

        case "Houses":
            if !SendToRoblox("{Down}") {
                return false
            }

            Sleep(500)

            if !SendToRoblox("{Right}") {
                return false
            }

            Sleep(500)

            if !SendToRoblox("{Enter}") {
                return false
            }

            Sleep(500)
            return true

        case "Military":
            if !SendToRoblox("{Down}") {
                return false
            }

            Sleep(500)

            if !SendToRoblox("{Right}") {
                return false
            }

            if !SendToRoblox("{Right}") {
                return false
            }

            Sleep(500)

            if !SendToRoblox("{Enter}") {
                return false
            }

            Sleep(500)
            return true

        default:
            StopImmediately("Unknown category: " Category)
            return false
    }
}

NavigateToItem(DownCount) {
    Loop DownCount {
        Sleep(100)

        if !SendToRoblox("{Down}") {
            return false
        }
    }

    if !SendToRoblox("{Right}") {
        return false
    }

    Sleep(100)

    if !SendToRoblox("{Enter}") {
        return false
    }

    Sleep(100)

    return true
}

CompletePurchase() {
    if !SendToRoblox("{Right}") {
        return false
    }

    Loop 3 {
        if !SendToRoblox("{Up}") {
            return false
        }
    }

    if !SendToRoblox("{Left}") {
        return false
    }

    Sleep(100)

    if !SendToRoblox("{Left}") {
        return false
    }

    Sleep(100)

    if !SendToRoblox("{Down}") {
        return false
    }

    Sleep(100)

    if !SendToRoblox("{Enter}") {
        return false
    }

    Sleep(100)

    if !SendToRoblox("{Left}") {
        return false
    }

    Sleep(100)

    if !SendToRoblox("{Enter}") {
        return false
    }

    Sleep(100)

    return SendToRoblox("\")
}

; -----------------------------------------------------------------------------
; Input Safety
; -----------------------------------------------------------------------------

SendToRoblox(Keys) {
    global IsRunning, Settings

    if !IsRunning {
        return false
    }

    if !WinActive(Settings.robloxWindow) {
        StopImmediately("Stopped - Roblox lost focus.")
        return false
    }

    Send(Keys)
    return true
}

; -----------------------------------------------------------------------------
; Selection Helpers
; -----------------------------------------------------------------------------

IsItemSelected(Item) {
    return Item.listView.GetNext(Item.rowNumber - 1, "C") = Item.rowNumber
}

HasSelectedItems() {
    global Items

    for Item in Items {
        if IsItemSelected(Item) {
            return true
        }
    }

    return false
}

SelectAllItems(*) {
    global CategoryLists

    for Category, ShopList in CategoryLists {
        Loop ShopList.GetCount() {
            ShopList.Modify(A_Index, "Check")
        }
    }
}

ClearAllItems(*) {
    global CategoryLists, IsRunning

    if IsRunning {
        UpdateStatus("Stop AutoBuy before clearing selections.")
        return
    }

    for Category, ShopList in CategoryLists {
        Loop ShopList.GetCount() {
            ShopList.Modify(A_Index, "-Check")
        }
    }
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
