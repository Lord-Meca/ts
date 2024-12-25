AddCSLuaFile()

SWEP.PrintName = "Jinton | Kekkei Genkai"
SWEP.Author = "Lord_Meca"
SWEP.Instructions = ""

SWEP.Base = "weapon_base"

SWEP.Category = "TypeShit | Armes"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = "models/foc/ska/maskonoki.mdl"

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.NextSpecialMove = 0
SWEP.NextJintonLaser = 0
SWEP.NextJintonPrison = 0

function SWEP:Deploy()
    self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_ym_ohnoki.mdl")
end

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

local function cubeJinton(ply, self,cubePos,onPlayer,duration,damage)
    if not IsValid(ply) then return end

    local affectedNearbyEntities = {}


    local modelCube = ents.Create("prop_physics")

    if not IsValid(modelCube) then return end
    local modelCone = ents.Create("prop_physics")
    if onPlayer then
  
        if not IsValid(modelCone) then return end
        ply:SetVelocity(Vector(0, 0, 600))
        timer.Simple(1, function()
    
        
            modelCone:SetModel("models/fsc/billy/conejinton.mdl")
            modelCone:SetPos(ply:GetPos()-Vector(0,0,40))
            modelCone:SetModelScale(0.5)
            modelCone:SetAngles(Angle(0,0,180))
            modelCone:Spawn()
            modelCone:SetMoveType(MOVETYPE_NOCLIP)
            ply:SetMoveType(MOVETYPE_NONE)
            self:SetHoldType("weapon_art2")
            ply:SetAnimation(PLAYER_RELOAD)
        end)
    end
  





    modelCube:SetModel("models/fsc/billy/cubeonoki.mdl")
    modelCube:SetPos(cubePos)
    modelCube:SetModelScale(0.3)
    modelCube:Spawn()
    modelCube:SetMoveType(MOVETYPE_NOCLIP)

    local currentScale = 0.1
    local targetScale = 6
    local scaleIncrement = (targetScale - currentScale) / (duration * 10)

    timer.Create("CubeJintonEffect_" .. modelCube:EntIndex(), 0.1, duration * 10, function()
        if IsValid(modelCube) then
            if onPlayer then
                if self:GetHoldType() == "weapon_art2" then
                    ply:SetAnimation(PLAYER_RELOAD)
                end
            end

            if not onPlayer then
                local currentAngles = modelCube:GetAngles()
                local newAngles = currentAngles + Angle(10, 10, 10) 
                modelCube:SetAngles(newAngles)
            end

        
            currentScale = currentScale + scaleIncrement
            modelCube:SetModelScale(currentScale, 0)

            for _, entity in pairs(ents.FindInSphere(modelCube:GetPos(), 60 * currentScale)) do
                if IsValid(entity) and (entity:IsPlayer() or entity:IsNPC()) then
                    if entity ~= ply and not affectedNearbyEntities[entity] then
                        local damageInfo = DamageInfo()
                        damageInfo:SetDamage(damage)
                        damageInfo:SetDamageType(DMG_BLAST)
                        damageInfo:SetAttacker(ply)
                        damageInfo:SetInflictor(ply)

                        entity:TakeDamageInfo(damageInfo)

                        affectedNearbyEntities[entity] = true

                        net.Start("DisplayDamage")
                        net.WriteInt(damage, 32)
                        net.WriteEntity(entity)
                        net.WriteColor(Color(51, 125, 255, 255))
                        net.Send(ply)
                    end
                end
            end
        else
            timer.Remove("CubeJintonEffect_" .. modelCube:EntIndex())
        end
    end)

    timer.Simple(duration, function()
        if IsValid(ply) then
            ply:SetMoveType(MOVETYPE_WALK)
        end

        if IsValid(modelCube) then
            modelCube:Remove()
            if onPlayer then

                modelCone:Remove()
                self:SetHoldType("anim_invoke")
                ply:SetAnimation(PLAYER_ATTACK1)
            end
            timer.Remove("CubeJintonEffect_" .. modelCube:EntIndex())
        end
    end)
end

local function cylindreLaserJinton(ply, self)
    if not IsValid(ply) then return end

    local duration = 2
    local damage = 100
    local maxDistance = 1000
    local forward = 700
    local affectedNearbyEntities = {}

    local trace = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * maxDistance,
        filter = ply
    })

    local spawnPos = ply:GetPos() + ply:EyeAngles():Forward() * forward

    local modelCylindre = ents.Create("prop_physics")
    if not IsValid(modelCylindre) then return end

    modelCylindre:SetModel("models/fsc/billy/cylindreonoki.mdl")
    modelCylindre:SetPos(spawnPos + Vector(0, 0, 50))
    modelCylindre:SetModelScale(3)
    modelCylindre:Spawn()
    modelCylindre:SetMoveType(MOVETYPE_NOCLIP)

    local forwardDir = ply:EyeAngles():Forward()
    local angles = forwardDir:Angle()
    angles:RotateAroundAxis(angles:Right(), 90)

    modelCylindre:SetAngles(angles + Angle(0, 90, 0))

    ply:SetNWBool("freezePlayer", true)

    local currentScale = 3
    local targetScale = 0.1
    local scaleIncrement = (currentScale - targetScale) / (duration * 10)

    timer.Create("CylindreLaserEffect_" .. modelCylindre:EntIndex(), 0.1, duration * 10, function()
        if IsValid(modelCylindre) then
          
            currentScale = currentScale - scaleIncrement
            modelCylindre:SetModelScale(currentScale, 0)

            local adjustedForward = (currentScale > 0.5 and forward or forward * 0.4)
            modelCylindre:SetPos(ply:GetPos() + Vector(0, 0, 50) + forwardDir * adjustedForward)

         
            if currentScale <= targetScale then
                
                if(self:GetHoldType() == "weapon_art2") then
                    self:SetHoldType("anim_launch") 
                    ply:SetAnimation(PLAYER_ATTACK1)
                    ply:SetNWBool("freezePlayer", false )
                
                end
                util.SpriteTrail(modelCylindre, 0, Color(255,255,255), false, 10, 10, 1, 50, "trails/laser.vmt")
                local velocity = forwardDir * 1500
                modelCylindre:SetVelocity(velocity)

          
                timer.Create("CylindreLaserImpact_" .. modelCylindre:EntIndex(), 0.1, 0, function()
                    if not IsValid(modelCylindre) then return end
                    
              
                    local traceImpact = util.TraceLine({
                        start = modelCylindre:GetPos(),
                        endpos = modelCylindre:GetPos() + velocity * 0.1,
                        filter = modelCylindre
                    })

                  
                    if traceImpact.Hit then
                     
                      

                        cubeJinton(ply, self,modelCylindre:GetPos(),false,5,600)
                        modelCylindre:Remove()
                        timer.Remove("CylindreLaserImpact_" .. modelCylindre:EntIndex())
                    end
                end)


                timer.Remove("CylindreLaserEffect_" .. modelCylindre:EntIndex())
            end

        else
            timer.Remove("CylindreLaserEffect_" .. modelCylindre:EntIndex())
        end
    end)


end

-- local function chainConeJinton(ply, self)
--     if not IsValid(ply) then return end

--     local coneCount = 5
--     local coneDistance = 200 
--     local coneModel = "models/fsc/billy/conejinton.mdl"
--     local coneScale = 0.3 
--     local ropeWidth = 1 
--     local ropeMaterial = "cable/cable2"
--     local lifetime = 5 
--     local spawnDelay = 0.3 
--     local coneEntities = {}

--     local function spawnCones()
--         for i = 1, coneCount do
--             timer.Simple(spawnDelay * i, function()
--                 if not IsValid(ply) then return end

--                 local forwardOffset = ply:EyeAngles():Forward() * (coneDistance * i)
--                 local spawnPos = ply:GetPos() + forwardOffset + Vector(0, 0, 50)

--                 local cone = ents.Create("prop_physics")
--                 if IsValid(cone) then
--                     cone:SetModel(coneModel)
--                     cone:SetPos(spawnPos)
--                     cone:SetAngles(Angle(0, 0, 0))
--                     cone:SetModelScale(coneScale)
--                     cone:Spawn()
--                     cone:SetMoveType(MOVETYPE_NOCLIP)
--                     table.insert(coneEntities, cone)

--                     if i > 1 and IsValid(coneEntities[i - 1]) then
--                         constraint.Rope(
--                             coneEntities[i - 1],
--                             cone,
--                             0,
--                             0,
--                             Vector(0, 0, 0),
--                             Vector(0, 0, 0),
--                             coneDistance,
--                             100,
--                             0,
--                             ropeWidth,
--                             ropeMaterial,
--                             Color(255, 255, 255)
--                         )
--                     end

--                     if i == 1 then
--                         constraint.Rope(
--                             cone,
--                             ply,
--                             0,
--                             0,
--                             Vector(0, 0, 0),
--                             Vector(0, 0, 50),
--                             coneDistance,
--                             100,
--                             0,
--                             ropeWidth,
--                             ropeMaterial,
--                             Color(255, 255, 255)
--                         )
--                     end
--                 end
--             end)
--         end
--     end

--     local function activateConeMovement()
--         local followTimerName = "FollowConeDirection_" .. ply:EntIndex()
--         timer.Create(followTimerName, 0.5, lifetime / 0.05, function()
--             if not IsValid(ply) then
--                 timer.Remove(followTimerName)
--                 return
--             end

--             local forwardDir = ply:EyeAngles():Forward()
--             for i, cone in ipairs(coneEntities) do
--                 if IsValid(cone) then
                   
--                     local randomOffset = Vector(
--                         math.random(-60, 70),
--                         math.random(-60, 70),
--                         math.random(-20, 25)
--                     )
--                     local targetPos = ply:GetPos() + forwardDir * (coneDistance * i) + Vector(0, 0, 50) + randomOffset
--                     cone:SetPos(targetPos)
--                 end
--             end
--         end)

--         timer.Simple(lifetime, function()
--             timer.Remove(followTimerName)
--             for _, cone in ipairs(coneEntities) do
--                 if IsValid(cone) then
--                     cone:Remove()
--                 end
--             end
--         end)
--     end

--     spawnCones()
--     timer.Simple(coneCount * spawnDelay + 0.1, function()
--         activateConeMovement()
--     end)
-- end

local function prisonConeJinton(ply, self, target)
    if not IsValid(target) then return end

    local coneModel = "models/fsc/billy/conejinton.mdl"
    local coneScale = 1
    local targetHeight = 300
    local targetDuration = 3
    local coneDuration = targetDuration + 3
    local nextParticleTime = CurTime() + 0.5
    local tickDamage = 75

    local function createCone(position, angle)
        local cone = ents.Create("prop_physics")
        if not IsValid(cone) then return nil end
        cone:SetModel(coneModel)
        cone:SetPos(position)
        cone:SetAngles(angle)
        cone:SetModelScale(coneScale)
        cone:Spawn()
        cone:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        cone:SetSolid(SOLID_NONE)
        return cone
    end

    local spawnPos = target:GetPos() - Vector(0, 0, 50)


    local coneBottom = createCone(spawnPos, Angle(0, 0, 180))
    local coneTop = createCone(spawnPos + Vector(0, 0, 150), Angle(0, 0, 0))

    if not IsValid(coneBottom) or not IsValid(coneTop) then return end

    local startTime = CurTime()
    local initialPosBottom = coneBottom:GetPos()
    local initialPosTop = coneTop:GetPos()
    local targetPosBottom = initialPosBottom + Vector(0, 0, targetHeight)
    local targetPosTop = initialPosTop + Vector(0, 0, targetHeight)

    local originalMoveType = target:GetMoveType()
    target:SetMoveType(MOVETYPE_NONE) 
   
    local function animateCone()
        if not IsValid(coneBottom) or not IsValid(coneTop) then return end

        local elapsedTime = CurTime() - startTime
        local progress = math.Clamp(elapsedTime / targetDuration, 0, 1)

        local newPosBottom = LerpVector(progress, initialPosBottom, targetPosBottom)
        coneBottom:SetPos(newPosBottom)

        local newPosTop = LerpVector(progress, initialPosTop, targetPosTop)
        coneTop:SetPos(newPosTop)

        if elapsedTime < 3 then
            target:SetPos(newPosBottom)
            
        else
            if CurTime() >= nextParticleTime then
               
                ParticleEffect("nrp_kenjutsu_slash", target:GetPos(), Angle(0, 0, 0), nil)
                local damageInfo = DamageInfo()
                damageInfo:SetDamage(tickDamage)
                damageInfo:SetDamageType(DMG_BLAST)
                damageInfo:SetAttacker(ply)
                damageInfo:SetInflictor(ply)

                target:TakeDamageInfo(damageInfo)

                net.Start("DisplayDamage")
                net.WriteInt(tickDamage, 32)
                net.WriteEntity(target)
                net.WriteColor(Color(51, 125, 255, 255))
                net.Send(ply)
                
                nextParticleTime = CurTime() + 0.5
            end
        end
     
    end

    local thinkHook = "PrisonConeAnimation_" .. coneBottom:EntIndex()
    hook.Add("Think", thinkHook, function()
        if not IsValid(coneBottom) then
            hook.Remove("Think", thinkHook)
            return
        end
        animateCone()
    end)

    timer.Simple(coneDuration, function()

        if IsValid(ply) then
            target:SetMoveType(originalMoveType) 
        end

        if IsValid(coneBottom) then
            coneBottom:Remove()
        end
        if IsValid(coneTop) then
            coneTop:Remove()
        end

        hook.Remove("Think", thinkHook)
    end)
end




function SWEP:Reload()
    local ply = self.Owner

    if CurTime() < self.NextSpecialMove then return end
    self.NextSpecialMove = CurTime() + 2

    self:SetHoldType("anim_ninjutsu2")
    ply:SetAnimation(PLAYER_RELOAD)

    local trace = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 1000,
        filter = ply 
    })

    local cubePos = trace.HitPos 
    if trace.HitWorld then
        cubePos = cubePos + trace.HitNormal * 10 
    end

    if SERVER then
        cubeJinton(ply, self,cubePos,true,3,300)
    end
end

hook.Add("PlayerButtonDown", "jintonSweps", function(ply, button)

	local activeWeapon = ply:GetActiveWeapon()

    if not IsValid(activeWeapon) or activeWeapon:GetClass() ~= "jinton_kg" then
        return
    end

   if button == KEY_E then

		if ply:GetNWBool("freezePlayer") or CurTime() < activeWeapon.NextJintonLaser then
			return
		end
        activeWeapon.NextJintonLaser = CurTime() + 2
        activeWeapon:SetHoldType("weapon_art2")
        ply:SetAnimation(PLAYER_RELOAD)
        if SERVER then
            cylindreLaserJinton(ply,activeWeapon)
        end
	
	elseif button == KEY_F then

		if ply:GetNWBool("freezePlayer") or CurTime() < activeWeapon.NextJintonPrison then
			return
		end

        activeWeapon.NextJintonPrison = CurTime() + 2
        local maxDistance = 2000
        local radius = 300

        local trace = ply:GetEyeTrace()
        local target = trace.Entity
        if not (IsValid(target) and target:IsPlayer() and trace.HitPos:DistToSqr(ply:GetPos()) <= maxDistance ^ 2) then

            local hitPos = trace.HitPos
            for _, ent in ipairs(ents.FindInSphere(hitPos, radius)) do
                if ent:IsPlayer() and ent ~= ply then
                    target = ent
             
                    break
                end
            end

            if not (IsValid(target) and target:IsPlayer()) then
                return
            end
        end

    
       
        activeWeapon:SetHoldType("anim_invoke")
        ply:SetAnimation(PLAYER_ATTACK1)


        if SERVER then
            prisonConeJinton(ply,activeWeapon,target)
        end
	
	end

	
end)
