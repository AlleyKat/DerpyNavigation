-- local C,M,L,V = unpack(select(2,...)) --

local ns = select(2,...)
ns[1] = {}
ns[2] = DerpyData[1]
ns[3] = DerpyData[2]

if not _G.DerpyNav then
	_G.DerpyNav = {
		["trigers"] = {
			["junk"] = false,
			["autoinv"] = false,
			["autoacceptinv"] = false,
			["autodeclineinv"] = false,
			["declineduels"] = false,
			["repair"] = false},
		
		["zone_change"] = true,--
		["map_show_coord"] = true,
		["weaponench"] = true,--
		["map_show_coord_mouse"] = true,
		["buffs"] = true,--	
		["debuffs"] = false,--
		["map"] = true,--
		["map_bg"] = true,--
		["show_reminder"] = false,
		
		["rollbuffs"] = 12,
		["rolldebuffs"] = 12,
		["buffssize"] = 32,
		["debuffsize"] = 32,
		["bufffont"] = 14,
		["debufffont"] = 14,
		["map_size_ratio"] = 65,
		
		["rightmenu"] = {
			["shown"] = false,
			["current"] = 1},
				
	}
end

ns[4] = _G.DerpyNav

ns[1].territory_colors = {
	["friendly"] = {0.1, 1.0, 0.1},
	["sanctuary"] = {0.41, 0.8, 0.94},
	["arena"] = {1.0, 0.1, 0.1},
	["hostile"] = {1.0, 0.1, 0.1},
	["combat"] = {1.0, 0.1, 0.1},
	["contested"] = {1.0, 0.7, 0.0},
	["none"] = {0.1, 1.0, 0.1},
}

-- Settings
local C,M,L,V = unpack(select(2,...))

local nav = M.make_settings_template("NAVIGATION",214,340)

M.tweaks_mvn(nav,V,{
	["map"] = "MAP",
	["weaponench"] = "ENCHANTS",
	["zone_change"] = "ZONE UPDATE",
	["map_bg"] = "BATLLFIELD MAP",
	["buffs"] = "BUFFS",
	["debuffs"] = "DEBUFFS",},18)

local st1 = {
	"rollbuffs",
	"rolldebuffs",
	"buffssize",
	"debuffsize",
	"bufffont",
	"debufffont",
	"map_size_ratio",
}

local st2 = {
	"MAX BUFFS PER ROLL",
	"MAX DEBUFFS PER ROLL",
	"BUFF ICON SIZE",
	"DEBUFF ICON SIZE",
	"BUFF FONT SIZE",
	"DEBUFF FONT SIZE",}
	
local st3 = {32,32,64,64,24,24}
local pers

for i=1,6 do
	local a = M.makevarbar(nav,204,0,st3[i],V,st1[i],st2[i])
		if i == 1 then
			a:SetPoint("TOP",nav,0,-114)
		else
			a:SetPoint("TOP",pers,"BOTTOM")
		end
	pers = a
end