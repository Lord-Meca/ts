
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
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/ame_ninja_npc.mdl")
end


function SWEP:Initialize()

    self:SetHoldType( "none" )

end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

local function invokeSalamander(ply)
    local particleName = "nrp_venom_poisonsmoke"
    local poisonSoundName = "ambient/fire/firebig.wav"
    local modelEntity = ents.Create("prop_dynamic")

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

    local particlePos = modelEntity:GetPos() + Vector(0, 0, 50)
    ParticleEffect(particleName, particlePos, modelEntity:GetAngles(), modelEntity)
    ply:EmitSound(poisonSoundName)

    local attackAnimID = modelEntity:LookupSequence("attack")
    if attackAnimID < 0 then return end

    modelEntity:SetSequence(attackAnimID)
    modelEntity:SetCycle(0)
    modelEntity:SetPlaybackRate(1)

    local attackDuration = modelEntity:SequenceDuration(attackAnimID)
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
            ParticleEffect("[6]_windstorm_add_4", particlePos, modelEntity:GetAngles(), modelEntity)
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

	local particleName = "[6]_windstorm_add_4"
	local attachment = ply:LookupBone("ValveBiped.Bip01_R_Foot")

	self:SetHoldType("anim_invoke")
	ply:SetAnimation(PLAYER_ATTACK1)
	if SERVER then


		timer.Simple(0.3, function()
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

				invokeSalamander(ply)

			
				timer.Simple(1.2, function()
					ply:StopParticles()
					ply:Freeze(false)
					if IsValid(modelEntity) then
		
						modelEntity:Remove()
							
					end
			
				end)

			end





		end)
	end

end
