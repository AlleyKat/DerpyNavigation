local C,M,L,V = unpack(select(2,...))
local mP = C.Minimap_bg

local Exit = CreateFrame("BUTTON","DerpyExit",Minimap,"SecureActionButtonTemplate");
Exit:SetFrameLevel(14)
Exit:SetFrameStrata("BACKGROUND")
Exit:SetWidth(46)
Exit:SetHeight(17)
Exit:SetPoint("TOPLEFT",mP,"BOTTOMLEFT",4,3)
Exit:RegisterForClicks("AnyDown")
Exit:SetScript("OnClick",VehicleExit)
--Exit:SetBackdrop({bgFile = M.media.blank}) --нужно

local veb = M.frame(Minimap,0,"BACKGROUND");
veb:SetPoint("TOPLEFT",mP,"BOTTOMLEFT",4,7)
veb:SetAlpha(0)
veb:SetWidth(49)

veb:RegisterEvent("UNIT_ENTERING_VEHICLE")
veb:RegisterEvent("UNIT_ENTERED_VEHICLE")
veb:RegisterEvent("UNIT_EXITING_VEHICLE")
veb:RegisterEvent("UNIT_EXITED_VEHICLE")

local animation = CreateFrame("Frame",nil,veb)
animation:SetAllPoints()
animation:SetFrameStrata("BACKGROUND")
animation:SetFrameLevel(1)
M.style(animation,true)
animation:SetBackdrop(M.bg_edge)
M.backcolor(animation,1,0,0,.8)

local anim_text = M.setfont(animation,13)
anim_text:SetPoint("CENTER",0,.4)
anim_text:SetText("EJECT")
anim_text:SetTextColor(1,0,0)

animation:SetAlpha(0)
animation.anim = animation:CreateAnimationGroup("Flash")
M.anim_alpha(animation.anim,"a",0,.2,1)
M.anim_alpha(animation.anim,"b",1,.5,0)
M.anim_alpha(animation.anim,"c",2,.2,-1)
M.anim_alpha(animation.anim,"d",3,.3,0)
animation.anim:SetLooping("REPEAT")
veb.anim = animation.anim
veb.play = function(self)
	if not self.anim:IsPlaying() then
		self.anim:Play()
	end
end

veb.stop = function(self)
	if self.anim:IsPlaying() then
		self.anim:Finish()
	end
end

local simple_height =  M.simple_height
local finish_hide = function(self)
	self:SetAlpha(0)
end

veb.hpos = 0

veb.showin = function(self)
	if self.show == true then return end
	self.show = true
	self:SetAlpha(1)
	self:SetScript("OnUpdate",nil)
	self.hspeed = 19
	self.hlimit = 19
	self.hmod = 1
	self.finish_function = self.play
	self:SetScript("OnUpdate",simple_height)
end

veb.showout = function(self)
	if self.show ~= true then return end
	self.show = false
	self:SetScript("OnUpdate",nil)
	self.hspeed = -19
	self.hlimit = 0
	self.hmod = -1 
	self.finish_function = finish_hide
	self:stop()
	self:SetScript("OnUpdate",simple_height)
end

veb:SetScript("OnEvent", function(self,event,arg1)	
	if(((event=="UNIT_ENTERING_VEHICLE") or (event=="UNIT_ENTERED_VEHICLE")) and arg1 == "player") then
		self:showin()
	elseif(((event=="UNIT_EXITING_VEHICLE") or (event=="UNIT_EXITED_VEHICLE")) and arg1 == "player") then
		self:showout()
	end
end)
