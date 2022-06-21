local MysticExtended, MyExt = ...
local addonName = "SpecMenu";
_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
local addon = _G[addonName];

AddonPrefix = "fnGB";

local function Addon_OnEvent(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		print(event, ...)
	elseif event == "PLAYER_LOGIN" then
		local successfulRequest = C_ChatInfo.RegisterAddonMessagePrefix(AddonPrefix)
		print(successfulRequest);
	elseif event == "PLAYER_ENTERING_WORLD" then
		C_ChatInfo.SendAddonMessage(AddonPrefix, "HHEELLOOO!", "WHISPER", UnitName("player"))
	end
end
local f = CreateFrame("Frame")
f:SetScript("OnEvent", Addon_OnEvent)
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("PLAYER_ENTERING_WORLD");