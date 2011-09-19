---- worldmap from tukui
local C,M,L,V = unpack(select(2,...))
if V.map~=true then return end

WORLDMAP_WINDOWED_SIZE = V.map_size_ratio/100

local territory_colors = C.territory_colors
local ft = M["media"].font -- Map font
local fontsize = 22 -- Map Font Size
local _update_coord_savedvars = M.null

local mapbg = M.frame(WorldMapDetailFrame,20,"MEDIUM",true)
mapbg:SetBackdrop(M.bg_edge)
mapbg:SetBackdropBorderColor(unpack(M.media.shadow))
local movebutton = M.frame(mapbg,89,"MEDIUM")

local bt_grad_tex = function(point,r,g,b,a1,a2,xv)
	local x = movebutton:CreateTexture(nil,"OVERLAY")
	x:SetSize(60,16)
	x:SetTexture(M['media'].blank)
	x:SetGradientAlpha("HORIZONTAL",r,g,b,a1,r,g,b,a2)
	x:SetPoint(point,xv,0)
	return x
end

local function mk_texture(point,hook,r,g,b,a1,a2,xv)
	local x = bt_grad_tex(point,r,g,b,a1,a2,xv)
	x:Hide()
	_G[hook]:HookScript("OnEnter",function() x:Show() end)
	_G[hook]:HookScript("OnLeave",function() x:Hide() end)
end

local ll = bt_grad_tex("LEFT",1,.7,.2,.85,0,4)
ll:SetDrawLayer("HIGHLIGHT")

local rr = bt_grad_tex("RIGHT",1,.7,.2,0,.85,-4)
rr:SetDrawLayer("HIGHLIGHT")

local crossholder = CreateFrame("Frame",nil,mapbg)
crossholder:SetSize(40,24)
crossholder:SetPoint("BOTTOMRIGHT",mapbg,"TOPRIGHT",0,-2)

local tobigmap = CreateFrame("Frame",nil,mapbg)
tobigmap:SetSize(40,24)
tobigmap:SetPoint("BOTTOMLEFT",mapbg,"TOPLEFT",0,-2)

movebutton:SetHeight(24)
movebutton:SetPoint("BOTTOMRIGHT",mapbg,"TOPRIGHT",0,-2)
movebutton:SetPoint("BOTTOMLEFT",mapbg,"TOPLEFT",0,-2)
movebutton:EnableMouse(true)

local current_local_name = M.setfont(movebutton,13,nil,nil,"CENTER")
current_local_name:SetPoint("LEFT",6,1)
current_local_name:SetPoint("RIGHT",-7,1)

local zoneupdate = function()
	local text = GetMinimapZoneText()
	local p = GetZoneText()
	if p:match(text) then
		text = ""
	else
		text = ": "..text
	end
	current_local_name:SetText(p..text)
	current_local_name:SetTextColor(unpack(territory_colors[GetZonePVPInfo() or "none"]))
end

movebutton:RegisterEvent("PLAYER_ENTERING_WORLD")
movebutton:RegisterEvent("ZONE_CHANGED_NEW_AREA")
movebutton:RegisterEvent("ZONE_CHANGED")
movebutton:RegisterEvent("ZONE_CHANGED_INDOORS")
movebutton:SetScript("OnEvent",zoneupdate)

local mk_swich_bt = function(frame)
	local bt = CreateFrame("Frame",nil,frame)
	bt:SetFrameLevel(frame:GetFrameLevel()+4)
	bt:SetSize(40,12)
	bt:SetBackdrop(M.bg)
	bt:SetPoint("RIGHT",-6,0)
	bt:EnableMouse(true)
	frame.bt = bt
end

--Coordinates^
local coord_frame = CreateFrame("Frame",nil,mapbg)
coord_frame:SetFrameStrata("HIGH")

-- The strings
local mk_str = function(r,g,b,strata,t1,t2,x1,y1,x2,y2)
	local t = coord_frame:CreateTexture(nil,strata)
	t:SetSize(1,1)
	t:SetTexture(r,g,b,1)
	local text1 = M.setfont(coord_frame,12)
	text1:SetPoint(t1,t,x1,y1)
	text1:SetTextColor(r,g,b)
	local text2 = M.setfont(coord_frame,12,nil,nil,"RIGHT")
	text2:SetPoint(t2,t,x2,y2)
	text2:SetTextColor(r,g,b)
	t:Hide(); text1:Hide(); text2:Hide();
	return t,text1,text2
end

local y_pl,y_pl_t1,y_pl_t2 = mk_str(.2,1,1,"ARTWORK","BOTTOMLEFT","TOPRIGHT",2,3,-1,0)
local x_pl,x_pl_t1,x_pl_t2 = mk_str(.2,1,1,"ARTWORK","TOPLEFT","BOTTOMRIGHT",2,1,-2,3)
local y_cur,y_cur_t1,y_cur_t2 = mk_str(1,1,1,"OVERLAY","BOTTOMLEFT","TOPRIGHT",2,3,-1,0)
local x_cur,x_cur_t1,x_cur_t2 = mk_str(1,1,1,"OVERLAY","TOPLEFT","BOTTOMRIGHT",2,1,-2,3)

--buttons
local st_colors = {{1,.1,.1,.9},{0,.8,.8,.9}}
local _Color = function(self)
	if self._bool then
		self:SetBackdropColor(unpack(st_colors[2]))
		self:SetBackdropBorderColor(unpack(st_colors[2]))
	else
		self:SetBackdropColor(unpack(st_colors[1]))
		self:SetBackdropBorderColor(unpack(st_colors[1]))
	end
end

local press = function(self)
	self._bool = self._Update()
	_Color(self)
end

local bottom_tab = {}
do
	local nl = {
		function() return WatchFrame.showObjectives end,
		function() return GetCVarBool("digSites") end,
		function() return V.map_show_coord end,
		function() return V.map_show_coord_mouse end}
	local tl = {
	function(self)
		if WatchFrame.showObjectives == true then
			WatchFrame.showObjectives = nil
			WorldMapQuestShowObjectives:SetChecked(false)
			WorldMapBlobFrame:Hide()
			WorldMapPOIFrame:Hide()
		else
			WatchFrame.showObjectives = true
			WorldMapQuestShowObjectives:SetChecked(true)
			WorldMapBlobFrame:Show()
			WorldMapPOIFrame:Show()
		end
		WatchFrame_Update()
		return WatchFrame.showObjectives
	end,
	function(self)
		local x
		if GetCVarBool("digSites") then
			x = nil
			WorldMapShowDigSites:SetChecked(false)
			WorldMapArchaeologyDigSites:Hide()
		else
			x = true
			WorldMapShowDigSites:SetChecked(true)
			WorldMapArchaeologyDigSites:Show()
		end
		SetCVar("digSites",x and "1" or nil)
		SetMapToCurrentZone()
		return x
	end,
	function(self)
		if V.map_show_coord == true then
			V.map_show_coord = false
			y_pl:Hide(); y_pl_t1:Hide(); y_pl_t2:Hide();
			x_pl:Hide(); x_pl_t1:Hide(); x_pl_t2:Hide();
		else
			V.map_show_coord = true
		end
		_update_coord_savedvars()
		return V.map_show_coord
	end,
	function(self)
		if V.map_show_coord_mouse == true then
			V.map_show_coord_mouse = false
			y_cur:Hide(); y_cur_t1:Hide(); y_cur_t2:Hide();
			x_cur:Hide(); x_cur_t1:Hide(); x_cur_t2:Hide();
		else
			V.map_show_coord_mouse = true
		end
		_update_coord_savedvars()
		return V.map_show_coord_mouse
	end}
	for i=1,4 do
		local f = M.frame(mapbg,24,"MEDIUM")
		f:SetHeight(21)
		if i == 1 then
			f:SetPoint("TOPLEFT",mapbg,"BOTTOMLEFT",0,2)
		elseif i == 4 then
			f:SetPoint("TOPRIGHT",mapbg,"BOTTOMRIGHT",0,2)
		elseif i == 2 then
			f:SetPoint("TOPRIGHT",mapbg,"BOTTOM",2,2)
			f:SetPoint("LEFT",bottom_tab[i-1],"RIGHT",-2,0)
		elseif i == 3 then
			f:SetPoint("TOPLEFT",mapbg,"BOTTOM",0,2)
		end
		mk_swich_bt(f)
		f.bt.nl = nl[i]
		f.bt:SetScript("OnMouseDown",press)
		f.bt:SetScript("OnShow",function(self)
			self._bool = self.nl()
			_Color(self)
		end)
		local text = M.setfont(f,12)
		text:SetPoint("LEFT",7,1)
		text:SetPoint("RIGHT",-48,1)
		f.text = text
		bottom_tab[i] = f
	end
	M.addafter(function()
		mk_texture('RIGHT',"WorldMapFrameCloseButton",1,0,0,0,.85,-4)
		mk_texture('LEFT',"WorldMapFrameSizeUpButton",0,.9,1,.85,0,4)
		for i=1,4 do
			local f = bottom_tab[i].bt
			f._Update = tl[i]
			if i == 1 then 
				f._bool = WatchFrame.showObjectives
			else
				f._bool = nl[i]()
			end
			_Color(f)
		end
	end)
end

movebutton:SetScript("OnMouseDown", function()
	local maplock = GetCVar("advancedWorldMap")
	if maplock ~= "1" or InCombatLockdown() then return end
	WorldMapScreenAnchor:ClearAllPoints()
	WorldMapFrame:ClearAllPoints()
	WorldMapFrame:StartMoving()
	WorldMapBlobFrame:Hide()
	coord_frame:Hide()
end)

movebutton:SetScript("OnMouseUp", function()
	local maplock = GetCVar("advancedWorldMap")
	if maplock ~= "1" or InCombatLockdown() then return end
	WorldMapFrame:StopMovingOrSizing()
	WorldMapScreenAnchor:StartMoving()
	WorldMapScreenAnchor:SetPoint("TOPLEFT", WorldMapFrame)
	WorldMapScreenAnchor:StopMovingOrSizing()
	WorldMapBlobFrame:Show()
	WorldMapFrame_DisplayQuests()
	coord_frame:Show()
end)

-- look if map is not locked
local MoveMap = GetCVarBool("advancedWorldMap")
if MoveMap == nil then
	SetCVar("advancedWorldMap", 1)
end

local style_AreaFrame = function(x,y)
	WorldMapFrameAreaFrame:SetFrameStrata("DIALOG")
	WorldMapFrameAreaFrame:SetFrameLevel(20)
	WorldMapFrameAreaLabel:SetFont(ft, fontsize*3)
	WorldMapFrameAreaLabel:SetShadowOffset(x,y)
	WorldMapFrameAreaLabel:SetTextColor(1, 1, 1)
end

local SmallerMapSkin = function()
	-- don't need this
	M.kill(WorldMapTrackQuest)
	
	if not mapbg.fixed then
		mapbg:SetPoint("TOPLEFT", WorldMapDetailFrame, -4, 4)
		mapbg:SetPoint("BOTTOMRIGHT", WorldMapDetailFrame, 4, -4)
		mapbg:SetScale(1/mapbg:GetParent():GetScale())
		local x = floor(mapbg:GetWidth()/4)
		bottom_tab[4]:SetWidth(x+3)
		bottom_tab[1]:SetWidth(x+3)
		bottom_tab[3]:SetPoint("RIGHT",bottom_tab[4],"LEFT",2,0)
		bottom_tab[2].text:SetText(WorldMapShowDigSitesText:GetText())
		bottom_tab[1].text:SetText(WorldMapQuestShowObjectivesText:GetText())
		bottom_tab[3].text:SetText(L['map'].coord..GetUnitName("player"))
		bottom_tab[4].text:SetText(L['map'].coord..L['map'].cursor)
		mapbg.fixed = true
	end
	
	-- map border and bg
	mapbg:Show()
	-- move buttons / texts and hide default border
	WorldMapButton:SetAllPoints(WorldMapDetailFrame)
	WorldMapFrame:SetFrameStrata("MEDIUM")
	WorldMapFrame:SetClampedToScreen(true) 
	WorldMapDetailFrame:SetFrameStrata("MEDIUM")
	WorldMapTitleButton:Show()	
	WorldMapFrameMiniBorderLeft:Hide()
	WorldMapFrameMiniBorderRight:Hide()
	WorldMapFrameSizeUpButton:Show()
	WorldMapFrameSizeUpButton:ClearAllPoints()
	WorldMapFrameSizeUpButton:SetFrameLevel(92)
	WorldMapFrameSizeUpButton:SetFrameStrata('HIGH')
	WorldMapFrameSizeUpButton:SetAlpha(0)
	WorldMapFrameSizeUpButton:SetAllPoints(tobigmap)
	WorldMapFrameCloseButton:ClearAllPoints()
	WorldMapFrameCloseButton:SetAllPoints(crossholder)
	WorldMapFrameCloseButton:SetFrameLevel(92)
	WorldMapFrameCloseButton:SetFrameStrata('HIGH')
	WorldMapFrameCloseButton:SetAlpha(0)
	WorldMapFrameTitle:Hide()	
	WorldMapTitleButton:SetFrameStrata("MEDIUM")
	WorldMapTooltip:SetFrameStrata("TOOLTIP")
	WorldMapShowDigSites:SetScale(0.000001)
	WorldMapShowDigSites:SetAlpha(0)
	WorldMapQuestShowObjectives:Hide()
	WorldMapTitleButton:EnableMouse(false)
	style_AreaFrame(4,-4)
	
	-- 3.3.3, hide the dropdown added into this patch
	WorldMapLevelDropDown:SetAlpha(0)
	WorldMapLevelDropDown:SetScale(0.00001)

	-- fix tooltip not hidding after leaving quest # tracker icon
	hooksecurefunc("WorldMapQuestPOI_OnLeave", function() WorldMapTooltip:Hide() end)
end
hooksecurefunc("WorldMap_ToggleSizeDown",SmallerMapSkin)

local BiggerMapSkin = function()
	-- 3.3.3, show the dropdown added into this patch
	WorldMapLevelDropDown:SetAlpha(1)
	WorldMapLevelDropDown:SetScale(1)
	WorldMapShowDigSites:SetScale(1)
	WorldMapShowDigSites:SetAlpha(1)
	WorldMapFrameCloseButton:SetAlpha(1)
	WorldMapFrameTitle:Show()
	mapbg:Hide()
	WorldMapQuestShowObjectives:Show()
	style_AreaFrame(2,-2)
	WorldMapFrameCloseButton:ClearAllPoints()
	WorldMapFrameCloseButton:SetPoint("TOPLEFT",WorldMapFrameSizeDownButton,"TOPRIGHT",-12,0)
end
hooksecurefunc("WorldMap_ToggleSizeUp",BiggerMapSkin)

mapbg:SetScript("OnShow", function(self)
	local SmallerMap = GetCVarBool("miniWorldMap")
	if SmallerMap == nil then
		self:Hide()
		style_AreaFrame(2,-2)
	else
		SmallerMapSkin()
	end
	self:SetScript("OnShow",nil)
end)

local temp_obj
local addon = CreateFrame('Frame')
addon:RegisterEvent("PLAYER_REGEN_ENABLED")
addon:RegisterEvent("PLAYER_REGEN_DISABLED")
addon:SetScript("OnEvent", function(self, event)
		--ShowUIPanel(WorldMapFrame)
		--HideUIPanel(WorldMapFrame)
	if event == "PLAYER_REGEN_DISABLED" then
		WorldMapFrameSizeDownButton:Disable() 
		WorldMapFrameSizeUpButton:Disable()
		HideUIPanel(WorldMapFrame)
		temp_obj = WatchFrame.showObjectives
		WatchFrame.showObjectives = nil
		WorldMapQuestShowObjectives:SetChecked(false)
		WorldMapQuestShowObjectives:Hide()
		WorldMapTitleButton:Hide()
		WorldMapBlobFrame:Hide()
		WorldMapPOIFrame:Hide()

		WorldMapQuestShowObjectives.Show = M.Null
		WorldMapTitleButton.Show = M.Null
		WorldMapBlobFrame.Show = M.Null
		WorldMapPOIFrame.Show = M.Null      

		WatchFrame_Update()
	elseif event == "PLAYER_REGEN_ENABLED" then
		WorldMapFrameSizeDownButton:Enable()
		WorldMapFrameSizeUpButton:Enable()
		WorldMapQuestShowObjectives.Show = WorldMapQuestShowObjectives:Show()
		WorldMapTitleButton.Show = WorldMapTitleButton:Show()
		WorldMapBlobFrame.Show = WorldMapBlobFrame:Show()
		WorldMapPOIFrame.Show = WorldMapPOIFrame:Show()

		local SmallerMap = GetCVarBool("miniWorldMap")
		if not SmallerMap then
			WorldMapQuestShowObjectives:Show()
		else
			WorldMapQuestShowObjectives:Hide()
		end
		WorldMapTitleButton:Show()
		
		WatchFrame.showObjectives = temp_obj
		WorldMapQuestShowObjectives:SetChecked(temp_obj or false)

		WorldMapBlobFrame:Show()
		WorldMapPOIFrame:Show()

		for i=1,2 do
			local x = bottom_tab[i].bt
			x._bool = x.nl()
			_Color(x)
		end
		
		WatchFrame_Update()
	end
end)

-- MapFrame@ -- main unk for dis stuff
do
	-- Get Mouse Pos
	local MapFrame = WorldMapDetailFrame;
	local GetCursorPosition = GetCursorPosition;
	local left,top,width,height,scale,_scale = 0,0,0,0,0,0
	local y_cur,x_cur,y_cur_t1,x_cur_t1,y_cur_t2,x_cur_t2 = y_cur,x_cur,y_cur_t1,x_cur_t1,y_cur_t2,x_cur_t2
	local y_pl,y_pl_t1,x_pl_t1,x_pl,y_pl_t2,x_pl_t2 = y_pl,y_pl_t1,x_pl_t1,x_pl,y_pl_t2,x_pl_t2
	local flo = math.floor
	local show_player_coord,show_cursor_coord
	local GetPlayerMapPosition = GetPlayerMapPosition;
	local the_n = 0
	
	local _update_coord_vars = function()
		_scale = M.scale
		scale = MapFrame:GetEffectiveScale()/_scale
		left = MapFrame:GetLeft()*scale
		top = MapFrame:GetTop()*scale
		width = MapFrame:GetWidth()*scale
		height = MapFrame:GetHeight()*scale
	end
	M.addafter(_update_coord_vars)
	coord_frame:SetScript("OnShow",function() _update_coord_vars() the_n = 0 end)
	
	_update_coord_savedvars = function()
		show_player_coord = V.map_show_coord
		show_cursor_coord = V.map_show_coord_mouse
	end
	_update_coord_savedvars()
	
	-- get x,y on MapFrame@
	local _XY_cur = function(x,y,player)
		local cx,cy
		if player then
			if not x then return end
			cx = width*x
			cy = height *y
		else
			x = x/_scale
			y = y/_scale
			cx = (x - left)
			cy = (top - y)
		end
		if cx < 0 or cx > width or cy < 0 or cy > height then
			return
		else
			return cx, cy
		end
	end

	-- For cursor
	local _update_cursor = function()
		local x,y = _XY_cur(GetCursorPosition())
		
		if not x then
			if y_cur:IsShown() then
				y_cur:Hide(); y_cur_t1:Hide(); x_cur_t1:Hide();
				x_cur:Hide(); y_cur_t2:Hide(); x_cur_t2:Hide(); 
			end
			return
		end
		if not y_cur:IsShown() then
			y_cur:Show(); y_cur_t1:Show(); x_cur_t1:Show();
			x_cur:Show(); y_cur_t2:Show(); x_cur_t2:Show();
		end
		y_cur:SetPoint("TOPLEFT",MapFrame,"TOPLEFT",0,-y)
		y_cur:SetPoint("TOPRIGHT",MapFrame,"TOPRIGHT",0,-y)
		x_cur:SetPoint("TOPLEFT",MapFrame,"TOPLEFT",x,0)
		x_cur:SetPoint("BOTTOMLEFT",MapFrame,"BOTTOMLEFT",x,0)
		local tx,ty = flo(x/width*100),flo(y/height*100)
		y_cur_t1:SetText(ty)
		y_cur_t2:SetText(ty)
		x_cur_t1:SetText(tx)
		x_cur_t2:SetText(tx)
	end

	-- For Player
	local _update_player = function()
		local x,y = GetPlayerMapPosition("player")
		x = x or 0; y = y or 0;
		
		if x == 0 and y == 0 then 
			if y_pl:IsShown() then
				y_pl:Hide(); y_pl_t1:Hide(); x_pl_t1:Hide();
				x_pl:Hide(); y_pl_t2:Hide(); x_pl_t2:Hide(); 
			end
			return
		end
		if not y_pl:IsShown() then
			y_pl:Show(); y_pl_t1:Show(); x_pl_t1:Show();
			x_pl:Show(); y_pl_t2:Show(); x_pl_t2:Show();
		end
		x,y = _XY_cur(x,y,true)
		x = flo(x); y = flo(y)
		y_pl:SetPoint("TOPLEFT",MapFrame,"TOPLEFT",0,-y)
		y_pl:SetPoint("TOPRIGHT",MapFrame,"TOPRIGHT",0,-y)
		x_pl:SetPoint("TOPLEFT",MapFrame,"TOPLEFT",x,0)
		x_pl:SetPoint("BOTTOMLEFT",MapFrame,"BOTTOMLEFT",x,0)
		local tx,ty = flo(x/width*100),flo(y/height*100)
		y_pl_t1:SetText(ty)
		y_pl_t2:SetText(ty)
		x_pl_t1:SetText(tx)
		x_pl_t2:SetText(tx)
	end
		
	-- update
	coord_frame:SetScript("OnUpdate",function(self,t)
		the_n = the_n - t
		if show_cursor_coord then _update_cursor() end
		if the_n > 0 then return end
		if show_player_coord then _update_player() end
		the_n = .2
	end)
	
end