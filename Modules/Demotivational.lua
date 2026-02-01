-- Modules/Demotivational.lua - Demotivational Sayings Module

Dadabase = Dadabase or {}

local defaultSayings = {
    "Remember: Failure is always an option.",
    "The only difference between you and a corpse is about 5 seconds.",
    "At least we're consistent.",
    "It's not a learning experience if we don't learn from it. So... same strat?",
    "Mistakes: Proof that you're trying. We're trying a LOT.",
    "If at first you don't succeed... lower your expectations.",
    "We're not bad, we're just differently successful.",
    "Every wipe is just another opportunity to wipe again.",
    "The floor tank strategy is bold. Not effective, but bold.",
    "Achievement Unlocked: Creative New Ways to Die",
    "Practice doesn't make perfect. As we've demonstrated.",
    "We're speedrunning... dying.",
    "That mechanic is optional, right? Right?",
    "Someone's gear broke. Was it our spirits? Yes.",
    "We put the 'fun' in 'funeral'.",
    "At this rate, we'll clear it by next expansion.",
    "I see the problem: We're not good enough.",
    "Well, we tried nothing and we're all out of ideas.",
    "Our DPS stands for 'Dies Per Second'.",
    "We're not wiping, we're strategically repositioning to the graveyard.",
    "Remember when we thought this would be easy? Good times.",
    "The best ability is responsibility. We have neither.",
    "We didn't wipe. We performed a group tactical reset.",
    "Some say 'learn from mistakes.' We say 'make new ones!'",
    "Repair bills are just success tax. We're very successful.",
    "We're building character. And repair bills.",
    "That wasn't mechanics. That was gravity. Very aggressive gravity.",
    "We're not failing, we're discovering what doesn't work.",
    "Perhaps the real loot was the trauma we collected along the way.",
    "When in doubt, panic. We're following that strategy perfectly."
}

-- Register with Database Manager
Dadabase.DatabaseManager:RegisterModule("demotivational", {
    name = "Demotivational",
    defaultContent = defaultSayings,
    dbVersion = 1,
    defaultSettings = {
        enabled = false,
        triggers = {
            wipe = false,
            death = false
        },
        groups = {
            raid = false,
            party = false
        }
    }
})

-- Register config tab
Dadabase.Config:RegisterModuleTab("demotivational", {
    name = "Demotivational",
    buildContent = function(container, moduleId)
        Dadabase.Config:BuildModuleContent(container, moduleId)
    end
})
