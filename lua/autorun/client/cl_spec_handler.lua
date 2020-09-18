if CLIENT then
	ASPECTATOR = {}
	ASPECTATOR.admin_wallhack_enabled = false

	net.Receive("ttt2_net_aspectator_start_wallhack", function()
		for _, p in pairs(player.GetAll()) do
			ASPECTATOR:AddStencil(p, p:AS_GetRoleColor())
		end
	end)
	net.Receive("ttt2_net_aspectator_stop_wallhack", function()
		marks.Remove(player.GetAll())
	end)

	function ASPECTATOR:AddStencil(ply, clr, force)
		timer.Simple(0.2, function()
			if not LocalPlayer():IsSpec() and not force then return end
			if not GetGlobalBool("ttt_aspectator_enable_wallhack", true) then return end

			if not GetGlobalBool("ttt_aspectator_display_wallhack_role", true) then
				clr = Color(255, 50, 50)
			end

			marks.Add({ply}, clr)
		end)
	end

	-- ADMIN ONLY TOGLLEABLE WALLHACK

	hook.Add("Initialize", "ttt2_aspectator_lang_and_bind", function()
		LANG.AddToLanguage("English", "ttt2_aspectator_wallhack", "Toggle Admin Wallhack")
		LANG.AddToLanguage("Deutsch", "ttt2_aspectator_wallhack", "Schalte Admin-Wallhack um")
		LANG.AddToLanguage("Español", "ttt2_aspectator_wallhack", "Activar Wallhack de Administrador")

		LANG.AddToLanguage("English", "ttt2_aspectator_started_wallack", "Started admin only wallhack.")
		LANG.AddToLanguage("Deutsch", "ttt2_aspectator_started_wallack", "Admin-only Wallhack gestartet.")
		LANG.AddToLanguage("Español", "ttt2_aspectator_started_wallack", "Wallhack Sólo-Admin activado.")

		LANG.AddToLanguage("English", "ttt2_aspectator_stopped_wallack", "Stopped admin only wallhack.")
		LANG.AddToLanguage("Deutsch", "ttt2_aspectator_stopped_wallack", "Admin-only Wallhack gestoppt.")
		LANG.AddToLanguage("Español", "ttt2_aspectator_stopped_wallack", "Wallhack Sólo-Admin desactivado.")

		bind.Register("ttt2_aspectator_wallhack", function()
			if not GetGlobalBool("ttt_aspectator_admin_wallhack") then return end

			local client = LocalPlayer()

			if not client or not IsValid(client) then return end
			if not client:IsAdmin() then return end

			-- toggle wallhack now
			ASPECTATOR.admin_wallhack_enabled = not ASPECTATOR.admin_wallhack_enabled

			local text = ""

			if ASPECTATOR.admin_wallhack_enabled then
				text = LANG.GetTranslation("ttt2_aspectator_started_wallack")
				for _, p in pairs(player.GetAll()) do
					ASPECTATOR:AddStencil(p, p:AS_GetRoleColor(), true)
				end
			else
				text = LANG.GetTranslation("ttt2_aspectator_stopped_wallack")
				marks.Remove(player.GetAll())
			end

			chat.AddText("[TTT2] Advanced Spectator: ", COLOR_WHITE, text)
		end, nil, nil, "ttt2_aspectator_wallhack")
	end)

	hook.Add("PostDrawTranslucentRenderables", "ttt2_aspectator_draw_overhad_icons", function(bDepth, bSkybox)
		if not GetGlobalBool("ttt_aspectator_admin_wallhack") then return end

		local client = LocalPlayer()

		if not client or not IsValid(client) then return end
		if not client:IsAdmin() then return end

		if not ASPECTATOR.admin_wallhack_enabled then return end

		for _, p in pairs(player.GetAll()) do
			DrawOverheadRoleIcon(p, p:AS_GetRoleData().iconMaterial, p:AS_GetRoleColor())
		end
	end)

	local function ResetAdminWallhack()
		if not GetGlobalBool("ttt_aspectator_admin_wallhack") then return end

		local client = LocalPlayer()

		if not client or not IsValid(client) then return end
		if not client:IsAdmin() then return end

		if not ASPECTATOR.admin_wallhack_enabled then return end

		text = LANG.GetTranslation("ttt2_aspectator_stopped_wallack")
		chat.AddText("[TTT2] Advanced Spectator: ", COLOR_WHITE, text)

		ASPECTATOR.admin_wallhack_enabled = false
	end

	hook.Add("TTTPrepareRound", "ttt2_aspectator_disable_admin_wallhack_on_round_prepare", function()
		ResetAdminWallhack()
	end)

	hook.Add("TTTBeginRound", "ttt2_aspectator_disable_admin_wallhack_on_round_begin", function()
		ResetAdminWallhack()
	end)
end
