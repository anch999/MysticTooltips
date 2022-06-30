local MysticTooltips, MTip = ...
local addonName = "MysticTooltips";
_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
local addon = _G[addonName];
local select, UnitBuff, UnitDebuff, UnitAura, UnitGUID, tonumber, strfind, hooksecurefunc =
    select, UnitBuff, UnitDebuff, UnitAura, UnitGUID, tonumber, strfind, hooksecurefunc

local realmName = GetRealmName();
local guildName
local playerName = UnitName("player");

--Setup for addon database
local function MysticTooltips_Setup()
    if (MysticTooltipsDB == nil) then
        MysticTooltipsDB = {};
    end

    if (MysticTooltipsDB[realmName] == nil) then
        MysticTooltipsDB[realmName] = {["Account"] = {}, ["Guilds"] = {}};
    end

    if (MysticTooltipsDB[realmName]["Account"][guildName] == nil) and guildName then
        MysticTooltipsDB[realmName]["Account"][guildName] = { ["accountKey"] = playerName , ["charList"] = {playerName}, ["DisplayName"] = playerName };
    end

    if MysticTooltipsDB[realmName]["Guilds"] == nil and guildName or MysticTooltipsDB[realmName]["Guilds"][guildName] == nil and guildName then
        MysticTooltipsDB[realmName]["Guilds"][guildName] = {};
    end

    if guildName then
        if MysticTooltipsDB[realmName]["Account"][guildName]["accountKey"] ~= playerName then
            local nameChecked = false;
                for i , v in pairs(MysticTooltipsDB[realmName]["Account"][guildName]["charList"]) do
                    if v == playerName then
                        nameChecked = true;
                    end
                end
            if not nameChecked then
            table.insert(MysticTooltipsDB[realmName]["Account"][guildName]["charList"], playerName);
            end
        end
    end
end

--Build list of known mystic enchants
local function BuildKnownList(known)
    local list = {}
    for i , v in pairs(MYSTIC_ENCHANTS) do
        if not v.known then
            v.known = IsReforgeEnchantmentKnown(i)
        end
        if (v.known and known) or (not known and not v.known) then
                table.insert(list, v.enchantID)
        end
    end
    return list
end

--Sends enchant list to people with addon in guild
local function MysticTooltips_Broadcast(ComID)
    local knownList = BuildKnownList(true);
    local sendData = {};
    if guildName ~= nil then
    sendData["accountKey"] = MysticTooltipsDB[realmName]["Account"][guildName]["accountKey"];
    sendData["displayName"] = MysticTooltipsDB[realmName]["Account"][guildName]["DisplayName"];
    sendData["knownList"] = knownList;
    sendData = addon:Serialize(sendData);
    addon:SendCommMessage(ComID, sendData, "GUILD", playerName);
    end
end

--Receive enchant list of other people with the addon in guild
local function MysticTooltips_Receive(event, knownList, init, from)
        if event ==  "MYSTICTOOLTIPS_SEND" or event == "MYSTICTOOLTIPS_REQUEST_UPDATE" then
            if from ~= playerName  then
				local success, data = addon:Deserialize(knownList);
                if success then
                    if MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]] == nil then
                        MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]] = {};
                    end
                        MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]]["displayName"] = data["displayName"];
                        MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]]["knownList"] = data["knownList"];
                end
                --print("Mystic Enchant List Received")
                if event == "MYSTICTOOLTIPS_SEND" then
                MysticTooltips_Broadcast("MYSTICTOOLTIPS_REQUEST_UPDATE");
                end
			end
        end
end

--Gets the list of people with that enchant to add to tooltip
local function getCharMysticList(id, type)
local returnNames;
if MysticTooltipsDB[realmName]["Guilds"][guildName] ~= nil then
    if MysticTooltipsDB[realmName]["Guilds"][guildName] then
        local function getName(v)
            local enchantID;
            enchantID =  MYSTIC_ENCHANTS[v].enchantID;
                for c , d in pairs(MysticTooltipsDB[realmName]["Guilds"][guildName]) do
                    for e , f in pairs(d.knownList) do
                        if f == enchantID then
                            if returnNames then
                                returnNames = "|cffffffff" .. returnNames .. "|cFF66CDAA||" .. "|cffffffff".. d.displayName;
                            else
                                returnNames = "|cffffffff" .. d.displayName;
                            end
                        end
                    end
                end
        end
        if type == "Spell" then
            for i , v in pairs(MYSTIC_ENCHANT_SPELLS) do
                if id == v then
                    getName(v)
                end
            end
                return returnNames;
        elseif type == "Item" then
            if id then
                getName(id)
                return returnNames;
            end
        end
    end
end
end

--Sends updated display name to other addons if its swaped
function MysticTooltips_DisplayNameUpdate(name, key)
    local sendData = {};
    if guildName ~= nil then
        sendData["accountKey"] = MysticTooltipsDB[realmName]["Account"][guildName]["accountKey"];
        sendData["displayName"] = MysticTooltipsDB[realmName]["Account"][guildName]["DisplayName"];
        sendData = addon:Serialize(sendData);
        addon:SendCommMessage("MYSTICTOOLTIPS_DISPLAYNAME_UPDATE", sendData, "GUILD", playerName);
    end
end

--Update of display name received
local function MysticTooltips_DisplayNameReceive(event, knownList, init, from)
    if event ==  "MYSTICTOOLTIPS_DISPLAYNAME_UPDATE" then
        if from ~= playerName  then
            local success, data = addon:Deserialize(knownList);
            if success then
                if MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]] == nil then
                    MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]] = {};
                end
                    MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]]["displayName"] = data["displayName"];
            end
            --print("Mystic Enchant List Received")
        end
    end
end

--Update of display name received
local function MysticTooltips_NewEnchantReceive(event, knownList, init, from)
    if event ==  "MYSTICTOOLTIPS_NEWENCHANT_UPDATE" then
        if from ~= playerName  then
            local success, data = addon:Deserialize(knownList);
            if success then
                if MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]] == nil then
                    MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]] = {};
                end
                    MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]]["displayName"] = data["displayName"];
                    table.insert(MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]]["knownList"], data["newEnchant"])
            end
            --print("Mystic Enchant List Received")
        end
    end
end
-- Handle Ascension event
-- COMMENTATOR_SKIRMISH_QUEUE_REQUEST
--      ASCENSION_REFORGE_ENCHANTMENT_LEARNED
--          enchantID
function addon:COMMENTATOR_SKIRMISH_QUEUE_REQUEST(event, subevent, data ,...)
    if subevent == "ASCENSION_REFORGE_ENCHANTMENT_LEARNED" then
        RE = GetREData(data);
        if RE.enchantID ~= 0 and guildName then
            local sendData = {};
                sendData["accountKey"] = MysticTooltipsDB[realmName]["Account"][guildName]["accountKey"];
                sendData["displayName"] = MysticTooltipsDB[realmName]["Account"][guildName]["DisplayName"];
                sendData["newEnchant"] = RE.enchantID;
                sendData = addon:Serialize(sendData);
                addon:SendCommMessage("MYSTICTOOLTIPS_NEWENCHANT_UPDATE", sendData, "GUILD", playerName);
        end
    
    end
end
--Add tooltip line to spell or item tooltip
local function addLine(tooltip, id)
    tooltip:AddLine(" ")
    tooltip:AddLine("|cFF00FF00Enchant Known By:")
    tooltip:AddLine(id)
    tooltip:Show()
end

local function addLineSelf(tooltip, known)
    if known then
        tooltip:AddLine("|cFF00FF00Mystic Enchant Known")
    else
        tooltip:AddLine("|cFFFF0000Mystic Enchant Not Known")
    end
end
--Spell tooltip
GameTooltip:HookScript("OnTooltipSetSpell", function(self)
    local id = select(3, self:GetSpell())
    id = getCharMysticList(id, "Spell")
    if id then addLine(self, id) end
end)

-- Itemlink tooltip
hooksecurefunc("SetItemRef", function(link, ...)
    local id = tonumber(link:match("spell:(%d+)"));
    id = getCharMysticList(id, "Spell");
    if id then addLine(ItemRefTooltip, id) end;
end)

-- Item tooltip
local function attachItemTooltip(self)
    local focus = GetMouseFocus();
    local bagID, slotID = focus:GetParent():GetID(), focus:GetID();
    local id = getCharMysticList(GetREInSlot(bagID,slotID), "Item");
    if GetREInSlot(bagID, slotID) and IsReforgeEnchantmentKnown(GetREInSlot(bagID,slotID)) then
        addLineSelf(self, true)
    elseif GetREInSlot(bagID, slotID) then
        addLineSelf(self, false)
    end
        if id then addLine(self, id) end
end

GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)

local function addonLoaded()
    MysticTooltips_Setup();
    addon:RegisterComm("MYSTICTOOLTIPS_SEND", MysticTooltips_Receive);
    addon:RegisterComm("MYSTICTOOLTIPS_REQUEST_UPDATE", MysticTooltips_Receive);
    addon:RegisterComm("MYSTICTOOLTIPS_DISPLAYNAME_UPDATE", MysticTooltips_DisplayNameReceive);
    addon:RegisterComm("MYSTICTOOLTIPS_NEWENCHANT_UPDATE", MysticTooltips_NewEnchantReceive);
    MysticTooltips_Broadcast("MYSTICTOOLTIPS_SEND");
    addon:RegisterEvent("COMMENTATOR_SKIRMISH_QUEUE_REQUEST");
    MysticTooltipsOptions_CreateFrame();
end
local function getGuildName()
    guildName = GetGuildInfo("Player");
    addonLoaded();
    addon:UnregisterEvent("GUILD_ROSTER_UPDATE");
 end

function addon:OnInitialize()
    addon:RegisterEvent("GUILD_ROSTER_UPDATE",getGuildName);
end