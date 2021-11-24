CLGAMEMODESUBMENU.base = "base_gamemodesubmenu"

CLGAMEMODESUBMENU.priority = 0
CLGAMEMODESUBMENU.title = "submenu_server_addons_advancedspectator_title"

function CLGAMEMODESUBMENU:Populate(parent)
	local form = vgui.CreateTTT2Form(parent, "header_addons_advancedspectator_hud")

	form:MakeCheckBox({
		serverConvar = "ttt_aspectator_display_role",
		label = "label_aspectator_display_role"
	})

	form:MakeCheckBox({
		serverConvar = "ttt_aspectator_admin_only",
		label = "label_aspectator_admin_only"
	})

	local form2 = vgui.CreateTTT2Form(parent, "header_addons_advancedspectator_wallhack")

	local masterEnb = form2:MakeCheckBox({
		serverConvar = "ttt_aspectator_enable_wallhack",
		label = "label_aspectator_enable_wallhack"
	})

	form2:MakeCheckBox({
		serverConvar = "ttt_aspectator_display_wallhack_role",
		label = "label_aspectator_display_wallhack_role",
		master = masterEnb
	})

	form2:MakeHelp({
		label = "help_aspectator_admin_wallhack"
	})

	form2:MakeCheckBox({
		serverConvar = "ttt_aspectator_admin_wallhack",
		label = "label_aspectator_admin_wallhack"
	})
end
