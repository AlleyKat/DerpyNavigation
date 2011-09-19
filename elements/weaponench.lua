local C,M,L,V = unpack(select(2,...))
if V.weaponench~=true then return end

local enchants = {}
-- [1] - Main
-- [2] - Second
-- [3] - Gun

local stages = {
	[3] = 3600,
	[2] = 1800,
	[1] = 900}
	
local color = {
	[3] = {.2,.5,1,.4},
	[2] = {1,.8,.1,.4},
	[1] = {1,.2,.2,.4}}	

local make_anim_in = function(self)
	self.show_in = self:CreateAnimationGroup("IN")
	M.anim_trans(self.show_in,"b",1,2,"OUT",-40)
end	

local show_out = function(self)
	self.show_out = self:CreateAnimationGroup("OUT")
	M.anim_trans(self.show_out,"a",1,2,"IN",40)
end
	
local createbar = function(cc)
	local st = CreateFrame("StatusBar",nil,Minimap)
	st:SetFrameLevel(1)
	st:SetFrameStrata("BACKGROUND")
	st:SetSize(30,11)
	st:SetMinMaxValues(0,stages[3])
	st:SetValue(0)
	st:SetPoint("TOPRIGHT",Minimap,"BOTTOMRIGHT",-2 - (cc-1) * 34,-1)
	st.point1 = {"TOPRIGHT",Minimap,"BOTTOMRIGHT",-2 - (cc-1) * 34,-1}
	st.point2 = {"TOPRIGHT",Minimap,"BOTTOMRIGHT",-2 - (cc-1) * 34,39}
	local bg = M.frame(st)
	bg:SetPoint("TOPLEFT",-4,4)
	bg:SetPoint("BOTTOMRIGHT",4,-4)
	bg:SetFrameStrata("BACKGROUND")
	bg:SetFrameLevel(0)
	make_anim_in(st)
	show_out(st)
	st:SetStatusBarTexture(M["media"].blank)
	st:SetStatusBarColor(unpack(color[3]))
	st.char = M.setfont(st,13,nil,nil,"RIGHT")
	st.char:SetPoint("RIGHT",-1.7,1)
	st.blockupdate = false
	st.tehskip = 0
	st.show_in:SetScript("OnPlay",function() st.blockupdate = true st:SetPoint(unpack(st.point2)) end)
	st.show_in:SetScript("OnFinished",function() st.blockupdate = false st:SetPoint(unpack(st.point1)) st.tehskip = 0 end)
	st.show_out:SetScript("OnFinished",function() st:Hide() end)
	local stmask = CreateFrame("Frame",nil,st)
	stmask:SetAllPoints()
	stmask:EnableMouse(true)
	stmask.id = cc+15
	stmask:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:ClearLines()
		GameTooltip:SetInventoryItem("player", self.id)
        GameTooltip:Show()
	end)
	stmask:SetScript("OnLeave",function() GameTooltip:Hide() end)
	st:Hide()
	enchants[cc] = st
end

for i=1,3 do
	createbar(i)
end

local ccminmax = function(self,t)
	self.tehskip = self.tehskip - 1
	if self.tehskip < 0 then
		self.tehskip = 5
		for i = 1,3 do
			if stages[i] >= t then
				self:SetStatusBarColor(unpack(color[i]))
				self:SetMinMaxValues(0,stages[i])
				return
			end
		end
	end
end

local bar_show = function(self)
	if self:IsShown() then return end
		self:SetValue(0)
		self.show_out:Stop()
		self:Show()
		self.show_in:Play()
end

local bar_hide = function(self)
	if not self:IsShown() or self.show_out:IsPlaying() then return end
		self.show_in:Stop()
		self.show_out:Play()
end

local superupdateframe = CreateFrame("Frame")
superupdateframe:Hide()
local theN = 2

local entime = {}
local encount = {}
local enench = {}

local Update = function(self,t)
	theN = theN - t 
	if theN > 0 then return end
	theN = 1
	
	enench[1],entime[1],encount[1],enench[2],entime[2],encount[2],enench[3],entime[3],encount[3] = GetWeaponEnchantInfo()

	for i = 1,3 do
		if enench[i] then
			bar_show(enchants[i])
			if enchants[i].blockupdate ~= true then
				local the_time = entime[i]/1000
				enchants[i]:SetValue(the_time)
				ccminmax(enchants[i],the_time)
				if encount[i] == 0 then
					enchants[i].char:SetText("")
				else
					enchants[i].char:SetText(encount[i] or "")
				end
			end
		else
			bar_hide(enchants[i])
		end
	end
end

superupdateframe:SetScript("OnUpdate",Update)
M.addafter(function()
	TemporaryEnchantFrame:Hide()
	superupdateframe:Show()
end)
	

