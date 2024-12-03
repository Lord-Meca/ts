
AddCSLuaFile()

SWEP.PrintName = "Piétinement du Crapeau | Invocation"
SWEP.Author = "Lord_Meca"
SWEP.Instructions = ""

SWEP.Base = "weapon_base"

SWEP.Category = "TypeShit | Invocations"

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
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/sogeki_man_samurairouge_corne.mdl")
end


function SWEP:Initialize()

    self:SetHoldType( "none" )

end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end



local function invokeToad(ply)

    local modelEntity = ents.Create("prop_dynamic")
    local moveTimeLeft = 4
    local tickDamage = 300

    if not IsValid(modelEntity) then return end

    modelEntity:SetModel("models/foc/ska/gamakichi.mdl")

    local spawnOffset = Vector(0, 0, 0) 
    local playerAngles = ply:EyeAngles()
    spawnOffset = spawnOffset + playerAngles:Forward() * 300 

    local spawnPos = ply:GetPos() + spawnOffset

    modelEntity:SetPos(spawnPos)
    modelEntity:SetAngles(Angle(0, playerAngles.yaw, 0))
    modelEntity:SetModelScale(1)
    modelEntity:Spawn()

    local animID = modelEntity:LookupSequence("gamakichimoveaction")
    if animID < 0 then return end

    modelEntity:SetSequence(animID)
    modelEntity:SetCycle(0)
    modelEntity:SetPlaybackRate(2)

    ply:EmitSound("content/shukaku_scream1.wav")

    local direction = playerAngles:Forward()
    local moveDistancePerSecond = 2000

    local function getGroundPos(pos)
        local trace = util.TraceLine({
            start = pos + Vector(0, 0, 10), 
            endpos = pos + Vector(0, 0, -50), 
            filter = modelEntity
        })

        return trace.HitPos
    end


    for i = 1, 2 do
        
        timer.Simple((i - 1) * 2.5, function()
      
            if i == 1 then
                timer.Simple(0.5, function()
                    moveDistancePerSecond = 0
                end)
            end

            ParticleEffect("nrp_tool_invocation", modelEntity:GetPos() + modelEntity:GetForward() * 0 + Vector(0, 0, 0), Angle(0, 0, 0), nil)
            util.ScreenShake(ply:GetPos(), 20, 2, 3, 3000)
            ply:EmitSound(Sound("physics/concrete/concrete_break3.wav"))

            local entitiesInRange = ents.FindInSphere(modelEntity:GetPos(), 750)
            for _, entity in ipairs(entitiesInRange) do
                if IsValid(entity) and (entity:IsPlayer() or entity:IsNPC()) and entity ~= ply then
                    local damageInfo = DamageInfo()
                    damageInfo:SetDamage(tickDamage)
                    damageInfo:SetDamageType(DMG_BLAST)
                    damageInfo:SetAttacker(ply)
                    damageInfo:SetInflictor(ply)
                    entity:TakeDamageInfo(damageInfo)
                    ParticleEffect("blood_advisor_puncture_withdraw", entity:GetPos() + entity:GetForward() * 0 + Vector(0, 0, 40), Angle(0, 45, 0))
                    net.Start("DisplayDamage")
                    net.WriteInt(tickDamage, 32)
                    net.WriteEntity(entity)
                    net.WriteColor(Color(160, 37, 37, 255))
                    net.Send(ply)
                end
            end
        end)
    end





    local moveTimer = timer.Create("ToadMove", 0.1, moveTimeLeft * 10, function()
        if IsValid(modelEntity) then
           

        
            local newPos = modelEntity:GetPos() + direction * moveDistancePerSecond * 0.1

            newPos = getGroundPos(newPos)
            modelEntity:SetPos(newPos)

        else
            timer.Remove("ToadMove")
        end
    end)


    timer.Simple(moveTimeLeft, function()


        modelEntity:StopParticles() 
  
        ParticleEffect("nrp_tool_invocation", modelEntity:GetPos(), modelEntity:GetAngles(), modelEntity)
        ply:EmitSound("ambient/explosions/explode_9.wav")
        timer.Simple(1, function()
            if IsValid(modelEntity) then
                modelEntity:Remove()
            end
            timer.Remove("ToadMove")
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
                    invokeToad(ply)

                    
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
