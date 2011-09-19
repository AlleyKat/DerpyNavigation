local C,M,L,V = unpack(select(2,...))
local _G = _G
local buff
M.call.buffs = function()
	if buff then buff:Show() return end
	local st = {
		["buffs"] = "Buffs",
		["debuffs"] = "Debuffs",
	}
	buff = M.make_settings(st,V,207,230,"BUFFS AND DEBUFFS",true)
	local sr = {
		["rollbuffs"] = "Max Buffs Per Roll",
		["rolldebuffs"] = "Max Debuffs Per Roll",
		["buffssize"] = "Buff Icon Size",
		["debuffsize"] = "Debuff Icon Size",
		["bufffont"] = "Buff Font Size",
		["debufffont"] = "Debuff Font Size",
	}
	local limits = {
		["rollbuffs"] = 32,
		["rolldebuffs"] = 32,
		["buffssize"] = 64,
		["debuffsize"] = 64,
		["bufffont"] = 24,
		["debufffont"] = 24,
	}
	local c = 1
	local pers
	for p,t in pairs(sr) do
		local a = M.makevarbar(buff,230,0,limits[p],V,p,t)
		if c == 1 then
			a:SetPoint("TOP",buff,0,-27)
			c = nil
		else
			a:SetPoint("TOP",pers,"BOTTOM")
		end
		pers = a
	end
	buff:Show()
end

if V.buffs ~= true then return end

local unchor_frame = CreateFrame("Frame","DerpyBuffsUnchor",UIParent)
unchor_frame:SetSize(2,130)

ConsolidatedBuffs:ClearAllPoints()
ConsolidatedBuffs:SetPoint("LEFT", Minimap)
ConsolidatedBuffs:SetSize(16, 16)
ConsolidatedBuffsIcon:SetTexture("")
ConsolidatedBuffs.SetPoint = M.null

local rowbuffs = V.rollbuffs
local maxbuff = V.rollbuffs*2
local maxdebuffs = V.rolldebuffs
local bsize = V.buffssize
local desize = V.debuffsize
local fsize = V.bufffont
local defsize = V.debufffont

WorldStateAlwaysUpFrame:SetFrameStrata("BACKGROUND")
WorldStateAlwaysUpFrame:SetFrameLevel(0)

local takecolor = function(target,r,g,b)
	target.top:SetTexture(r,g,b)
	target.bottom:SetTexture(r,g,b)
	target.left:SetTexture(r,g,b)
	target.right:SetTexture(r,g,b)
	target:SetBackdropBorderColor(r,g,b,.5)
end

local function StyleBuffs(buttonName, index, debuff)
	local buff		= _G[buttonName..index]
	local icon		= _G[buttonName..index.."Icon"]
	local border	= _G[buttonName..index.."Border"]
	local duration	= _G[buttonName..index.."Duration"]
	local count 	= _G[buttonName..index.."Count"]
	if icon and not _G[buttonName..index.."Panel"] then
		icon:SetPoint("TOPLEFT")
		icon:SetPoint("BOTTOMRIGHT")
		icon:SetGradient("VERTICAL",.5,.5,.5,1,1,1)
		
		duration:ClearAllPoints()
		duration:SetShadowOffset(1.4,-1.4)
		duration:SetPoint("BOTTOMLEFT",.1,.1)
		duration:SetJustifyH("LEFT")
		
		count:ClearAllPoints()
		count:SetPoint("TOPRIGHT",1,0)
		count:SetShadowOffset(1,-1)
		
		local panel = M.frame(buff,buff:GetFrameLevel() + 2,buff:GetFrameStrata(),true,nil,nil)
		panel:SetPoint("TOPLEFT",-4,4)
		panel:SetPoint("BOTTOMRIGHT",4,-4)
		panel:SetBackdrop(M.bg_edge)
		panel:SetBackdropBorderColor(unpack(M["media"].shadow))
		icon:SetTexCoord(3/32,1-3/32,5/32,1-5/32)
		
		if not debuff then
			buff:SetSize(bsize,bsize*(.875))
			duration:SetFont(M["media"].cdfont,fsize, "OUTLINE")
			count:SetFont(M["media"].font, fsize-1, "OUTLINE")
		else	
			buff:SetSize(desize,desize*(.875))
			duration:SetFont(M["media"].cdfont,defsize, "OUTLINE")
			count:SetFont(M["media"].font, defsize-1, "OUTLINE")
			panel.takecolor = takecolor
		end
		
		_G[buttonName..index.."Panel"] = panel
	end
	if border then border:Hide() end
end

local function UpdateBuffAnchors()
	buttonName = "BuffButton"
	local buff, previousBuff, aboveBuff;
	local numBuffs = 0;
	for index=1, BUFF_ACTUAL_DISPLAY do
		local buff = _G[buttonName..index]
		StyleBuffs(buttonName, index, false)
		
		if ( buff.consolidated ) then
			if ( buff.parent == BuffFrame ) then
				buff:SetParent(ConsolidatedBuffsContainer)
				buff.parent = ConsolidatedBuffsContainer
			end
		else
			numBuffs = numBuffs + 1
			index = numBuffs
			if index > maxbuff then buff:Hide() end
			buff:ClearAllPoints()
			if ( (index > 1) and (mod(index, rowbuffs) == 1) ) then
				if ( index == rowbuffs+1 ) then
					buff:SetPoint("TOPRIGHT", unchor_frame, "TOPLEFT",-5, -38)
				else
					buff:SetPoint("TOPRIGHT", unchor_frame, "TOPLEFT",-5, 0)
				end
				aboveBuff = buff;
			elseif ( index == 1 ) then
				buff:SetPoint("TOPRIGHT", unchor_frame, "TOPLEFT",-5, 0)
			else
				buff:SetPoint("RIGHT", previousBuff, "LEFT", -6, 0)
			end
			previousBuff = buff
		end		
	end
end

local UpdateDebuffAnchors = M.null
if V.debuffs then
	UpdateDebuffAnchors = function(buttonName, index)
		local debuff = _G[buttonName..index];
		StyleBuffs(buttonName, index, true)
		local dtype = select(5, UnitDebuff("player",index))      
		local color
		if (dtype ~= nil) then
			color = DebuffTypeColor[dtype]
		else
			color = DebuffTypeColor["none"]
		end
		_G[buttonName..index.."Panel"]:takecolor(color.r,color.g,color.b)
		debuff:ClearAllPoints()
		if index == 1 then
			debuff:SetPoint("BOTTOMRIGHT", unchor_frame, "BOTTOMLEFT",-5, 0)
		elseif index > maxdebuffs then
			debuff:Hide()
		else
			debuff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", -6, 0)
		end
	end
else
	UpdateDebuffAnchors = function(buttonName, index)
		_G[buttonName..index]:Hide()
	end
end

hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffAnchors)
hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffAnchors)

do
	local floor = floor
	local mod = mod
	local format = format
	SecondsToTimeAbbrev = function(time)
		local hr, m, text
		if time <= 0 then text = ""
		elseif(time < 3600 and time > 60) then
			hr = floor(time / 3600)
			m = floor(mod(time, 3600) / 60 + 1)
			text = format("|cffffffff%dm|r", m)
		elseif time < 60 then
			m = floor(time / 60)
			text = (m == 0 and format("|cffff0000%.1f|r",time))
		else
			hr = floor(time / 3600 + 1)
			text = format("|cffffffff%dh|r", hr)
		end
		return text
	end
end
