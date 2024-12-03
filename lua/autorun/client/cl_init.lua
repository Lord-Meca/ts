
hook.Add( "HUDShouldDraw", "RemoveRedScreen", function( name ) 
    if ( name == "CHudDamageIndicator" ) then 
       return false 
    end
end )
-- hook.Add("PlayerBindPress", "DisableMouseWheel", function(ply, bind, pressed)
   
--     if string.find(bind, "invnext") or string.find(bind, "invprev") then
--         return true
--     end
-- end)
-- local parryCD = {}

-- local allowedWeapons = {
--     weapon_standardsword = true,
--     weapon_kiba_nrp = true,
--     weapon_shibuki_nrp = true,
--     weapon_wukong = true
-- }

hook.Add("HUDPaint", "DrawHealthBarAboveEntities", function()
    local ply = LocalPlayer()
    local maxDistance = 1000 


    local function DrawHealthBar(entity)
        if not IsValid(entity) or entity == ply then return end  
        local pos = entity:GetPos() + Vector(0, 0, 80)
        local screenPos = pos:ToScreen()

        if screenPos.visible then
            local distance = ply:GetPos():Distance(entity:GetPos())
            
        
            if distance < maxDistance then
                local scale = math.Clamp(1 / (distance / 500), 0.2, 1)  

                local barWidth = 150 * scale
                local barHeight = 10 * scale
                local healthPercentage = entity:Health() / entity:GetMaxHealth()
                local barColor = Color(255, 0, 0, 255)

                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawRect(screenPos.x - barWidth / 2 - 5, screenPos.y - barHeight / 2 - 5, barWidth + 10, barHeight + 10)

                surface.SetDrawColor(barColor)
                surface.DrawRect(screenPos.x - barWidth / 2, screenPos.y - barHeight / 2, barWidth * healthPercentage, barHeight)
            end
        end
    end

    
    for _, target in ipairs(player.GetAll()) do
        if IsValid(target) and target:Alive() and target ~= ply then
            DrawHealthBar(target)
        end
    end


    for _, npc in ipairs(ents.FindByClass("npc_*")) do
        if IsValid(npc) and npc:Health() > 0 then
            DrawHealthBar(npc)
        end
    end
end)

-- hook.Add("PlayerButtonDown", "DetectKeyPress", function(ply, button)

--     if ply:IsPlayer() and IsValid(ply) then

--         local weapon = ply:GetActiveWeapon()
--         local playerID = ply:SteamID() 

--         if not IsValid(weapon) then return end

--         if allowedWeapons[weapon:GetClass()] then

--             -- if button == KEY_LALT then
--             --     if parryCD[playerID] == nil then 
--             --         parryCD[playerID] = 0 
--             --     end

--             --     if CurTime() < parryCD[playerID] then return end
--             --     parryCD[playerID] = CurTime() + 0.5

--             --     weapon:SetHoldType("sword_parade")
--             --     ply:SetAnimation(PLAYER_ATTACK1)

--             --     weapon.canParry = true

--             --     timer.Simple(3, function()
--             --         weapon:SetHoldType("g_combo1")
--             --         weapon.canParry = false
--             --     end)
--             -- end


--             -- if button == KEY_E then


--             --     if not ply:IsOnGround() or bisectionCD[playerID] then return end
--             --     bisectionCD[playerID] = true
--             --     weapon:SetHoldType("slashdown")
--             --     ply:SetAnimation(PLAYER_ATTACK1)

           

--             --     local attachment = ply:LookupBone("ValveBiped.Bip01_R_Foot")

--             --     if attachment then
--             --         ParticleEffectAttach("[6]_wind_breath", PATTACH_ABSORIGIN_FOLLOW, ply, attachment)
--             --     end

--             --     ply:EmitSound("ambient/fire/mtov_flame2.wav")

--             --     local startPos = ply:EyePos()
--             --     local direction = ply:GetAimVector()
--             --     local endPos = startPos + direction * 600

                
--             --     local trace = {
--             --         start = startPos,
--             --         endpos = endPos,
--             --         filter = ply 
--             --     }
--             --     local traceResult = util.TraceLine(trace)

--             --     local target = traceResult.Entity

               
--             --     if target:IsPlayer() or target:IsNPC() then
--             --         ply:ChatPrint(target:Health() .. " -30")

          
--             --         net.Start("ApplyDamageToTarget")
--             --         net.WriteEntity(target)
--             --         net.WriteInt(30, 16)
--             --         net.WriteString("physics/body/body_medium_break3.wav")
--             --         net.SendToServer()

                
--             --     end
             
--             --     timer.Simple(0.1, function()
--             --         if IsValid(ply) then
--             --             ply:StopParticles() 
--             --         end
--             --     end)

--             --     timer.Simple(5, function()
--             --         bisectionCD[playerID] = false
--             --     end)
--             -- elseif button == KEY_F then
                
--             --     if splitGateCD[playerID] then return end

--             --     weapon:SetHoldType("leapattack")
--             --     ply:SetAnimation(PLAYER_ATTACK1)

--             --     splitGateCD[playerID] = true

--             --     ParticleEffect("nrp_kenjutsu_tranchant",ply:GetPos() + ply:GetForward() * 0 + Vector( 0, 0, 20 ),Angle(0,45,0),nil)

--             --     ply:EmitSound("physics/body/body_medium_impact_hard1.wav")

--             --     local entities = ents.FindInSphere(ply:GetPos(), 100)
--             --     for _, entity in pairs(entities) do
--             --         if (entity:IsPlayer() or entity:IsNPC()) and entity ~= ply then

--             --             net.Start("ApplyDamageToTarget")
--             --             net.WriteEntity(entity)
--             --             net.WriteInt(100, 16)
--             --             net.WriteString("physics/body/body_medium_break3.wav")
--             --             net.SendToServer()
--             --             ply:ChatPrint(entity:Health() .. " -100")

--             --             if IsValid(target) then
--             --                 target:Freeze( true )
--             --                 timer.Simple(1, function()
--             --                     if IsValid(target) then 
--             --                         target:Freeze( false )
--             --                     end 
--             --                 end)
--             --             end
--             --         end
--             --     end

--             --     timer.Simple(10, function()
--             --         splitGateCD[playerID] = false
--             --     end)
--             -- end

--         end
--     end
-- end)

