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
		
		["zone_change"] = true,
		["map_show_coord"] = true,
		["weaponench"] = true,
		["map_show_coord_mouse"] = true,
		["buffs"] = true,	
		["debuffs"] = false,
		["map"] = true,
		["map_bg"] = true,
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
