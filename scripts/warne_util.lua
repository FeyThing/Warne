function WarneUpvalue(fn, upvalue_name, set_upvalue)
	if fn == nil or upvalue_name == nil then
		return
	end
	
	local i = 1
	while true do
		local val, v = debug.getupvalue(fn, i)
		
		if not val then
			break
		end
		if val == upvalue_name then
			if set_upvalue then
				debug.setupvalue(fn, i, set_upvalue)
			end
			
			return v, i
		end
		i = i + 1
	end
end

AddShardModRPCHandler("Warne", "SoulJarRevive_Start", function(shardid, userid)
	if userid == nil then
		return
	end
	
	for k, v in pairs(Ents) do
		if v.prefab == "warne_souljar" and v:IsValid() and v.StartWarneRevive and v._warneid == userid then
			v:DoTaskInTime(TUNING.WARNE_REVIVE_DELAY, v.StartWarneRevive, userid)
		end
	end
end)

AddShardModRPCHandler("Warne", "SoulJarRevive_Over", function(shardid, userid, current_shardid, x, y, z)
	if userid == nil or current_shardid == nil or z == nil then
		return
	end
	
	for i, player in ipairs(AllPlayers) do
		if player.userid == userid and player.StartWarneJarRevive then
			if current_shardid ~= TheShard:GetShardId() then
				player:StartWarneJarRevive()
				TheWorld:PushEvent("ms_playerdespawnandmigrate", {player = player, portalid = nil, worldid = current_shardid, x = x, y = y, z = z})
			else
				player:StartWarneJarRevive(true)
				player.Transform:SetPosition(x, y, z)
			end
		end
	end
end)