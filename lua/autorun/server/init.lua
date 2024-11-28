
local playerHitCount = {}

function GetPlayerHitCount(player)
    if IsValid(player) then
        local playerID = player:SteamID()
        return playerHitCount[playerID] or 0
    end
    return nil
end

util.AddNetworkString("UpdateHitCount")
util.AddNetworkString("ApplyDamageToTarget")

function SendHitCountToClient(player)
    local hitCount = GetPlayerHitCount(player)
    net.Start("UpdateHitCount")
    net.WriteInt(hitCount, 32)
    net.Send(player)
end

hook.Add("EntityTakeDamage", "CancelPlayerDamage", function(target, dmginfo)

    if target:IsPlayer() then
        local weapon = target:GetActiveWeapon()
        local playerID = target:SteamID() 
 
        if IsValid(weapon) and weapon.canParry then

            dmginfo:SetDamage(0)
            target:SetAnimation(PLAYER_ATTACK1)

            target:EmitSound("physics/body/body_medium_impact_hard1.wav")

            local attacker = dmginfo:GetAttacker()
            if IsValid(attacker) then
                local particleName = "[0]_chakra_restore"
                local attachment = target:LookupBone("ValveBiped.Bip01_R_Foot")

                if attachment then
                    ParticleEffectAttach(particleName, PATTACH_ABSORIGIN_FOLLOW, target, attachment)
                end



                if attacker:IsPlayer() then
                    attacker:Freeze(true)

                    timer.Simple(0.5, function()
                        if IsValid(attacker) then
                                    
                            attacker:Freeze(false)
                        end
                    end)
                end

                timer.Simple(0.5, function()
                    target:StopParticles()
                end)
            end
        

            -- --playerHitCount[playerID] = 0
            -- if not playerHitCount[playerID] then
            --     playerHitCount[playerID] = 0
            -- end

            -- if playerHitCount[playerID] < 3 then
            --     playerHitCount[playerID] = playerHitCount[playerID] + 1
            --     local actualPlayerHitCount = playerHitCount[playerID]
            --     SendHitCountToClient(target)

            --     timer.Simple(3, function()
                 
            --         if playerHitCount[playerID] == actualPlayerHitCount and playerHitCount[playerID] > 0 then
                        
           
            --             if playerHitCount[playerID] == 2 then
            --                 playerHitCount[playerID] = playerHitCount[playerID] - 1
            --                 SendHitCountToClient(target)

            --                 timer.Simple(3, function()
            --                     if playerHitCount[playerID] == 1 then
            --                         playerHitCount[playerID] = playerHitCount[playerID] - 1
            --                         SendHitCountToClient(target)
            --                     end
            --                 end)
                        
                     
            --             elseif playerHitCount[playerID] == 1 then
            --                 playerHitCount[playerID] = playerHitCount[playerID] - 1
            --                 SendHitCountToClient(target)
            --             end
            --         end
            --     end)


            -- end

            -- if playerHitCount[playerID] >= 3 then

            --     dmginfo:SetDamage(50)

            --     target:Freeze(true)

            --     timer.Simple(0.5, function()
            --         if IsValid(target) then
            --             target:Freeze(false)
            --         end
            --     end)
            --     util.ScreenShake(ply:GetPos(), 10, 2, 3, 3000)
            --     target:EmitSound("physics/body/body_medium_break4.wav")
            --     local particleName = "nrp_hit_main"
            --     local attachment = target:LookupBone("ValveBiped.Bip01_R_Foot")

            --     if attachment then
            --         ParticleEffectAttach(particleName, PATTACH_ABSORIGIN_FOLLOW, target, attachment)
            --     end

            --     playerHitCount[playerID] = 0
            --     SendHitCountToClient(target)

            -- else
            
            --     dmginfo:SetDamage(0)
            --     target:SetAnimation(PLAYER_ATTACK1)

            --     target:EmitSound("physics/body/body_medium_impact_hard1.wav")

            --     local attacker = dmginfo:GetAttacker()
            --     if IsValid(attacker) then
            --         local particleName = "[0]_chakra_restore"
            --         local attachment = target:LookupBone("ValveBiped.Bip01_R_Foot")

            --         if attachment then
            --             ParticleEffectAttach(particleName, PATTACH_ABSORIGIN_FOLLOW, target, attachment)
            --         end



            --         if attacker:IsPlayer() then
            --             attacker:Freeze(true)

            --             timer.Simple(0.5, function()
            --                 if IsValid(attacker) then
                                    
            --                     attacker:Freeze(false)
            --                 end
            --             end)
            --         end

            --         timer.Simple(0.5, function()
            --             target:StopParticles()
            --         end)
            --     end
            -- end
        end
    end
end)




net.Receive("ApplyDamageToTarget", function(len, ply)
    local target = net.ReadEntity()
    local damageAmount = net.ReadInt(16)
    local soundToPlay = net.ReadString()

    if IsValid(target) and (target:IsPlayer() or target:IsNPC()) then


        local damageInfo = DamageInfo()
        damageInfo:SetDamage(damageAmount)
        damageInfo:SetAttacker(ply)
        damageInfo:SetInflictor(ply)
        damageInfo:SetDamageType(DMG_BULLET)


        target:TakeDamageInfo(damageInfo)
        target:EmitSound(soundToPlay)

        ParticleEffect("blood_advisor_puncture",target:GetPos() + target:GetForward() * 0 + Vector( 0, 0, 20 ),Angle(0,45,0),nil)
    end
end)
