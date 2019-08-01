if CLIENT then
    ASPECTATOR = {}
    ASPECTATOR.requested_initial_data = false

    net.Receive('ttt2_net_aspectator_start_wallhack', function()
        for _, p in pairs(player.GetAll()) do
            ASPECTATOR:AddStencil(p, p:AS_GetRoleColor())
        end
    end)
    net.Receive('ttt2_net_aspectator_stop_wallhack', function()
        marks.Remove(player.GetAll())
    end)

    function ASPECTATOR:AddStencil(ply, clr)
        timer.Simple(0.1, function() 
            if not LocalPlayer():IsSpec() then return end
            if not GetGlobalBool('ttt_aspectator_enable_wallhack', true) then return end

            if not GetGlobalBool('ttt_aspectator_display_wallhack_role', true) then
                clr = Color(255, 50, 50)
            end

            marks.Add({ply}, clr)
        end)
    end



    hook.Add('SetupMove', 'ttt2_aspectator_request_initial_data', function()
        if not LocalPlayer() or not IsValid(LocalPlayer()) or not LocalPlayer():IsPlayer() then return end

        if ASPECTATOR.requested_initial_data then return end

        net.Start('ttt2_net_aspectator_request_initial_data')
        net.WriteEntity(LocalPlayer())
        net.SendToServer()

        ASPECTATOR.requested_initial_data = true
    end)
end