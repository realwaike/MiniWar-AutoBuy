#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================================================
; MiniWar AutoBuy
; A lightweight AutoHotkey v2 utility for repeated Mini War shop purchases.
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

; Shop positions are based on the known-working Mini War menu layout.
; If Mini War changes its shop order, update these values only.
Items := [
    {name: "Air Base",                category: "Military",  position: 16},
    {name: "Artillery Depot",         category: "Military",  position: 17},
    {name: "Rocket Bunker",           category: "Military",  position: 18},
    {name: "Mech",                    category: "Military",  position: 19},

    {name: "Data Center",             category: "Factories", position: 19},
    {name: "Blackhole Generator",     category: "Factories", position: 20},
    {name: "Area 51",                 category: "Factories", position: 21},

    {name: "Giant Skyscraper",        category: "Housing",   position: 12},
    {name: "Double Turbo Tower",      category: "Housing",   position: 13}
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

MainGui := Gui("+MinSize380x520")
MainGui.Title := "MiniWar AutoBuy"

MainGui.SetFont("s10", "Segoe UI")
MainGui.Add("Text", "w350", "Select the items to purchase automatically.")
MainGui.Add("Text", "w350", "F1 = Start / Stop     F2 = Exit")

MainGui.Add("Text", "xm y+18 w350 0x10")

CurrentCategory := ""

for Item in Items {
    if Item.category != CurrentCategory {
        CurrentCategory := Item.category
        MainGui.SetFont("s10 Bold", "Segoe UI")
        MainGui.Add("Text", "xm y+12 w350", CurrentCategory)
        MainGui.SetFont("s10 Norm", "Segoe UI")
    }

    Checkbox := MainGui.Add("Checkbox", "xm+12 y+6 w325", Item.name)
    Item.checkbox := Checkbox
}

MainGui.Add("Text", "xm y+16 w350 0x10")

SelectAllButton := MainGui.Add("Button", "xm y+12 w105 h30", "Select All")
ClearAllButton := MainGui.Add("Button", "x+8 w105 h30", "Clear All")
StartStopButton := MainGui.Add("Button", "x+8 w125 h30 Default", "Start AutoBuy")

StatusLabel := MainGui.Add("Text", "xm y+18 w350", "Status: Stopped")
FocusLabel := MainGui.Add("Text", "xm y+6 w350", "Roblox focus required before starting.")

SelectAllButton.OnEvent("Click", SelectAllItems)
ClearAllButton.OnEvent("Click", ClearAllItems)
StartStopButton.OnEvent("Click", ToggleAutoBuy)
MainGui.OnEvent("Close", (*) => ExitApp())

MainGui.Show("w380")

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
    global IsRunning, IsStopRequested, Items, Settings

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

    ; Launch the worker separately so the F1 hotkey remains responsive.
    SetTimer(RunPurchaseCycle, -1)
}

RequestStop() {
    global IsRunning, IsCycleActive, IsStopRequested

    ; Prevent a scheduled future cycle from starting.
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
        if !IsRunning {
            break
        }

        if IsStopRequested {
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
    global Settings

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

        case "Housing":
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
; GUI Helpers
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

UpdateStartStopButton() {
    global IsRunning, StartStopButton

    StartStopButton.Text := IsRunning ? "Stop AutoBuy" : "Start AutoBuy"
}

UpdateStatus(Message) {
    global StatusLabel
    StatusLabel.Text := "Status: " Message
}
