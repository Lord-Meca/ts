
AddCSLuaFile()

SWEP.PrintName = "Ailes de Papier | Kami"
SWEP.Author = "Lord_Meca"
SWEP.Instructions = ""

SWEP.Base = "weapon_base"

SWEP.Category = "TypeShit | Armes"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = "models/narutorp/gonzo/wings.mdl"

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
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_custom_armor_nass_01.mdl")
	self:SetNoDraw(true)
end


function SWEP:Initialize()

	self:SetHoldType("none")



end




function SWEP:PrimaryAttack()
end
function SWEP:SecondaryAttack()
end

function SWEP:Reload()

	local ply = self:GetOwner() 
	
    if not IsValid(ply) or not ply:IsPlayer() or not ply:IsOnGround() then return end

    self:SetHoldType("anim_ninjutsu2") 

    if CurTime() < (self.NextSpecialMove or 0) then return end
    self.NextSpecialMove = CurTime() + 3

	ply:SetAnimation(PLAYER_ATTACK1)

	timer.Simple(1,function()
		
		self:SetNoDraw(false)
		ParticleEffectAttach("kami_protect", PATTACH_ABSORIGIN_FOLLOW, ply, ply:LookupBone("ValveBiped.Bip01_R_Foot"))
		timer.Simple(5,function()
			if IsValid(self) then
				self:SetNoDraw(true)
				ply:StopParticles()
			end
		end)

	end)

end

