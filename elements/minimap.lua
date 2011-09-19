local C,M,L,V = unpack(select(2,...))
local Minimap = Minimap
local on_update = M.simple_move

local mP = M.frame(Minimap,4,"BACKGROUND")
	mP:SetPoint("TOPRIGHT",4,-1)
	mP:SetPoint("BOTTOMLEFT",-4,1)
	mP:SetBackdrop(nil)
	mP.bg:SetTexture(1,1,1,1)
	mP.bg:SetGradientAlpha("VERTICAL",.5,.5,.5,0,0,0,0,.6)
	mP.bg:SetBlendMode("BLEND")

C.Minimap_bg = M.frame(Minimap,2,"BACKGROUND",true)	
local Nav_Backdrop = C.Minimap_bg
	Nav_Backdrop:SetPoint("TOP",mP)
	Nav_Backdrop:SetPoint("BOTTOM",mP)
	Nav_Backdrop:SetWidth(180)
	Nav_Backdrop:SetBackdropColor(.15,.15,.15,.75)
	
C.Minimap_left = M.frame(Nav_Backdrop,7,"BACKGROUND")
local Left_Nav = C.Minimap_left
	Left_Nav:SetSize(23,138)
	Left_Nav:SetBackdropBorderColor(.1,.1,.1,.1)
	Left_Nav.bg:SetGradientAlpha("HORIZONTAL",.26,.26,.26,.15,.2,.2,.2,.6)
	Left_Nav.point_1 = "LEFT"
	Left_Nav.point_2 = "LEFT"
	Left_Nav.pos = 0
	Left_Nav.hor = true
	Left_Nav.parent = Nav_Backdrop

C.Minimap_right = M.frame(Nav_Backdrop,7,"BACKGROUND")
local Right_Nav = C.Minimap_right
	Right_Nav:SetPoint("RIGHT")
	Right_Nav:SetSize(23,138)
	Right_Nav:SetBackdropBorderColor(.1,.1,.1,.1)
	Right_Nav.bg:SetGradientAlpha("HORIZONTAL",.2,.2,.2,.6,.26,.26,.26,.15)
	Right_Nav.point_1 = "RIGHT"
	Right_Nav.point_2 = "RIGHT"
	Right_Nav.pos = 0
	Right_Nav.hor = true
	Right_Nav.parent = Nav_Backdrop
	
	Left_Nav.start_go_left = function(self)
		self:SetScript("OnUpdate",nil)
		self.mod = -1
		self.limit = -9
		self.speed = -22
		self:SetScript("OnUpdate",on_update)
	end
	
	Left_Nav.start_go_back = function(self)
		self:SetScript("OnUpdate",nil)
		self.mod = 1
		self.limit = 0
		self.speed = 22
		self:SetScript("OnUpdate",on_update)
	end
	

local CombatFrame = CreateFrame("Frame",nil,Minimap)
	CombatFrame:SetFrameLevel(12)
	CombatFrame:Hide()
	CombatFrame:SetScript("OnUpdate", FadingFrame_OnUpdate)
	CombatFrame.fadeInTime = .3
	CombatFrame.fadeOutTime = .5
	CombatFrame.holdTime = .2
	
local a = CombatFrame:CreateTexture(nil,"OVERLAY")
	a:SetPoint("TOPLEFT",Left_Nav,4,-4)
	a:SetPoint("BOTTOMRIGHT",Left_Nav,-4,4)
	a:SetTexture(M.media.blank)
	a:SetGradientAlpha("HORIZONTAL",1,.1,.1,0,1,.1,.1,.5)
	
local a = CombatFrame:CreateTexture(nil,"OVERLAY")
	a:SetPoint("TOPLEFT",Right_Nav,4,-4)
	a:SetPoint("BOTTOMRIGHT",Right_Nav,-4,4)
	a:SetTexture(M.media.blank)
	a:SetGradientAlpha("HORIZONTAL",1,.1,.1,.5,1,.1,.1,0)

	M.addcombat(function() _G.FadingFrame_Show(CombatFrame) end,"DerpyMinimapCombat","in")
	
	Minimap:SetScale(1)
	Minimap:SetFrameStrata("BACKGROUND")
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", -22,0)	
	Minimap:SetFrameLevel(3)
	Minimap:SetMaskTexture(M.media.path.."minimapmask.tga")
	MinimapBorder:Hide()
	MinimapBorderTop:Hide()
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	MiniMapVoiceChatFrame:Hide()
	GameTimeFrame:Hide()
	MinimapNorthTag:SetTexture(nil)
	MinimapZoneTextButton:Hide()
	MiniMapTracking:Hide()
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("TOPRIGHT", mP, -1, 0)
	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture(M.media.path.."mail.tga")
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("BOTTOMRIGHT", mP, -1, 4)
	MiniMapWorldMapButton:Hide()
	MiniMapInstanceDifficulty:ClearAllPoints()
	MiniMapInstanceDifficulty:SetParent(Minimap)
	MiniMapInstanceDifficulty:SetPoint("TOPLEFT", mP, "TOPLEFT", 4, -4)
	GuildInstanceDifficulty:ClearAllPoints()
	GuildInstanceDifficulty:SetParent(Minimap)
	GuildInstanceDifficulty:SetPoint("TOPLEFT", mP, "TOPLEFT", 4, -4)
	MiniMapLFGFrameBorder:Hide()
	MiniMapBattlefieldBorder:Hide()
	StreamingIcon:SetParent(Minimap)
	StreamingIcon:ClearAllPoints()
	StreamingIcon:SetPoint("BOTTOMLEFT",mP,-2,-3)
	StreamingIcon.SetPoint = M.null
	StreamingIcon:EnableMouse(false)

local function UpdateLFG()
	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:SetPoint("BOTTOMRIGHT", mP, "BOTTOMRIGHT", -1, 4)
end
hooksecurefunc("MiniMapLFG_UpdateIsShown", UpdateLFG)

Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end)

Minimap:SetScript("OnMouseUp", function(self, btn)
	if btn == "RightButton" then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self)
	else
		Minimap_OnClick(self)
	end
end)

function _G.GetMinimapShape() return 'SQUARE' end

local m_zone = M.frame(UIParent,5,"LOW")
	m_zone:SetPoint("TOP",mP,"TOP",0,36)
	m_zone:SetSize(floor(Minimap:GetWidth()+.5),20)
	m_zone.point_1 = "TOP"
	m_zone.point_2 = "TOP"
	m_zone.pos = 36
	m_zone.parent = mP
	
	m_zone.start_go_up = function(self)
		self.mod = 1
		self.limit = 36
		self.speed = 180
		self:SetScript("OnUpdate",on_update)
	end
	
	m_zone.start_go_down = function(self)
		self.mod = -1
		self.limit = -4
		self.speed = -180
		self:SetScript("OnUpdate",on_update)
	end
	
local m_zone_text = M.setfont(m_zone,13,nil,nil,"CENTER")
	m_zone_text:SetPoint("TOPLEFT",6,0)
	m_zone_text:SetPoint("BOTTOMRIGHT",-5,0)
	
local m_coord = M.frame(UIParent,5,"LOW")
	m_coord:SetSize(46,20)
	m_coord:SetPoint("BOTTOMLEFT",mP,201,4)
	m_coord.point_1 = "BOTTOMLEFT"
	m_coord.point_2 = "BOTTOMLEFT"
	m_coord.pos = 201
	m_coord.alt = 4
	m_coord.hor = true
	m_coord.parent = mP
	m_coord:Hide()
	
	m_coord.start_go_up = function(self)
		self.mod = 1
		self.limit = 201
		self.speed = 922,5
		self.finish_hide = true
		self:SetScript("OnUpdate",on_update)
		self:Show()
	end
	
	m_coord.start_go_down = function(self)
		self.mod = -1
		self.limit = 4
		self.speed = -922,5
		self.finish_hide = nil
		self:SetScript("OnUpdate",on_update)
		self:Show()
	end
	
local m_coord_text = M.setfont(m_coord,13,nil,nil,"CENTER")
	m_coord_text:SetPoint("TOPLEFT",2,0)
	m_coord_text:SetPoint("BOTTOMRIGHT",-1,0)
	
Minimap:SetScript("OnEnter",function()
	m_coord:start_go_down()
	m_zone:start_go_down()
end)

Minimap:SetScript("OnLeave",function()
	m_coord:start_go_up()
	m_zone:start_go_up()
end)

m_coord_text:SetText("Error")

local ela = 0
local abc = CreateFrame("Frame",nil,m_coord)
local coord_Update = function(self,t)
	ela = ela - t
	if ela > 0 then return end
	local x,y = GetPlayerMapPosition("player")
	local xt,yt
	x = math.floor(100 * x)
	y = math.floor(100 * y)
	if x == 0 and y == 0 then
		m_coord_text:SetText("X _ X")
	else
		if x < 10 then 
			xt = "0"..x
		else 
			xt = x 
		end
		if y < 10 then 
			yt = "0"..y 
		else 
			yt = y 
		end
		m_coord_text:SetText(xt..","..yt)
	end
	ela = .2
end
abc:SetScript("OnUpdate",coord_Update)

do
	local zone_show_enable = V.zone_change
	local territory_colors = C.territory_colors
	local GetZoneText = GetZoneText
	local GetMinimapZoneText = GetMinimapZoneText
	local GetZonePVPInfo = GetZonePVPInfo
	local zone_Update = function()
		local text = GetMinimapZoneText()
		local r,g,b = unpack(territory_colors[GetZonePVPInfo() or "none"])
		m_zone_text:SetText(text)
		m_zone_text:SetTextColor(r,g,b)	
		if not(zone_show_enable) then return end
		local p = GetZoneText()
		if p:match(text) then
			text = ""
		else
			text = ": "..text
		end
		M.sl_run(p..text,r,g,b)
	end
	M.addafter(zone_Update)
	m_zone:SetScript("OnEvent",zone_Update) 
end
m_zone:RegisterEvent("PLAYER_ENTERING_WORLD")
m_zone:RegisterEvent("ZONE_CHANGED_NEW_AREA")
m_zone:RegisterEvent("ZONE_CHANGED")
m_zone:RegisterEvent("ZONE_CHANGED_INDOORS")

M.addenter(function()
	M.kill(TimeManagerClockButton)
end)

if V.zone_change then
	M.kill(ZoneTextFrame)
	M.kill(SubZoneTextFrame)
end