local realmName, guildName, playerName;

local function MysticTooltipsOptions_DisplayNameSel_OnClick()
	local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(MysticTooltipsOptions_DisplayNameSel, thisID);
	MysticTooltipsDB[realmName]["Account"][guildName]["DisplayName"] = MysticTooltipsDB[realmName]["Account"][guildName]["charList"][thisID];
	MysticTooltips_DisplayNameUpdate()
end

local function MysticTooltipsOptions_DisplayNameSel_Initialize()
	--Loads the list off characters in current guild into the dropdown menu
	if guildName ~= nil then
		local info;
		for k,v in pairs(MysticTooltipsDB[realmName]["Account"][guildName]["charList"]) do
			info = {
				text = v;
				func = MysticTooltipsOptions_DisplayNameSel_OnClick;
			};
				UIDropDownMenu_AddButton(info);
		end
	end
end

function MysticTooltips_DropDownInitialize()
	MysticTooltips_GetPlayerDetails();
	local id
	--Setup for Dropdown menus in the settings
	if guildName ~= nil then
		UIDropDownMenu_Initialize(MysticTooltipsOptions_DisplayNameSel, MysticTooltipsOptions_DisplayNameSel_Initialize);
		for k,v in pairs(MysticTooltipsDB[realmName]["Account"][guildName]["charList"]) do
			if MysticTooltipsDB[realmName]["Account"][guildName]["DisplayName"] == v then
				id = k
			end
		end
		UIDropDownMenu_SetSelectedID(MysticTooltipsOptions_DisplayNameSel, id);
		UIDropDownMenu_SetText(MysticTooltipsOptions_DisplayNameSel, MysticTooltipsDB[realmName]["Account"][guildName]["DisplayName"])
	end
	
end

--Creates the options frame and all its assets
function MysticTooltipsOptions_CreateFrame()
	
	local mainframe = CreateFrame("FRAME", "MysticTooltipsOptionsFrame", InterfaceOptionsFrame, nil);
    local fstring = mainframe:CreateFontString(mainframe, "OVERLAY", "GameFontNormal");
	fstring:SetText("Mystic Tooltips Settings");
	fstring:SetPoint("TOPLEFT", 15, -15);
	mainframe.name = "MysticTooltips";
	InterfaceOptions_AddCategory(mainframe);

	local namesel = CreateFrame("Button", "MysticTooltipsOptions_DisplayNameSel", MysticTooltipsOptionsFrame, "UIDropDownMenuTemplate");
    namesel:SetPoint("TOPLEFT", MysticTooltipsOptionsFrame, "TOPLEFT", 5, -40);
	namesel.Lable = namesel:CreateFontString(nil , "BORDER", "GameFontNormal");
	namesel.Lable:SetJustifyH("RIGHT");
	namesel:SetWidth(150);
	namesel.Lable:SetPoint("BOTTOMLEFT", namesel, "BOTTOMLEFT", 20, -20);
	namesel.Lable:SetText("Select Display Name For Guild");
end

