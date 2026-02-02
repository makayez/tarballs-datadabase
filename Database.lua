-- Database.lua - Generic content database manager

Dadabase = Dadabase or {}
Dadabase.DatabaseManager = {}

local DB = Dadabase.DatabaseManager

-- Registered modules
DB.modules = {}

-- Content cache for performance (especially with 1100+ jokes)
DB.contentCache = {}

-- ============================================================================
-- Module Registration
-- ============================================================================

function DB:RegisterModule(moduleId, config)
    if self.modules[moduleId] then
        error("Module '" .. moduleId .. "' already registered!")
    end

    self.modules[moduleId] = {
        id = moduleId,
        name = config.name,
        defaultContent = config.defaultContent or {},
        dbVersion = config.dbVersion or 1,
        defaultSettings = config.defaultSettings or {}
    }
end

-- ============================================================================
-- Database Initialization
-- ============================================================================

function DB:Initialize()
    TarballsDadabaseDB = TarballsDadabaseDB or {}
    TarballsDadabaseDB.modules = TarballsDadabaseDB.modules or {}

    -- Initialize each registered module
    for moduleId, module in pairs(self.modules) do
        local moduleDB = TarballsDadabaseDB.modules[moduleId]

        if TarballsDadabaseDB.debug then
            print("[DEBUG] " .. module.name .. ": Module dbVersion=" .. module.dbVersion .. ", defaultContent=" .. #module.defaultContent)

            if not moduleDB then
                print("[DEBUG] " .. module.name .. ": First install")
            else
                print("[DEBUG] " .. module.name .. ": Existing install, saved dbVersion=" .. (moduleDB.dbVersion or 0) .. ", has content=" .. tostring(moduleDB.content ~= nil))
            end
        end

        if not moduleDB then
            -- First install - create module DB with defaults
            TarballsDadabaseDB.modules[moduleId] = {
                enabled = module.defaultSettings.enabled or false,
                triggers = module.defaultSettings.triggers or {},
                groups = module.defaultSettings.groups or {},
                userAdditions = {},
                userDeletions = {},
                dbVersion = module.dbVersion
            }
            moduleDB = TarballsDadabaseDB.modules[moduleId]
        else
            -- Migration: Convert old 'content' array to new structure
            if moduleDB.content then
                -- Build set of default content for comparison
                local defaultSet = {}
                for _, item in ipairs(module.defaultContent) do
                    defaultSet[item] = true
                end

                -- Anything in content that's NOT in defaults = user addition
                moduleDB.userAdditions = {}
                for _, item in ipairs(moduleDB.content) do
                    if not defaultSet[item] then
                        table.insert(moduleDB.userAdditions, item)
                    end
                end

                -- Anything in defaults that's NOT in content = user deletion
                -- Build set of existing content for fast lookup
                local contentSet = {}
                for _, item in ipairs(moduleDB.content) do
                    contentSet[item] = true
                end

                moduleDB.userDeletions = {}
                for _, item in ipairs(module.defaultContent) do
                    if not contentSet[item] then
                        table.insert(moduleDB.userDeletions, item)
                    end
                end

                -- Remove old content field
                moduleDB.content = nil

                if TarballsDadabaseDB.debug then
                    print(module.name .. ": Migrated to new content tracking system")
                end
            end
        end

        -- Ensure all settings exist
        if moduleDB.triggers == nil then moduleDB.triggers = {} end
        if moduleDB.groups == nil then moduleDB.groups = {} end
        if moduleDB.userAdditions == nil then moduleDB.userAdditions = {} end
        if moduleDB.userDeletions == nil then moduleDB.userDeletions = {} end
        if moduleDB.dbVersion == nil then moduleDB.dbVersion = 0 end

        -- Update version (new defaults will be automatically included via GetEffectiveContent)
        if moduleDB.dbVersion < module.dbVersion then
            -- Invalidate cache before checking counts
            self.contentCache[moduleId] = nil

            -- Preserve both user deletions and additions
            -- New default content will appear automatically (not in deletions list)
            local deletionCount = #moduleDB.userDeletions
            local additionCount = #moduleDB.userAdditions
            local oldCount = #self:GetEffectiveContent(moduleId)

            moduleDB.dbVersion = module.dbVersion

            -- Invalidate cache again after version change
            self.contentCache[moduleId] = nil

            local newCount = #self:GetEffectiveContent(moduleId)
            local addedCount = newCount - oldCount

            if TarballsDadabaseDB.debug then
                print(module.name .. ": Updated to version " .. module.dbVersion)
                print("  - Preserved " .. deletionCount .. " user deletions")
                print("  - Preserved " .. additionCount .. " user additions")
                print("  - Added " .. addedCount .. " new default items")
                print("  - Total content now: " .. newCount)
            end
        end
    end
end

-- ============================================================================
-- Content Retrieval
-- ============================================================================

function DB:GetEffectiveContent(moduleId)
    -- Return cached content if available
    if self.contentCache[moduleId] then
        return self.contentCache[moduleId]
    end

    local module = self.modules[moduleId]

    -- Check if SavedVariables is initialized
    if not TarballsDadabaseDB or not TarballsDadabaseDB.modules then
        return {}
    end

    local moduleDB = TarballsDadabaseDB.modules[moduleId]

    if not module or not moduleDB then
        return {}
    end

    local effective = {}
    local deletionSet = {}

    -- Build fast lookup of deleted items
    for _, item in ipairs(moduleDB.userDeletions) do
        deletionSet[item] = true
    end

    -- Add default content (excluding deleted ones)
    for _, item in ipairs(module.defaultContent) do
        if not deletionSet[item] then
            table.insert(effective, item)
        end
    end

    -- Add user's custom additions
    for _, item in ipairs(moduleDB.userAdditions) do
        table.insert(effective, item)
    end

    -- Cache the result for future calls
    self.contentCache[moduleId] = effective

    return effective
end

function DB:GetTotalContentCount()
    local total = 0
    if not self.modules then
        return 0
    end
    for moduleId, _ in pairs(self.modules) do
        local content = self:GetEffectiveContent(moduleId)
        total = total + #content
    end
    return total
end

function DB:GetContentPrefix(moduleId)
    -- Random adjectives to inject into prefixes
    local adjectives = {
        "uplifting",
        "inspiring",
        "satisfying",
        "heartwarming",
        "gratifying",
        "enlightening",
        "encouraging",
        "rewarding",
        "fulfilling",
        "refreshing",
        "invigorating",
        "delightful",
        "wonderful",
        "magnificent",
        "spectacular",
        "amazing",
        "breathtaking",
        "brilliant",
        "captivating",
        "charming",
        "dazzling",
        "empowering",
        "exceptional",
        "extraordinary",
        "fabulous",
        "glorious",
        "incredible",
        "legendary",
        "marvelous",
        "motivating",
        "outstanding",
        "phenomenal",
        "powerful",
        "remarkable",
        "sensational",
        "splendid",
        "stirring",
        "stunning",
        "sublime",
        "superb",
        "tremendous",
        "triumphant",
        "upbeat",
        "vibrant",
        "awe-inspiring",
        "life-changing",
        "thought-provoking",
        "soul-stirring",
        "mind-blowing",
        "game-changing",
        "electrifying",
        "exhilarating",
        "mesmerizing",
        "enchanting",
        "riveting",
        "spellbinding",
        "enthralling",
        "intriguing",
        "mystifying",
        "tantalizing",
        "scintillating",
        "fascinating",
        "gripping",
        "compelling",
        "engrossing",
        "absorbing",
        "hypnotic",
        "magnetic",
        "irresistible",
        "unforgettable",
        "timeless",
        "priceless",
        "invaluable",
        "unparalleled",
        "unrivaled",
        "unmatched",
        "unsurpassed",
        "unbeatable",
        "supreme",
        "divine",
        "transcendent",
        "celestial",
        "heavenly",
        "angelic",
        "majestic",
        "noble",
        "regal",
        "stately",
        "dignified",
        "prestigious",
        "distinguished",
        "illustrious",
        "eminent",
        "exalted",
        "elevated",
        "lofty",
        "grandiose",
        "monumental",
        "colossal",
        "titanic",
        "epic",
        "heroic",
        "valiant",
        "gallant",
        "bold",
        "daring",
        "intrepid",
        "fearless"
    }

    -- Bounds checking - fallback if adjectives table is empty or corrupted
    if #adjectives == 0 then
        return ""
    end

    local randomAdjective = adjectives[math.random(#adjectives)]

    -- Determine a/an based on first letter
    local firstLetter = randomAdjective:sub(1, 1):lower()
    local vowels = {a = true, e = true, i = true, o = true, u = true}
    local article = vowels[firstLetter] and "an" or "a"

    local prefixes = {
        dadjokes = "And now, for " .. article .. " " .. randomAdjective .. " dad joke: ",
        demotivational = "And now, for " .. article .. " " .. randomAdjective .. " motivational quote: ",
        guildquotes = "And now, for some " .. randomAdjective .. " famous words from a friend: "
    }
    return prefixes[moduleId] or ""
end

function DB:GetRandomContent(trigger, group, ignoreTriggers)
    -- Build pool of all matching content from enabled modules
    -- Each entry is {content = "text", moduleId = "id"}
    local contentPool = {}

    -- Check if database is initialized
    if not TarballsDadabaseDB or not TarballsDadabaseDB.modules then
        return "The Dadabase is empty. This wipe is now canon.", "unknown"
    end

    for moduleId, _ in pairs(self.modules) do
        local moduleDB = TarballsDadabaseDB.modules[moduleId]

        if moduleDB and moduleDB.enabled then
            local shouldInclude = false

            if ignoreTriggers then
                -- For manual commands, ignore trigger/group settings
                shouldInclude = true
            else
                -- Check if this module matches the trigger
                local triggerMatch = moduleDB.triggers[trigger] == true

                -- Check if this module matches the group
                -- For solo players (group is nil), skip group requirement for death triggers
                local groupMatch
                if group == nil and trigger == "death" then
                    groupMatch = true
                else
                    groupMatch = moduleDB.groups[group] == true
                end

                shouldInclude = triggerMatch and groupMatch
            end

            if shouldInclude then
                -- Add all effective content from this module to the pool
                local content = self:GetEffectiveContent(moduleId)
                for _, item in ipairs(content) do
                    table.insert(contentPool, {content = item, moduleId = moduleId})
                end
            end
        end
    end

    -- Return random item from pool
    if #contentPool == 0 then
        -- Return fallback with first enabled module ID (or "unknown" if none)
        local fallbackModuleId = "unknown"
        for moduleId, _ in pairs(self.modules) do
            local moduleDB = TarballsDadabaseDB.modules[moduleId]
            if moduleDB and moduleDB.enabled then
                fallbackModuleId = moduleId
                break
            end
        end
        return "The Dadabase is empty. This wipe is now canon.", fallbackModuleId
    end

    local selected = contentPool[math.random(#contentPool)]
    return selected.content, selected.moduleId
end

function DB:GetModuleSettings(moduleId)
    if not TarballsDadabaseDB or not TarballsDadabaseDB.modules then
        return nil
    end
    return TarballsDadabaseDB.modules[moduleId]
end

function DB:SetModuleEnabled(moduleId, enabled)
    if TarballsDadabaseDB and TarballsDadabaseDB.modules and TarballsDadabaseDB.modules[moduleId] then
        TarballsDadabaseDB.modules[moduleId].enabled = enabled
    end
end

function DB:SetModuleTrigger(moduleId, trigger, enabled)
    if TarballsDadabaseDB and TarballsDadabaseDB.modules and TarballsDadabaseDB.modules[moduleId] then
        TarballsDadabaseDB.modules[moduleId].triggers[trigger] = enabled
    end
end

function DB:SetModuleGroup(moduleId, group, enabled)
    if TarballsDadabaseDB and TarballsDadabaseDB.modules and TarballsDadabaseDB.modules[moduleId] then
        TarballsDadabaseDB.modules[moduleId].groups[group] = enabled
    end
end

function DB:SetEffectiveContent(moduleId, newContent)
    -- Validate inputs
    if type(moduleId) ~= "string" then
        error("SetEffectiveContent: moduleId must be a string, got " .. type(moduleId))
        return
    end

    if type(newContent) ~= "table" then
        error("SetEffectiveContent: newContent must be a table, got " .. type(newContent))
        return
    end

    local module = self.modules[moduleId]
    local moduleDB = TarballsDadabaseDB.modules[moduleId]

    if not module then
        error("SetEffectiveContent: module not found: " .. tostring(moduleId))
        return
    end

    if not moduleDB then
        error("SetEffectiveContent: moduleDB not initialized for: " .. tostring(moduleId))
        return
    end

    -- Build set of new content for fast lookup
    local newContentSet = {}
    for _, item in ipairs(newContent) do
        if type(item) ~= "string" then
            error("SetEffectiveContent: all content items must be strings, found " .. type(item))
            return
        end
        newContentSet[item] = true
    end

    -- Build set of default content for fast lookup
    local defaultSet = {}
    for _, item in ipairs(module.defaultContent) do
        defaultSet[item] = true
    end

    -- Clear existing changes
    moduleDB.userAdditions = {}
    moduleDB.userDeletions = {}

    -- Find additions: items in newContent that are NOT in defaults
    for _, item in ipairs(newContent) do
        if not defaultSet[item] then
            table.insert(moduleDB.userAdditions, item)
        end
    end

    -- Find deletions: items in defaults that are NOT in newContent
    for _, item in ipairs(module.defaultContent) do
        if not newContentSet[item] then
            table.insert(moduleDB.userDeletions, item)
        end
    end

    -- Invalidate cache since content changed
    self.contentCache[moduleId] = nil
end

-- Legacy function for backward compatibility
function DB:AddContent(moduleId, content)
    if TarballsDadabaseDB.modules[moduleId] then
        table.insert(TarballsDadabaseDB.modules[moduleId].userAdditions, content)
        -- Invalidate cache
        self.contentCache[moduleId] = nil
    end
end

-- Legacy function for backward compatibility
function DB:RemoveContent(moduleId, index)
    local effective = self:GetEffectiveContent(moduleId)
    if effective[index] then
        local itemToRemove = effective[index]
        local module = self.modules[moduleId]
        local moduleDB = TarballsDadabaseDB.modules[moduleId]

        -- Check if it's a default item
        local isDefault = false
        for _, defaultItem in ipairs(module.defaultContent) do
            if defaultItem == itemToRemove then
                isDefault = true
                break
            end
        end

        if isDefault then
            -- Add to deletions
            table.insert(moduleDB.userDeletions, itemToRemove)
        else
            -- Remove from additions
            for i, item in ipairs(moduleDB.userAdditions) do
                if item == itemToRemove then
                    table.remove(moduleDB.userAdditions, i)
                    break
                end
            end
        end

        -- Invalidate cache since content changed
        self.contentCache[moduleId] = nil
    end
end

-- Legacy function for backward compatibility
function DB:GetContent(moduleId)
    return self:GetEffectiveContent(moduleId)
end
