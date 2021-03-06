CreateConVar("ttt_aspectator_display_role", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("ttt_aspectator_enable_wallhack", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("ttt_aspectator_display_wallhack_role", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("ttt_aspectator_admin_only", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("ttt_aspectator_admin_wallhack", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE})

hook.Add("TTTUlxInitCustomCVar", "TTTAdvancedSpectatorInitRWCVar", function(name)
	ULib.replicatedWritableCvar("ttt_aspectator_display_role", "rep_ttt_aspectator_display_role", GetConVar("ttt_aspectator_display_role"):GetBool(), true, false, name)
	ULib.replicatedWritableCvar("ttt_aspectator_enable_wallhack", "rep_ttt_aspectator_enable_wallhack", GetConVar("ttt_aspectator_enable_wallhack"):GetBool(), true, false, name)
	ULib.replicatedWritableCvar("ttt_aspectator_display_wallhack_role", "rep_ttt_aspectator_display_wallhack_role", GetConVar("ttt_aspectator_display_wallhack_role"):GetBool(), true, false, name)
	ULib.replicatedWritableCvar("ttt_aspectator_admin_only", "rep_ttt_aspectator_admin_only", GetConVar("ttt_aspectator_admin_only"):GetBool(), true, false, name)
	ULib.replicatedWritableCvar("ttt_aspectator_admin_wallhack", "rep_ttt_aspectator_admin_wallhack", GetConVar("ttt_aspectator_admin_wallhack"):GetBool(), true, false, name)
end)

if SERVER then
	AddCSLuaFile()

	-- ConVar replication is broken in GMod, so we do this, at least Alf added a hook!
	-- I don't like it any more than you do, dear reader. Copycat!
	hook.Add("TTT2SyncGlobals", "ttt2_aspectator_sync_convars", function()
		SetGlobalBool("ttt_aspectator_display_role", GetConVar("ttt_aspectator_display_role"):GetBool())
		SetGlobalBool("ttt_aspectator_enable_wallhack", GetConVar("ttt_aspectator_enable_wallhack"):GetBool())
		SetGlobalBool("ttt_aspectator_display_wallhack_role", GetConVar("ttt_aspectator_display_wallhack_role"):GetBool())
		SetGlobalBool("ttt_aspectator_admin_only", GetConVar("ttt_aspectator_admin_only"):GetBool())
		SetGlobalBool("ttt_aspectator_admin_wallhack", GetConVar("ttt_aspectator_admin_wallhack"):GetBool())
	end)

	-- sync convars on change
	cvars.AddChangeCallback("ttt_aspectator_display_role", function(cv, old, new)
		SetGlobalBool("ttt_aspectator_display_role", tobool(tonumber(new)))
	end)
	cvars.AddChangeCallback("ttt_aspectator_enable_wallhack", function(cv, old, new)
		SetGlobalBool("ttt_aspectator_enable_wallhack", tobool(tonumber(new)))
	end)
	cvars.AddChangeCallback("ttt_aspectator_display_wallhack_role", function(cv, old, new)
		SetGlobalBool("ttt_aspectator_display_wallhack_role", tobool(tonumber(new)))
	end)
	cvars.AddChangeCallback("ttt_aspectator_admin_only", function(cv, old, new)
		SetGlobalBool("ttt_aspectator_admin_only", tobool(tonumber(new)))
	end)
	cvars.AddChangeCallback("ttt_aspectator_admin_wallhack", function(cv, old, new)
		SetGlobalBool("ttt_aspectator_admin_wallhack", tobool(tonumber(new)))
	end)
end

if CLIENT then
	hook.Add("TTTUlxModifyAddonSettings", "TTTAdvancedSpectatorModifySettings", function(name)
		local tttrspnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

		-- Chat Messages
		local tttrsclp = vgui.Create("DCollapsibleCategory", tttrspnl)
		tttrsclp:SetSize(390, 100)
		tttrsclp:SetExpanded(1)
		tttrsclp:SetLabel("UI")

		local tttrslst = vgui.Create("DPanelList", tttrsclp)
		tttrslst:SetPos(5, 25)
		tttrslst:SetSize(390, 100)
		tttrslst:SetSpacing(5)

		tttrslst:AddItem(xlib.makecheckbox{
			label = "ttt_aspectator_display_role (Def. 1)",
			repconvar = "rep_ttt_aspectator_display_role",
			parent = tttrslst
		})

		tttrslst:AddItem(xlib.makecheckbox{
			label = "ttt_aspectator_admin_only (Def. 0)",
			repconvar = "rep_ttt_aspectator_admin_only",
			parent = tttrslst
		})

		tttrslst:AddItem(xlib.makecheckbox{
			label = "ttt_aspectator_admin_wallhack (Def. 0)",
			repconvar = "rep_ttt_aspectator_admin_wallhack",
			parent = tttrslst
		})

		tttrslst:AddItem(xlib.makelabel{
			label = "Enabling this admin wallhack feature here does not start it automatically. A key needs to be bound in the bindings menue as well. The key is used to toggle the wallhack.",
			x = 0,
			y = 0,
			w = 410,
			wordwrap = true,
			parent = tttrslst
		})


		-- Popup
		local tttrsclp2 = vgui.Create("DCollapsibleCategory", tttrspnl)
		tttrsclp2:SetSize(390, 50)
		tttrsclp2:SetExpanded(1)
		tttrsclp2:SetLabel("Wallhack")

		local tttrslst2 = vgui.Create("DPanelList", tttrsclp2)
		tttrslst2:SetPos(5, 25)
		tttrslst2:SetSize(390, 50)
		tttrslst2:SetSpacing(5)

		tttrslst2:AddItem(xlib.makecheckbox{
			label = "ttt_aspectator_enable_wallhack (Def. 1)",
			repconvar = "rep_ttt_aspectator_enable_wallhack",
			parent = tttrslst2
		})

		tttrslst2:AddItem(xlib.makecheckbox{
			label = "ttt_aspectator_display_wallhack_role (Def. 1)",
			repconvar = "rep_ttt_aspectator_display_wallhack_role",
			parent = tttrslst2
		})


		xgui.hookEvent("onProcessModules", nil, tttrspnl.processModules)
		xgui.addSubModule("Advanced Spectator", tttrspnl, nil, name)
	end)
end