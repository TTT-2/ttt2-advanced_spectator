local base = "pure_skin_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 365, h = 128},
		minsize = {w = 225, h = 128}
	}

	local icon_armor = Material("vgui/ttt/hud_armor")
	local icon_armor_rei = Material("vgui/ttt/hud_armor_reinforced")

	local icon_health = Material("vgui/ttt/hud_health.vmt")
	local icon_health_low = Material("vgui/ttt/hud_health_low.vmt")

	local mat_tid_ammo = Material("vgui/ttt/tid/tid_ammo")

	local color_health = Color(234, 41, 41)
	local color_ammo = Color(238, 151, 0)

	local rolesize = 44
	local padding = 10

	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		local hud = huds.GetStored("pure_skin")
		if hud then
			hud:ForceElement(self.id)
		end

		-- set as fallback default, other skins have to be set to true!
		self.disabledUnlessForced = false
	end

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()

		BaseClass.Initialize(self)
	end

	function HUDELEMENT:PerformLayout()
		self.scale = self:GetHUDScale()

		self.basecolor = self:GetHUDBasecolor()
		self.padding = math.Round(padding * self.scale, 0)
		self.rolesize = math.Round(rolesize * self.scale, 0)

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = 10 * self.scale, y = ScrH() - (64 * self.scale + self.size.h)}

		return const_defaults
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
	end

	function HUDELEMENT:ShouldDraw()
		local c = LocalPlayer()
		local tgt = c:GetObserverTarget()

		if GetGlobalBool("ttt_aspectator_admin_only", false) and not c:IsAdmin() then return false end

		local tgt_is_valid = IsValid(tgt) and tgt:IsPlayer()

		return (tgt_is_valid and GAMEMODE.round_state == ROUND_ACTIVE) or HUDEditor.IsEditing
	end
	-- parameter overwrites end

	function HUDELEMENT:Draw()
		-- get target
		local tgt = LocalPlayer():GetObserverTarget()

		-- fallback for HUD switcher
		if not IsValid(tgt) or not tgt:IsPlayer() then
			tgt = LocalPlayer()
		end

		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h

		local show_role = GetGlobalBool("ttt_aspectator_display_role", true)
		if not show_role then
			h = h - self.rolesize
			y = y + self.rolesize
		end

		-- draw bg
		self:DrawBg(x, y, w, h, self.basecolor)

		if show_role then
			local text = LANG.GetTranslation(tgt:AS_GetRoleData().name)
			local tx = x + self.rolesize
			local ty = y + self.rolesize * 0.5

			self:DrawBg(x, y, self.rolesize, h, tgt:AS_GetRoleColor())

			local icon = tgt:AS_GetRoleData().iconMaterial
			if icon then
				draw.FilteredShadowedTexture(x + 4, y + 4, self.rolesize - 8, self.rolesize - 8, icon, 255, util.GetDefaultColor(tgt:AS_GetRoleColor()), self.scale)
			end

			--calculate the scale multplier for role text
			surface.SetFont("PureSkinRole")

			local role_text_width = surface.GetTextSize(string.upper(text)) * self.scale
			local role_scale_multiplier = (self.size.w - self.rolesize - 2 * self.padding) / role_text_width

			role_scale_multiplier = math.Clamp(role_scale_multiplier, 0.55, 0.85) * self.scale
			draw.AdvancedText(string.upper(text), "PureSkinRole", tx + self.padding, ty, util.GetDefaultColor(self.basecolor), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, Vector(role_scale_multiplier * 0.9, role_scale_multiplier, role_scale_multiplier))
		end

		-- draw dark bottom overlay
		self:DrawBg(x, y + ((show_role == true) and self.rolesize or 0), w, h - ((show_role == true) and self.rolesize or 0), Color(0, 0, 0, 90))

		-- draw bars
		local bx = x + ((show_role == true) and self.rolesize or 0) + self.padding
		local by = y + ((show_role == true) and self.rolesize or 0) + self.padding

		local bw = w - ((show_role == true) and self.rolesize or 0) - self.padding * 2 -- bar width
		local bh = 26 * self.scale -- bar height
		local spc = 7 * self.scale -- space between bars

		-- health bar
		local health = math.max(0, tgt:Health())
		local max_health = math.max(0, tgt:GetMaxHealth())

		local health_icon = icon_health

		if health <= max_health * 0.25 then
			health_icon = icon_health_low
		end

		self:DrawBar(bx, by, bw, bh, color_health, health / max_health, self.scale)

		local a_size = bh - math.Round(11 * self.scale)
		local a_pad = math.Round(5 * self.scale)

		local a_pos_y = by + a_pad
		local a_pos_x = bx + (a_size / 2)

		local at_pos_y = by + 1
		local at_pos_x = a_pos_x + a_size + a_pad

		draw.FilteredShadowedTexture(a_pos_x, a_pos_y, a_size, a_size, health_icon, 255, COLOR_WHITE, self.scale)
		draw.AdvancedText(health, "PureSkinBar", at_pos_x, at_pos_y, util.GetDefaultColor(color_health), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, true, self.scale)

		-- draw armor information
		local armor = tgt:AS_GetArmor()

		if not GetGlobalBool("ttt_armor_classic", false) and armor > 0 then
			local icon_mat = tgt:AS_ArmorIsReinforced() and icon_armor_rei or icon_armor

			a_pos_x = bx + bw - math.Round(65 * self.scale)
			at_pos_x = a_pos_x + a_size + a_pad

			draw.FilteredShadowedTexture(a_pos_x, a_pos_y, a_size, a_size, icon_mat, 255, COLOR_WHITE, self.scale)

			draw.AdvancedText(armor, "PureSkinBar", at_pos_x, at_pos_y, util.GetDefaultColor(color_health), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, true, self.scale)
		end

		-- Draw ammo
		local clip, clip_max, ammo, ammo_type = tgt:AS_GetWeapon()
		ammo_type = string.lower(game.GetAmmoTypes()[ammo_type])

		if clip ~= -1 then
			local text = string.format("%i + %02i", clip, ammo)
			local icon_mat = BaseClass.BulletIcons[ammo_type] or mat_tid_ammo

			self:DrawBar(bx, by + bh + spc, bw, bh, color_ammo, clip / clip_max, self.scale)

			a_pos_x = nx + (a_size / 2)
			a_pos_y = by + bh + spc + a_pad
			at_pos_y = by + bh + spc + 1
			at_pos_x = a_pos_x + a_size + a_pad

			draw.FilteredShadowedTexture(a_pos_x, a_pos_y, a_size, a_size, icon_mat, 255, COLOR_WHITE, self.scale)
			draw.AdvancedText(text, "PureSkinBar", at_pos_x, at_pos_y, util.GetDefaultColor(color_ammoBar), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, true, self.scale)
		end

		-- draw border and shadow
		self:DrawLines(x, y, w, h, self.basecolor.a)
	end
end
