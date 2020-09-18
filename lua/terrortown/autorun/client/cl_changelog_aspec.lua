hook.Add("TTT2AddChange", "TTT2_role_aspec_changelog", function()
	AddChange("TTT2 AdvancedSpectator - v1.0", [[
		<ul>
			<li>Initial Release</li>
			<li>Added role wallhack for dead players</li>
			<li>Added role info for dead players</li>
		</ul>
	]], os.time({year = 2019, month = 08, day = 28}))

	AddChange("TTT2 AdvancedSpectator - v1.1", [[
		<ul>
			<li>Added admin only feature with a bind to allow admins to see all roles with overheadicon</li>
		</ul>
	]], os.time({year = 2019, month = 10, day = 09}))
end)
