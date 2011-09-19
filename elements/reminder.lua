-- RaidBuffReminder
-- Taked from EvlUI
local C,M,L,V = unpack(select(2,...))

local flaskbuffs = {
	94160, --"Flask of Flowing Water"
	79469, --"Flask of Steelskin"
	79470, --"Flask of the Draconic Mind"
	79471, --"Flask of the Winds
	79472, --"Flask of Titanic Strength"
	79638, --"Flask of Enhancement-STR"
	79639, --"Flask of Enhancement-AGI"
	79640, --"Flask of Enhancement-INT"
	92679, --Flask of battle
}
local battleelixirbuffs = {
		--Scrolls
	89343, --Agility
	63308, --Armor 
	89347, --Int
	89342, --Spirit
	63306, --Stam
	89346, --Strength
	
	--Elixirs
	79481, --Hit
	79632, --Haste
	79477, --Crit
	79635, --Mastery
	79474, --Expertise
	79468, --Spirit
}
local guardianelixirbuffs = {
	79480, --Armor
	79631, --Resistance+90
}
local foodbuffs = {
	87545, --90 STR
	87546, --90 AGI
	87547, --90 INT
	87548, --90 SPI
	87549, --90 MAST
	87550, --90 HIT
	87551, --90 CRIT
	87552, --90 HASTE
	87554, --90 DODGE
	87555, --90 PARRY
	87635, --90 EXP
	87556, --60 STR
	87557, --60 AGI
	87558, --60 INT
	87559, --60 SPI
	87560, --60 MAST
	87561, --60 HIT
	87562, --60 CRIT
	87563, --60 HASTE
	87564, --60 DODGE
	87634, --60 EXP
	87554, --Seafood Feast
}

local battleelixired	
local guardianelixired
local caster = false
local select = select
local pairs = pairs
local class = M.class
local Right_Nav = C.Minimap_right

local return_true = function() return true end
local return_2_false = function() if GetPrimaryTalentTree() == "2" then return false end return true end

local iscaster = {
	["WARLOCK"] = return_true,
	["MAGE"] = return_true,
	["PRIEST"] = return_true,
	["DRUID"] = return_2_false,
	["SHAMAN"] = return_2_false,
	["PALADIN"] = function() if GetPrimaryTalentTree() ~= "1" then return false end return true end,
}

local FlaskFrame
local FoodFrame
local Spell3Frame
local Spell4Frame
local Spell5Frame
local Spell6Frame
local Spell3Buff
local Spell4Buff
local Spell5Buff
local Spell6Buff

--Setup Caster Buffs
local function SetCasterOnlyBuffs()
	Spell3Buff = { --Total Stats
		1126, -- "Mark of the wild"
		90363, --"Embrace of the Shale Spider"
		20217, --"Greater Blessing of Kings",
	}
	Spell4Buff = { --Total Stamina
		469, -- Commanding
		6307, -- Blood Pact
		90364, -- Qiraji Fortitude
		72590, -- Drums of fortitude
		21562, -- Fortitude
	}
	Spell5Buff = { --Total Mana
		61316, --"Dalaran Brilliance"
		1459, --"Arcane Brilliance"
	}
	Spell6Buff = { --Mana Regen
		5675, --"Mana Spring Totem"
		19740, --"Blessing of Might"
	}
end

--Setup everyone else's buffs
local function SetBuffs()
	Spell3Buff = { --Total Stats
		1126, -- "Mark of the wild"
		90363, --"Embrace of the Shale Spider"
		20217, --"Greater Blessing of Kings",
	}
	Spell4Buff = { --Total Stamina
		469, -- Commanding
		6307, -- Blood Pact
		90364, -- Qiraji Fortitude
		72590, -- Drums of fortitude
		21562, -- Fortitude
	}
	Spell5Buff = { --Total Mana
		61316, --"Dalaran Brilliance"
		1459, --"Arcane Brilliance"
	}
	Spell6Buff = { --Total AP
		19740, --"Blessing of Might" placing it twice because i like the icon better :D code will stop after this one is read, we want this first 
		30808, --"Unleashed Rage"
		53138, --Abom Might
		19506, --Trushot
		19740, --"Blessing of Might"
	}
end

local update_caster = function()
	if iscaster[class] and iscaster[class]() then 
		SetCasterOnlyBuffs()
	else
		SetBuffs()
	end
end

-- we need to check if you have two differant elixirs if your not flasked, before we say your not flasked
local function CheckElixir(unit)
	if (battleelixirbuffs and battleelixirbuffs[1]) then
		for i, battleelixirbuffs in pairs(battleelixirbuffs) do
			local spellname = select(1, GetSpellInfo(battleelixirbuffs))
			if UnitAura("player", spellname) then
				FlaskFrame.t:SetTexture(select(3, GetSpellInfo(battleelixirbuffs)))
				battleelixired = true
				break
			else
				battleelixired = false
			end
		end
	end
	
	if (guardianelixirbuffs and guardianelixirbuffs[1]) then
		for i, guardianelixirbuffs in pairs(guardianelixirbuffs) do
			local spellname = select(1, GetSpellInfo(guardianelixirbuffs))
			if UnitAura("player", spellname) then
				guardianelixired = true
				if not battleelixired then
					FlaskFrame.t:SetTexture(select(3, GetSpellInfo(guardianelixirbuffs)))
				end
				break
			else
				guardianelixired = false
			end
		end
	end	
	
	if guardianelixired == true and battleelixired == true then
		FlaskFrame:Disable()
		return
	else
		FlaskFrame:Enable()
	end
end

--Main Script
RaidReminderShown = true
local function OnAuraChange(self, event, arg1, unit)
	if (event == "UNIT_AURA" and arg1 ~= "player") then 
		return
	end
	if event == "ACTIVE_TALENT_GROUP_CHANGED" then 
		update_caster() 
	end
	
	--Start checking buffs to see if we can find a match from the list
	if (flaskbuffs and flaskbuffs[1]) then
		FlaskFrame.t:SetTexture(select(3, GetSpellInfo(flaskbuffs[1])))
		for i, flaskbuffs in pairs(flaskbuffs) do
			local spellname = select(1, GetSpellInfo(flaskbuffs))
			if UnitAura("player", spellname) then
				FlaskFrame.t:SetTexture(select(3, GetSpellInfo(flaskbuffs)))
				FlaskFrame:Disable()
				break
			else
				CheckElixir()
			end
		end
	end
	
	if (foodbuffs and foodbuffs[1]) then
		FoodFrame.t:SetTexture(select(3, GetSpellInfo(foodbuffs[1])))
		for i, foodbuffs in pairs(foodbuffs) do
			local spellname = select(1, GetSpellInfo(foodbuffs))
			if UnitAura("player", spellname) then
				FoodFrame:Disable()
				FoodFrame.t:SetTexture(select(3, GetSpellInfo(foodbuffs)))
				break
			else
				FoodFrame:Enable()
			end
		end
	end
	
	for i, Spell3Buff in pairs(Spell3Buff) do
		local spellname = select(1, GetSpellInfo(Spell3Buff))
		if UnitAura("player", spellname) then
			Spell3Frame:Disable()
			Spell3Frame.t:SetTexture(select(3, GetSpellInfo(Spell3Buff)))
			break
		else
			Spell3Frame:Enable()
			Spell3Frame.t:SetTexture(select(3, GetSpellInfo(Spell3Buff)))
		end
	end
	
	for i, Spell4Buff in pairs(Spell4Buff) do
		local spellname = select(1, GetSpellInfo(Spell4Buff))
		if UnitAura("player", spellname) then
			Spell4Frame:Disable()
			Spell4Frame.t:SetTexture(select(3, GetSpellInfo(Spell4Buff)))
			break
		else
			Spell4Frame:Enable()
			Spell4Frame.t:SetTexture(select(3, GetSpellInfo(Spell4Buff)))
		end
	end
	
	for i, Spell5Buff in pairs(Spell5Buff) do
		local spellname = select(1, GetSpellInfo(Spell5Buff))
		if UnitAura("player", spellname) then
			Spell5Frame:Disable()
			Spell5Frame.t:SetTexture(select(3, GetSpellInfo(Spell5Buff)))
			break
		else
			Spell5Frame:Enable()
			Spell5Frame.t:SetTexture(select(3, GetSpellInfo(Spell5Buff)))
		end
	end	

	for i, Spell6Buff in pairs(Spell6Buff) do
		local spellname = select(1, GetSpellInfo(Spell6Buff))
		if UnitAura("player", spellname) then
			Spell6Frame:Disable()
			Spell6Frame.t:SetTexture(select(3, GetSpellInfo(Spell6Buff)))
			break
		else
			Spell6Frame:Enable()
			Spell6Frame.t:SetTexture(select(3, GetSpellInfo(Spell6Buff)))
		end
	end	
end

local raidbuff_reminder = CreateFrame("Frame", "RaidBuffReminder", UIParent)
raidbuff_reminder:SetScript("OnEvent", OnAuraChange)

local Enable = function(self)
	if self.enabled == true then return end
	self.enabled = true
	self.t:SetGradient("VERTICAL",.5,.5,.5,1,1,1)
end

local Disable = function(self)
	if self.enabled ~= true then return end
	self.enabled = false
	self.t:SetGradient("VERTICAL",.1,.1,.1,.5,.5,.5)
end

local buttons = {}
local c = 1
local function CreateButton(name)
	local button = M.frame(RaidBuffReminder,14,"BACKGROUND",true)
	buttons[c] = button
	if c ~= 1 then button:SetPoint("TOP",buttons[c-1],"BOTTOM",0,2) end
	button:SetSize(32,28)
	button:SetAlpha(0)
	button:SetBackdropColor(0,0,0,0)
	button.Enable = Enable
	button.Disable = Disable
	button.t = button:CreateTexture(nil, "OVERLAY")
	button.t:SetTexCoord(4/32,1-4/32,6/32,1-6/32)
	button.t:SetGradient("VERTICAL",.5,.5,.5,1,1,1)
	button.t:SetPoint("TOPLEFT",4,-4)
	button.t:SetPoint("BOTTOMRIGHT",-4,4)
	button.enabled = true
	c = c + 1
	RaidBuffReminder[name] = button
end

local ts = {
	"FlaskFrame",
	--"FoodFrame", Не помещается
	"Spell3Frame",
	"Spell4Frame", 
	"Spell5Frame", 
	"Spell6Frame",
}

for i=1,#ts do
	CreateButton(ts[i])
end

FlaskFrame = buttons[1]
-- FoodFrame = buttons[2] Не помещается
Spell3Frame = buttons[2]
Spell4Frame = buttons[3]
Spell5Frame = buttons[4]
Spell6Frame = buttons[5]

FoodFrame = CreateFrame("Frame",nil,FlaskFrame)
FoodFrame:SetFrameLevel(16)
FoodFrame:SetFrameStrata("BACKGROUND")
FoodFrame.t = FoodFrame:CreateTexture(nil, "OVERLAY")
FoodFrame.t:SetTexCoord(4/32,1-4/32,9/32,1-9/32)
FoodFrame.t:SetGradient("VERTICAL",.5,.5,.5,1,1,1)
FoodFrame.t:SetPoint("TOPLEFT",FlaskFrame,4,-4)
FoodFrame.t:SetPoint("BOTTOMRIGHT",FlaskFrame,-4,4) 
-- Получается, что еда находится на уровень выше фласок, пока не будет активирована еда, не покажутся фласки
FoodFrame.Disable = function(self)
	if self.enabled ~= true then return end
	self.enabled = false
	self:Hide()
end
FoodFrame.Enable = function(self)
	if self.enabled == true then return end
	self.enabled = true
	self:Show()
end

local smooth_show = function()
	for i=1,5 do
		UIFrameFadeIn(buttons[i],.5,0,1)
	end
end

local smooth_hide = function()
	UIFrameFadeOut(buttons[3],.9,1,0)
	for i=1,2 do
		UIFrameFadeOut(buttons[i],i*.3,1,0)
		UIFrameFadeOut(buttons[6-i],i*.3,1,0)
	end
end

raidbuff_reminder.Enable_Updating = function(self)
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:RegisterEvent("CHARACTER_POINTS_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	update_caster()
	OnAuraChange()
	smooth_show()
end

raidbuff_reminder.Disable_Updating = function(self)
	self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:UnregisterEvent("CHARACTER_POINTS_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	smooth_hide()
end

local on_update = M.simple_move

local finish = function() 
	raidbuff_reminder:Enable_Updating()
end

Right_Nav:EnableMouse(true)

Right_Nav.start_go_right = function(self)
	self:SetScript("OnUpdate",nil)
	self.mod = 1
	self.limit = 9
	self.speed = 22
	self.finish_function = finish
	self:SetScript("OnUpdate",on_update)
end

Right_Nav.start_go_back = function(self)
	self:SetScript("OnUpdate",nil)
	self.mod = -1
	self.limit = 0
	self.speed = -22
	self.finish_function = nil
	self:SetScript("OnUpdate",on_update)
	raidbuff_reminder:Disable_Updating()
end

Right_Nav.check_var = function(self)
	if V.show_reminder == true then
		if self.finish_function then return end
		self:start_go_right()
	else
		if not self.finish_function then return end
		self:start_go_back()
	end
end

Right_Nav:SetScript("OnMouseDown",function(self)
	if V.show_reminder == true then
		V.show_reminder = false 
	else 
		V.show_reminder = true
	end
	self:check_var()
end)

M.addlast(function()
	Right_Nav:check_var()
end)

buttons[1]:SetPoint("TOPRIGHT",UIParent,1,-4)
