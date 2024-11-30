
AddCSLuaFile()

SWEP.PrintName = "Grande division des Limaces | Invocation"
SWEP.Author = "Lord_Meca"
SWEP.Instructions = ""

SWEP.Base = "weapon_base"

SWEP.Category = "TypeShit | Armes"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.NextSpecialMove = 0

function SWEP:Deploy()
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_anbublackops_hood_01_suna.mdl")
end


function SWEP:Initialize()
    self:SetHoldType( "none" )
end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

local function progressiveHeal(entity, index)
    if not IsValid(entity) then
        timer.Remove("SlugProgressiveHeal_" .. index) 
        return
    end

    local maxHealth = entity:GetMaxHealth()
    local currentHealth = entity:Health()
    local healthStep = maxHealth * 0.10
  
    local newHealth = math.min(currentHealth + healthStep, maxHealth)
    entity:SetHealth(newHealth)

    if newHealth >= maxHealth then
        timer.Remove("SlugProgressiveHeal_" .. index)
    end
end

local function invokeSlug(ply)
    local particleName = "izox_nrp_venom_poisonsmoke_rework"
    local soundName = "ambient/fire/firebig.wav"

    local modelEntity = ents.Create("prop_dynamic")
    local tickHeal = 10

    local katsuyuTimes = {
        largeKatsuyuDuration = 5,
        smallKatsuyuDuration = 3,
        smallKatsuyuSpawn = 1
    }

    if not IsValid(modelEntity) then return end

    modelEntity:SetModel("models/falko_naruto_foc/animal/katsuyu.mdl")

    local spawnOffset = Vector(100, -100, 0)  
    local playerAngles = ply:EyeAngles()  
    spawnOffset = spawnOffset + playerAngles:Right() * 100

    local spawnPos = ply:GetPos() + spawnOffset
    modelEntity:SetPos(spawnPos)
    modelEntity:SetAngles(Angle(0, playerAngles.yaw, 0))
    modelEntity:SetModelScale(4)
    modelEntity:Spawn()

    local animID = modelEntity:LookupSequence("idle")
    if animID < 0 then return end

    modelEntity:SetSequence(animID)
    modelEntity:SetCycle(0)
    modelEntity:SetPlaybackRate(1)

    local function getGroundPos(pos)
        local trace = util.TraceLine({
            start = pos + Vector(0, 0, 10), 
            endpos = pos + Vector(0, 0, -50), 
            filter = modelEntity
        })

        return trace.HitPos
    end

    local smallKatsuyuEntities = {}
    local katsuyuTargetMap = {}

    local function spawnSmallKatsuyu()
        local smallKatsuyu = ents.Create("prop_dynamic")
        if not IsValid(smallKatsuyu) then return end

        smallKatsuyu:SetModel("models/falko_naruto_foc/animal/katsuyu.mdl")
        smallKatsuyu:SetPos(modelEntity:GetPos() + Vector(math.random(-50, 50), math.random(-50, 50), 0))
        smallKatsuyu:SetAngles(Angle(0, playerAngles.yaw, 0))
        smallKatsuyu:SetModelScale(1)
        smallKatsuyu:Spawn()

        smallKatsuyu:SetSequence(animID)
        smallKatsuyu:SetCycle(0)
        smallKatsuyu:SetPlaybackRate(2)

        local entitiesInRange = ents.FindInSphere(modelEntity:GetPos(), 1200)
        for _, entity in ipairs(entitiesInRange) do
            if IsValid(entity) and (entity:IsPlayer() or entity:IsNPC()) and entity ~= ply and entity:Health() < entity:GetMaxHealth() then

                local targetAssigned = false
                for katsuyu, target in pairs(katsuyuTargetMap) do
                    if target == entity then
                        targetAssigned = true
                        break
                    end
                end

                if not targetAssigned then
                  
                    katsuyuTargetMap[smallKatsuyu] = entity
                 
                    local moveTimer = timer.Create("SlugMove_" .. smallKatsuyu:EntIndex(), 0.1, 0, function()
                        if IsValid(smallKatsuyu) then
                            local target = katsuyuTargetMap[smallKatsuyu]
                            if IsValid(target) then
                                local direction = (target:GetPos() - smallKatsuyu:GetPos()):GetNormalized()
                                local speed = 200

                                local newPos = smallKatsuyu:GetPos() + direction * speed * 0.1
                                newPos = getGroundPos(newPos)

                                smallKatsuyu:SetPos(newPos)

                             
                                if (target:GetPos() - smallKatsuyu:GetPos()):Length() < 10 then
                                    timer.Remove("SlugMove_" .. smallKatsuyu:EntIndex())
                                    

                                    ply:ChatPrint("oui cible index: " .. smallKatsuyu:EntIndex())

                                    ParticleEffectAttach("izoxfoc_taijutsu_porte_green_bis_e", PATTACH_ABSORIGIN_FOLLOW, target, 0)

                                    timer.Create("SlugProgressiveHeal_" .. smallKatsuyu:EntIndex(), 1, 5, function()
                                        progressiveHeal(entity, smallKatsuyu:EntIndex())
                                    end)

                                    timer.Simple(katsuyuTimes.smallKatsuyuDuration, function()
                                        katsuyuTargetMap[smallKatsuyu] = nil
                                        target:StopParticles()

                                        ParticleEffect("nrp_tool_invocation", newPos, playerAngles, ply)
                                        ply:EmitSound("ambient/explosions/explode_9.wav")
                                        
                                        if IsValid(smallKatsuyu) then
                                            smallKatsuyu:Remove()
                                        end
                                    end)
                                end
                            end
                        else
                            timer.Remove("SlugMove_" .. smallKatsuyu:EntIndex())
                            katsuyuTargetMap[smallKatsuyu] = nil
                        end
                    end)


                end
            end
        end

        table.insert(smallKatsuyuEntities, smallKatsuyu)
    end



    timer.Create("smallKatsuyuSpawn", katsuyuTimes.smallKatsuyuSpawn, katsuyuTimes.largeKatsuyuDuration * (1 / katsuyuTimes.smallKatsuyuSpawn), spawnSmallKatsuyu)

    local defaultScale = 4
    local scaleReduction = 0.05

    timer.Create("scaleReduction", 0.1, katsuyuTimes.largeKatsuyuDuration * (1 / 0.1), function()
        if defaultScale > 0 then
            defaultScale = defaultScale - scaleReduction
            modelEntity:SetModelScale(defaultScale)
        end
    end)


    timer.Simple(katsuyuTimes.largeKatsuyuDuration, function()
      
        ParticleEffect("nrp_tool_invocation", spawnPos, playerAngles, ply)
        ply:EmitSound("ambient/explosions/explode_9.wav")
        
        if IsValid(modelEntity) then
            modelEntity:Remove()
        end
        timer.Simple(1, function()
            for _, katsuyus in ipairs(smallKatsuyuEntities) do
                print(katsuyuTargetMap[katsuyus])
                if katsuyuTargetMap[katsuyus] == nil then
                    ParticleEffect("nrp_tool_invocation", katsuyus:GetPos(), playerAngles, ply)
                    ply:EmitSound("ambient/explosions/explode_9.wav")

                    katsuyus:Remove()
                end 
            end
        end)


    end)

end








function SWEP:Reload()
	local ply = self.Owner

	if not ply:IsOnGround() then return end

	if CurTime() < self.NextSpecialMove then return end
	self.NextSpecialMove = CurTime() + 10

	local particleName = "nrp_tool_invocation"
	local attachment = ply:LookupBone("ValveBiped.Bip01_R_Foot")

	self:SetHoldType("anim_invoke")
    ply:SetAnimation(PLAYER_RELOAD)
	timer.Simple(1, function()
		self:SetHoldType("anim_invoke")
		ply:SetAnimation(PLAYER_ATTACK1)
	end)



	if SERVER then


		timer.Simple(1.5, function()
			ply:Freeze(true)
			ply:EmitSound("ambient/explosions/explode_9.wav")
			if attachment then
				ParticleEffectAttach(particleName, PATTACH_ABSORIGIN_FOLLOW, ply, attachment)
			end


			local modelEntity = ents.Create("prop_physics")
			if IsValid(modelEntity) then
				modelEntity:SetModel("models/foc_props_jutsu/jutsu_sceau_piege/foc_jutsu_sceau_piege.mdl")
				
				modelEntity:SetPos(ply:GetPos() + Vector(0, 0, 0)) 
				modelEntity:SetAngles(Angle(0, 0, 0))
				modelEntity:SetColor(Color(0,0,0,255))
				modelEntity:SetModelScale(4)
				modelEntity:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE) 
				modelEntity:SetRenderMode(RENDERMODE_TRANSCOLOR)
				modelEntity:SetKeyValue("solid", "0")
					
				modelEntity:Spawn()

				local physObj = modelEntity:GetPhysicsObject()
				if IsValid(physObj) then
					physObj:EnableMotion(false)
				end

			

                timer.Simple(0.5, function()
                    invokeSlug(ply)

                    
                    timer.Simple(0.7, function() 
                        if IsValid(ply) then
                            ply:StopParticles()
                            ply:Freeze(false)
                        end

                        if IsValid(modelEntity) then
                            modelEntity:Remove()
                        end
                    end)
                end)


			end





		end)
	end

end
