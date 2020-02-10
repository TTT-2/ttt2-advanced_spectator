-- this file contains the structure of the shared player data

if SERVER then
	util.AddNetworkString("ttt2_net_aspectator_update_weapon")
	util.AddNetworkString("ttt2_net_aspectator_update_role")
end

local plymeta = FindMetaTable("Player")

function plymeta:AS_UpdateWeapon(clip, clip_max, ammo)
	self.as_wep_clip = clip
	self.as_wep_clip_max = clip_max
	self.as_wep_ammo = ammo

	-- send data to client
	if SERVER then
		net.Start("ttt2_net_aspectator_update_weapon")
		net.WriteEntity(self)
		net.WriteInt(clip, 16)
		net.WriteInt(clip_max, 16)
		net.WriteInt(ammo, 16)
		net.Send(player.GetAll())
	end
end

function plymeta:AS_UpdateRole(role, color)
	self.as_role = roles.GetByIndex(role)
	self.as_color = color

	-- send data to client
	if SERVER then
		net.Start("ttt2_net_aspectator_update_role")
		net.WriteEntity(self)
		net.WriteUInt(role, ROLE_BITS)
		net.WriteUInt(color.r, 8)
		net.WriteUInt(color.g, 8)
		net.WriteUInt(color.b, 8)
		net.WriteUInt(color.a, 8)
		net.Send(player.GetAll())
	end
end

function plymeta:AS_GetWeapon()
	return self.as_wep_clip or -1, self.as_wep_clip_max or -1, self.as_wep_ammo or -1
end

function plymeta:AS_GetRoleColor()
	if not self.as_color then
		return Color(36, 40, 46, 255)
	end

	return self.as_color
end

function plymeta:AS_GetRoleData()
	if not self.as_role then
		return roles.GetByIndex(1)
	end

	return self.as_role
end

-- handle client <-> server syncing
if CLIENT then
	net.Receive("ttt2_net_aspectator_update_weapon", function()
		local client = net.ReadEntity()

		if not client or not IsValid(client) then return end

		client:AS_UpdateWeapon(net.ReadInt(16), net.ReadInt(16), net.ReadInt(16))
	end)

	net.Receive("ttt2_net_aspectator_update_role", function()
		local client = net.ReadEntity()

		if not client or not IsValid(client) then return end

		client:AS_UpdateRole(
			net.ReadUInt(ROLE_BITS),
			{
				r = net.ReadUInt(8),
				g = net.ReadUInt(8),
				b = net.ReadUInt(8),
				a = net.ReadUInt(8)
			}
		)
	end)
end
