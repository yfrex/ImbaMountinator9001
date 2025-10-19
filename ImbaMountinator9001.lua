-- yfrex ftw
local loglevel = 0
local debugging = false
local function debugPrint(message, level)
    if loglevel >= level then
        print("ImbaMountinator9001: "..message)
    end
end

function printTable(table)
    debugPrint("tbl:", 2)
    if loglevel >= 3 then
        for k, v in pairs(table) do
            print("         tbl["..k.."] = "..tostring(v))
        end
    end
    if loglevel == 2 then
        for k, v in pairs(table) do
            if v then
                print("         tbl["..k.."] = "..tostring(v))
            end
        end
    end
end

SLASH_ImbaMountinator90011 = "/ImbaMountinator9001"
SLASH_ImbaMountinator90012 = "/imbamountinator"
SLASH_ImbaMountinator90013 = "/imbamount"
SLASH_ImbaMountinator90014 = "/imba"
SLASH_ImbaMountinator90015= "/im"
SLASH_ImbaMountinator90016 = "/9001"
SlashCmdList["ImbaMountinator9001"] = function(msg)
    debugPrint("ImbaMountinator9001 by yfrex", 0)
end

local FlyingMounts = {
    -- Gryphons (Alliance)
    "Ebon Gryphon",
    "Snowy Gryphon",
    "Golden Gryphon",
    "Swift Blue Gryphon",
    "Swift Green Gryphon",
    "Swift Purple Gryphon",
    "Swift Red Gryphon",
    "Armored Snowy Gryphon",

    -- Wind Riders (Horde)
    "Tawny Wind Rider",
    "Blue Wind Rider",
    "Green Wind Rider",
    "Swift Red Wind Rider",
    "Swift Green Wind Rider",
    "Swift Yellow Wind Rider",
    "Swift Purple Wind Rider",

    -- Netherwing Drakes
    "Onyx Netherwing Drake",
    "Azure Netherwing Drake",
    "Cobalt Netherwing Drake",
    "Purple Netherwing Drake",
    "Veridian Netherwing Drake",
    "Violet Netherwing Drake",

    -- Proto-Drakes
    "Albino Drake",
    "Black Proto-Drake",
    "Blue Proto-Drake",
    "Green Proto-Drake",
    "Red Proto-Drake",
    "Rusted Proto-Drake",
    "Violet Proto-Drake",
    "Ironbound Proto-Drake",
    "Plagued Proto-Drake",
    "Time-Lost Proto-Drake",

    -- Dragon mounts
    "Bronze Drake Mount",
    "Azure Drake Mount",
    "Blue Drake Mount",
    "Red Drake Mount",
    "Twilight Drake Mount",
    "Black Drake Mount",
    "Onyxian Drake",
    "Veridian Drake",
    "Violet Drake",

    -- Nether Rays
    "Blue Riding Nether Ray",
    "Green Riding Nether Ray",
    "Purple Riding Nether Ray",
    "Red Riding Nether Ray",
    "Silver Riding Nether Ray",

    -- Frostwyrms
    "Icebound Frostbrood Vanquisher",
    "Bloodbathed Frostbrood Vanquisher",

    -- Special flying mounts
    "X-51 Nether-Rocket",
    "X-51 Nether-Rocket X-TREME",
    "Turbo-Charged Flying Machine",
    "Flying Machine",
    "Rusted Proto-Drake",
    "Ironbound Proto-Drake",
    "Merciless Nether Drake",
    "Vengeful Nether Drake",
    "Brutal Nether Drake",
    "Deadly Gladiator's Frost Wyrm",
    "Mimiron's Head",

    -- Hippogryphs
    "Cenarion War Hippogryph",
    "Silver Covenant Hippogryph",
    "Argent Hippogryph",

    -- Carpets
    "Flying Carpet",
    "Magnificent Flying Carpet",
    "Frosty Flying Carpet"
}

local HybridMounts = {
    "Celestial Steed",
    "Big Love Rocket",
    "Headless Horseman's Mount",
    "Invincible",
    "X-51 Nether-Rocket",
    "X-51 Nether-Rocket X-TREME",
    "X-53 Touring Rocket"
}

-- vars
local overlayButtonSet = {}
local canceldbwActive = true
local groundIcon
local groundBtn
local flyIcon
local flyBtn
local activeGroundSet = {}
local activeFlyingSet = {}
local nextGroundMountID = ""
local nextFlyingMountID = ""

if debugging then
    activeGroundSet["Black War Tiger"] = true
    activeGroundSet["Black Battlestrider"] = true
end

local function updateDB()
    debugPrint("Updating DB", 3)
    ImbaMountinator9001DB.activeGroundSet = activeGroundSet
    ImbaMountinator9001DB.activeFlyingSet = activeFlyingSet
end

function CancelDeathbringersWillBuff()
    if not UnitAffectingCombat("player") and canceldbwActive then
        local buffs = {
            "Strength of the Taunka",
            "Agility of the Vrykul",
            "Aim of the Iron Dwarves",
            "Power of the Taunka",
            "Precision of the Iron Dwarves",
            "Speed of the Vrykul"
        }

        for i = 1, 40 do
            local name = UnitBuff("player", i)
            if not name then break end

            for _, buffName in ipairs(buffs) do
                if name == buffName then
                    CancelUnitBuff("player", i)
                    return
                end
            end
        end
    end
end

-- mount set related shit
local function isInList(list, str)
    for _, v in ipairs(list) do
        if v == str then
            return true
        end
    end
    return false
end

local function addMount(tbl, str)
    debugPrint("adding " .. str, 3)
    tbl[str] = true
end

local function removeMount(tbl, str)
    debugPrint("removing " .. str, 3)
    tbl[str] = false
end

local function toggleMountTable(tbl, str)
    if tbl[str] == true then
        debugPrint("removing " .. str, 3)
        tbl[str] = false
    else
        debugPrint("adding " .. str, 3)
        tbl[str] = true
    end
    printTable(tbl)
end

local function toggleMount(str)
    if isInList(HybridMounts, str) then
        debugPrint(str .. " is a HYBDRID mount", 1)
        toggleMountTable(activeGroundSet, str)
        toggleMountTable(activeFlyingSet, str)
    elseif isInList(FlyingMounts, str) then
        debugPrint(str .. " is a FLYING mount", 1)
        toggleMountTable(activeFlyingSet, str)
    else
        debugPrint(str .. " is a GROUND mount", 1)
        toggleMountTable(activeGroundSet, str)
    end
    updateDB()
end

local function isMountActiveInSet(set, mount)
    for str, val in pairs(set) do
        if val and str == mount then
            return true
        end
    end
    return false
end

local function isMountActive(str)
    if isMountActiveInSet(activeGroundSet, str) or isMountActiveInSet(activeFlyingSet, str) then
        return true
    end
    return false
end

function GetMountSpellLinkByCreatureName(creatureName)
    for i = 1, GetNumCompanions("MOUNT") do
        local _, name, spellID = GetCompanionInfo("MOUNT", i)
        if name == creatureName then
            return GetSpellLink(spellID):match("%[(.+)%]")
        end
    end
end

local function getAvailableMountNumber(tbl)
    n = 0
    for str in pairs(tbl) do
        if tbl[str] == true then
            n = n + 1
        end
    end
    debugPrint("getAvailableMountNumber returns " .. n, 4)
    return n
end

local function getRandomMount(tbl)
    if getAvailableMountNumber(tbl) > 0 then
        local keys = {}
        for str, val in pairs(tbl) do
            if val then
                debugPrint("inserted " .. str, 4)
                table.insert(keys, str)
            end
        end

        -- Select a random key
        randomKey = keys[math.random(1, #keys)]
        debugPrint("Got random mount " .. randomKey, 2)
        return randomKey
    end
    return ""
end

local function getMountID(str)
    local numMounts = GetNumCompanions("MOUNT")
    for i = 1, numMounts do
        local creatureID, creatureName = GetCompanionInfo("MOUNT", i)
        if creatureName == str then
            debugPrint("Got mount ID " .. i, 4)
            return i
        end
    end
end

-- nice
local function castMount(tbl)
    if getAvailableMountNumber(tbl) == 0 then
        debugPrint("No mount available", 1)
        return
    end

    -- Pick random name from table
    local chosenName = getRandomMount(tbl)
    debugPrint("got random mount: " .. chosenName, 3)

    -- find that thing
    local numMounts = GetNumCompanions("MOUNT")
    for i = 1, numMounts do
        local creatureID, creatureName = GetCompanionInfo("MOUNT", i)
        if creatureName == chosenName then
            debugPrint("Trying to summon: " .. i, 2)
            CallCompanion("MOUNT", i)
            return
        end
    end
end

function castGroundMount()
    CancelDeathbringersWillBuff()
    if IsMounted() then
        Dismount()
    else
        if not nextGroundMountID then
            debugPrint("No ground mount selected. ALT-click on a mount to favorite it.", 0)
        else
            debugPrint("Trying to summon: " .. nextGroundMountID, 2)
            CallCompanion("MOUNT", nextGroundMountID)
            cacheNextMounts()
        end
    end
end

function castFlyingMount()
    CancelDeathbringersWillBuff()
    if IsMounted() then
        Dismount()
    else
        if not nextFlyingMountID then
            debugPrint("No flying mount selected. ALT-click on a mount to favorite it.", 0)
        else
            debugPrint("Trying to summon: " .. nextFlyingMountID, 2)
            CallCompanion("MOUNT", nextFlyingMountID)
            cacheNextMounts()
        end
    end
end

function cacheNextMounts()
    nextGroundMountID = getMountID(getRandomMount(activeGroundSet))
    -- debugPrint("Next ground mount: " .. nextGroundMountID, 2)
    nextFlyingMountID = getMountID(getRandomMount(activeFlyingSet))
    -- debugPrint("Next flying mount: " .. nextFlyingMountID, 2)
end

local function updateMacro(macroName, macroContent)
        local macroIndex = GetMacroIndexByName(macroName)
        EditMacro(macroIndex, macroName, 1, macroContent, false, false)
end

-- philosophy
local function updateCompanionButtons()
    debugPrint("Updating CompanionButttons", 4)
    -- for _, overlayButton in ipairs(overlayButtonSet) do
    for i = 1,12 do
        overlayButtonSet[i]:Show()
        local btn = _G["CompanionButton"..i]
        debugPrint("btn:getID: "..btn:GetID(), 4)
        debugPrint("pageMount: "..PetPaperDollFrameCompanionFrame.pageMount, 4)
        -- local companionIndex = btn:GetID() + (12 * ((PetPaperDollFrameCompanionFrame.pageMount) -1))
        local companionIndex = PetPaperDollFrameCompanionFrame.pageMount * 12 + btn:GetID()
        debugPrint("CompanionIndex: "..companionIndex, 4)
        local creatureID, creatureName, spellID = GetCompanionInfo("MOUNT", companionIndex)
        -- local spellLink = GetSpellLink(spellID)
        -- debugPrint("CompanionIndexMount: " .. creatureName, 4)
        -- debugPrint("spellLink: " .. spellLink, 4)

        if isMountActive(creatureName) then
            debugPrint("set minus", 4)
            -- overlayButtonSet[i]:SetText("-")
            overlayButtonSet[i]:SetBackdropBorderColor(0, 1, 0, 1)
        else
            debugPrint("set plus", 4)
            overlayButtonSet[i]:SetBackdropBorderColor(0, 0, 0, 0)
        end

        overlayButtonSet[i]:SetScript("OnClick", function(self)
            if IsAltKeyDown() then
                if creatureName then
                    debugPrint("Clicked overlayButton on mount: " .. creatureName, 3)
                    debugPrint("Creature Spell name: " .. GetMountSpellLinkByCreatureName(creatureName), 3)
                    toggleMount(creatureName)
                end
                cacheNextMounts()
                updateCompanionButtons()
            else
                btn:Click()
            end
        end)
        overlayButtonSet[i]:RegisterForDrag("LeftButton")
        overlayButtonSet[i]:SetScript("OnDragStart", function(self)
            debugPrint("Dragging", 2)
            local dragged = btn:GetID() + (PetPaperDollFrameCompanionFrame.pageMount or 0)*12;
            PickupCompanion( PetPaperDollFrameCompanionFrame.mode, dragged );
        end)
    end

    --update ground/fly buttons
    groundBtn:Show()
    flyBtn:Show()
    if getAvailableMountNumber(activeGroundSet) == 0 then
        groundIcon:SetDesaturated(true)
    else
        groundIcon:SetDesaturated(false)
    end
    if getAvailableMountNumber(activeFlyingSet) == 0 then
        flyIcon:SetDesaturated(true)
    else
        flyIcon:SetDesaturated(false)
    end
end

local function createCompanionButtons()
    debugPrint("creating CompanionButttons", 4)
    for i = 1, 12 do
        local btn = _G["CompanionButton"..i]
        if btn then
            local overlayButton = CreateFrame("Button", "CompanionoverlayButtonButton"..i, btn:GetParent())
            overlayButton:SetAllPoints(btn)
            overlayButton:SetFrameStrata(btn:GetFrameStrata())
            overlayButton:SetFrameLevel(btn:GetFrameLevel() + 1)
            overlayButton:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8X8", -- small white texture (we'll keep alpha 0)
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true, tileSize = 4, edgeSize = 20,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            overlayButton:SetBackdropColor(0, 0, 0, 0)
            overlayButton:SetBackdropBorderColor(0, 0, 0, 0)

            local companionIndex = btn:GetID()
            debugPrint("companionIndex: " .. companionIndex, 4)
            local creatureID, creatureName = GetCompanionInfo("MOUNT", companionIndex)
            -- debugPrint(creatureID .. " " .. creatureName, 4)

            overlayButtonSet[i] = overlayButton
        end
    end
    updateCompanionButtons()
end

function createMountingButtons()
    -- ground button
    groundBtn = CreateFrame("Button", "MySpellButton", CompanionModelFrame, "SecureActionButtonTemplate")
    groundBtn:SetSize(36, 36)
    groundBtn:SetPoint("CENTER", CompanionModelFrame, "BOTTOMRIGHT", -22, 19)
    -- Make it static
    groundBtn:SetMovable(false)
    groundBtn:EnableMouse(true)
    groundBtn:RegisterForDrag("LeftButton")
    groundBtn:RegisterForClicks("AnyUp")
    -- Add icon texture
    groundIcon = groundBtn:CreateTexture(nil, "LOW")
    groundIcon:SetAllPoints(groundBtn)
    groundIcon:SetTexture("Interface\\Icons\\Spell_nature_swiftness")
    groundBtn.icon = groundIcon
    local groundPushed = groundBtn:CreateTexture(nil, "HIGH")
    groundPushed:SetAllPoints(groundBtn)
    groundPushed:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    groundBtn:SetPushedTexture(groundPushed)

    groundBtn:SetScript("OnDragStart", function(self)
        if not UnitAffectingCombat("player") then
            if getAvailableMountNumber(activeGroundSet) > 0 then
                local groundMacroName = "ImbaMountinator9001: Ground Mount"
                local randomMount = getRandomMount(activeGroundSet)
                debugPrint("randomMount = " .. randomMount, 2)
                local groundMacroContent = "#showtooltip " .. GetMountSpellLinkByCreatureName(randomMount) .."\
/run castGroundMount()"
                local macroIndex = GetMacroIndexByName(groundMacroName)
                debugPrint("macroIndex before creating: " .. macroIndex, 2)
                if macroIndex == 0 then
                    if numGlobal == 36 then
                        debugPrint("Cant drag-and-drop, because general macros are full. Please delete one general macro.", 1)
                    else
                        groundMacroID = CreateMacro(groundMacroName, 1, groundMacroContent, false)
                        debugPrint("Created macro, groundMacroId = " .. groundMacroID, 2)
                    end
                else
                    updateMacro(groundMacroName, groundMacroContent)
                end
                PickupMacro(groundMacroName)
            end
        else
            debugPrint("ImbaMountinator9001: Cant drag-and-drop in combat", 0)
        end
    end)
    groundBtn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            groundBtn:SetButtonState("PUSHED")
            debugPrint("Direct ground button click", 4)
            castGroundMount()
        end
    end)
    groundBtn:SetScript("OnEnter", function(self, button)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Summon Random Ground Mount", 1, 1, 1)
        GameTooltip:AddLine("ALT-click on a mount to favorite it!")
        GameTooltip:Show()
    end)
    groundBtn:SetScript("OnLeave", function(self, button)
        GameTooltip:Hide()

    end)

    -- fly Button
    flyBtn = CreateFrame("Button", "MySpellButton", CompanionModelFrame, "SecureActionButtonTemplate")
    flyBtn:SetSize(36, 36)
    flyBtn:SetPoint("CENTER", CompanionModelFrame, "BOTTOMRIGHT", -22, -21)
    -- Make it static
    flyBtn:SetMovable(false)
    flyBtn:EnableMouse(true)
    flyBtn:RegisterForDrag("LeftButton")
    flyBtn:RegisterForClicks("AnyUp")
    -- Add icon texture
    flyIcon = flyBtn:CreateTexture(nil, "HIGH")
    flyIcon:SetAllPoints(flyBtn)
    flyIcon:SetTexture("Interface\\Icons\\Ability_Druid_Flightform")
    flyBtn.icon = flyIcon
    local pushed = flyBtn:CreateTexture(nil, "HIGH")
    pushed:SetAllPoints(flyBtn)
    pushed:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    flyBtn:SetPushedTexture(pushed)

    flyBtn:SetScript("OnDragStart", function(self)
        if getAvailableMountNumber(activeFlyingSet) > 0 then
            local flyMacroName = "ImbaMountinator9001: Flying Mount"
            local randomMount = getRandomMount(activeFlyingSet)
            local flyMacroContent = "#showtooltip " .. GetMountSpellLinkByCreatureName(randomMount) .."\
/run castFlyingMount()"
            local macroIndex = GetMacroIndexByName(flyMacroName)
            debugPrint("macroIndex before creating: " .. macroIndex, 2)
            if macroIndex == 0 then
                local numGlobal, _ = GetNumMacros()
                debugPrint("Total global macros: " .. numGlobal, 2)
                if numGlobal == 36 then
                    debugPrint("Cant drag-and-drop, because general macros are full. Please delete one general macro.", 1)
                else
                    flyingMacroID = CreateMacro(flyMacroName, 1, flyMacroContent, false)
                    debugPrint("Created macro, flyingMacroId = " .. flyingMacroID, 2)
                end
            else
                updateMacro(flyMacroName, flyMacroContent)
            end
            PickupMacro(flyMacroName)
        end
    end)
    flyBtn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            debugPrint("Direct flying button click", 4)
            castFlyingMount()
        end
    end)
    flyBtn:SetScript("OnEnter", function(self, button)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Summon Random Flying Mount", 1, 1, 1)
        GameTooltip:AddLine("ALT-click on a mount to favorite it!")
        GameTooltip:Show()
    end)
    flyBtn:SetScript("OnLeave", function(self, button)
        GameTooltip:Hide()
    end)
end

local function hideCompanionButtons()
    debugPrint("Hiding CompanionButttons", 2)
    for _, overlayButton in ipairs(overlayButtonSet) do
        overlayButton:Hide()
        groundBtn:Hide()
        flyBtn:Hide()
    end
end

-- fuck bill gates
local addon = CreateFrame("Frame")
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_LOGOUT")
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("PLAYER_REGEN_ENABLED")

addon:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ImbaMountinator9001" then
        debugPrint("ADDON LOADED: " .. arg1, 2)
        if not ImbaMountinator9001DB then
            debugPrint("No DB found", 2)
            ImbaMountinator9001DB = {}
        end
        debugPrint("DB INIT", 2)
        activeGroundSet = ImbaMountinator9001DB.activeGroundSet or {}
        activeFlyingSet = ImbaMountinator9001DB.activeFlyingSet or {}
        print("|cffff0000ImbaMountinator9001|r |cff808080by|r |cff00ff00yfrex|r |cff808080- Icecrown|r")
    elseif event == "PLAYER_LOGIN" then
        cacheNextMounts()
        if not CharacterFrame then
            debugPrint("CharacterFrame not found.", 1)
            return
        end

        -- faster debugging
        if debugging then
            CharacterFrame:Show()
            ToggleCharacter("PetPaperDollFrame")
            PetPaperDollFrame_SetTab(3)
        end
        --

        -- button creation
        createMountingButtons()
        createCompanionButtons()

        --aye aye
        hooksecurefunc("PetPaperDollFrame_SetCompanionPage", function()
            debugPrint("PetPaperDollFrame_SetCompanionPage triggered:" .. PetPaperDollFrameCompanionFrame.mode, 3)
            if not UnitAffectingCombat("player") then
                if PetPaperDollFrameCompanionFrame.mode == "MOUNT" then
                    updateCompanionButtons()
                else
                    hideCompanionButtons()
                end
            end
        end)
        debugPrint("CompanionoverlayButton: Buttons created.", 4)
    elseif event == "PLAYER_REGEN_ENABLED" then
        if PetPaperDollFrameCompanionFrame.mode == "MOUNT" then
            updateCompanionButtons()
        else
            hideCompanionButtons()
        end
    end
end)
