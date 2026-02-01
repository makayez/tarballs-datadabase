-- Database.lua - Generic content database manager

Dadabase = Dadabase or {}
Dadabase.DatabaseManager = {}

local DB = Dadabase.DatabaseManager

-- Registered modules
DB.modules = {}

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

        if not moduleDB then
            -- First install - create module DB with defaults
            TarballsDadabaseDB.modules[moduleId] = {
                enabled = module.defaultSettings.enabled or false,
                triggers = module.defaultSettings.triggers or {},
                groups = module.defaultSettings.groups or {},
                content = {},
                dbVersion = 0
            }
            moduleDB = TarballsDadabaseDB.modules[moduleId]
        end

        -- Ensure all settings exist
        if moduleDB.triggers == nil then moduleDB.triggers = {} end
        if moduleDB.groups == nil then moduleDB.groups = {} end
        if moduleDB.content == nil then moduleDB.content = {} end
        if moduleDB.dbVersion == nil then moduleDB.dbVersion = 0 end

        -- Handle content versioning
        if moduleDB.dbVersion < module.dbVersion then
            if #moduleDB.content == 0 then
                -- First install: copy all default content
                for _, item in ipairs(module.defaultContent) do
                    table.insert(moduleDB.content, item)
                end
            else
                -- Upgrade: merge in new content
                local existingContent = {}
                for _, item in ipairs(moduleDB.content) do
                    existingContent[item] = true
                end

                local newCount = 0
                for _, item in ipairs(module.defaultContent) do
                    if not existingContent[item] then
                        table.insert(moduleDB.content, item)
                        newCount = newCount + 1
                    end
                end

                if newCount > 0 then
                    print(module.name .. ": " .. newCount .. " new items added!")
                end
            end

            moduleDB.dbVersion = module.dbVersion
        end
    end
end

-- ============================================================================
-- Content Retrieval
-- ============================================================================

function DB:GetTotalContentCount()
    local total = 0
    for moduleId, _ in pairs(self.modules) do
        local moduleDB = TarballsDadabaseDB.modules[moduleId]
        if moduleDB and moduleDB.content then
            total = total + #moduleDB.content
        end
    end
    return total
end

function DB:GetRandomContent(trigger, group)
    -- Build pool of all matching content from enabled modules
    local contentPool = {}

    for moduleId, _ in pairs(self.modules) do
        local moduleDB = TarballsDadabaseDB.modules[moduleId]

        if moduleDB and moduleDB.enabled then
            -- Check if this module matches the trigger
            local triggerMatch = moduleDB.triggers[trigger] == true

            -- Check if this module matches the group
            local groupMatch = moduleDB.groups[group] == true

            if triggerMatch and groupMatch then
                -- Add all content from this module to the pool
                for _, item in ipairs(moduleDB.content) do
                    table.insert(contentPool, item)
                end
            end
        end
    end

    -- Return random item from pool
    if #contentPool == 0 then
        return "The Dadabase is empty. This wipe is now canon."
    end

    return contentPool[math.random(#contentPool)]
end

function DB:GetModuleSettings(moduleId)
    return TarballsDadabaseDB.modules[moduleId]
end

function DB:SetModuleEnabled(moduleId, enabled)
    if TarballsDadabaseDB.modules[moduleId] then
        TarballsDadabaseDB.modules[moduleId].enabled = enabled
    end
end

function DB:SetModuleTrigger(moduleId, trigger, enabled)
    if TarballsDadabaseDB.modules[moduleId] then
        TarballsDadabaseDB.modules[moduleId].triggers[trigger] = enabled
    end
end

function DB:SetModuleGroup(moduleId, group, enabled)
    if TarballsDadabaseDB.modules[moduleId] then
        TarballsDadabaseDB.modules[moduleId].groups[group] = enabled
    end
end

function DB:AddContent(moduleId, content)
    if TarballsDadabaseDB.modules[moduleId] then
        table.insert(TarballsDadabaseDB.modules[moduleId].content, content)
    end
end

function DB:RemoveContent(moduleId, index)
    if TarballsDadabaseDB.modules[moduleId] then
        table.remove(TarballsDadabaseDB.modules[moduleId].content, index)
    end
end

function DB:GetContent(moduleId)
    if TarballsDadabaseDB.modules[moduleId] then
        return TarballsDadabaseDB.modules[moduleId].content
    end
    return {}
end
