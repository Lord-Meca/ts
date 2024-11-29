
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

function SWEP:Initialize()
    self:SetHoldType( "none" )

end

function SWEP:Reload()
    local ply = self.Owner

    if CurTime() < self.NextSpecialMove then return end
    self.NextSpecialMove = CurTime() + 10

	local particleName = "[6]_windstorm_add_4"
	local attachment = ply:LookupBone("ValveBiped.Bip01_R_Foot")

	self:SetHoldType("anim_invoke")
	ply:SetAnimation(PLAYER_ATTACK1)

	timer.Simple(0.5, function()

		ply:Freeze(true)
		if attachment then
			ParticleEffectAttach(particleName, PATTACH_ABSORIGIN_FOLLOW, ply, attachment)
		end


		local modelEntity = ents.Create("prop_physics")
		if IsValid(modelEntity) then
			modelEntity:SetModel("models/foc_props_jutsu/jutsu_sceau_piege/foc_jutsu_sceau_piege.mdl")
				
			
			modelEntity:SetPos(ply:GetPos() + Vector(0, 0, 0)) 
			modelEntity:SetAngles(Angle(0, 0, 0))
			modelEntity:SetColor(Color(255, 0, 0, 255))
			modelEntity:SetModelScale(1.5)
			modelEntity:Spawn()

			local physObj = modelEntity:GetPhysicsObject()
			if IsValid(physObj) then
				physObj:EnableMotion(false)
			end

		
			timer.Simple(2, function()
				ply:StopParticles()
				if IsValid(modelEntity) then

					modelEntity:Remove()
						
				end
				ply:Freeze(false)
			end)

		end





	end)

end
