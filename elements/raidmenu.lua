local ns,M,L,V = unpack(select(2,...))
local names = L['raid_primochka']

local raid_or_group = function()
	if UnitInRaid("player") then return "raid" end
	local GetPartyMember = GetPartyMember
	for i = MAX_PARTY_MEMBERS, 1, -1 do
		if GetPartyMember(i) then return "party" end
	end
	return false
end

local destroy_raid = function()
	local GetRaidRosterInfo = GetRaidRosterInfo
	local UninviteUnit = UninviteUnit
	local pName = UnitName("player")
	for i = 1, GetNumRaidMembers() do
		local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
		if online and name ~= pName then
			UninviteUnit(name)
		end
	end
	LeaveParty()
end

local destroy_group = function()
	local UninviteUnit = UninviteUnit
	local GetPartyMember = GetPartyMember
	local UnitName = UnitName
	for i = MAX_PARTY_MEMBERS, 1, -1 do
		if GetPartyMember(i) then UninviteUnit(UnitName("party"..i)) end
	end
	LeaveParty()
end

local bye_bye = function()
	local _type = raid_or_group()
	if not _type then return
	elseif _type == "raid" then destroy_raid()
	elseif _type == "party" then destroy_raid() end
end

StaticPopupDialogs["DERPYDISBANDTWO"] = {
	text = names["sure2"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = bye_bye,
	timeout = 0,
	whileDead = 1,}

StaticPopupDialogs["DERPYDISBANDONE"] = {
	text = names["sure1"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() StaticPopup_Show("DERPYDISBANDTWO") end,
	timeout = 0,
	whileDead = 1,}

local bye = function() 
	if raid_or_group() then
		StaticPopup_Show("DERPYDISBANDONE")
	end
 end
 
SlashCmdList["GROUPDISBAND"] = bye
SLASH_GROUPDISBAND1 = "/rd"
SLASH_GROUPDISBAND2 = "/ро"

local lc = function()
	if raid_or_group() then
		InitiateRolePoll() 
	end
end

SlashCmdList["ROLECHECK"] = lc
SLASH_GROUPDISBAND1 = "/lc"
SLASH_GROUPDISBAND2 = "/дс"
M.addenter(function() end)
local rc = function()
	if raid_or_group() then
		DoReadyCheck() 
	end
end 

SlashCmdList["READYCHECK"] = lc
SLASH_GROUPDISBAND1 = "/rc"
SLASH_GROUPDISBAND2 = "/кс"

ns["topright"].frames[2] = CreateFrame("Frame","DerpyRaidUtility",ns["topright"])
local frame = ns["topright"].frames[2]
frame.name = "UTILITY"
M.make_plav(frame,.2)
frame:SetPoint("RIGHT",-2,0)
frame:SetSize(232,136)
frame:Hide()

local make_button = function(name,template,x,y,point1,point2,unchor,Name,px,py)
	local b = CreateFrame("Button",name,frame,template)
	b:SetSize(x,y)
	b:SetPoint(point1,unchor,point2,px,py)
	b:EnableMouse(true)
	local t = M.setfont(b,12)
	t:SetPoint("CENTER",0,1)
	t:SetText(Name)
	b.Name = t
	return b
end

--Disband Raid 
local DisbandRaidButton = make_button("DerpyRaidUtilityDisbandRaidButton","UIMenuButtonStretchTemplate",200,24,"TOPLEFT","TOPLEFT",frame,names["Disband"],11,-35)
	DisbandRaidButton:SetScript("OnMouseUp",bye)

--Role Check 
local RoleCheckButton = make_button("DerpyRaidUtilityRoleCheckButton","UIMenuButtonStretchTemplate",200,24,"TOPLEFT","BOTTOMLEFT",DisbandRaidButton,names["Role"],0,2)
	RoleCheckButton:SetScript("OnMouseUp",lc)

-- Tank
local MainTankButton = make_button("DerpyRaidUtilityMainTankButton","SecureActionButtonTemplate, UIMenuButtonStretchTemplate",101,24,"TOPLEFT","BOTTOMLEFT",RoleCheckButton,names["Tank"],0,2)
	MainTankButton:SetAttribute("type", "maintank")
	MainTankButton:SetAttribute("unit", "target")
	MainTankButton:SetAttribute("action", "set")
	
--Assist
local MainAssistButton = make_button("DerpyRaidUtilityMainAssistButton","SecureActionButtonTemplate, UIMenuButtonStretchTemplate",101,24,"LEFT","RIGHT",MainTankButton,names["Assist"],-2,0)
	MainAssistButton:SetAttribute("type", "mainassist")
	MainAssistButton:SetAttribute("unit", "target")
	MainAssistButton:SetAttribute("action", "set")
	
--Ready Check
local ReadyCheck = make_button("DerpyRaidUtilityReadyCheckButton","UIMenuButtonStretchTemplate",175,24,"TOPLEFT","BOTTOMLEFT",MainTankButton,names["Ready"],0,2)
	ReadyCheck:SetScript("OnMouseUp",rc)

--Other
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:ClearAllPoints()
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetPoint("LEFT",ReadyCheck,"RIGHT")
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetParent(frame)
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetSize(24,24)

-- Not need
CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:ClearAllPoints()
CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:SetPoint("BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLockedModeToggle, "TOPLEFT", 0, 1)
CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:SetPoint("BOTTOMRIGHT", CompactRaidFrameManagerDisplayFrameHiddenModeToggle, "TOPRIGHT", 0, 1)

CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:ClearAllPoints()
CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:SetPoint("BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "TOPLEFT", 0, 1)
CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:SetPoint("BOTTOMRIGHT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "TOPRIGHT", 0, 1)

do
	local _enter = function(self) self:backcolor(0,.8,.8,.8); if self.Name then self.Name:SetTextColor(0,.8,.8) end end
	local _leave = function(self) self:backcolor(0,0,0); if self.Name then self.Name:SetTextColor(1,1,1) end end
	local _G = _G
	local buttons = {
		"CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton",
		"DerpyRaidUtilityMainTankButton",
		"DerpyRaidUtilityDisbandRaidButton",
		"DerpyRaidUtilityRoleCheckButton",
		"DerpyRaidUtilityMainAssistButton",
		"DerpyRaidUtilityReadyCheckButton",
	}
	for i, button in pairs(buttons) do
		local f = _G[button]
		_G[button.."Left"]:SetAlpha(0)
		_G[button.."Middle"]:SetAlpha(0)
		_G[button.."Right"]:SetAlpha(0)
		f:SetHighlightTexture("")
		f:SetDisabledTexture("")
		f:SetScript("OnEnter",_enter)
		f:SetScript("OnLeave",_leave)
		M.ChangeTemplate(f)
	end
end
