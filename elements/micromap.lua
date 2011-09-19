-- Stolen from Tukui, yes again
local C,M,L,V = unpack(select(2,...))
if V.map_bg ~= true then return end

local tinymap = CreateFrame("Frame", "DerpyZoneMap", UIParent)
tinymap:SetSize(227,154)
tinymap:EnableMouse(true)
tinymap:SetMovable(true)
tinymap:RegisterEvent("ADDON_LOADED")
tinymap:SetPoint("CENTER", UIParent, 0, 0)
tinymap:SetFrameLevel(20)
tinymap:Hide()

-- create minimap background
local tinymapbg = CreateFrame("Frame", nil, tinymap)
tinymapbg:SetAllPoints()
tinymapbg:SetFrameLevel(tinymap:GetFrameLevel() - 10)
M.style(tinymapbg,true)
tinymapbg:SetBackdrop(M.bg_edge)
tinymapbg:SetBackdropBorderColor(unpack(M["media"].shadow))
tinymap:SetScript("OnEvent", function(self, event, addon)
	if addon ~= "Blizzard_BattlefieldMinimap" then return end
	
	self:UnregisterEvent("ADDON_LOADED")
	self:SetScript("OnEvent",nil)
	
	BattlefieldMinimap:SetScript("OnShow", function(self)
		tinymap:Show()		
		M.kill(BattlefieldMinimapCorner)
		M.kill(BattlefieldMinimapBackground)
		M.kill(BattlefieldMinimapTab)
		M.kill(BattlefieldMinimapTabLeft)
		M.kill(BattlefieldMinimapTabMiddle)
		M.kill(BattlefieldMinimapTabRight)
		self:SetParent(tinymap)
		self:SetPoint("TOPLEFT", tinymap, "TOPLEFT", 4, -4)
		self:SetFrameStrata(tinymap:GetFrameStrata())
		self:SetFrameLevel(tinymap:GetFrameLevel() + 1)
		BattlefieldMinimapCloseButton:ClearAllPoints()
		BattlefieldMinimapCloseButton:SetPoint("TOPRIGHT", 0, 6)
		BattlefieldMinimapCloseButton:SetFrameLevel(tinymap:GetFrameLevel() + 1)
		tinymap:SetScale(1)
		tinymap:SetAlpha(1)
	end)

	BattlefieldMinimap:SetScript("OnHide", function(self)
		tinymap:SetScale(.000001)
		tinymap:SetAlpha(0)
	end)
	
	local x = CreateFrame("Frame",nil,tinymapbg)
	x:SetFrameLevel(tinymap:GetFrameLevel() + 2)
	local the_X = x:CreateFontString(nil,"OVERLAY")
		the_X:SetFont(M['media'].font_s,18)
		the_X:SetText("X")
		the_X:SetTextColor(1,0,0)
		the_X:SetPoint("CENTER",BattlefieldMinimapCloseButton,2.3,0)

	BattlefieldMinimapCloseButton:HookScript("OnEnter",function() the_X:SetTextColor(1,1,0) end)
	BattlefieldMinimapCloseButton:HookScript("OnLeave",function() the_X:SetTextColor(1,0,0) end)
	BattlefieldMinimapCloseButton:SetAlpha(0)
	BattlefieldMinimapCloseButton.SetAlpha = M.null
	
	self:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" then
			self:StopMovingOrSizing()
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end -- seem to be a bug with default ui in 4.0, we hide it on next click
		elseif btn == "RightButton" then
			ToggleDropDownMenu(1, nil, BattlefieldMinimapTabDropDown, self:GetName(), 0, -4)
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end -- seem to be a bug with default ui in 4.0, we hide it on next click
		end
	end)

	self:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" then
			if BattlefieldMinimapOptions and BattlefieldMinimapOptions.locked then
				return
			else
				self:StartMoving()
			end
		end
	end)
end)