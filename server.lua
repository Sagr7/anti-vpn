--[[                                                                                                                                                                            
--------------------------------------------------------
---------------Anti-VPN script by Overlord--------------
--------------------------------------------------------
Commands available: /checkVPN (case insensitive)
--]]

local o_avpn = {}

----------------------------Can be changed----------------------------
--Set to true to check all the connected players on the resource start
o_avpn.onStartCheckup = true 

o_avpn.avoided = {
	"127.0.0.1",	--Add here the IP's that you want to avoid checking
}
-----------------------------------------------------------------------


addEventHandler("onResourceStart", resourceRoot, function()
	outputDebugString("Anti-VPN by Overord started.")

	if o_avpn.onStartCheckup then
		for i, player in ipairs(getElementsByType("player")) do
			setTimer(function() o_avpn.check(player) end, i*100, 1)
		end
	end
end)

function o_avpn.check(player, requester)
	assert(getElementType(player)=="player", "VPN ERROR: No players were supplied")	
	local playerIP = getPlayerIP(player)
	
	for _, ip in ipairs(o_avpn.avoided) do
		if ip == playerIP then outputDebugString("IP avoided.", 2) return false end
	end
	
	fetchRemote("http://proxy.mind-media.com/block/proxycheck.php?ip="..playerIP, function(rdata, err)
		if err == 0 then
			if rdata == "Y" then
				if requester then 
					outputChatBox("The test results for the player "..getPlayerName(player).." #FFFFFFare #FF0000Positive. #FFFFFFThe player appears to be using a VPN.", requester, 255, 255, 255, true)
				else
					if string.lower(get("vpnwarn")) == "true" then
						outputDebugString("Player "..getPlayerName(player).." is using VPN.", 2)
						for _, adm in ipairs(getElementsByType("player")) do
							local admAcc = getPlayerAccount(adm)
							if not isGuestAccount(admAcc) and isObjectInACLGroup("user."..getAccountName(admAcc), aclGetGroup(get("vpnacl"))) then
								outputChatBox("Player "..getPlayerName(player).." is using VPN.", adm)
							end
						end
					end
					if string.lower(get("vpnkick")) == "true" then
						outputDebugString("Player "..getPlayerName(player).." has been kicked.")
						kickPlayer(player, "VPN Detected.")
					end
				end
			elseif rdata == "N" then
				if requester then 
					outputChatBox("The test results for the player "..getPlayerName(player).." #FFFFFFare #00FF00Negative. #FFFFFFThe player appears NOT to be using a VPN.", requester, 255, 255, 255, true)
				end
			elseif rdata == "X" then
				if requester then 
					outputChatBox("Something wrong with the player's IP player "..getPlayerName(player).." #FFFFFFIP: #00FF00"..playerIP, requester, 255, 255, 255, true)
				elseif string.lower(get("vpnwarn")) == "true" then
					for _, adm in ipairs(getElementsByType("player")) do
						local admAcc = getPlayerAccount(adm)
						if not isGuestAccount(admAcc) and isObjectInACLGroup("user."..getAccountName(admAcc), aclGetGroup(get("vpnacl"))) then
							outputChatBox("Something wrong with the player's IP player "..getPlayerName(player).." #FFFFFFIP: #00FF00"..playerIP, adm, 255, 255, 255, true)
						end
					end
				end
			else
				outputDebugString("UNKNOWN RESPONSE.. "..rdata, 1)
			end
		else
			if requester then 
				outputChatBox("[Anti-VPN]: Error while connecting to the server", requester)
			else
				outputDebugString("Connection Error while checking the player "..getPlayerName(player), 2)
			end	
		end
	end)
	return true
end
addEventHandler("onPlayerJoin", root, function()
	o_avpn.check(source, false)
end)

addCommandHandler("checkVPN", function(cmder, cmd, playerName)
	local cmderAcc = getPlayerAccount(cmder)
	if not isGuestAccount(cmderAcc) and isObjectInACLGroup("user."..getAccountName(cmderAcc), aclGetGroup(get("vpnacl"))) then
		if type(playerName) ~= "string" then
			outputChatBox("[Anti-VPN]: currect usage: /checkVPN [player's name]", cmder, 230, 50, 0)
			return false
		end
		
		local player = getPlayerFromName(playerName)
		if isElement(player) and getElementType(player) == "player" then
			return o_avpn.check(player, cmder)
		else
			outputChatBox("[Anti-VPN]: Couldn't find such player.", cmder, 230, 50, 0)
			return false
		end
	else
		outputDebugString("WARNING: Player "..getPlayerName(cmder).." has tried to use /checkVPN", 2)
	end
end, false, false)
