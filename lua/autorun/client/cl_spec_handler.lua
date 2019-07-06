if CLIENT then
    ASPECTATOR = {}
    ASPECTATOR.player = {}

    net.Receive('ttt2_net_aspectator_add_player', function() 
        local id = net.ReadUInt(16)
        local ply = net.ReadEntity()

        ASPECTATOR.player[id] = {}
        ASPECTATOR.player[id].ply = ply
    end)
    net.Receive('ttt2_net_aspectator_remove_player', function() 
        local ply = net.ReadEntity()

        ASPECTATOR.player[ply:UserID()] = nil        
    end)

    net.Receive('ttt2_net_aspectator_change_weapon', function()
        local ply = net.ReadEntity()

        if not ASPECTATOR.player[ply:UserID()] then return end
        
        ASPECTATOR.player[ply:UserID()].weapon = net.ReadEntity()
        ASPECTATOR.player[ply:UserID()].wep_clip = net.ReadInt(16)
        ASPECTATOR.player[ply:UserID()].wep_clip_max = net.ReadInt(16)
        ASPECTATOR.player[ply:UserID()].wep_ammo = net.ReadInt(16)
    end)

    net.Receive('ttt2_net_aspectator_update_weapon', function()
        local ply = net.ReadEntity()
        
        if not ASPECTATOR.player[ply:UserID()] then return end

        ASPECTATOR.player[ply:UserID()].wep_clip = net.ReadInt(16)
        ASPECTATOR.player[ply:UserID()].wep_clip_max = net.ReadInt(16)
        ASPECTATOR.player[ply:UserID()].wep_ammo = net.ReadInt(16)
    end)
    
    net.Receive('ttt2_net_aspectator_update_role', function()
        local ply = net.ReadEntity()

        if not ply or not ply['UserID'] then return end
        
        if not ASPECTATOR.player[ply:UserID()] then return end

        local role = GetRoleByIndex(net.ReadUInt(ROLE_BITS))

        ASPECTATOR.player[ply:UserID()].role = role
        ASPECTATOR.player[ply:UserID()].role_c = {}
        ASPECTATOR.player[ply:UserID()].role_c.r = net.ReadUInt(8)
        ASPECTATOR.player[ply:UserID()].role_c.g = net.ReadUInt(8)
        ASPECTATOR.player[ply:UserID()].role_c.b = net.ReadUInt(8)
        ASPECTATOR.player[ply:UserID()].role_c.a = net.ReadUInt(8)
    end)

    function ASPECTATOR:GetRole(ply)
        if ply and ply['UserID'] then
            return self.player[ply:UserID()].role
        else
            return GetRoleByIndex(1)
        end
    end

    function ASPECTATOR:GetRoleColor(ply)
        if ply and ply['UserID'] then
            return self.player[ply:UserID()].role_c
        else
            return GetRoleByIndex(1).color
        end
    end

    function ASPECTATOR:GetPlayer(ply)
        if ply and ply['UserID'] then
            return self.player[ply:UserID()].ply
        else
            return LocalPlayer()
        end
    end

    function ASPECTATOR:GetWeapon(ply)
        if ply and ply['UserID'] then
            return self.player[ply:UserID()].wep_clip, self.player[ply:UserID()].wep_clip_max, self.player[ply:UserID()].wep_ammo
        else
            return -1, -1, -1
        end
    end
end