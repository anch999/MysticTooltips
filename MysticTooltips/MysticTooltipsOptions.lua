function SpecMenuOptions_Toggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide();
	else
		InterfaceOptionsFrame_OpenToCategory("SpecMenu");
	end
end

local function SpecMenuOptions_QuickSwap2_OnClick()
	local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, thisID);
	SpecMenu_QuickswapNum2 = thisID;
	SpecMenuDB["Specs"][SpMenuSpecNum][3] = SpecMenu_QuickswapNum2;
end

function SpecMenuOptions_QuickSwap2_Initialize()
	--Loads the spec list into the quickswap2 dropdown menu
	local info;
	for k,v in pairs(SpecMenuDB["Specs"]) do
		info = {
			text = SpecMenuDB["Specs"][k][1];
			func = SpecMenuOptions_QuickSwap2_OnClick;
		};
			UIDropDownMenu_AddButton(info);
			lastSpecPos = k + 1
	end
	--Adds Lastspec as the last entry on the quickswap2 dropdown menu 
	info = {
		text = specmenu_options_swap;
		func = SpecMenuOptions_QuickSwapLastSpec_OnClick;
	};
		UIDropDownMenu_AddButton(info);
		quickSwapNum = "2"

end

local function SpecMenu_DropDownInitialize()
	--Setup for Dropdown menus in the settings
	UIDropDownMenu_Initialize(SpecMenuOptions_QuickSwap2, SpecMenuOptions_QuickSwap2_Initialize);
	UIDropDownMenu_SetWidth(SpecMenuOptions_QuickSwap2, 150);
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, SpecMenuDB["Specs"][menuID][3]);
	UIDropDownMenu_SetText(SpecMenuOptions_QuickSwap2, SpecMenuDB["Specs"][SpecMenuDB["Specs"][menuID][3]][1]);
end

--Creates the options frame and all its assets
function SpecMenuOptions_CreateFrame()
	local mainframe = CreateFrame("FRAME", "SpecMenuOptionsFrame", InterfaceOptionsFrame, nil);
    local fstring = mainframe:CreateFontString(mainframe, "OVERLAY", "GameFontNormal");
	fstring:SetText("Spec Menu Settings");
	fstring:SetPoint("TOPLEFT", 15, -15)
	mainframe.name = "SpecMenu";
	InterfaceOptions_AddCategory(mainframe);

	local quickswap2 = CreateFrame("Button", "SpecMenuOptions_QuickSwap2", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    quickswap2:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 190, -89);
	quickswap2.Lable = quickswap2:CreateFontString(nil , "BORDER", "GameFontNormal")
	quickswap2.Lable:SetJustifyH("RIGHT")
	quickswap2.Lable:SetPoint("BOTTOMLEFT", quickswap2, "BOTTOMLEFT", 20, -20)
	quickswap2.Lable:SetText("QuickSwap Right Click")

	SpecMenu_DropDownInitialize();
end

