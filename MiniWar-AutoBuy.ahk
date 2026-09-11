#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================================================
; MiniWar AutoBuy
; v2.5.4 Navigation Reset Test Build
;
; Complete shop coverage, larger UI, search/filtering, per-category controls,
; configurable cycle timing, runtime statistics, Roblox status, settings
; persistence, full-stock purchase attempts, and single-item purchase timing fix.
; =============================================================================

; -----------------------------------------------------------------------------
; Application
; -----------------------------------------------------------------------------

AppVersion := "v2.5.4-nav-reset-test"
ConfigFile := A_ScriptDir "\MiniWar-AutoBuy.ini"

Settings := {
    robloxWindow: "ahk_exe RobloxPlayerBeta.exe",

    ; Runtime settings. These are updated from the Settings panel.
    cycleDelay: 20000,
    betweenItemsDelay: 150,
    autoFocusRoblox: true,
    rememberSelections: true,

    ; The shop can contain more than one copy of the same item.
    ; The macro cannot read the visible stock number, so it safely attempts
    ; the same focused purchase button up to this many times.
    buyFullStock: true,
    maxStockAttempts: 8,

    ; Purchase timing.
    purchaseClickDelay: 250,
    purchaseSettleDelay: 350,

    ; Faster navigation timing.
    shopEntryDelay: 300,
    shopOpenDelay: 1200,
    categoryDelay: 175,
    navigationDelay: 60,
    itemFocusDelay: 90,
    resetDelay: 65,
    autoFocusDelay: 150,

    ; Shop safety / fast fixed-stock purchasing.
    shopGuardEnabled: true,
    fixedPurchaseDelay: 90,
    shopCloseDelay: 180
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

ActiveCategory := "Factories"
VisibleShopItems := []

; -----------------------------------------------------------------------------
; Load Saved Preferences
; -----------------------------------------------------------------------------

LoadPreferences()

; -----------------------------------------------------------------------------
; GUI
; -----------------------------------------------------------------------------

MainGui := Gui("+MinSize1180x780")
MainGui.Title := "MiniWar AutoBuy " AppVersion
MainGui.MarginX := 22
MainGui.MarginY := 18

; Header ----------------------------------------------------------------------

MainGui.SetFont("s18 Bold", "Segoe UI")
MainGui.Add("Text", "xm ym w560 h34", "MiniWar AutoBuy")

MainGui.SetFont("s9 Norm", "Segoe UI")
MainGui.Add("Text", "x+8 yp+9 w120 h22", AppVersion)

RobloxStatusLabel := MainGui.Add(
    "Text",
    "x840 yp w300 h24 Right",
    "Roblox: Checking..."
)

MainGui.SetFont("s10 Norm", "Segoe UI")
MainGui.Add(
    "Text",
    "xm y+2 w760 h24",
    "Choose shop items on the left. Runtime controls and settings stay on the right."
)

MainGui.Add("Text", "xm y+12 w1135 h1 0x10")

; Left panel: shop ------------------------------------------------------------

MainGui.SetFont("s10 Bold", "Segoe UI")
MainGui.Add("GroupBox", "xm y+14 w770 h625", "Shop Items")

MainGui.SetFont("s9 Bold", "Segoe UI")
MainGui.Add("Text", "x42 y129 w70 h22", "Search")

MainGui.SetFont("s10 Norm", "Segoe UI")
SearchEdit := MainGui.Add(
    "Edit",
    "x115 y124 w555 h30",
    ""
)

ClearSearchButton := MainGui.Add(
    "Button",
    "x680 y124 w82 h30",
    "Clear"
)

MainGui.SetFont("s9 Bold", "Segoe UI")
MainGui.Add("Text", "x42 y174 w70 h22", "Section")

MainGui.SetFont("s10 Norm", "Segoe UI")
CategoryDropdown := MainGui.Add(
    "DropDownList",
    "x115 y168 w225 Choose1",
    ["Factories", "Houses", "Military"]
)

SelectCategoryButton := MainGui.Add(
    "Button",
    "x355 y168 w165 h30",
    "Select All Factories"
)

ClearCategoryButton := MainGui.Add(
    "Button",
    "x530 y168 w165 h30",
    "Clear Factories"
)

CategorySummaryLabel := MainGui.Add(
    "Text",
    "x42 y210 w700 h22",
    "Factories"
)

ShopList := MainGui.Add(
    "ListView",
    "x42 y238 w720 h445 Checked -Multi",
    ["Shop Item"]
)

ShopList.ModifyCol(1, 680)

SelectionLabel := MainGui.Add(
    "Text",
    "x42 y699 w500 h24",
    "Selected: 0 items"
)

; Right panel: run status -----------------------------------------------------

MainGui.SetFont("s10 Bold", "Segoe UI")
MainGui.Add("GroupBox", "x815 y91 w340 h250", "Run Status")

MainGui.SetFont("s9 Norm", "Segoe UI")
StatusLabel := MainGui.Add("Text", "x835 y123 w300 h36", "Status: Stopped")
CurrentItemLabel := MainGui.Add("Text", "x835 y167 w300 h42", "Buying: —")
ProgressLabel := MainGui.Add("Text", "x835 y214 w300 h24", "Item: —")
CyclesLabel := MainGui.Add("Text", "x835 y248 w300 h24", "Cycles completed: 0")
AttemptsLabel := MainGui.Add("Text", "x835 y278 w300 h24", "Purchase attempts: 0")
RuntimeLabel := MainGui.Add("Text", "x835 y308 w300 h24", "Session runtime: 0s")

; Right panel: settings -------------------------------------------------------

MainGui.SetFont("s10 Bold", "Segoe UI")
MainGui.Add("GroupBox", "x815 y356 w340 h300", "Settings")

MainGui.SetFont("s9 Norm", "Segoe UI")
MainGui.Add("Text", "x835 y391 w145 h24", "Repeat every")
CycleDelayEdit := MainGui.Add("Edit", "x985 y386 w82 h28 Number", Round(Settings.cycleDelay / 1000))
MainGui.Add("UpDown", "Range5-600", Round(Settings.cycleDelay / 1000))
MainGui.Add("Text", "x1075 y391 w45 h24", "sec")

MainGui.Add("Text", "x835 y430 w145 h24", "Between items")
BetweenItemsEdit := MainGui.Add("Edit", "x985 y425 w82 h28 Number", Settings.betweenItemsDelay)
MainGui.Add("UpDown", "Range100-5000", Settings.betweenItemsDelay)
MainGui.Add("Text", "x1075 y430 w45 h24", "ms")

MainGui.Add("Text", "x835 y469 w145 h24", "Max stock attempts")
MaxStockEdit := MainGui.Add("Edit", "x985 y464 w82 h28 Number", Settings.maxStockAttempts)
MainGui.Add("UpDown", "Range1-12", Settings.maxStockAttempts)

BuyFullStockCheckbox := MainGui.Add("Checkbox", "x835 y506 w285 h24", "Buy full available stock")
BuyFullStockCheckbox.Value := Settings.buyFullStock ? 1 : 0

AutoFocusCheckbox := MainGui.Add("Checkbox", "x835 y539 w285 h24", "Auto-focus Roblox when starting")
AutoFocusCheckbox.Value := Settings.autoFocusRoblox ? 1 : 0

RememberSelectionsCheckbox := MainGui.Add("Checkbox", "x835 y572 w285 h24", "Remember selections and settings")
RememberSelectionsCheckbox.Value := Settings.rememberSelections ? 1 : 0

MainGui.SetFont("s8 Norm", "Segoe UI")
MainGui.Add(
    "Text",
    "x835 y607 w285 h38",
    "Fast stock: 8 attempts   •   Shop guard: ON   •   90 ms per press"
)

; Primary action --------------------------------------------------------------

MainGui.SetFont("s10 Bold", "Segoe UI")
StartStopButton := MainGui.Add(
    "Button",
    "x815 y674 w340 h44 Default",
    "Start AutoBuy"
)

MainGui.SetFont("s9 Norm", "Segoe UI")
MainGui.Add("Text", "x815 y730 w340 h24 Center", "F1  Start / Stop     •     F2  Exit")

; Events ----------------------------------------------------------------------

SearchEdit.OnEvent("Change", (*) => RebuildShopList())
ClearSearchButton.OnEvent("Click", ClearSearch)
CategoryDropdown.OnEvent("Change", CategoryChanged)
SelectCategoryButton.OnEvent("Click", (*) => SetCategorySelection(ActiveCategory, true))
ClearCategoryButton.OnEvent("Click", (*) => SetCategorySelection(ActiveCategory, false))
ShopList.OnEvent("ItemCheck", OnShopItemCheck)
StartStopButton.OnEvent("Click", StartStopButtonClicked)
MainGui.OnEvent("Close", OnGuiClose)

MainGui.Show("w1180 h780")

RebuildShopList()
RefreshSelectionSummary()
UpdateRobloxStatus()
UpdateStatsDisplay()

SetTimer(UpdateRobloxStatus, 1000)
SetTimer(UpdateRuntimeDisplay, 1000)

; -----------------------------------------------------------------------------
; GUI / Shop Browser
; -----------------------------------------------------------------------------

CategoryChanged(*) {
    global CategoryDropdown, ActiveCategory
    global SelectCategoryButton, ClearCategoryButton

    ActiveCategory := CategoryDropdown.Text

    SelectCategoryButton.Text := "Select All " ActiveCategory
    ClearCategoryButton.Text := "Clear " ActiveCategory

    RebuildShopList()
}

RebuildShopList(*) {
    global Items, ShopList, VisibleShopItems
    global SearchEdit, ActiveCategory, IsRefreshingLists
    global CategorySummaryLabel

    SearchText := StrLower(Trim(SearchEdit.Value))

    IsRefreshingLists := true
    ShopList.Delete()
    VisibleShopItems := []

    CategoryTotal := 0
    VisibleCount := 0
    SelectedInCategory := 0

    for Item in Items {
        if Item.category != ActiveCategory {
            continue
        }

        CategoryTotal += 1

        if Item.selected {
            SelectedInCategory += 1
        }

        if SearchText != "" && !InStr(StrLower(Item.name), SearchText) {
            continue
        }

        RowOptions := Item.selected ? "Check" : ""
        ShopList.Add(RowOptions, Item.name)
        VisibleShopItems.Push(Item)
        VisibleCount += 1
    }

    ShopList.ModifyCol(1, 680)
    IsRefreshingLists := false

    if SearchText = "" {
        CategorySummaryLabel.Text := (
            ActiveCategory
            "  •  "
            CategoryTotal
            " items  •  "
            SelectedInCategory
            " selected"
        )
    } else {
        CategorySummaryLabel.Text := (
            ActiveCategory
            "  •  "
            VisibleCount
            " matching  •  "
            SelectedInCategory
            " selected total"
        )
    }

    RefreshSelectionSummary()
}

OnShopItemCheck(Ctrl, Row, Checked) {
    global VisibleShopItems, IsRefreshingLists

    if IsRefreshingLists {
        return
    }

    if Row < 1 || Row > VisibleShopItems.Length {
        return
    }

    VisibleShopItems[Row].selected := Checked ? true : false

    SetTimer(RebuildShopList, -1)
}

ClearSearch(*) {
    global SearchEdit

    SearchEdit.Value := ""
    RebuildShopList()
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

    RebuildShopList()
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

            Sleep(Settings.autoFocusDelay)
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

    Categories := ["Factories", "Houses", "Military"]
    TotalSelected := SelectedItems.Length
    OverallIndex := 0

    for Category in Categories {
        if !IsRunning || IsStopRequested {
            break
        }

        CategoryItems := []

        for Item in SelectedItems {
            if Item.category = Category {
                CategoryItems.Push(Item)
            }
        }

        if CategoryItems.Length = 0 {
            continue
        }

        UpdateStatus("Opening " Category "...")

        if !OpenShop() {
            break
        }

        if !OpenCategory(Category) {
            break
        }

        ; Navigate from the category's starting focus to the first selected item.
        FirstItem := CategoryItems[1]

        if !NavigateToPurchaseButton(FirstItem.downCount) {
            break
        }

        PreviousDownCount := FirstItem.downCount

        for CategoryIndex, Item in CategoryItems {
            if !IsRunning || IsStopRequested {
                break
            }

            OverallIndex += 1

            ; After a purchase, focus remains on that item's green cash button.
            ; Moving Down advances directly to the next item's cash button.
            if CategoryIndex > 1 {
                StepsDown := Item.downCount - PreviousDownCount

                if StepsDown < 1 {
                    StopImmediately("Invalid shop order for " Item.name ".")
                    break
                }

                if !MoveDownThroughShop(StepsDown) {
                    break
                }
            }

            UpdateStatus("Buying " Item.name "...")
            UpdateCurrentProgress(
                Item.name,
                OverallIndex " of " TotalSelected
            )

            PurchaseAttempts += 1
            UpdateStatsDisplay()

            if !PurchaseAvailableStock() {
                break
            }

            PreviousDownCount := Item.downCount

            if IsStopRequested {
                break
            }

            Sleep(Settings.betweenItemsDelay)
        }

        if !IsRunning || IsStopRequested {
            break
        }

        ; Close safely once after the entire category.
        if !CloseShopSafely() {
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

MoveDownThroughShop(Count) {
    global Settings

    Loop Count {
        if !SendToRoblox("{Down}") {
            return false
        }

        Sleep(Settings.navigationDelay)
    }

    return true
}

; -----------------------------------------------------------------------------
; Purchase Engine
; -----------------------------------------------------------------------------
;
; v2.4 bulk mode:
;   - open the shop once per selected category;
;   - navigate to the first selected item;
;   - buy its available stock;
;   - move Down directly between selected item cash buttons;
;   - close/reset once at the end of that category.
;
; The screenshots confirmed that after buying an item, focus remains on the
; same green cash button and one Down moves to the next item's cash button.
; -----------------------------------------------------------------------------

OpenShop() {
    global Settings

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

    Sleep(Settings.shopEntryDelay)

    if !SendToRoblox("e") {
        return false
    }

    Sleep(Settings.shopOpenDelay)

    return true
}

OpenCategory(Category) {
    global Settings

    switch Category {
        case "Factories":
            if !SendToRoblox("{Down}") {
                return false
            }

            Sleep(Settings.navigationDelay)

            if !SendToRoblox("{Enter}") {
                return false
            }

            Sleep(Settings.navigationDelay)
            return true

        case "Houses":
            if !SendToRoblox("{Down}") {
                return false
            }

            Sleep(Settings.categoryDelay)

            if !SendToRoblox("{Right}") {
                return false
            }

            Sleep(Settings.categoryDelay)

            if !SendToRoblox("{Enter}") {
                return false
            }

            Sleep(Settings.categoryDelay)
            return true

        case "Military":
            if !SendToRoblox("{Down}") {
                return false
            }

            Sleep(Settings.categoryDelay)

            if !SendToRoblox("{Right}") {
                return false
            }

            if !SendToRoblox("{Right}") {
                return false
            }

            Sleep(Settings.categoryDelay)

            if !SendToRoblox("{Enter}") {
                return false
            }

            Sleep(Settings.categoryDelay)
            return true

        default:
            StopImmediately("Unknown category: " Category)
            return false
    }
}

NavigateToPurchaseButton(DownCount) {
    global Settings

    Loop DownCount {
        Sleep(Settings.navigationDelay)

        if !SendToRoblox("{Down}") {
            return false
        }
    }

    if !SendToRoblox("{Right}") {
        return false
    }

    Sleep(Settings.itemFocusDelay)

    return true
}

PurchaseAvailableStock() {
    global Settings, IsStopRequested

    Attempts := Settings.buyFullStock ? Settings.maxStockAttempts : 1

    ; Check the shop once before purchasing. Do not perform expensive visual
    ; stock detection between every Enter press.
    if Settings.shopGuardEnabled && !IsShopVisible() {
        StopImmediately("Shop lost - AutoBuy stopped for safety.")
        return false
    }

    Loop Attempts {
        if IsStopRequested {
            return true
        }

        if !SendToRoblox("{Enter}") {
            return false
        }

        Sleep(Settings.fixedPurchaseDelay)
    }

    ; Small settle delay before moving to the next item's cash button.
    Sleep(80)

    return true
}

CloseShopSafely() {
    global Settings

    if Settings.shopGuardEnabled && !IsShopVisible() {
        StopImmediately("Shop lost - AutoBuy stopped for safety.")
        return false
    }

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        StopImmediately("Could not read Roblox window position.")
        return false
    }

    ; IMPORTANT:
    ; The purchase sweep uses Roblox UI Navigation, so it is still ON here.
    ; Disable it BEFORE the mouse closes the shop. Otherwise Roblox remembers
    ; the previous cash button as its selected UI object, and the next shop
    ; opening can begin from that stale focus and wander into unrelated UI.
    Send("\")
    Sleep(90)

    ; Close the visible shop with the mouse while UI Navigation is OFF.
    CloseX := ClientX + Round(ClientWidth * 0.735)
    CloseY := ClientY + Round(ClientHeight * 0.215)

    Click(CloseX, CloseY)
    Sleep(Settings.shopCloseDelay)

    ; OpenShop() deliberately starts with "\". Because navigation is now OFF,
    ; that next "\" will always ENABLE it from a clean state.
    return true
}

IsShopVisible() {
    global Settings

    if !WinActive(Settings.robloxWindow) {
        return false
    }

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        return false
    }

    HeaderLeft := ClientX + Round(ClientWidth * 0.22)
    HeaderTop := ClientY + Round(ClientHeight * 0.14)
    HeaderRight := ClientX + Round(ClientWidth * 0.50)
    HeaderBottom := ClientY + Round(ClientHeight * 0.27)

    CloseLeft := ClientX + Round(ClientWidth * 0.68)
    CloseTop := ClientY + Round(ClientHeight * 0.14)
    CloseRight := ClientX + Round(ClientWidth * 0.78)
    CloseBottom := ClientY + Round(ClientHeight * 0.28)

    HasBlueHeader := PixelSearch(
        &FoundHeaderX,
        &FoundHeaderY,
        HeaderLeft,
        HeaderTop,
        HeaderRight,
        HeaderBottom,
        0x55BFEA,
        85
    )

    HasRedClose := PixelSearch(
        &FoundCloseX,
        &FoundCloseY,
        CloseLeft,
        CloseTop,
        CloseRight,
        CloseBottom,
        0xE83434,
        85
    )

    return HasBlueHeader && HasRedClose
}

GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
    global Settings

    try {
        WinGetClientPos(
            &ClientX,
            &ClientY,
            &ClientWidth,
            &ClientHeight,
            Settings.robloxWindow
        )

        return ClientWidth > 0 && ClientHeight > 0
    } catch {
        return false
    }
}

CompletePurchaseReset() {
    global Settings

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

    Sleep(Settings.resetDelay)

    if !SendToRoblox("{Left}") {
        return false
    }

    Sleep(Settings.resetDelay)

    if !SendToRoblox("{Down}") {
        return false
    }

    Sleep(Settings.resetDelay)

    if !SendToRoblox("{Enter}") {
        return false
    }

    Sleep(Settings.resetDelay)

    if !SendToRoblox("{Left}") {
        return false
    }

    Sleep(Settings.resetDelay)

    if !SendToRoblox("{Enter}") {
        return false
    }

    Sleep(Settings.itemFocusDelay)

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

    CycleSecondsValue := ReadClampedInteger(
        CycleDelayEdit,
        20,
        5,
        600
    )

    BetweenItemsValue := ReadClampedInteger(
        BetweenItemsEdit,
        150,
        100,
        5000
    )

    MaxStockValue := ReadClampedInteger(
        MaxStockEdit,
        8,
        1,
        12
    )

    CycleDelayEdit.Value := CycleSecondsValue
    BetweenItemsEdit.Value := BetweenItemsValue
    MaxStockEdit.Value := MaxStockValue

    Settings.cycleDelay := CycleSecondsValue * 1000
    Settings.betweenItemsDelay := BetweenItemsValue
    Settings.maxStockAttempts := MaxStockValue
    Settings.buyFullStock := BuyFullStockCheckbox.Value = 1
    Settings.autoFocusRoblox := AutoFocusCheckbox.Value = 1
    Settings.rememberSelections := RememberSelectionsCheckbox.Value = 1
}

ReadClampedInteger(Control, DefaultValue, MinimumValue, MaximumValue) {
    RawValue := Trim(Control.Value)

    ; Windows UpDown controls can render values such as "1,000".
    ; Remove thousands separators before numeric conversion.
    RawValue := StrReplace(RawValue, ",", "")

    if RawValue = "" || !IsNumber(RawValue) {
        return DefaultValue
    }

    NumericValue := Round(RawValue + 0)

    return Max(
        MinimumValue,
        Min(MaximumValue, NumericValue)
    )
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
            IniRead(ConfigFile, "Settings", "BetweenItemsMs", "150") + 0
        )
    )

    try Settings.maxStockAttempts := Max(
        1,
        Min(
            12,
            IniRead(ConfigFile, "Settings", "MaxStockAttempts", "8") + 0
        )
    )

    ; Migrate the previous v2.3-test default of 5 to the new default of 8.
    if Settings.maxStockAttempts = 5 {
        Settings.maxStockAttempts := 8
    }

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
