#Requires AutoHotkey v2.0
#SingleInstance Force

; Use one coordinate system everywhere for mouse clicks and pixel checks.
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")

; =============================================================================
; MiniWar AutoBuy
; v2.6.0 Mouse Anchor Test Build
;
; Complete shop coverage, larger UI, search/filtering, per-category controls,
; configurable cycle timing, runtime statistics, Roblox status, settings
; persistence, full-stock purchase attempts, and single-item purchase timing fix.
; =============================================================================

; -----------------------------------------------------------------------------
; Application
; -----------------------------------------------------------------------------

AppVersion := "v3.1.0-shopkeeper-recovery-test"
ConfigFile := A_ScriptDir "\MiniWar-AutoBuy.ini"

Settings := {
    robloxWindow: "ahk_exe RobloxPlayerBeta.exe",

    ; Runtime settings. These are updated from the Settings panel.
    cycleDelay: 20000,
    betweenItemsDelay: 150,
    autoFocusRoblox: true,
    rememberSelections: true,
    repeatMode: "Fixed Interval",

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
    shopCloseDelay: 180,

    ; Military tab needs a little more time than Factory/Houses to settle.
    militaryTabMoveDelay: 500,
    militaryTabEnterDelay: 350,

    ; Mouse-anchored category navigation.
    categoryClickDelay: 180,
    itemAnchorDelay: 160,

    ; Self-healing mouse-only shop sweep.
    mouseOnlyPurchasing: true,
    wheelStepDelay: 35,
    rowAlignmentTolerance: 14,
    rowAdvanceMaxAttempts: 12,
    stateRetryLimit: 3
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

; Roblox remembers the last visible shop category after the shop closes.
; Track the category we last selected so the next reopen can navigate relative
; to the category Roblox is actually showing.
CurrentShopCategory := ""
CurrentCategoryFirstDownCount := 1
CurrentRowAnchorY := 0

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

MainGui := Gui("+MinSize1120x760")
MainGui.Title := "MiniWar AutoBuy " AppVersion
MainGui.MarginX := 20
MainGui.MarginY := 18

MainGui.SetFont("s17 Bold", "Segoe UI")
MainGui.Add("Text", "xm ym w500 h32", "MiniWar AutoBuy")

MainGui.SetFont("s9 Norm", "Segoe UI")
VersionLabel := MainGui.Add("Text", "x+10 yp+7 w145", AppVersion)
RobloxStatusLabel := MainGui.Add(
    "Text",
    "x820 yp w250 Right",
    "Roblox: Checking..."
)

MainGui.SetFont("s10 Norm", "Segoe UI")
MainGui.Add(
    "Text",
    "xm y+4 w820 h22",
    "Fast bulk purchasing for the Mini War rotating shop."
)

MainTabs := MainGui.Add(
    "Tab3",
    "xm y+16 w1080 h620",
    ["Shop", "Settings"]
)

; SHOP TAB --------------------------------------------------------------------

MainTabs.UseTab("Shop")

MainGui.SetFont("s10 Bold", "Segoe UI")
MainGui.Add("GroupBox", "x40 y150 w690 h545", "Shop Selection")

MainGui.SetFont("s9 Bold", "Segoe UI")
MainGui.Add("Text", "x60 y180 w70", "Search")
MainGui.SetFont("s10 Norm", "Segoe UI")
SearchEdit := MainGui.Add("Edit", "x130 y175 w450 h28")
ClearSearchButton := MainGui.Add("Button", "x590 y175 w95 h28", "Clear")

MainGui.SetFont("s9 Bold", "Segoe UI")
MainGui.Add("Text", "x60 y220 w70", "Section")
MainGui.SetFont("s10 Norm", "Segoe UI")
CategoryDropdown := MainGui.Add(
    "DropDownList",
    "x130 y214 w200 Choose1",
    ["Factories", "Houses", "Military"]
)

SelectCategoryButton := MainGui.Add(
    "Button",
    "x350 y214 w150 h28",
    "Select All Factories"
)

ClearCategoryButton := MainGui.Add(
    "Button",
    "x510 y214 w150 h28",
    "Clear Factories"
)

CategorySummaryLabel := MainGui.Add(
    "Text",
    "x60 y255 w625 h22",
    "Factories"
)

ShopList := MainGui.Add(
    "ListView",
    "x60 y282 w640 h365 Checked -Multi",
    ["Shop Item"]
)
ShopList.ModifyCol(1, 600)

SelectionLabel := MainGui.Add(
    "Text",
    "x60 y660 w300 h24",
    "Selected: 0 items"
)

MainGui.SetFont("s10 Bold", "Segoe UI")
MainGui.Add("GroupBox", "x755 y150 w325 h315", "Run Status")

MainGui.SetFont("s9 Norm", "Segoe UI")
StatusLabel := MainGui.Add("Text", "x775 y180 w285 h24", "Status: Stopped")
CurrentItemLabel := MainGui.Add("Text", "x775 y215 w285 h42", "Buying: —")
ProgressLabel := MainGui.Add("Text", "x775 y260 w285 h22", "Item: —")
CyclesLabel := MainGui.Add("Text", "x775 y300 w285 h22", "Cycles completed: 0")
AttemptsLabel := MainGui.Add("Text", "x775 y330 w285 h22", "Purchase attempts: 0")
RuntimeLabel := MainGui.Add("Text", "x775 y360 w285 h22", "Session runtime: 0s")
RepeatStatusLabel := MainGui.Add("Text", "x775 y400 w285 h42", "Repeat: Fixed interval")

StartStopButton := MainGui.Add(
    "Button",
    "x755 y485 w325 h42 Default",
    "Start AutoBuy"
)

MainGui.Add(
    "Text",
    "x755 y540 w325 h24 Center",
    "F1  Start / Stop     •     F2  Exit"
)

MainGui.Add(
    "Text",
    "x755 y585 w325 h60",
    "Bulk mode keeps purchases fast while the shop guard stops the macro if the shop disappears."
)

; SETTINGS TAB ----------------------------------------------------------------

MainTabs.UseTab("Settings")

MainGui.SetFont("s10 Bold", "Segoe UI")
MainGui.Add("GroupBox", "x40 y150 w510 h500", "Cycle & Purchase")

MainGui.SetFont("s9 Norm", "Segoe UI")

MainGui.Add("Text", "x65 y185 w180 h22", "Repeat mode")
RepeatModeDropdown := MainGui.Add(
    "DropDownList",
    "x255 y180 w240 Choose1",
    ["Fixed Interval"]
)

MainGui.Add("Text", "x65 y230 w180 h22", "Repeat every")
CycleDelayEdit := MainGui.Add(
    "Edit",
    "x255 y225 w100 h26 Number",
    Round(Settings.cycleDelay / 1000)
)
MainGui.Add("UpDown", "Range5-600", Round(Settings.cycleDelay / 1000))
MainGui.Add("Text", "x365 y230 w60 h22", "seconds")

MainGui.Add("Text", "x65 y275 w180 h22", "Between items")
BetweenItemsEdit := MainGui.Add(
    "Edit",
    "x255 y270 w100 h26 Number",
    Settings.betweenItemsDelay
)
MainGui.Add("UpDown", "Range100-5000", Settings.betweenItemsDelay)
MainGui.Add("Text", "x365 y275 w80 h22", "ms")

MainGui.Add("Text", "x65 y320 w180 h22", "Max stock attempts")
MaxStockEdit := MainGui.Add(
    "Edit",
    "x255 y315 w100 h26 Number",
    Settings.maxStockAttempts
)
MainGui.Add("UpDown", "Range1-12", Settings.maxStockAttempts)

BuyFullStockCheckbox := MainGui.Add(
    "Checkbox",
    "x65 y365 w280 h24",
    "Buy full available stock"
)
BuyFullStockCheckbox.Value := Settings.buyFullStock ? 1 : 0

MainGui.SetFont("s8 Norm", "Segoe UI")
MainGui.Add(
    "Text",
    "x65 y405 w420 h70",
    "Fast-stock mode sends repeated purchase presses with a fixed safety ceiling. Current default: 8 attempts."
)

MainGui.SetFont("s10 Bold", "Segoe UI")
MainGui.Add("GroupBox", "x580 y150 w500 h500", "Behavior & Safety")

MainGui.SetFont("s9 Norm", "Segoe UI")

AutoFocusCheckbox := MainGui.Add(
    "Checkbox",
    "x605 y185 w330 h24",
    "Auto-focus Roblox when starting"
)
AutoFocusCheckbox.Value := Settings.autoFocusRoblox ? 1 : 0

RememberSelectionsCheckbox := MainGui.Add(
    "Checkbox",
    "x605 y225 w330 h24",
    "Remember selections and settings"
)
RememberSelectionsCheckbox.Value := Settings.rememberSelections ? 1 : 0

ShopGuardCheckbox := MainGui.Add(
    "Checkbox",
    "x605 y265 w330 h24",
    "Stop if shop UI is lost"
)
ShopGuardCheckbox.Value := Settings.shopGuardEnabled ? 1 : 0

MainGui.Add("Text", "x605 y315 w170 h22", "Purchase press delay")
FixedPurchaseDelayEdit := MainGui.Add(
    "Edit",
    "x790 y310 w90 h26 Number",
    Settings.fixedPurchaseDelay
)
MainGui.Add("UpDown", "Range50-500", Settings.fixedPurchaseDelay)
MainGui.Add("Text", "x890 y315 w60 h22", "ms")

MainGui.Add("Text", "x605 y360 w170 h22", "Shop open delay")
ShopOpenDelayEdit := MainGui.Add(
    "Edit",
    "x790 y355 w90 h26 Number",
    Settings.shopOpenDelay
)
MainGui.Add("UpDown", "Range500-5000", Settings.shopOpenDelay)
MainGui.Add("Text", "x890 y360 w60 h22", "ms")

MainGui.Add("Text", "x605 y400 w170 h22", "Row align tolerance")
RowToleranceEdit := MainGui.Add(
    "Edit",
    "x790 y395 w90 h26 Number",
    Settings.rowAlignmentTolerance
)
MainGui.Add("UpDown", "Range6-30", Settings.rowAlignmentTolerance)
MainGui.Add("Text", "x890 y400 w60 h22", "px")

MainGui.SetFont("s8 Norm", "Segoe UI")
MainGui.Add(
    "Text",
    "x605 y455 w420 h100",
    "Self-healing mode uses the real Buy → Shopkeeper → E route, verifies the rotating shop before every action, and recovers from lost shop state without touching the premium Shop button."
)

MainTabs.UseTab()

SearchEdit.OnEvent("Change", (*) => RebuildShopList())
ClearSearchButton.OnEvent("Click", ClearSearch)
CategoryDropdown.OnEvent("Change", CategoryChanged)
SelectCategoryButton.OnEvent("Click", (*) => SetCategorySelection(ActiveCategory, true))
ClearCategoryButton.OnEvent("Click", (*) => SetCategorySelection(ActiveCategory, false))
ShopList.OnEvent("ItemCheck", OnShopItemCheck)
StartStopButton.OnEvent("Click", StartStopButtonClicked)
RepeatModeDropdown.OnEvent("Change", RepeatModeChanged)

MainGui.OnEvent("Close", OnGuiClose)

MainGui.Show("w1120 h760")

RebuildShopList()
RefreshSelectionSummary()
UpdateRobloxStatus()
UpdateStatsDisplay()
RepeatModeChanged()

SetTimer(UpdateRobloxStatus, 1000)
SetTimer(UpdateRuntimeDisplay, 1000)

RepeatModeChanged(*) {
    global RepeatModeDropdown, CycleDelayEdit, RepeatStatusLabel

    IsFixed := RepeatModeDropdown.Text = "Fixed Interval"
    CycleDelayEdit.Enabled := IsFixed

    RepeatStatusLabel.Text := (
        "Repeat: "
        RepeatModeDropdown.Text
    )
}

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
    global CyclesCompleted, PurchaseAttempts, Items
    global CurrentRowAnchorY

    if !IsRunning || IsCycleActive {
        return
    }

    SelectedItems := GetSelectedItems()

    if SelectedItems.Length = 0 {
        StopImmediately("No items are selected.")
        return
    }

    IsCycleActive := true

    if !EnsureShopOpen() {
        IsCycleActive := false
        return
    }

    Categories := ["Factories", "Houses", "Military"]
    TotalSelected := SelectedItems.Length
    OverallIndex := 0

    for Category in Categories {
        if !IsRunning || IsStopRequested {
            break
        }

        CategoryItems := []

        for Item in Items {
            if Item.category = Category {
                CategoryItems.Push(Item)
            }
        }

        HasSelectedInCategory := false

        for Item in CategoryItems {
            if Item.selected {
                HasSelectedInCategory := true
                break
            }
        }

        if !HasSelectedInCategory {
            continue
        }

        UpdateStatus("Preparing " Category "...")

        if !PrepareVisualCategory(Category) {
            break
        }

        for ItemIndex, Item in CategoryItems {
            if !IsRunning || IsStopRequested {
                break
            }

            if Item.selected {
                OverallIndex += 1

                UpdateStatus("Buying " Item.name "...")
                UpdateCurrentProgress(
                    Item.name,
                    OverallIndex " of " TotalSelected
                )

                PurchaseAttempts += 1
                UpdateStatsDisplay()

                if !ClickAnchoredCashButton() {
                    break
                }
            }

            if ItemIndex < CategoryItems.Length {
                if !AdvanceExactlyOneShopRow() {
                    UpdateStatus("Recovering " Category " position...")

                    if !RecoverCategoryPosition(Category, ItemIndex + 1) {
                        StopImmediately(
                            "Could not recover shop position - AutoBuy stopped."
                        )
                        break
                    }
                }
            }
        }

        if !IsRunning || IsStopRequested {
            break
        }
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
        "Cycle complete - waiting "
        Round(Settings.cycleDelay / 1000)
        " seconds"
    )

    UpdateCurrentProgress("—", "Cycle complete")

    ; Leave the shop open. The next cycle re-validates everything before acting.
    SetTimer(RunPurchaseCycle, -Settings.cycleDelay)
}

EnsureShopOpen() {
    global Settings

    if IsShopkeeperShopVisible() {
        return true
    }

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        StopImmediately("Could not read Roblox window position.")
        return false
    }

    ; IMPORTANT:
    ; The left-side red basket opens the PREMIUM/CRATE shop.
    ; The rotating Wheat/Corn/etc. shop is reached through the top Buy button,
    ; which teleports the player to the Shopkeeper NPC. Then E opens the shop.
    BuyX := ClientX + Round(ClientWidth * 0.325)
    BuyY := ClientY + Round(ClientHeight * 0.055)

    Loop Settings.stateRetryLimit {
        if !WinActive(Settings.robloxWindow) {
            StopImmediately("Roblox lost focus.")
            return false
        }

        UpdateStatus("Returning to Shopkeeper...")

        Click(BuyX, BuyY)

        ; Allow the Buy teleport / camera relocation to finish.
        Sleep(900)

        ; The Shopkeeper interaction prompt uses E.
        Send("e")
        Sleep(700)

        if IsShopkeeperShopVisible() {
            return true
        }

        ; A second E covers slower interaction-prompt initialization without
        ; clicking unrelated HUD buttons.
        Send("e")
        Sleep(700)

        if IsShopkeeperShopVisible() {
            return true
        }
    }

    StopImmediately("Could not reach the Shopkeeper shop.")
    return false
}

PrepareVisualCategory(Category) {
    global Settings, CurrentRowAnchorY

    if !EnsureShopOpen() {
        return false
    }

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        return false
    }

    switch Category {
        case "Factories":
            TabX := ClientX + Round(ClientWidth * 0.307)

        case "Houses":
            TabX := ClientX + Round(ClientWidth * 0.435)

        case "Military":
            TabX := ClientX + Round(ClientWidth * 0.563)

        default:
            StopImmediately("Unknown category: " Category)
            return false
    }

    TabY := ClientY + Round(ClientHeight * 0.307)

    Loop Settings.stateRetryLimit {
        if !IsShopVisible() {
            if !EnsureShopOpen() {
                return false
            }
        }

        Click(TabX, TabY)
        Sleep(Settings.categoryClickDelay)

        ; Force this category to the top without assuming how many wheel
        ; notches are required.
        ListX := ClientX + Round(ClientWidth * 0.620)
        ListY := ClientY + Round(ClientHeight * 0.590)

        MouseMove(ListX, ListY, 0)

        Loop 35 {
            Send("{WheelUp}")
        }

        Sleep(120)

        Centers := FindRobuxButtonCenters()

        if Centers.Length >= 2 {
            CurrentRowAnchorY := Centers[1]
            return true
        }

        Sleep(150)
    }

    StopImmediately("Could not verify " Category " shop rows.")
    return false
}

FindRobuxButtonCenters() {
    Centers := []

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        return Centers
    }

    SampleX1 := ClientX + Round(ClientWidth * 0.500)
    SampleX2 := ClientX + Round(ClientWidth * 0.535)
    SampleX3 := ClientX + Round(ClientWidth * 0.570)

    SearchTop := ClientY + Round(ClientHeight * 0.355)
    SearchBottom := ClientY + Round(ClientHeight * 0.835)

    InRun := false
    RunStart := 0
    LastMatchY := 0
    MatchCount := 0

    Y := SearchTop

    while Y <= SearchBottom {
        PurpleVotes := 0

        for SampleX in [SampleX1, SampleX2, SampleX3] {
            Color := PixelGetColor(SampleX, Y, "RGB")

            Red := (Color >> 16) & 0xFF
            Green := (Color >> 8) & 0xFF
            Blue := Color & 0xFF

            IsPurple := (
                Red >= 95
                && Blue >= 105
                && Green <= 125
                && Red >= Green * 1.15
                && Blue >= Green * 1.20
            )

            if IsPurple {
                PurpleVotes += 1
            }
        }

        if PurpleVotes >= 2 {
            if !InRun {
                InRun := true
                RunStart := Y
                MatchCount := 0
            }

            LastMatchY := Y
            MatchCount += 1
        } else if InRun {
            RunHeight := LastMatchY - RunStart

            if RunHeight >= 18 && MatchCount >= 5 {
                Centers.Push(Round((RunStart + LastMatchY) / 2))
            }

            InRun := false
            RunStart := 0
            LastMatchY := 0
            MatchCount := 0
        }

        Y += 3
    }

    if InRun {
        RunHeight := LastMatchY - RunStart

        if RunHeight >= 18 && MatchCount >= 5 {
            Centers.Push(Round((RunStart + LastMatchY) / 2))
        }
    }

    return Centers
}

ClickAnchoredCashButton() {
    global Settings, CurrentRowAnchorY

    if !IsShopVisible() {
        StopImmediately("Shop lost - AutoBuy stopped for safety.")
        return false
    }

    if CurrentRowAnchorY <= 0 {
        StopImmediately("Shop row anchor was lost.")
        return false
    }

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        return false
    }

    Centers := FindRobuxButtonCenters()

    if !HasCenterNear(Centers, CurrentRowAnchorY, Settings.rowAlignmentTolerance) {
        return false
    }

    CashX := ClientX + Round(ClientWidth * 0.680)
    CashY := CurrentRowAnchorY

    ; Never click unless the target is inside the verified shop list region.
    MinimumY := ClientY + Round(ClientHeight * 0.350)
    MaximumY := ClientY + Round(ClientHeight * 0.840)

    if CashY < MinimumY || CashY > MaximumY {
        StopImmediately("Unsafe purchase coordinate blocked.")
        return false
    }

    MouseMove(CashX, CashY, 0)

    Attempts := Settings.buyFullStock ? Settings.maxStockAttempts : 1

    Loop Attempts {
        if !IsRunning || IsStopRequested {
            return true
        }

        if !IsShopVisible() {
            StopImmediately("Shop lost - AutoBuy stopped for safety.")
            return false
        }

        Click()
        Sleep(Settings.fixedPurchaseDelay)
    }

    Sleep(60)
    return true
}

AdvanceExactlyOneShopRow() {
    global Settings, CurrentRowAnchorY

    if !IsShopVisible() {
        return false
    }

    if CurrentRowAnchorY <= 0 {
        return false
    }

    BeforeFingerprint := GetRowFingerprint(CurrentRowAnchorY)

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        return false
    }

    ListX := ClientX + Round(ClientWidth * 0.620)
    ListY := ClientY + Round(ClientHeight * 0.610)
    MouseMove(ListX, ListY, 0)

    Loop Settings.rowAdvanceMaxAttempts {
        Send("{WheelDown}")
        Sleep(Settings.wheelStepDelay)

        Centers := FindRobuxButtonCenters()

        if !HasCenterNear(
            Centers,
            CurrentRowAnchorY,
            Settings.rowAlignmentTolerance
        ) {
            continue
        }

        AfterFingerprint := GetRowFingerprint(CurrentRowAnchorY)

        if FingerprintsDiffer(BeforeFingerprint, AfterFingerprint) {
            return true
        }
    }

    return false
}

GetRowFingerprint(RowY) {
    Fingerprint := []

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        return Fingerprint
    }

    SampleXs := [
        ClientX + Round(ClientWidth * 0.285),
        ClientX + Round(ClientWidth * 0.315),
        ClientX + Round(ClientWidth * 0.350),
        ClientX + Round(ClientWidth * 0.405)
    ]

    for OffsetY in [-45, -15, 15, 45] {
        SampleY := RowY + OffsetY

        for SampleX in SampleXs {
            Fingerprint.Push(PixelGetColor(SampleX, SampleY, "RGB"))
        }
    }

    return Fingerprint
}

FingerprintsDiffer(First, Second) {
    if First.Length = 0 || First.Length != Second.Length {
        return false
    }

    DifferenceScore := 0

    Loop First.Length {
        ColorA := First[A_Index]
        ColorB := Second[A_Index]

        RedA := (ColorA >> 16) & 0xFF
        GreenA := (ColorA >> 8) & 0xFF
        BlueA := ColorA & 0xFF

        RedB := (ColorB >> 16) & 0xFF
        GreenB := (ColorB >> 8) & 0xFF
        BlueB := ColorB & 0xFF

        DifferenceScore += Abs(RedA - RedB)
        DifferenceScore += Abs(GreenA - GreenB)
        DifferenceScore += Abs(BlueA - BlueB)
    }

    return DifferenceScore >= 500
}

HasCenterNear(Centers, TargetY, Tolerance) {
    for CenterY in Centers {
        if Abs(CenterY - TargetY) <= Tolerance {
            return true
        }
    }

    return false
}

RecoverCategoryPosition(Category, CompletedItemCount) {
    global Settings, CurrentRowAnchorY

    if !PrepareVisualCategory(Category) {
        return false
    }

    ; CompletedItemCount is the number of rows already processed. Rebuild the
    ; exact position from a known top-of-category state.
    Loop CompletedItemCount {
        if !AdvanceExactlyOneShopRow() {
            return false
        }
    }

    return true
}

PrepareMouseCategory(Category) {
    global Settings

    if Settings.shopGuardEnabled && !IsShopVisible() {
        StopImmediately("Shop lost - AutoBuy stopped for safety.")
        return false
    }

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        StopImmediately("Could not read Roblox window position.")
        return false
    }

    switch Category {
        case "Factories":
            TabX := ClientX + Round(ClientWidth * 0.307)

        case "Houses":
            TabX := ClientX + Round(ClientWidth * 0.435)

        case "Military":
            TabX := ClientX + Round(ClientWidth * 0.563)

        default:
            StopImmediately("Unknown category: " Category)
            return false
    }

    TabY := ClientY + Round(ClientHeight * 0.318)

    Click(TabX, TabY)
    Sleep(Settings.categoryClickDelay)

    if Settings.shopGuardEnabled && !IsShopVisible() {
        StopImmediately("Category switch failed - shop lost.")
        return false
    }

    ; Put the mouse over the shop list and force the scroll frame to the top.
    ListX := ClientX + Round(ClientWidth * 0.615)
    ListY := ClientY + Round(ClientHeight * 0.555)

    MouseMove(ListX, ListY, 0)

    Loop 40 {
        Send("{WheelUp}")
    }

    Sleep(120)
    return true
}

ClickCurrentCashButton() {
    global Settings

    if Settings.shopGuardEnabled && !IsShopVisible() {
        StopImmediately("Shop lost - AutoBuy stopped for safety.")
        return false
    }

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        StopImmediately("Could not read Roblox window position.")
        return false
    }

    ; Top visible item's green cash button.
    CashX := ClientX + Round(ClientWidth * 0.679)
    CashY := ClientY + Round(ClientHeight * 0.553)

    MouseMove(CashX, CashY, 0)

    Attempts := Settings.buyFullStock ? Settings.maxStockAttempts : 1

    Loop Attempts {
        if !IsRunning || IsStopRequested {
            return true
        }

        Click()
        Sleep(Settings.fixedPurchaseDelay)
    }

    Sleep(60)
    return true
}

ScrollShopOneItem() {
    global Settings

    if Settings.shopGuardEnabled && !IsShopVisible() {
        StopImmediately("Shop lost - AutoBuy stopped for safety.")
        return false
    }

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        return false
    }

    ; Keep the pointer inside the scrolling list so wheel events cannot affect
    ; unrelated Roblox UI.
    ListX := ClientX + Round(ClientWidth * 0.615)
    ListY := ClientY + Round(ClientHeight * 0.610)
    MouseMove(ListX, ListY, 0)

    Loop Settings.wheelStepsPerItem {
        Send("{WheelDown}")
        Sleep(Settings.wheelStepDelay)
    }

    return true
}

CloseShopSafelyMouseMode() {
    global Settings

    if Settings.shopGuardEnabled && !IsShopVisible() {
        StopImmediately("Shop lost - AutoBuy stopped for safety.")
        return false
    }

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        return false
    }

    CloseX := ClientX + Round(ClientWidth * 0.735)
    CloseY := ClientY + Round(ClientHeight * 0.215)

    Click(CloseX, CloseY)
    Sleep(Settings.shopCloseDelay)

    return true
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
    return EnsureShopOpen()
}

OpenCategory(Category) {
    global Settings

    if Settings.shopGuardEnabled && !IsShopVisible() {
        StopImmediately("Shop lost - AutoBuy stopped for safety.")
        return false
    }

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        StopImmediately("Could not read Roblox window position.")
        return false
    }

    ; Switch the visible shop category directly.
    switch Category {
        case "Factories":
            TabX := ClientX + Round(ClientWidth * 0.306)

        case "Houses":
            TabX := ClientX + Round(ClientWidth * 0.433)

        case "Military":
            TabX := ClientX + Round(ClientWidth * 0.561)

        default:
            StopImmediately("Unknown category: " Category)
            return false
    }

    TabY := ClientY + Round(ClientHeight * 0.307)

    Click(TabX, TabY)
    Sleep(Settings.categoryClickDelay)

    if Settings.shopGuardEnabled && !IsShopVisible() {
        StopImmediately("Category switch failed - shop lost.")
        return false
    }

    ; Anchor on the first item's purchase-button row.
    AnchorX := ClientX + Round(ClientWidth * 0.676)
    AnchorY := ClientY + Round(ClientHeight * 0.529)

    Click(AnchorX, AnchorY)
    Sleep(Settings.itemAnchorDelay)

    ; Roblox UI Navigation resolves this row to the left purchase button
    ; (the purple Robux button). Move one step right onto the green cash button
    ; before any vertical bulk navigation begins.
    if !SendToRoblox("{Right}") {
        return false
    }

    Sleep(Settings.navigationDelay)

    return true
}

NavigateToPurchaseButton(DownCount) {
    global Settings

    ; OpenCategory() anchors to the first item cash button.
    ; Convert the old per-category downCount to zero-based movement:
    ;   Factories/Houses first item = downCount 2
    ;   Military first item = downCount 1
    ;
    ; Determine the active category from the down-count convention through the
    ; current item metadata before this function is called. To keep the call
    ; signature stable, FirstItemOffset is set by the caller.
    global CurrentCategoryFirstDownCount

    StepsDown := DownCount - CurrentCategoryFirstDownCount

    if StepsDown < 0 {
        StopImmediately("Invalid item position.")
        return false
    }

    Loop StepsDown {
        if !SendToRoblox("{Down}") {
            return false
        }

        Sleep(Settings.navigationDelay)
    }

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
    return IsShopkeeperShopVisible()
}

IsShopkeeperShopVisible() {
    global Settings

    if !WinActive(Settings.robloxWindow) {
        return false
    }

    if !GetRobloxClientRect(&ClientX, &ClientY, &ClientWidth, &ClientHeight) {
        return false
    }

    ; Verify the SPECIFIC Shopkeeper shop, not just any Mini War modal.
    ;
    ; Anchor 1: cyan Shop! header.
    HeaderLeft := ClientX + Round(ClientWidth * 0.22)
    HeaderTop := ClientY + Round(ClientHeight * 0.13)
    HeaderRight := ClientX + Round(ClientWidth * 0.50)
    HeaderBottom := ClientY + Round(ClientHeight * 0.25)

    ; Anchor 2: yellow Restock button unique to this shop.
    RestockLeft := ClientX + Round(ClientWidth * 0.52)
    RestockTop := ClientY + Round(ClientHeight * 0.14)
    RestockRight := ClientX + Round(ClientWidth * 0.70)
    RestockBottom := ClientY + Round(ClientHeight * 0.27)

    ; Anchor 3: red close button.
    CloseLeft := ClientX + Round(ClientWidth * 0.68)
    CloseTop := ClientY + Round(ClientHeight * 0.13)
    CloseRight := ClientX + Round(ClientWidth * 0.78)
    CloseBottom := ClientY + Round(ClientHeight * 0.28)

    HasBlueHeader := PixelSearch(
        &HeaderX,
        &HeaderY,
        HeaderLeft,
        HeaderTop,
        HeaderRight,
        HeaderBottom,
        0x55BFEA,
        90
    )

    HasYellowRestock := PixelSearch(
        &RestockX,
        &RestockY,
        RestockLeft,
        RestockTop,
        RestockRight,
        RestockBottom,
        0xF0C832,
        90
    )

    HasRedClose := PixelSearch(
        &CloseX,
        &CloseY,
        CloseLeft,
        CloseTop,
        CloseRight,
        CloseBottom,
        0xE83434,
        90
    )

    return HasBlueHeader && HasYellowRestock && HasRedClose
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
    global BuyFullStockCheckbox, ShopGuardCheckbox
    global FixedPurchaseDelayEdit, ShopOpenDelayEdit, RepeatModeDropdown, RowToleranceEdit

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
    Settings.shopGuardEnabled := ShopGuardCheckbox.Value = 1
    Settings.fixedPurchaseDelay := ReadClampedInteger(
        FixedPurchaseDelayEdit,
        90,
        50,
        500
    )
    Settings.shopOpenDelay := ReadClampedInteger(
        ShopOpenDelayEdit,
        1200,
        500,
        5000
    )
    Settings.rowAlignmentTolerance := ReadClampedInteger(
        RowToleranceEdit,
        14,
        6,
        30
    )
    Settings.repeatMode := RepeatModeDropdown.Text
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
