util.AddNetworkString("ttt2_net_aspectator_start_wallhack")
util.AddNetworkString("ttt2_net_aspectator_stop_wallhack")
util.AddNetworkString("ttt2_net_aspectator_request_initial_data")

ASPECTATOR = {}

function ASPECTATOR:CheckForWeaponChange(ply, weapon)
	if not IsValid(ply) or not IsValid(weapon) then return end

	local wep_clip, wep_clip_max, wep_ammo, wep_ammo_type = ply:AS_GetWeapon()
	local wep_clip_new, wep_clip_max_new, wep_ammo_new, wep_ammo_type_new = weapon:Clip1(), weapon:GetMaxClip1(), weapon:Ammo1(), weapon:GetPrimaryAmmoType()

	-- check if values are numbers (e.g. snowball has a boolean for ammo)
	if type(wep_clip_new) ~= "number" then wep_clip_new = -1 end
	if type(wep_clip_max_new) ~= "number" then wep_clip_max_new = -1 end
	if type(wep_ammo_new) ~= "number" then wep_ammo_new = -1 end
	if type(wep_ammo_type_new) ~= "number" then wep_ammo_type_new = -1 end

	-- make sure all values are integers
	wep_clip_new = math.floor(wep_clip_new)
	wep_clip_max_new = math.floor(wep_clip_max_new)
	wep_ammo_new = math.floor(wep_ammo_new)
	wep_ammo_type_new = math.floor(wep_ammo_type_new)

	-- a value has changed
	if wep_clip ~= wep_clip_new or wep_clip_max ~= wep_clip_max_new or wep_ammo ~= wep_ammo_new or wep_ammo_type ~= wep_ammo_type_new then
		ply:AS_UpdateWeapon(wep_clip_new, wep_clip_max_new, wep_ammo_new, wep_ammo_type_new)
	end
end

function ASPECTATOR:CheckForArmorChange(ply)
	if not IsValid(ply) then return end

	if ply:AS_GetArmor() ~= ply:GetArmor() then
		ply:AS_UpdateArmor(ply:GetArmor())
	end
end

function ASPECTATOR:StartWallhack(ply)
	if not ply or not IsValid(ply) then return end

	net.Start("ttt2_net_aspectator_start_wallhack")
	net.Send(ply)
end

function ASPECTATOR:StopWallhack(ply)
	if not ply or not IsValid(ply) then return end

	net.Start("ttt2_net_aspectator_stop_wallhack")
	net.Send(ply)
end

-- HOOKS
hook.Add("PlayerDeath", "ttt2_aspectator_player_death", function(ply)
	ASPECTATOR:StartWallhack(ply)
end)

hook.Add("PlayerSpawn", "ttt2_aspectator_player_spawn", function(ply)
	ASPECTATOR:StopWallhack(ply)
end)

hook.Add("TTTBeginRound", "ttt2_aspectator_begin_round", function()
	for _, p in pairs(player.GetAll()) do
		ASPECTATOR:StopWallhack(p)

		-- start wallhack when player is spectator!
		if p:IsSpec() then
			timer.Simple(0.25, function() -- wait until role is set
				ASPECTATOR:StartWallhack(p)
			end)
		end
	end
end)

hook.Add("PlayerSwitchWeapon", "ttt2_aspectator_change_weapon_switch", function(ply, old_weapon, new_weapon)
	ASPECTATOR:CheckForWeaponChange(ply, new_weapon)
end)

hook.Add("TTT2UpdateSubrole", "ttt2_aspectator_role_update", function(ply, old_role, new_role)
	if not ply or not IsValid(ply) or not ply:IsPlayer() then return end

	timer.Simple(0.1, function() -- add a short delay since the rolecolor is set after this hook is called
		if not ply or not IsValid(ply) then return end

		ply:AS_UpdateRole(new_role, ply:GetRoleColor())
	end)
end)

-- TIMER
timer.Create("ttt2_aspectator_recheck_weapon", 0.5, 0, function()
	for _, p in pairs(player.GetAll()) do
		ASPECTATOR:CheckForWeaponChange(p, p:GetActiveWeapon())
		ASPECTATOR:CheckForArmorChange(p)
	end
end)

-- send data to player who connected while round was active
hook.Add("TTT2PlayerReady", "ttt2_aspectator_player_ready", function(ply)
	if not IsValid(ply) then return end

	-- send full status update for players that connect after round has begun
	for _, p in pairs(player.GetAll()) do
		if p and IsValid(p) and p:IsPlayer() then

			-- set current role
			p:AS_UpdateRole(p:GetSubRole(), p:GetRoleColor())

			-- set current weapon data
			local weapon = p:GetActiveWeapon()
			if weapon and IsValid(weapon) then
				p:AS_UpdateWeapon(weapon:Clip1(), weapon:GetMaxClip1(), weapon:Ammo1(), weapon:GetPrimaryAmmoType())
			end
		end
	end

	ASPECTATOR:StartWallhack(ply)
end)
