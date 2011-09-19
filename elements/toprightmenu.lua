local ns,M,L,V = unpack(select(2,...)) 
ns["topright"] = M.frame(UIParent,1,"BACKGROUND")
local menu = ns["topright"]
local btns = {}
local UIFrameFadeOut = UIFrameFadeOut
local UIFrameFadeIn = UIFrameFadeIn
MinimapCluster:EnableMouse(false)
local SAVED = V.rightmenu
local LEFT_BAR = ns.Minimap_left

if DerpyBuffsUnchor then
	DerpyBuffsUnchor:SetPoint("LEFT",menu,0,0)
end

menu:SetPoint("RIGHT",Minimap,"LEFT",-12,0)
menu.frames = {}

local MAX_POS = 235
local menu_update = M.simple_width
local finish_alt = function(self)
	self:register_combat()
	if not DerpyBuffsUnchor then return end
	DerpyBuffsUnchor:SetPoint("LEFT",LEFT_BAR,2,0)
end

menu.go_go_then = function(self)
	self:SetScript("OnUpdate",menu_update)
end

menu.show = function(self)
	if self.wpos == MAX_POS then return end
	self:register_combat()
	SAVED.shown = true
	self.wspeed = MAX_POS
	self.wmod = 1
	self.wlimit = MAX_POS
	self.wfinish_hide = nil
	self.finish_function = self._finish
	self:go_go_then()
	self:Show()
	self.unit_name:SetText("OPENING")
	UIFrameFadeIn(self,.6,0,1)
	LEFT_BAR:start_go_left()
	if not DerpyBuffsUnchor then return end
	DerpyBuffsUnchor:SetPoint("LEFT",self,0,0)
end

menu.hide = function(self)
	if self.wpos == 6 then return end
	SAVED.shown = false
	self.wspeed = -200
	self.wmod = -1
	self.wlimit = 6
	self.wfinish_hide = true
	self.finish_function = finish_alt
	self:go_go_then()
	self.frames[SAVED.current]:Hide()
	self:Show()
	self.unit_name:SetText("CLOSING")
	UIFrameFadeOut(self,.6,1,0)
	UIFrameFadeOut(btns[1],.15,1,0)
	UIFrameFadeOut(btns[2],.3,1,0)
	LEFT_BAR:start_go_back()
end

local teh_showbutton = CreateFrame("Frame",nil,LEFT_BAR)
	teh_showbutton:SetFrameLevel(10)
	teh_showbutton:SetFrameStrata("BACKGROUND")
	teh_showbutton:SetAllPoints()
	teh_showbutton:SetAlpha(0)
	teh_showbutton:SetPoint("LEFT",Minimap,-11,0)
	teh_showbutton:SetScript("OnMouseDown", function(self) self:EnableMouse(false); menu:show() end)
	menu:SetScript("OnHide",function() teh_showbutton:EnableMouse(true) end)
	
	
local teh_closebutton = CreateFrame("Frame",nil,LEFT_BAR)
	teh_closebutton:SetFrameLevel(10)
	teh_closebutton:SetFrameStrata("BACKGROUND")
	teh_closebutton:SetAllPoints()
	teh_closebutton:SetPoint("CENTER",menu,"LEFT",4,0)
	teh_closebutton:SetScript("OnMouseDown", function(self) self:EnableMouse(false); menu:hide(); end)

local shown_switch = function()
	if menu:IsShown() then
		teh_closebutton:EnableMouse(true)
		teh_showbutton:EnableMouse(false)
	else
		teh_showbutton:EnableMouse(true)
		teh_closebutton:EnableMouse(false)
	end
end

M.addcombat(shown_switch,"DerpyToprightShownSwitch","out")
M.addcombat(function() 
	teh_showbutton:EnableMouse(false)
	teh_closebutton:EnableMouse(false)
end,"DerpyToprightShownSwitch","in")
	
local unit_name = M.setfont(menu,22,nil,nil,"RIGHT")
unit_name:SetPoint("TOPRIGHT",-21.5,-9)
menu.unit_name = unit_name

menu.set_unit = function(self)
	if self.curent_unit then
		self.curent_unit:Hide()
	end
	self.curent_unit = self.frames[SAVED.current]
end

menu.show_unit = function(self)
	self.curent_unit:show()
	self.unit_name:SetText(self.curent_unit.name)
end

menu.InCombatLockdown = InCombatLockdown

menu.__SetWidth = menu.SetWidth
menu.SetWidth = function(self,x)
	if self.InCombatLockdown() then
		self.exam = self.go_go_then
		self:SetScript("OnUpdate",nil)
		self.unit_name:SetText("OH SHI~!")
		self.unit_name:SetTextColor(1,0,0)
		return
	end
	menu:__SetWidth(x)
end

menu._finish = function(self)
	if self.InCombatLockdown() then
		self.exam = self._finish
		self.unit_name:SetText("OH SHI~!")
		self.unit_name:SetTextColor(1,0,0)
		return
	end
	teh_closebutton:EnableMouse(true)
	self:show_unit()
	UIFrameFadeIn(btns[1],.2,0,1)
	UIFrameFadeIn(btns[2],.4,0,1)
end

menu.__hide = menu.Hide
menu.Hide = function(self)
	if self.InCombatLockdown() then
		self.exam = self.Hide
		return
	end
	self:__hide()
end

M.addenter(function()
	menu:set_unit()
	if menu:IsShown() then
		menu:show_unit()
	end
end)

local cur = SAVED.current
local color = M.media.button

local re_show = function(self)
	for i = 1,2 do
		btns[i]:SetBackdropBorderColor(unpack(color[3]))
		btns[i]:SetBackdropColor(unpack(color[3]))
	end
	self:SetBackdropColor(unpack(color[2]))
	self:SetBackdropBorderColor(unpack(color[2]))
	SAVED.current = self.id_
	menu:set_unit()
	menu:show_unit()
end

for i = 1,2 do
	local b = CreateFrame("Button",nil,menu)
		b:SetSize(37,12)
		b:SetBackdrop(M.bg)
		b.id_ = i
		b:SetBackdropBorderColor(unpack(color[3]))
		b:SetBackdropColor(unpack(color[3]))
		b:SetScript("OnClick",re_show)
		btns[i] = b
		if i == 1 then
			btns[i]:SetPoint("TOPLEFT",13,-15)
		else
			btns[i]:SetPoint("LEFT",btns[i-1],"RIGHT",6,0)
		end
		if SAVED.shown ~= true then b:Hide() end
end
btns[cur]:SetBackdropBorderColor(unpack(color[2]))
btns[cur]:SetBackdropColor(unpack(color[2]))

menu.incombat = function()
	btns[SAVED.current]:SetBackdropBorderColor(unpack(color[1]))
	btns[SAVED.current]:SetBackdropColor(unpack(color[1]))
	btns[1]:EnableMouse(false)
	btns[2]:EnableMouse(false)
end

menu.outcombat = function()
	btns[SAVED.current]:SetBackdropBorderColor(unpack(color[2]))
	btns[SAVED.current]:SetBackdropColor(unpack(color[2]))
	btns[1]:EnableMouse(true)
	btns[2]:EnableMouse(true)
	if menu.exam then
		menu:exam()
		menu.exam = nil
		menu.unit_name:SetTextColor(1,1,1)
	end
end

menu.register_combat = function(self)
	M.addcombat(self.incombat,"DerpyToprightIn","in")
	M.addcombat(self.outcombat,"DerpyToprightOut","out")
end

menu.un_register_combat = function(self)
	M.addcombat("remove","DerpyToprightIn","in")
	M.addcombat("remove","DerpyToprightOut","out")
end

if SAVED.shown ~= true then
	menu.wpos = 6
	menu:SetSize(6,132)
	menu:Hide()
	menu:un_register_combat()
	LEFT_BAR:SetPoint("LEFT")
	LEFT_BAR.pos = 0	
else
	menu:register_combat()
	menu.wpos = MAX_POS
	menu:SetSize(MAX_POS,132)
	LEFT_BAR:SetPoint("LEFT",-9,0)
	LEFT_BAR.pos = -9
end

shown_switch()
