#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================================================
; MiniWar AutoBuy
; v2.3 Test Build
;
; Complete shop coverage, larger UI, search/filtering, per-category controls,
; configurable cycle timing, runtime statistics, Roblox status, settings
; persistence, full-stock purchase attempts, and single-item purchase timing fix.
; =============================================================================

; -----------------------------------------------------------------------------
; Application
; -----------------------------------------------------------------------------

AppVersion := "v2.3-test"
ConfigFile := A_ScriptDir "\MiniWar-AutoBuy.ini"

Settings := {
    robloxWindow: "ahk_exe RobloxPlayerBeta.exe",

    ; Runtime settings. These are updated from the Settings panel.
    cycleDelay: 20000,
    betweenItemsDelay: 1000,
    autoFocusRoblox: true,
    rememberSelections: true,

    ; The shop can contain more than one copy of the same item.
    ; The macro cannot read the visible stock number, so it safely attempts
    ; the same focused purchase button up to this many times.
    buyFullStock: true,
    maxStockAttempts: 5,

    ; Purchase timing.
    purchaseClickDelay: 400,
    purchaseSettleDelay: 650
}

; -----------------------------------------------------------------------------
; Shop Data
; -----------------------------------------------------------------------------
;
; "downCount" preserves the working navigation mapping from v2.1/v2.2.
;
; Factories and Houses use list index + 1.
; Military uses the list index directly.
;
; Known working anchors:
;   Data Center            = 19
;   Blackhole Generator    = 20
;   Giant Skyscraper       = 12
;   Double Turbo Tower     = 13
;   Air Base               = 16
;   Artillery Depot        = 17
; -----------------------------------------------------------------------------

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

for Item in Items {
    Item.selected := false
}

; -----------------------------------------------------------------------------
; Runtime State
; -----------------------------------------------------------------------------

IsRunning := false
IsCycleActive := false
IsStopRequested := false
IsRefreshingLists := false

CyclesCompleted := 0
PurchaseAttempts := 0
RunStartedAt := 0
LastRunElapsedMs := 0

CategoryLists := Map()
CategoryVisibleItems := Map()

; -----------------------------------------------------------------------------
; Load Saved Preferences
; -----------------------------------------------------------------------------

LoadPreferences()

; -----------------------------------------------------------------------------
; GUI
; -----------------------------------------------------------------------------

MainGui := Gui("+MinSize1040x720")
MainGui.Title := "MiniWar AutoBuy " AppVersion
MainGui.MarginX := 20
MainGui.MarginY := 18

; Header ----------------------------------------------------------------------

MainGui.SetFont("s17 Bold", "Segoe UI")
MainGui.Add("Text", "xm ym w540 h32", "MiniWar AutoBuy")

MainGui.SetFont("s9 Norm", "Segoe UI")
MainGui.Add("Text", "x+10 yp+7 w115 Right", AppVersion)

RobloxStatusLabel := MainGui.Add(
    "Text",
    "x700 yp w300 h24 Right",
    "Roblox: Checking..."
)

MainGui.SetFont("s10 Norm", "Segoe UI")
MainGui.Add(
    "Text",
    "xm y+4 w650 h22",
    "Select shop items, configure the cycle, then start AutoBuy."
)

; Search ----------------------------------------------------------------------

MainGui.SetFont("s9 Bold", "Segoe UI")
MainGui.Add("Text", "xm y+18 w90 h22", "Search")

MainGui.SetFont("s10 Norm", "Segoe UI")
SearchEdit := MainGui.Add(
    "Edit",
    "x+8 yp-3 w560 h28",
    ""
)

ClearSearchButton := MainGui.Add(
    "Button",
    "x+8 yp w80 h28",
    "Clear"
)

; Shop tabs -------------------------------------------------------------------

ShopTabs := MainGui.Add(
    "Tab3",
    "xm y+14 w650 h520",
    ["Factories", "Houses", "Military"]
)

CreateCategoryTab("Factories")
CreateCategoryTab("Houses")
CreateCategoryTab("Military")

ShopTabs.UseTab()

; Right-side status panel -----------------------------------------------------

MainGui.SetFont("s10 Bold", "Segoe UI")
MainGui.Add("GroupBox", "x700 y98 w320 h215", "Run Status")

MainGui.SetFont("s9 Norm", "Segoe UI")
StatusLabel := MainGui.Add(
    "Text",
    "x720 y127 w280 h24",
    "Status: Stopped"
)

CurrentItemLabel := MainGui.Add(
    "Text",
    "x720 y158 w280 h42",
    "Buying: —"
)

ProgressLabel := MainGui.Add(
    "Text",
    "x720 y202 w280 h22",
    "Item: —"
)

CyclesLabel := MainGui.Add(
    "Text",
    "x720 y232 w280 h22",
    "Cycles completed: 0"
)

AttemptsLabel := MainGui.Add(
    "Text",
    "x720 y258 w280 h22",
    "Purchase attempts: 0"
)

RuntimeLabel := MainGui.Add(
    "Text",
    "x720 y284 w280 h22",
    "Session runtime: 0s"
)

; Settings panel --------------------------------------------------------------

MainGui.SetFont("s10 Bold", "Segoe UI")
MainGui.Add("GroupBox", "x700 y328 w320 h285", "Settings")

MainGui.SetFont("s9 Norm", "Segoe UI")

MainGui.Add("Text", "x720 y360 w150 h22", "Repeat every")
CycleDelayEdit := MainGui.Add(
    "Edit",
    "x875 y356 w75 h26 Number",
    Round(Settings.cycleDelay / 1000)
)
MainGui.Add("UpDown", "Range5-600", Round(Settings.cycleDelay / 1000))
MainGui.Add("Text", "x955 y360 w45 h22", "sec")

MainGui.Add("Text", "x720 y397 w150 h22", "Between items")
BetweenItemsEdit := MainGui.Add(
    "Edit",
    "x875 y393 w75 h26 Number",
    Settings.betweenItemsDelay
)
MainGui.Add("UpDown", "Range100-5000", Settings.betweenItemsDelay)
MainGui.Add("Text", "x955 y397 w45 h22", "ms")

MainGui.Add("Text", "x720 y434 w150 h22", "Max stock attempts")
MaxStockEdit := MainGui.Add(
    "Edit",
    "x875 y430 w75 h26 Number",
    Settings.maxStockAttempts
)
MainGui.Add("UpDown", "Range1-10", Settings.maxStockAttempts)

BuyFullStockCheckbox := MainGui.Add(
    "Checkbox",
    "x720 y470 w260 h24",
    "Buy full available stock"
)
BuyFullStockCheckbox.Value := Settings.buyFullStock ? 1 : 0

AutoFocusCheckbox := MainGui.Add(
    "Checkbox",
    "x720 y500 w260 h24",
    "Auto-focus Roblox when starting"
)
AutoFocusCheckbox.Value := Settings.autoFocusRoblox ? 1 : 0

RememberSelectionsCheckbox := MainGui.Add(
    "Checkbox",
    "x720 y530 w260 h24",
    "Remember selections and settings"
)
RememberSelectionsCheckbox.Value := Settings.rememberSelections ? 1 : 0

MainGui.SetFont("s8 Norm", "Segoe UI")
MainGui.Add(
    "Text",
    "x720 y562 w275 h42",
    "Cycle range: 5–600 sec   •   Between-item range: 100–5000 ms"
)

; Bottom controls -------------------------------------------------------------

MainGui.SetFont("s9 Norm", "Segoe UI")
SelectionLabel := MainGui.Add(
    "Text",
    "xm y+12 w250 h24",
    "Selected: 0 items"
)

MainGui.SetFont("s10 Bold", "Segoe UI")
StartStopButton := MainGui.Add(
    "Button",
    "x700 y628 w320 h40 Default",
    "Start AutoBuy"
)

MainGui.SetFont("s9 Norm", "Segoe UI")
MainGui.Add(
    "Text",
    "x700 y676 w320 h24 Center",
    "F1  Start / Stop     •     F2  Exit"
)

; Events ----------------------------------------------------------------------

SearchEdit.OnEvent("Change", (*) => RebuildShopLists())
ClearSearchButton.OnEvent("Click", ClearSearch)
StartStopButton.OnEvent("Click", StartStopButtonClicked)

MainGui.OnEvent("Close", OnGuiClose)

MainGui.Show("w1040 h720")

RebuildShopLists()
RefreshSelectionSummary()
UpdateRobloxStatus()
UpdateStatsDisplay()

SetTimer(UpdateRobloxStatus, 1000)
SetTimer(UpdateRuntimeDisplay, 1000)

; -----------------------------------------------------------------------------
; GUI Creation
; -----------------------------------------------------------------------------

CreateCategoryTab(Category) {
    global MainGui, ShopTabs, CategoryLists, CategoryVisibleItems

    ShopTabs.UseTab(Category)

    MainGui.SetFont("s9 Norm", "Segoe UI")

    SelectCategoryButton := MainGui.Add(
        "Button",
        "x42 y164 w135 h28",
        "Select All " Category
    )

    ClearCategoryButton := MainGui.Add(
        "Button",
        "x+8 yp w135 h28",
        "Clear " Category
    )

    CategoryCountLabel := MainGui.Add(
        "Text",
        "x+18 yp+5 w250 h22 Right",
        ""
    )

    ShopList := MainGui.Add(
        "ListView",
        "x42 y202 w605 h395 Checked -Multi",
        ["Shop Item"]
    )

    ShopList.ModifyCol(1, 570)

    SelectCategoryButton.OnEvent(
        "Click",
        (*) => SetCategorySelection(Category, true)
    )

    ClearCategoryButton.OnEvent(
        "Click",
        (*) => SetCategorySelection(Category, false)
    )

    ShopList.OnEvent(
        "ItemCheck",
        (Ctrl, Row, Checked) => OnShopItemCheck(Category, Row, Checked)
    )

    CategoryLists[Category] := ShopList
    CategoryVisibleItems[Category] := []
}

; -----------------------------------------------------------------------------
; Search / List Model
; -----------------------------------------------------------------------------

RebuildShopLists(*) {
    global Items, CategoryLists, CategoryVisibleItems
    global SearchEdit, IsRefreshingLists

    SearchText := StrLower(Trim(SearchEdit.Value))
    IsRefreshingLists := true

    for Category, ShopList in CategoryLists {
        ShopList.Delete()

        VisibleItems := []

        for Item in Items {
            if Item.category != Category {
                continue
            }

            if SearchText != "" && !InStr(StrLower(Item.name), SearchText) {
                continue
            }

            RowOptions := Item.selected ? "Check" : ""
            ShopList.Add(RowOptions, Item.name)
            VisibleItems.Push(Item)
        }

        CategoryVisibleItems[Category] := VisibleItems
        ShopList.ModifyCol(1, 570)
    }

    IsRefreshingLists := false
    RefreshSelectionSummary()
}

OnShopItemCheck(Category, Row, Checked) {
    global CategoryVisibleItems, IsRefreshingLists

    if IsRefreshingLists {
        return
    }

    VisibleItems := CategoryVisibleItems[Category]

    if Row < 1 || Row > VisibleItems.Length {
        return
    }

    VisibleItems[Row].selected := Checked ? true : false

    SetTimer(RefreshSelectionSummary, -1)
}

ClearSearch(*) {
    global SearchEdit

    SearchEdit.Value := ""
    RebuildShopLists()
}

SetCategorySelection(Category, ShouldSelect) {
    global Items, IsRunning

    if IsRunning {
        UpdateStatus("Stop AutoBuy before changing selections.")
        return
    }

    for Item in Items {
        if Item.category = Category {
            Item.selected := ShouldSelect
        }
    }

    RebuildShopLists()
}

RefreshSelectionSummary() {
    global Items, SelectionLabel

    SelectedCount := 0

    for Item in Items {
        if Item.selected {
            SelectedCount += 1
        }
    }

    SelectionLabel.Text := (
        "Selected: "
        SelectedCount
        " item"
        (SelectedCount = 1 ? "" : "s")
    )
}

GetSelectedItems() {
    global Items

    SelectedItems := []

    for Item in Items {
        if Item.selected {
            SelectedItems.Push(Item)
        }
    }

    return SelectedItems
}

HasSelectedItems() {
    return GetSelectedItems().Length > 0
}

; -----------------------------------------------------------------------------
; Hotkeys
; -----------------------------------------------------------------------------

F1::ToggleAutoBuyFromHotkey()
F2::ExitApplication()

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

StartAutoBuy(StartedFromGui) {
    global IsRunning, IsCycleActive, IsStopRequested, RunStartedAt
    global Settings

    if IsCycleActive {
        return
    }

    ApplySettingsFromGui()

    if !HasSelectedItems() {
        UpdateStatus("Select at least one item first.")
        return
    }

    if !WinExist(Settings.robloxWindow) {
        UpdateStatus("Roblox is not running.")
        return
    }

    if StartedFromGui {
        if Settings.autoFocusRoblox {
            UpdateStatus("Switching to Roblox...")
            WinActivate(Settings.robloxWindow)

            if !WinWaitActive(Settings.robloxWindow, , 2) {
                UpdateStatus("Could not focus Roblox.")
                return
            }

            Sleep(300)
        } else {
            UpdateStatus("Auto-focus is off. Press F1 while Roblox is focused.")
            return
        }
    } else if !WinActive(Settings.robloxWindow) {
        UpdateStatus("Press F1 while Roblox is focused.")
        return
    }

    IsRunning := true
    IsStopRequested := false
    RunStartedAt := A_TickCount

    SavePreferences()
    UpdateStartStopButton()
    UpdateStatus("Running")
    UpdateCurrentProgress("Preparing...", "Starting cycle")

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
    UpdateCurrentProgress("—", "—")
}

StopImmediately(Message) {
    global IsRunning, IsStopRequested

    SetTimer(RunPurchaseCycle, 0)

    IsRunning := false
    IsStopRequested := false

    UpdateStartStopButton()
    UpdateStatus(Message)
    UpdateCurrentProgress("—", "—")
}

RunPurchaseCycle() {
    global Settings
    global IsRunning, IsCycleActive, IsStopRequested
    global CyclesCompleted, PurchaseAttempts

    if !IsRunning || IsCycleActive {
        return
    }

    SelectedItems := GetSelectedItems()

    if SelectedItems.Length = 0 {
        StopImmediately("No items are selected.")
        return
    }

    IsCycleActive := true

    for Index, Item in SelectedItems {
        if !IsRunning || IsStopRequested {
            break
        }

        UpdateStatus("Buying " Item.name "...")
        UpdateCurrentProgress(
            Item.name,
            "Item " Index " of " SelectedItems.Length
        )

        PurchaseAttempts += 1
        UpdateStatsDisplay()

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
        UpdateCurrentProgress("—", "—")
        return
    }

    if !IsRunning {
        return
    }

    CyclesCompleted += 1
    UpdateStatsDisplay()

    UpdateStatus(
        "Waiting "
        Round(Settings.cycleDelay / 1000)
        " seconds for the next cycle"
    )

    UpdateCurrentProgress("—", "Cycle complete")

    SetTimer(RunPurchaseCycle, -Settings.cycleDelay)
}

; -----------------------------------------------------------------------------
; Purchase Engine
; -----------------------------------------------------------------------------
;
; Shop opening, category movement, item down-count navigation, and reset
; navigation retain the proven v2.1 sequence.
;
; The purchase-button step is the only intentional behavioral change:
;   1. Stay focused on the cash purchase button.
;   2. Press Enter repeatedly when full-stock mode is enabled.
;   3. Wait longer for the purchase to register.
;
; This fixes:
;   - only buying one unit from a multi-stock listing;
;   - single-selected-item runs moving correctly but failing to register a buy.
; -----------------------------------------------------------------------------

PurchaseItem(Item) {
    if !OpenShop() {
        return false
    }

    if !OpenCategory(Item.category) {
        return false
    }

    if !NavigateToPurchaseButton(Item.downCount) {
        return false
    }

    if !PurchaseAvailableStock() {
        return false
    }

    return CompletePurchaseReset()
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

NavigateToPurchaseButton(DownCount) {
    Loop DownCount {
        Sleep(100)

        if !SendToRoblox("{Down}") {
            return false
        }
    }

    if !SendToRoblox("{Right}") {
        return false
    }

    Sleep(150)

    return true
}

PurchaseAvailableStock() {
    global Settings, IsStopRequested

    Attempts := Settings.buyFullStock ? Settings.maxStockAttempts : 1

    Loop Attempts {
        if IsStopRequested {
            return true
        }

        if !SendToRoblox("{Enter}") {
            return false
        }

        Sleep(Settings.purchaseClickDelay)
    }

    ; Give even a single selected item enough time to register server-side
    ; before the UI-navigation reset begins.
    Sleep(Settings.purchaseSettleDelay)

    return true
}

CompletePurchaseReset() {
    ; This reset sequence is preserved from the working v2.1 build.

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

    Sleep(150)

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
; Settings
; -----------------------------------------------------------------------------

ApplySettingsFromGui() {
    global Settings
    global CycleDelayEdit, BetweenItemsEdit, MaxStockEdit
    global AutoFocusCheckbox, RememberSelectionsCheckbox
    global BuyFullStockCheckbox

    CycleSeconds := CycleDelayEdit.Value + 0
    BetweenMs := BetweenItemsEdit.Value + 0
    MaxAttempts := MaxStockEdit.Value + 0

    CycleSeconds := Max(5, Min(600, CycleSeconds))
    BetweenMs := Max(100, Min(5000, BetweenMs))
    MaxAttempts := Max(1, Min(10, MaxAttempts))

    CycleDelayEdit.Value := CycleSeconds
    BetweenItemsEdit.Value := BetweenMs
    MaxStockEdit.Value := MaxAttempts

    Settings.cycleDelay := CycleSeconds * 1000
    Settings.betweenItemsDelay := BetweenMs
    Settings.maxStockAttempts := MaxAttempts

    Settings.buyFullStock := BuyFullStockCheckbox.Value = 1
    Settings.autoFocusRoblox := AutoFocusCheckbox.Value = 1
    Settings.rememberSelections := RememberSelectionsCheckbox.Value = 1
}

LoadPreferences() {
    global ConfigFile, Settings, Items

    if !FileExist(ConfigFile) {
        return
    }

    try Settings.cycleDelay := Max(
        5000,
        Min(
            600000,
            (IniRead(ConfigFile, "Settings", "CycleSeconds", "20") + 0) * 1000
        )
    )

    try Settings.betweenItemsDelay := Max(
        100,
        Min(
            5000,
            IniRead(ConfigFile, "Settings", "BetweenItemsMs", "1000") + 0
        )
    )

    try Settings.maxStockAttempts := Max(
        1,
        Min(
            10,
            IniRead(ConfigFile, "Settings", "MaxStockAttempts", "5") + 0
        )
    )

    try Settings.buyFullStock := (
        IniRead(ConfigFile, "Settings", "BuyFullStock", "1") + 0
    ) = 1

    try Settings.autoFocusRoblox := (
        IniRead(ConfigFile, "Settings", "AutoFocusRoblox", "1") + 0
    ) = 1

    try Settings.rememberSelections := (
        IniRead(ConfigFile, "Settings", "RememberSelections", "1") + 0
    ) = 1

    if !Settings.rememberSelections {
        return
    }

    for Item in Items {
        SafeKey := MakeIniKey(Item.category "|" Item.name)

        try Item.selected := (
            IniRead(ConfigFile, "Selections", SafeKey, "0") + 0
        ) = 1
    }
}

SavePreferences() {
    global ConfigFile, Settings, Items

    ; Controls do not exist during early startup, so callers apply GUI settings
    ; before invoking this function while the application is running.

    try IniWrite(
        Round(Settings.cycleDelay / 1000),
        ConfigFile,
        "Settings",
        "CycleSeconds"
    )

    try IniWrite(
        Settings.betweenItemsDelay,
        ConfigFile,
        "Settings",
        "BetweenItemsMs"
    )

    try IniWrite(
        Settings.maxStockAttempts,
        ConfigFile,
        "Settings",
        "MaxStockAttempts"
    )

    try IniWrite(
        Settings.buyFullStock ? 1 : 0,
        ConfigFile,
        "Settings",
        "BuyFullStock"
    )

    try IniWrite(
        Settings.autoFocusRoblox ? 1 : 0,
        ConfigFile,
        "Settings",
        "AutoFocusRoblox"
    )

    try IniWrite(
        Settings.rememberSelections ? 1 : 0,
        ConfigFile,
        "Settings",
        "RememberSelections"
    )

    if Settings.rememberSelections {
        for Item in Items {
            SafeKey := MakeIniKey(Item.category "|" Item.name)

            try IniWrite(
                Item.selected ? 1 : 0,
                ConfigFile,
                "Selections",
                SafeKey
            )
        }
    } else {
        try IniDelete(ConfigFile, "Selections")
    }
}

MakeIniKey(Value) {
    Key := StrReplace(Value, " ", "_")
    Key := StrReplace(Key, "|", "__")
    Key := StrReplace(Key, "'", "")
    return Key
}

; -----------------------------------------------------------------------------
; Status / Statistics
; -----------------------------------------------------------------------------

UpdateRobloxStatus(*) {
    global Settings, RobloxStatusLabel

    if WinExist(Settings.robloxWindow) {
        RobloxStatusLabel.Text := "Roblox: Connected"
    } else {
        RobloxStatusLabel.Text := "Roblox: Not detected"
    }
}

UpdateStatus(Message) {
    global StatusLabel
    StatusLabel.Text := "Status: " Message
}

UpdateCurrentProgress(ItemName, ProgressText) {
    global CurrentItemLabel, ProgressLabel

    CurrentItemLabel.Text := "Buying: " ItemName
    ProgressLabel.Text := "Item: " ProgressText
}

UpdateStatsDisplay() {
    global CyclesCompleted, PurchaseAttempts
    global CyclesLabel, AttemptsLabel

    CyclesLabel.Text := "Cycles completed: " CyclesCompleted
    AttemptsLabel.Text := "Purchase attempts: " PurchaseAttempts
}

UpdateRuntimeDisplay(*) {
    global IsRunning, RunStartedAt, LastRunElapsedMs, RuntimeLabel

    if IsRunning && RunStartedAt > 0 {
        ElapsedMs := A_TickCount - RunStartedAt
        LastRunElapsedMs := ElapsedMs
    } else {
        ElapsedMs := LastRunElapsedMs
    }

    RuntimeLabel.Text := "Session runtime: " FormatDuration(ElapsedMs)
}

FormatDuration(Milliseconds) {
    TotalSeconds := Floor(Milliseconds / 1000)

    if TotalSeconds < 60 {
        return TotalSeconds "s"
    }

    Minutes := Floor(TotalSeconds / 60)
    Seconds := Mod(TotalSeconds, 60)

    if Minutes < 60 {
        return Minutes "m " Seconds "s"
    }

    Hours := Floor(Minutes / 60)
    Minutes := Mod(Minutes, 60)

    return Hours "h " Minutes "m"
}

UpdateStartStopButton() {
    global IsRunning, StartStopButton

    StartStopButton.Text := IsRunning ? "Stop AutoBuy" : "Start AutoBuy"
}

; -----------------------------------------------------------------------------
; Shutdown
; -----------------------------------------------------------------------------

OnGuiClose(*) {
    ExitApplication()
}

ExitApplication() {
    ApplySettingsFromGui()
    SavePreferences()
    ExitApp()
}
