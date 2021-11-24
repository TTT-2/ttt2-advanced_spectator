CreateConVar("ttt_aspectator_display_role", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("ttt_aspectator_enable_wallhack", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("ttt_aspectator_display_wallhack_role", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("ttt_aspectator_admin_only", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
CreateConVar("ttt_aspectator_admin_wallhack", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE})

if SERVER then
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
