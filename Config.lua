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

    -- Triggers section
    local triggersLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    triggersLabel:SetPoint("TOPLEFT", 10, yOffset)
    triggersLabel:SetText("Triggers:")
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
    yOffset = yOffset - 40

    -- Groups section
    local groupsLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    groupsLabel:SetPoint("TOPLEFT", 10, yOffset)
    groupsLabel:SetText("Enabled for:")
    yOffset = yOffset - 30

    -- Raid group
    local raidCheckbox = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    raidCheckbox:SetPoint("TOPLEFT", 20, yOffset)
    raidCheckbox.text = raidCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    raidCheckbox.text:SetPoint("LEFT", raidCheckbox, "RIGHT", 5, 0)
    raidCheckbox.text:SetText("Raids")
    raidCheckbox:SetChecked(moduleDB.groups.raid == true)
    raidCheckbox:SetScript("OnClick", function(self)
        DB:SetModuleGroup(moduleId, "raid", self:GetChecked())
    end)
    yOffset = yOffset - 30

    -- Party group
    local partyCheckbox = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    partyCheckbox:SetPoint("TOPLEFT", 20, yOffset)
    partyCheckbox.text = partyCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    partyCheckbox.text:SetPoint("LEFT", partyCheckbox, "RIGHT", 5, 0)
    partyCheckbox.text:SetText("Parties")
    partyCheckbox:SetChecked(moduleDB.groups.party == true)
    partyCheckbox:SetScript("OnClick", function(self)
        DB:SetModuleGroup(moduleId, "party", self:GetChecked())
    end)
    yOffset = yOffset - 40

    -- Content management section
    local contentLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    contentLabel:SetPoint("TOPLEFT", 10, yOffset)
    contentLabel:SetText("Content (" .. #moduleDB.content .. " items)")
    yOffset = yOffset - 30

    -- Scrollable content list
    local scrollFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, yOffset)
    scrollFrame:SetSize(630, 150)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(630, 1)

    local contentButtons = {}

    local function RefreshContentList()
        -- Clear existing buttons
        for _, btn in ipairs(contentButtons) do
            btn:Hide()
            btn:SetParent(nil)
        end
        contentButtons = {}

        contentLabel:SetText("Content (" .. #moduleDB.content .. " items)")

        local content = DB:GetContent(moduleId)
        local itemYOffset = 0

        for i, item in ipairs(content) do
            local itemFrame = CreateFrame("Frame", nil, scrollChild)
            itemFrame:SetSize(600, 50)
            itemFrame:SetPoint("TOPLEFT", 5, -itemYOffset)

            -- Item text
            local itemText = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            itemText:SetPoint("TOPLEFT", 5, -5)
            itemText:SetPoint("TOPRIGHT", -45, -5)
            itemText:SetJustifyH("LEFT")
            itemText:SetWordWrap(true)
            itemText:SetText(item)

            -- Delete button
            local deleteBtn = CreateFrame("Button", nil, itemFrame, "UIPanelButtonTemplate")
            deleteBtn:SetSize(40, 20)
            deleteBtn:SetPoint("TOPRIGHT", -5, -5)
            deleteBtn:SetText("Del")
            deleteBtn.itemIndex = i
            deleteBtn:SetScript("OnClick", function(self)
                DB:RemoveContent(moduleId, self.itemIndex)
                RefreshContentList()
            end)

            -- Divider
            local divider = itemFrame:CreateTexture(nil, "ARTWORK")
            divider:SetHeight(1)
            divider:SetPoint("BOTTOMLEFT", 0, 0)
            divider:SetPoint("BOTTOMRIGHT", 0, 0)
            divider:SetColorTexture(0.3, 0.3, 0.3, 0.5)

            table.insert(contentButtons, itemFrame)
            itemYOffset = itemYOffset + 50
        end

        scrollChild:SetHeight(math.max(itemYOffset, scrollFrame:GetHeight()))
    end

    container.RefreshContentList = RefreshContentList

    yOffset = yOffset - 160

    -- Add new item section
    local addLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    addLabel:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 10, 50)
    addLabel:SetText("Add new:")

    local addEditBox = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
    addEditBox:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 10, 25)
    addEditBox:SetSize(500, 25)
    addEditBox:SetAutoFocus(false)
    addEditBox:SetMaxLetters(500)

    local addBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    addBtn:SetSize(100, 25)
    addBtn:SetPoint("LEFT", addEditBox, "RIGHT", 10, 0)
    addBtn:SetText("Add")
    addBtn:SetScript("OnClick", function()
        local newItem = addEditBox:GetText():trim()
        if newItem ~= "" then
            DB:AddContent(moduleId, newItem)
            addEditBox:SetText("")
            RefreshContentList()
        end
    end)

    RefreshContentList()
end

-- ============================================================================
-- Panel Management
-- ============================================================================

Config.frame = nil

function Config:Show()
    if not self.frame then
        self.frame = CreateConfigPanel()
    end
    -- Refresh all content lists
    for _, tab in ipairs(self.moduleTabs) do
        if self.frame[tab.moduleId .. "RefreshContentList"] then
            self.frame[tab.moduleId .. "RefreshContentList"]()
        end
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
