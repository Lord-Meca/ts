
AddCSLuaFile()

SWEP.PrintName = "Ruée Salamandre | Invocation"
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
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_anbublackops_ame_hood_01.mdl")
end


function SWEP:Initialize()

    self:SetHoldType( "none" )

end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end



local function invokeSalamander(ply)
    local particleName = "izox_nrp_venom_smoke_rework"
    local poisonSoundName = "ambient/fire/firebig.wav"
    local modelEntity = ents.Create("prop_dynamic")
    local moveTimeLeft = 4
    local tickDamage = 100

    if not IsValid(modelEntity) then return end

    modelEntity:SetModel("models/warwax/salamandre.mdl")

    local spawnOffset = Vector(200, 0, 1000)
    local playerAngles = ply:EyeAngles()
    spawnOffset = playerAngles:Forward() * 300
    local spawnPos = ply:GetPos() + spawnOffset

    modelEntity:SetPos(spawnPos)
    modelEntity:SetAngles(Angle(0, playerAngles.yaw, 0))
    modelEntity:SetModelScale(4)
    modelEntity:Spawn()

    ParticleEffectAttach(particleName, PATTACH_ABSORIGIN_FOLLOW, modelEntity, 0)
    ply:EmitSound(poisonSoundName)

    local animID = modelEntity:LookupSequence("walk")
    if animID < 0 then return end

    modelEntity:SetSequence(animID)
    modelEntity:SetCycle(0)
    modelEntity:SetPlaybackRate(2)

    local direction = playerAngles:Forward()
    local moveDistancePerSecond = 1000  

    local function getGroundPos(pos)
        local trace = util.TraceLine({
            start = pos + Vector(0, 0, 10), 
            endpos = pos + Vector(0, 0, -50), 
            filter = modelEntity
        })

        return trace.HitPos
    end


    local moveTimer = timer.Create("SalamanderMove", 0.1, moveTimeLeft * 10, function()
        if IsValid(modelEntity) then
      
            local newPos = modelEntity:GetPos() + direction * moveDistancePerSecond * 0.1
         
            newPos = getGroundPos(newPos)

            modelEntity:SetPos(newPos)

       
            for _, entity in pairs(ents.FindInSphere(modelEntity:GetPos(), 300)) do
                if IsValid(entity) and (entity:IsPlayer() or entity:IsNPC()) and entity ~= ply then
                    local damageInfo = DamageInfo()
                    damageInfo:SetDamage(tickDamage)
                    damageInfo:SetDamageType(DMG_BLAST) 
                    damageInfo:SetAttacker(ply)
                    damageInfo:SetInflictor(ply) 

                    entity:TakeDamageInfo(damageInfo)

               
                    net.Start("DisplayDamage")
                    net.WriteInt(tickDamage, 32)
                    net.WriteEntity(entity)
                    net.WriteColor(Color(51,125,255,255))
                    net.Send(ply)
                end
            end
        else
            timer.Remove("SalamanderMove")
        end
    end)


    timer.Simple(moveTimeLeft, function()

        local animID = modelEntity:LookupSequence("idle")
        if animID < 0 then return end

        modelEntity:SetSequence(animID)
        modelEntity:SetCycle(0)
        modelEntity:SetPlaybackRate(1)

        modelEntity:StopParticles() 
        ply:StopSound(poisonSoundName)  
        ParticleEffect("nrp_tool_invocation", modelEntity:GetPos(), modelEntity:GetAngles(), modelEntity)
        ply:EmitSound("ambient/explosions/explode_9.wav")
        timer.Simple(1, function()
            if IsValid(modelEntity) then
                modelEntity:Remove()
            end
            timer.Remove("SalamanderMove")
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
			ply:SetNWBool("freezePlayer", true)
			ply:EmitSound("ambient/explosions/explode_9.wav")
			if attachment then
				ParticleEffectAttach(particleName, PATTACH_ABSORIGIN_FOLLOW, ply, attachment)
			end


			local modelEntity = ents.Create("prop_physics")
			if IsValid(modelEntity) then
				modelEntity:SetModel("models/foc_props_jutsu/jutsu_invocation/foc_jutsu_invocation.mdl")
				
				modelEntity:SetPos(ply:GetPos() + Vector(0, 0, 4)) 
				modelEntity:SetAngles(Angle(180, 0, 0))
				modelEntity:SetColor(Color(0,0,0,255))
				modelEntity:SetModelScale(1)
				modelEntity:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE) 
				modelEntity:SetRenderMode(RENDERMODE_TRANSCOLOR)
				modelEntity:SetKeyValue("solid", "0")
					
				modelEntity:Spawn()

				local physObj = modelEntity:GetPhysicsObject()
				if IsValid(physObj) then
					physObj:EnableMotion(false)
				end

			
                timer.Simple(0.5, function()
                    invokeSalamander(ply)

                    
                    timer.Simple(0.7, function() 
                        if IsValid(ply) then
                            ply:StopParticles()
                            ply:SetNWBool("freezePlayer", false)
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
