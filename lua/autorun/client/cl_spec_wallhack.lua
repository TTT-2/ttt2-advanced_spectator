if CLIENT then
    hook.Add("PostDrawOpaqueRenderables", "AdvancedSpectatorPlayerBorders", function()
        local client = LocalPlayer()

        if not client:IsSpec() then return end
        if not GetGlobalBool('ttt_aspectator_enable_wallhack', true) then return end

        --stencil work is done in postdrawopaquerenderables, where surface doesn't work correctly
        --workaround via 3D2D
        local ang = client:EyeAngles()
        local pos = client:EyePos() + ang:Forward() * 10

        ang = Angle(ang.p + 90, ang.y, 0)

        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(15)
        render.SetStencilFailOperation(STENCILOPERATION_KEEP)
        render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
        render.SetStencilPassOperation(STENCILOPERATION_KEEP)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
        render.SetBlend(0)

        local ents = player.GetAll() -- ents.FindByClass("prop_physics_multiplayer")

        for _, ply in ipairs(ents) do
            if ply:IsActive() then
                ply:DrawModel()
            end
        end

        render.SetBlend(1)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

        cam.Start3D2D(pos, ang, 1)

        surface.SetDrawColor(255, 50, 50)
        
        --surface.SetDrawColor(clr(ASPECTATOR:GetRoleColor(ply)))

        surface.DrawRect(-ScrW(), -ScrH(), ScrW() * 2, ScrH() * 2)

        cam.End3D2D()

        for _, ply in ipairs(ents) do
            if ply:IsActive() then
                ply:DrawModel()
            end
        end

        render.SetStencilEnable(false)
    end)
end