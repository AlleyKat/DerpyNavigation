local ns,M,L,V = unpack(select(2,...))
local DB = V["trigers"]

local invate_table = {
	"inv",
	"инв",
	"byd",
	"пати",
	"party",}

local names = L['tweaks']

local autoinvite = function(self,event,arg1,arg2,...)
	if DB.autoinv ~= true then return end
	local newstring = ""
	local count = 1
	for i = 1,3 do
		local chng
		chng,count = M.GetNextChar(arg1,count)
		newstring = newstring..chng
	end
	newstring = string.lower(newstring)
	for _,v in pairs(invate_table) do
		if newstring == v or arg1 == v then InviteUnit(arg2) return end
	end
end

local inviteplx,invitelol = CreateFrame("Frame"),CreateFrame("Frame")
	invitelol:RegisterEvent("CHAT_MSG_WHISPER")
	invitelol:SetScript("OnEvent",autoinvite)
	
local OnEvent = function(self, event, ...) self[event](self, event, ...) end
inviteplx:SetScript("OnEvent", OnEvent)

local function invmelol()
	StaticPopup_Hide("PARTY_INVITE")
	inviteplx:UnregisterEvent("PARTY_MEMBERS_CHANGED")
end

local InGroup = false
local function autoacceptinvite(self,event,arg1,...)
	if DB.autoacceptinv == true then
	local leader = arg1
	InGroup = false
	
	if GetNumFriends() > 0 then ShowFriends() end
	if IsInGuild() then GuildRoster() end
	
	for friendIndex = 1, GetNumFriends() do
		local friendName = GetFriendInfo(friendIndex)
		if friendName == leader then
			AcceptGroup()
			M.allertrun(names.malinvacc..leader)
			inviteplx:RegisterEvent("PARTY_MEMBERS_CHANGED")
			inviteplx["PARTY_MEMBERS_CHANGED"] = invmelol
			InGroup = true
			break
		end
	end
	
	if not InGroup then
		for guildIndex = 1, GetNumGuildMembers(true) do
			local guildMemberName = GetGuildRosterInfo(guildIndex)
			if guildMemberName == leader then
			M.allertrun(names.malinvacc..leader)
				AcceptGroup()
				inviteplx:RegisterEvent("PARTY_MEMBERS_CHANGED")
				inviteplx["PARTY_MEMBERS_CHANGED"] = invmelol
				InGroup = true
				break
			end
		end
	end
	
	if not InGroup then
		SendWho(leader)
	end
	
	if DB.autodeclineinv == true and not InGroup then 
		DeclineGroup()
		HideUIPanel(StaticPopup1)
		M.allertrun(names.malinvde..arg1)	
	end
	
	elseif DB.autodeclineinv == true then
	DeclineGroup()
	HideUIPanel(StaticPopup1)
	M.allertrun(names.malinvde..arg1)
	end
end

inviteplx:RegisterEvent("PARTY_INVITE_REQUEST")
inviteplx["PARTY_INVITE_REQUEST"] = autoacceptinvite

local declineduels = CreateFrame("Frame")
	declineduels:RegisterEvent("DUEL_REQUESTED")
	declineduels:SetScript("OnEvent", function(self, event, name)
		if DB.declineduels ~= true then return end
			HideUIPanel(StaticPopup1)
			CancelDuel()
			M.allertrun(names.malduelde..name)
	end)

local form_money = function(cost)
	local c,s,g
		c = " "..(cost%100).."|cffeda55fc|r."
		g = math.floor(cost/10000)
		s = math.floor((cost%10000)/100)
			if s~=0 or g~=0 then
				s = " "..s.."|cffc7c7cfs|r"
			else
				s = ""
			end
			if g~=0 then
				g = " "..g.."|cffffd700g|r"
			else
				g = ""
			end
	return g,s,c
end

local merc = CreateFrame("Frame")
local function Mer()
if DB.junk == true then
	for bagIndex = 0, 4 do
		if GetContainerNumSlots(bagIndex) > 0 then
			for slotIndex = 1, GetContainerNumSlots(bagIndex) do
				if select(2,GetContainerItemInfo(bagIndex, slotIndex)) then
					local quality = select(3, string.find(GetContainerItemLink(bagIndex, slotIndex), "(|c%x+)"))
					if quality == ITEM_QUALITY_COLORS[0].hex then
						UseContainerItem(bagIndex, slotIndex)
					end
				end
			end
		end
	end
end
if DB.repair == true then
	if not(CanMerchantRepair()) then return end
		local cost = GetRepairAllCost()
			if cost == 0 then return end
			local money = GetMoney()
			money = money - cost
			if money >= 0 then
				RepairAllItems()
				local g,s,c = form_money(cost)
				print(names.repairtrue..":"..g..s..c)
				M.sl_run(names.repairtrue..".")
			else
				local g,s,c = form_money(-money)
				print(names.repairfalse..":"..g..s..c)
				M.sl_run(names.repairfalse.."!")
			end
end
end

merc:RegisterEvent("MERCHANT_SHOW")
merc:SetScript("OnEvent",Mer)

local settingsframe = CreateFrame("Frame",nil,ns["topright"])
M.tweaks_mvn(settingsframe,V.trigers,L['tweaks_st'],40)
settingsframe.name = "TWEAKS"
settingsframe:Hide()
M.make_plav(settingsframe,.2)
settingsframe:SetPoint("RIGHT",-3,0)
settingsframe:SetSize(236,136)
ns["topright"].frames[1] = settingsframe
