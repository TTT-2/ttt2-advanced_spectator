local base = 'pure_skin_element'

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
    local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 365, h = 128},
		minsize = {w = 225, h = 128}
	}

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
		const_defaults["basepos"] = {x = 10 * self.scale, y = ScrH() - ((64) * self.scale + self.size.h)}

		return const_defaults
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
    end

    function HUDELEMENT:ShouldDraw()
        local c = LocalPlayer()
        local tgt = c:GetObserverTarget()
        
        if GetGlobalBool('ttt_aspectator_admin_only', false) and not c:IsAdmin() then return false end

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

        local client = LocalPlayer()
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
            local text = LANG.GetTranslation(tgt:AS_GetRole().name)
            local tx = x + self.rolesize
            local ty = y + self.rolesize * 0.5

            self:DrawBg(x, y, self.rolesize, h, tgt:AS_GetRoleColor())

            local icon = tgt:AS_GetRole().iconMaterial
            if icon then
                util.DrawFilteredTexturedRect(x + 4, y + 4, self.rolesize - 8, self.rolesize - 8, icon)
            end

            --calculate the scale multplier for role text
			surface.SetFont("PureSkinRole")

			local role_text_width = surface.GetTextSize(string.upper(text)) * self.scale
			local role_scale_multiplier = (self.size.w - self.rolesize - 2 * self.padding) / role_text_width

			role_scale_multiplier = math.Clamp(role_scale_multiplier, 0.55, 0.85) * self.scale
			draw.AdvancedText(string.upper(text), "PureSkinRole", tx + self.padding, ty, self:GetDefaultFontColor(self.basecolor), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, Vector(role_scale_multiplier * 0.9, role_scale_multiplier, role_scale_multiplier))
        end

        -- draw dark bottom overlay
        self:DrawBg(x, y + ((show_role == true) and self.rolesize or 0), w, h - ((show_role == true) and self.rolesize or 0), Color(0, 0, 0, 90))

        -- draw bars
        local bx = x + ((show_role == true) and self.rolesize or 0) + self.padding
        local by = y + ((show_role == true) and self.rolesize or 0) + self.padding

        local bw = w - ((show_role == true) and self.rolesize or 0) - self.padding * 2 -- bar width
        local bh = 26 * self.scale --  bar height
        local spc = 7 * self.scale -- space between bars

        -- health bar
        local health = math.max(0, tgt:Health())

        self:DrawBar(bx, by, bw, bh, Color(234, 41, 41), health / math.max(0, tgt:GetMaxHealth()), self.scale, "HEALTH: " .. health)

        -- Draw ammo
        local clip, clip_max, ammo = tgt:AS_GetWeapon()

        if clip ~= -1 then
            local text = string.format("%i + %02i", clip, ammo)

            self:DrawBar(bx, by + bh + spc, bw, bh, Color(238, 151, 0), clip / clip_max, self.scale, text)
        end
        
        -- draw border and shadow
        self:DrawLines(x, y, w, h, self.basecolor.a)
    end
end