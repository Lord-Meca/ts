
AddCSLuaFile()

SWEP.PrintName = "Invocation Salamandre"
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
    local particleName = "izox_nrp_venom_poisonsmoke_rework"
    local poisonSoundName = "ambient/fire/firebig.wav"
    local modelEntity = ents.Create("prop_dynamic")
    local tickDamage = 10

    if not IsValid(modelEntity) then return end

    modelEntity:SetModel("models/warwax/salamandre.mdl")

    local spawnOffset = Vector(200, 0, 0)
    local playerAngles = ply:EyeAngles()
    spawnOffset = playerAngles:Right() * -100
    local spawnPos = ply:GetPos() + spawnOffset

    modelEntity:SetPos(spawnPos)
    modelEntity:SetAngles(Angle(0, playerAngles.yaw, 0))
    modelEntity:SetModelScale(2)
    modelEntity:Spawn()

    ParticleEffectAttach(particleName, PATTACH_ABSORIGIN_FOLLOW, modelEntity, 0)
 

    ply:EmitSound(poisonSoundName)


    local entities = ents.FindInSphere(modelEntity:GetPos(), 350)


    local attackAnimID = modelEntity:LookupSequence("attack")
    if attackAnimID < 0 then return end

    modelEntity:SetSequence(attackAnimID)
    modelEntity:SetCycle(0)
    modelEntity:SetPlaybackRate(1)

    local attackDuration = modelEntity:SequenceDuration(attackAnimID)

    local rotateTimer
    rotateTimer = timer.Create("rotate_salamander", 0.05, 0, function()
        if not IsValid(modelEntity) or modelEntity:GetSequence() ~= attackAnimID then
            timer.Remove("rotate_salamander")
            return
        end

        local currentAngles = modelEntity:GetAngles()
        currentAngles:RotateAroundAxis(currentAngles:Up(), 5)
        modelEntity:SetAngles(currentAngles)

        for _, entity in pairs(entities) do
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
                net.WriteColor(Color(221,51,255,255))
                net.Send(ply)

            end
        end
    end)

    timer.Simple(attackDuration, function()
        if not IsValid(modelEntity) then return end

        local idleAnimID = modelEntity:LookupSequence("idle")
        if idleAnimID < 0 then return end

        modelEntity:SetSequence(idleAnimID)
        modelEntity:SetCycle(0)
        modelEntity:SetPlaybackRate(1)

        modelEntity:StopParticles() 
        ply:StopSound(poisonSoundName)  

        timer.Simple(5, function()
            ParticleEffect("nrp_tool_invocation", modelEntity:GetPos(), modelEntity:GetAngles(), modelEntity)
            ply:EmitSound("ambient/explosions/explode_9.wav")
            timer.Simple(1, function()
                if IsValid(modelEntity) then
                    modelEntity:Remove()
                end
            end)
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
                    invokeSalamander(ply)

                    
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
