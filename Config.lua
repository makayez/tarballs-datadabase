-- Config.lua - Configuration panel framework

Dadabase = Dadabase or {}
Dadabase.Config = {}

local Config = Dadabase.Config
local DB = Dadabase.DatabaseManager

-- Registered module config tabs
Config.moduleTabs = {}

-- ============================================================================
-- Module Tab Registration
-- ============================================================================

function Config:RegisterModuleTab(moduleId, config)
    table.insert(self.moduleTabs, {
        moduleId = moduleId,
        name = config.name,
        buildContent = config.buildContent
    })
end

-- ============================================================================
-- Configuration Panel Creation
-- ============================================================================

local function CreateConfigPanel()
    local panel = CreateFrame("Frame", "TarballsDadabaseConfigPanel", UIParent, "BasicFrameTemplateWithInset")
    panel:SetSize(700, 550)
    panel:SetPoint("CENTER")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:SetFrameStrata("DIALOG")
    panel:Hide()

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    panel.title:SetPoint("TOP", 0, -5)
    panel.title:SetText("Tarball's Dadabase")

    -- Tab system
    local tabButtons = {}
    local tabs = {}

    local function ShowTab(tabIndex)
        for i, tab in ipairs(tabs) do
            if i == tabIndex then
                tab:Show()
                tabButtons[i]:SetAlpha(1.0)
            else
                tab:Hide()
                tabButtons[i]:SetAlpha(0.6)
            end
        end
    end

    -- Settings Tab
    local settingsTabBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    settingsTabBtn:SetSize(100, 25)
    settingsTabBtn:SetPoint("TOPLEFT", 20, -35)
    settingsTabBtn:SetText("Settings")
    settingsTabBtn:SetScript("OnClick", function() ShowTab(1) end)
    table.insert(tabButtons, settingsTabBtn)

    local settingsTab = CreateFrame("Frame", nil, panel)
    settingsTab:SetPoint("TOPLEFT", 20, -70)
    settingsTab:SetPoint("BOTTOMRIGHT", -20, 20)
    table.insert(tabs, settingsTab)

    -- Build settings tab content
    local yOffset = -10

    local versionLabel = settingsTab:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    versionLabel:SetPoint("TOPLEFT", 10, yOffset)
    versionLabel:SetText("Version: " .. Dadabase.VERSION)
    yOffset = yOffset - 30

    local cooldownLabel = settingsTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cooldownLabel:SetPoint("TOPLEFT", 10, yOffset)
    cooldownLabel:SetText("Global cooldown between messages:")
    yOffset = yOffset - 30

    local cooldownSlider = CreateFrame("Slider", nil, settingsTab, "OptionsSliderTemplate")
    cooldownSlider:SetPoint("TOPLEFT", 10, yOffset)
    cooldownSlider:SetWidth(300)
    cooldownSlider:SetMinMaxValues(0, 60)
    cooldownSlider:SetValueStep(1)
    cooldownSlider:SetValue(TarballsDadabaseDB.cooldown)
    cooldownSlider:SetObeyStepOnDrag(true)

    cooldownSlider.Low:SetText("0s")
    cooldownSlider.High:SetText("60s")

    cooldownSlider.valueText = cooldownSlider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    cooldownSlider.valueText:SetPoint("TOP", cooldownSlider, "BOTTOM", 0, 0)
    cooldownSlider.valueText:SetText(TarballsDadabaseDB.cooldown .. " seconds")

    cooldownSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        TarballsDadabaseDB.cooldown = value
        self.valueText:SetText(value .. " seconds")
    end)

    -- Module Tabs
    for _, moduleTab in ipairs(Config.moduleTabs) do
        local tabBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        tabBtn:SetSize(100, 25)

        if #tabButtons == 1 then
            tabBtn:SetPoint("LEFT", tabButtons[1], "RIGHT", 5, 0)
        else
            tabBtn:SetPoint("LEFT", tabButtons[#tabButtons], "RIGHT", 5, 0)
        end

        tabBtn:SetText(moduleTab.name)
        local tabIndex = #tabs + 1
        tabBtn:SetScript("OnClick", function() ShowTab(tabIndex) end)
        table.insert(tabButtons, tabBtn)

        local moduleTabFrame = CreateFrame("Frame", nil, panel)
        moduleTabFrame:SetPoint("TOPLEFT", 20, -70)
        moduleTabFrame:SetPoint("BOTTOMRIGHT", -20, 20)
        table.insert(tabs, moduleTabFrame)

        -- Build module-specific content
        moduleTab.buildContent(moduleTabFrame, moduleTab.moduleId)
    end

    -- Show settings tab by default
    ShowTab(1)

    return panel
end

-- ============================================================================
-- Module Content Builder (shared for all modules)
-- ============================================================================

function Config:BuildModuleContent(container, moduleId)
    local moduleDB = DB:GetModuleSettings(moduleId)
    if not moduleDB then return end

    local module = DB.modules[moduleId]
    if not module then return end

    local yOffset = -10

    -- Enable checkbox
    local enableCheckbox = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    enableCheckbox:SetPoint("TOPLEFT", 10, yOffset)
    enableCheckbox.text = enableCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableCheckbox.text:SetPoint("LEFT", enableCheckbox, "RIGHT", 5, 0)
    enableCheckbox.text:SetText("Enable " .. module.name)
    enableCheckbox:SetChecked(moduleDB.enabled)
    enableCheckbox:SetScript("OnClick", function(self)
        DB:SetModuleEnabled(moduleId, self:GetChecked())
    end)

    yOffset = yOffset - 40

    -- Triggers section (left side)
    local triggersLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    triggersLabel:SetPoint("TOPLEFT", 10, yOffset)
    triggersLabel:SetText("Triggers:")

    -- Groups section (right side)
    local groupsLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    groupsLabel:SetPoint("TOPLEFT", 340, yOffset)
    groupsLabel:SetText("Enabled for:")
    yOffset = yOffset - 30

    -- Wipe trigger
    local wipeCheckbox = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    wipeCheckbox:SetPoint("TOPLEFT", 20, yOffset)
    wipeCheckbox.text = wipeCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    wipeCheckbox.text:SetPoint("LEFT", wipeCheckbox, "RIGHT", 5, 0)
    wipeCheckbox.text:SetText("Party/Raid wipes")
    wipeCheckbox:SetChecked(moduleDB.triggers.wipe == true)
    wipeCheckbox:SetScript("OnClick", function(self)
        DB:SetModuleTrigger(moduleId, "wipe", self:GetChecked())
    end)

    -- Raid group (right side, same row)
    local raidCheckbox = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    raidCheckbox:SetPoint("TOPLEFT", 350, yOffset)
    raidCheckbox.text = raidCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    raidCheckbox.text:SetPoint("LEFT", raidCheckbox, "RIGHT", 5, 0)
    raidCheckbox.text:SetText("Raids")
    raidCheckbox:SetChecked(moduleDB.groups.raid == true)
    raidCheckbox:SetScript("OnClick", function(self)
        DB:SetModuleGroup(moduleId, "raid", self:GetChecked())
    end)
    yOffset = yOffset - 30

    -- Death trigger
    local deathCheckbox = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    deathCheckbox:SetPoint("TOPLEFT", 20, yOffset)
    deathCheckbox.text = deathCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    deathCheckbox.text:SetPoint("LEFT", deathCheckbox, "RIGHT", 5, 0)
    deathCheckbox.text:SetText("Personal death")
    deathCheckbox:SetChecked(moduleDB.triggers.death == true)
    deathCheckbox:SetScript("OnClick", function(self)
        DB:SetModuleTrigger(moduleId, "death", self:GetChecked())
    end)

    -- Party group (right side, same row)
    local partyCheckbox = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    partyCheckbox:SetPoint("TOPLEFT", 350, yOffset)
    partyCheckbox.text = partyCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    partyCheckbox.text:SetPoint("LEFT", partyCheckbox, "RIGHT", 5, 0)
    partyCheckbox.text:SetText("Parties")
    partyCheckbox:SetChecked(moduleDB.groups.party == true)
    partyCheckbox:SetScript("OnClick", function(self)
        DB:SetModuleGroup(moduleId, "party", self:GetChecked())
    end)
    yOffset = yOffset - 40

    -- Content management section
    local effectiveContent = DB:GetEffectiveContent(moduleId)
    local contentLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    contentLabel:SetPoint("TOPLEFT", 10, yOffset)
    contentLabel:SetText("Content (" .. #effectiveContent .. " items)")
    yOffset = yOffset - 30

    -- Instructions
    local instructionsLabel = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    instructionsLabel:SetPoint("TOPLEFT", 10, yOffset)
    instructionsLabel:SetPoint("TOPRIGHT", -10, yOffset)
    instructionsLabel:SetJustifyH("LEFT")
    instructionsLabel:SetText("Edit the content below (one item per line). Delete lines to remove items, add lines to create new ones.")
    yOffset = yOffset - 25

    -- Multi-line text editor with border
    local editorBorder = CreateFrame("Frame", nil, container, "BackdropTemplate")
    editorBorder:SetPoint("TOPLEFT", 5, yOffset)
    editorBorder:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -5, 65)
    editorBorder:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    editorBorder:SetBackdropColor(0, 0, 0, 0.8)
    editorBorder:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

    local scrollFrame = CreateFrame("ScrollFrame", nil, editorBorder, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject("GameFontHighlightSmall")
    editBox:SetWidth(600)
    editBox:SetMaxLetters(0)
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    scrollFrame:SetScrollChild(editBox)

    -- Populate with current content
    local function LoadContent()
        local content = DB:GetEffectiveContent(moduleId)
        local text = table.concat(content, "\n")
        editBox:SetText(text)

        -- Calculate height based on content (roughly 14 pixels per line)
        local numLines = #content
        local lineHeight = 14
        local calculatedHeight = math.max(numLines * lineHeight, 180)
        editBox:SetHeight(calculatedHeight)

        editBox:SetCursorPosition(0)
        contentLabel:SetText("Content (" .. #content .. " items)")
    end

    container.LoadContent = LoadContent

    -- Save button and status
    local saveBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    saveBtn:SetSize(100, 25)
    saveBtn:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 10, 30)
    saveBtn:SetText("Save Changes")

    local statusLabel = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    statusLabel:SetPoint("LEFT", saveBtn, "RIGHT", 10, 0)
    statusLabel:SetText("")

    saveBtn:SetScript("OnClick", function()
        local text = editBox:GetText()
        local newContent = {}

        -- Parse lines (split by newline)
        for line in text:gmatch("[^\r\n]+") do
            line = line:trim()
            if line ~= "" then
                table.insert(newContent, line)
            end
        end

        -- Update the database
        DB:SetEffectiveContent(moduleId, newContent)

        -- Show feedback
        statusLabel:SetText("Saved! (" .. #newContent .. " items)")
        contentLabel:SetText("Content (" .. #newContent .. " items)")

        -- Clear status after 3 seconds
        C_Timer.After(3, function()
            statusLabel:SetText("")
        end)
    end)

    -- Reset button
    local resetBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    resetBtn:SetSize(120, 25)
    resetBtn:SetPoint("LEFT", saveBtn, "RIGHT", 120, 0)
    resetBtn:SetText("Reset to Defaults")
    resetBtn:SetScript("OnClick", function()
        -- Clear all user changes
        moduleDB.userAdditions = {}
        moduleDB.userDeletions = {}
        LoadContent()
        statusLabel:SetText("Reset to defaults!")
        C_Timer.After(3, function()
            statusLabel:SetText("")
        end)
    end)

    LoadContent()
end

-- ============================================================================
-- Panel Management
-- ============================================================================

Config.frame = nil

function Config:Show()
    if not self.frame then
        self.frame = CreateConfigPanel()
    end
    self.frame:Show()
end

function Config:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

function Config:Toggle()
    if self.frame and self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- ============================================================================
-- Interface Options Registration
-- ============================================================================

function Config:RegisterInterfaceOptions()
    if not self.frame then
        self.frame = CreateConfigPanel()
    end
    local category = Settings.RegisterCanvasLayoutCategory(self.frame, "Tarball's Dadabase")
    Settings.RegisterAddOnCategory(category)
    self.category = category
end
