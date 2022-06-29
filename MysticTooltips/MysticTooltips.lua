local MysticTooltips, MTip = ...
local addonName = "MysticTooltips";
_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
local addon = _G[addonName];
local select, UnitBuff, UnitDebuff, UnitAura, UnitGUID, tonumber, strfind, hooksecurefunc =
    select, UnitBuff, UnitDebuff, UnitAura, UnitGUID, tonumber, strfind, hooksecurefunc

local realmName = GetRealmName();
local guildName = GetGuildInfo("Player");
local playerName = UnitName("player");

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

    if MysticTooltipsDB[realmName]["Guilds"][guildName] == nil and guildName ~= nil then
        MysticTooltipsDB[realmName]["Guilds"][guildName] = {};
    end

    if guildName ~= nil then
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

local function MysticTooltips_Receive(event, knownList, init, from)
        if event ==  "MYSTICTOOLTIPS_SEND" or event == "MYSTICTOOLTIPS_SEND_UPDATE" then
            if from ~= playerName  then
				local success, data = addon:Deserialize(knownList);
                if success then
                    if MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]] == nil then
                        MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]] = {};
                    end
                        MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]]["displayName"] = data["displayName"];
                        MysticTooltipsDB[realmName]["Guilds"][guildName][data["accountKey"]]["knownList"] = data["knownList"];
                end
                print("Mystic Enchant List Received")
                if event == "MYSTICTOOLTIPS_SEND" then
                MysticTooltips_Broadcast("MYSTICTOOLTIPS_SEND_UPDATE");
                end
			end
        end
end

local function addLine(tooltip, id)
    tooltip:AddLine(" ")
    tooltip:AddLine("Enchant Known By:")
    tooltip:AddLine("|cffffffff" .. id)
    tooltip:Show()
end

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
                                returnNames = returnNames .. "|" .. d.displayName;
                            else
                                returnNames = d.displayName;
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

--Spells
GameTooltip:HookScript("OnTooltipSetSpell", function(self)
    local id = select(3, self:GetSpell())
    id = getCharMysticList(id, "Spell")
    if id then addLine(self, id) end
end)

-- Items
local function attachItemTooltip(self)
    local focus = GetMouseFocus();
    local bagID, slotID = focus:GetParent():GetID(), focus:GetID();
    local id = getCharMysticList(GetREInSlot(bagID,slotID), "Item");
        if id then addLine(self, id) end
end

GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)

function addon:OnInitialize()
    MysticTooltips_Setup();
    addon:RegisterComm("MYSTICTOOLTIPS_SEND", MysticTooltips_Receive);
    addon:RegisterComm("MYSTICTOOLTIPS_SEND_UPDATE", MysticTooltips_Receive);
    MysticTooltips_Broadcast("MYSTICTOOLTIPS_SEND");
end