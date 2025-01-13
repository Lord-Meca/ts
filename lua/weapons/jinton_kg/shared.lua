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
SWEP.NextJintonZone = 0
SWEP.NextJintonFinal = 0

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

local function cubeJinton(ply, self,cubePos,onPlayer,duration,damage,targetScale)
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
        if onPlayer then
            if IsValid(ply) then
                ply:SetMoveType(MOVETYPE_WALK)
            end
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

    local duration = 1
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
                     
                      

                        cubeJinton(ply, self,modelCylindre:GetPos(),false,5,600,6)
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



local function launchConeJintonMode(ply, self,damage)
    if not IsValid(ply) then return end

    local duration = 10
    local initialScale = 0.1
    local laserVelocity = ply:EyeAngles():Forward() * 1500
    local spawnPos = ply:GetPos() + Vector(0, 0, 50) + ply:EyeAngles():Forward() * 200

    local modelCone = ents.Create("prop_physics")
    if not IsValid(modelCone) then return end

    modelCone:SetModel("models/fsc/billy/conejinton.mdl")
    modelCone:SetPos(spawnPos)
    modelCone:SetAngles(ply:EyeAngles() + Angle(0, 0, 90))
    modelCone:SetModelScale(initialScale)
    modelCone:Spawn()
    modelCone:SetMoveType(MOVETYPE_NOCLIP)

    modelCone:SetVelocity(laserVelocity)


    local function checkImpact()
        if not IsValid(modelCone) then return end


        local traceImpact = util.TraceLine({
            start = modelCone:GetPos(),
            endpos = modelCone:GetPos() + laserVelocity * 0.1,
            filter = modelCone
        })

      
        if traceImpact.Hit then
    
            local hitEntity = traceImpact.Entity
            if IsValid(hitEntity) and (hitEntity:IsPlayer() or hitEntity:IsNPC()) then
                local damageInfo = DamageInfo()
                damageInfo:SetDamage(damage)
                damageInfo:SetDamageType(DMG_BLAST)
                damageInfo:SetAttacker(ply)
                damageInfo:SetInflictor(ply)

                hitEntity:TakeDamageInfo(damageInfo)

                net.Start("DisplayDamage")
                net.WriteInt(damage, 32)
                net.WriteEntity(hitEntity)
                net.WriteColor(Color(51, 125, 255, 255))
                net.Send(ply)
                modelCone:Remove()
            else

                if IsValid(modelCone) then
                    cubeJinton(ply, self, modelCone:GetPos(), false, 5, 150,3)
                    modelCone:Remove()
                end
            end
        end
    end

    timer.Create("launchConeJinton_" .. modelCone:EntIndex(), 0.1, duration * 10, checkImpact)

    timer.Simple(duration, function()
        if IsValid(modelCone) then
            modelCone:Remove()
        end
        timer.Remove("launchConeJinton_" .. modelCone:EntIndex()) 
    end)
end

local function cubeLaserJintonMode(ply, self)
    if not IsValid(ply) then return end

    local duration = 10
    local maxScale = 5
    local initialScale = 0.1
    local scaleStep = (maxScale - initialScale) / (duration * 10)
   
    local spawnPos = ply:GetPos() + Vector(0, 0, 150)
    local cubeModelPath = "models/fsc/billy/cubeonoki.mdl"
    local trailMaterial = "trails/laser.vmt"

    local modelCube = ents.Create("prop_physics")
    if not IsValid(modelCube) then return end

    modelCube:SetModel(cubeModelPath)
    modelCube:SetPos(spawnPos)
    modelCube:SetModelScale(initialScale)
    modelCube:Spawn()
    modelCube:SetMoveType(MOVETYPE_NOCLIP)

    ply:SetNWBool("freezePlayer", true)

    local function finalizeCube()
        if not IsValid(modelCube) then return end
        local laserVelocity = ply:EyeAngles():Forward() * 1500
        ply:SetNWBool("freezePlayer", false)

        util.SpriteTrail(modelCube, 0, Color(255, 255, 255), false, 10, 10, 1, 50, trailMaterial)
        modelCube:SetVelocity(laserVelocity)

        timer.Create("CubeLaserJintonImpact_" .. modelCube:EntIndex(), 0.1, 0, function()
            if not IsValid(modelCube) then
                timer.Remove("CubeLaserJintonImpact_" .. modelCube:EntIndex())
                return
            end

            local traceImpact = util.TraceLine({
                start = modelCube:GetPos(),
                endpos = modelCube:GetPos() + laserVelocity * 0.1,
                filter = modelCube
            })

            if traceImpact.Hit then
                cubeJinton(ply, self, modelCube:GetPos(), false, 2, 750,10)
                modelCube:Remove()
                timer.Remove("CubeLaserJintonImpact_" .. modelCube:EntIndex())
            end
        end)
    end

    timer.Create("CubeLaserJintonScale_" .. modelCube:EntIndex(), 0.1, duration * 10, function()
        if not IsValid(modelCube) then
            timer.Remove("CubeLaserJintonScale_" .. modelCube:EntIndex())
            return
        end

        local newScale = modelCube:GetModelScale() + scaleStep
        modelCube:SetModelScale(newScale, 0)

        local newAngles = modelCube:GetAngles() + Angle(10, 10, 10)
        modelCube:SetAngles(newAngles)

        if newScale >= 1 then
            finalizeCube()
            timer.Remove("CubeLaserJintonScale_" .. modelCube:EntIndex())
        end
    end)
end

local function growCylindreJintonMode(ply, self, max)
    if not SERVER then return end

    local modelPath = "models/fsc/billy/cylindreonoki.mdl"
    local animationDuration = 0.5
    local entityLifetime = 5
    local interval = 0.1
    local verticalOffset = Vector(0, 0, 100)

    for i = 1, max do
        timer.Simple(i * interval, function()
            if not IsValid(ply) then return end

            local traceStart = ply:GetPos() + ply:EyeAngles():Forward() * 150 * i + verticalOffset
            local traceEnd = traceStart - Vector(0, 0, 400)

            local traceData = {
                start = traceStart,
                endpos = traceEnd,
                filter = ply
            }

            local traceResult = util.TraceLine(traceData)
            if not traceResult.Hit then return end

            local modelEntity = ents.Create("prop_physics")
            if not IsValid(modelEntity) then return end

            modelEntity:SetModel(modelPath)
            modelEntity:SetPos(traceResult.HitPos - Vector(0, 0, 200))
            modelEntity:SetAngles(Angle(0, 0, 90))
            modelEntity:SetModelScale(1)
            modelEntity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            modelEntity:Spawn()

            local physObj = modelEntity:GetPhysicsObject()
            if IsValid(physObj) then
                physObj:EnableMotion(false)
            end

            local startPos = modelEntity:GetPos()
            local endPos = traceResult.HitPos + Vector(0, 0, 20)
            local startTime = CurTime()

            timer.Create("AnimateEntity_" .. modelEntity:EntIndex(), 0.02, animationDuration / 0.02, function()
                if not IsValid(modelEntity) then
                    timer.Remove("AnimateEntity_" .. modelEntity:EntIndex())
                    return
                end

                local elapsed = CurTime() - startTime
                local progress = math.Clamp(elapsed / animationDuration, 0, 1)

                modelEntity:SetPos(LerpVector(progress, startPos, endPos))
                self:SetHoldType("normal")
                ply:SetAnimation(PLAYER_ATTACK1)

                if progress >= 1 then
                    timer.Remove("AnimateEntity_" .. modelEntity:EntIndex())

                    for _, entity in ipairs(ents.FindInSphere(modelEntity:GetPos(), 250)) do
                        if (entity:IsPlayer() and entity ~= ply) or entity:IsNPC() then
                            entity:SetVelocity(Vector(0, 0, 600))
                        end
                    end
                end
            end)

            timer.Simple(entityLifetime, function()
                if IsValid(modelEntity) then
                    modelEntity:Remove()
                end
            end)
        end)
    end
end


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
                damageInfo:SetInflictor(self)

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

    if CurTime() < self.NextSpecialMove or ply:GetNWBool("jintonModePlayer") then return end
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
        cubeJinton(ply, self,cubePos,true,3,300,6)
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
        activeWeapon.NextJintonLaser = CurTime() + 5
        
        if ply:GetNWBool("jintonModePlayer") then
            activeWeapon:SetHoldType("anim_ninjutsu3")
            ply:SetAnimation(PLAYER_ATTACK1)
            if SERVER then
                cubeLaserJintonMode(ply,self)
            end

            return
        end
        
        activeWeapon:SetHoldType("weapon_art2")
        ply:SetAnimation(PLAYER_RELOAD)
        if SERVER then
            cylindreLaserJinton(ply,activeWeapon)
        end
	
	elseif button == KEY_F then

		if ply:GetNWBool("freezePlayer") or CurTime() < activeWeapon.NextJintonPrison then
			return
		end

        activeWeapon.NextJintonPrison = CurTime() + 0.5

        if ply:GetNWBool("jintonModePlayer") then
            activeWeapon:SetHoldType("anim_invoke")
            ply:SetAnimation(PLAYER_RELOAD)
            if SERVER then

                for i = 1,4 do
                    timer.Simple(0.3*i, function()
                        launchConeJintonMode(ply, self,50)
                    end)
                end
            
            end
          
            return
        end

        local targetEntity = nil
        
        local trace = util.TraceHull({
            start = ply:GetShootPos(),
            endpos = ply:GetShootPos() + ply:GetAimVector() * 1000,
            filter = function(ent)
                return (ent:IsPlayer() or ent:IsNPC()) and ent ~= ply
            end,
            mins = Vector(-32, -32, -32),
            maxs = Vector(32, 32, 32), 
        })
        
    
        if trace.Entity and trace.Entity:IsValid() then
    
            targetEntity = trace.Entity
        end

        if(IsValid(targetEntity)) then
            activeWeapon:SetHoldType("anim_invoke")
            ply:SetAnimation(PLAYER_ATTACK1)
    
    
            if SERVER then
                prisonConeJinton(ply,activeWeapon,targetEntity)
            end
        end
       
      
	
	elseif button == KEY_G then

		if ply:GetNWBool("freezePlayer") or CurTime() < activeWeapon.NextJintonZone then
			return
		end

        activeWeapon.NextJintonZone = CurTime() + 5

        if ply:GetNWBool("jintonModePlayer") then
            activeWeapon:SetHoldType("weapon_art2")
            ply:SetAnimation(PLAYER_ATTACK1)
            growCylindreJintonMode(ply, activeWeapon, 10)
            return
        end
        

        activeWeapon:SetHoldType("anim_ninjutsu2") 
        ply:SetAnimation(PLAYER_ATTACK1)
    
        if SERVER then
    
            local entity = ents.Create("jinton_zone")
            if not IsValid(entity) then return end
        
            entity:SetPos(ply:GetPos()) 
            entity:Spawn()
            entity:Activate()
    
            entity.Owner = ply
    
    
        end
	elseif button == KEY_C then

        if ply:GetNWBool("freezePlayer") or CurTime() < activeWeapon.NextJintonFinal then
            return
        end

        activeWeapon.NextJintonFinal = CurTime() + 5

        if ply:GetNWBool("jintonModePlayer") then
            ply:StopParticles()
            ply:SetNWBool("jintonModePlayer", false)
            return 
        end

        activeWeapon:SetHoldType("anim_jashin") 
        ply:SetAnimation(PLAYER_RELOAD)
        ply:SetNWBool("jintonModePlayer", true)
        timer.Simple(1.5, function()
  
            activeWeapon:SetHoldType("normal") 
            ply:SetAnimation(PLAYER_ATTACK1)
            
        end)
    
    end

	
end)
