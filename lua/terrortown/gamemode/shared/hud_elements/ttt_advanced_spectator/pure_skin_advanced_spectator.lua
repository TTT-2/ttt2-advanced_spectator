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
        self.basecolor = self:GetHUDBasecolor()
        self.padding = padding * self.scale

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

        local c_is_alive = c:Alive()
        local tgt_is_valid = IsValid(tgt) and tgt:IsPlayer()
        local tgt_is_synced_user = tgt and tgt['UserID'] and ASPECTATOR.player[tgt:UserID()]

        return (tgt_is_valid and tgt_is_synced_user) or HUDEditor.IsEditing
	end
    -- parameter overwrites end

    function HUDELEMENT:Draw()
        -- get target
        local tgt = LocalPlayer():GetObserverTarget()

        -- data for HUD switcher
        local tgt_data = {}
        if tgt and tgt['UserID'] then
            tgt_data = ASPECTATOR.player[tgt:UserID()]
        else
            tgt_data.role = GetRoleByIndex(1)
            tgt_data.role_c = tgt_data.role.color
        end

        local client = LocalPlayer()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
        local w, h = size.w, size.h
        
        local show_role = GetConVar('ttt_aspectator_display_role'):GetBool()
        if not show_role then
            h = h - rolesize
            y = y + rolesize
        end

        -- draw bg
        self:DrawBg(x, y, w, h, self.basecolor)

        if show_role then
            local text = LANG.GetTranslation(tgt_data.role.name)
            local tx = x + rolesize
            local ty = y + rolesize * 0.5

            self:DrawBg(x, y, rolesize, h, tgt_data.role_c)

            local icon = Material("vgui/ttt/dynamic/roles/icon_" .. tgt_data.role.abbr)
            if icon then
                util.DrawFilteredTexturedRect(x + 4, y + 4, rolesize - 8, rolesize - 8, icon)
            end

            --calculate the scale multplier for role text
			surface.SetFont("PureSkinRole")

			local role_text_width = surface.GetTextSize(string.upper(text)) * self.scale
			local role_scale_multiplier = (self.size.w - rolesize - 2 * self.padding) / role_text_width

			role_scale_multiplier = math.Clamp(role_scale_multiplier, 0.55, 0.85) * self.scale
			draw.AdvancedText(string.upper(text), "PureSkinRole", tx + self.padding, ty, self:GetDefaultFontColor(self.basecolor), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, Vector(role_scale_multiplier * 0.9, role_scale_multiplier, role_scale_multiplier))
        end

        -- draw dark bottom overlay
        self:DrawBg(x, y + ((show_role == true) and rolesize or 0), w, h - ((show_role == true) and rolesize or 0), Color(0, 0, 0, 90))

        -- draw bars
        local bx = x + ((show_role == true) and rolesize or 0) + self.padding
        local by = y + ((show_role == true) and rolesize or 0) + self.padding

        local bw = w - ((show_role == true) and rolesize or 0) - self.padding * 2 -- bar width
        local bh = 26 * self.scale --  bar height
        local spc = 7 * self.scale -- space between bars

        -- health bar
        local health = math.max(0, tgt_data.ply:Health())

        print(tostring(math.max(0, tgt_data.ply:GetMaxHealth())))

        self:DrawBar(bx, by, bw, bh, Color(234, 41, 41), health / math.max(0, tgt_data.ply:GetMaxHealth()), self.scale, "HEALTH: " .. health)

        -- Draw ammo
        local clip, clip_max, ammo = tgt_data.wep_clip, tgt_data.wep_clip_max, tgt_data.wep_ammo

        if clip ~= -1 then
            local text = string.format("%i + %02i", clip, ammo)

            self:DrawBar(bx, by + bh + spc, bw, bh, Color(238, 151, 0), clip / clip_max, self.scale, text)
        end
        
        -- draw border and shadow
        self:DrawLines(x, y, w, h, self.basecolor.a)
    end
end