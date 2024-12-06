
AddCSLuaFile()

SWEP.PrintName = "Zone d'Ombre | Nara"
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

function SWEP:Reload()

	local ply = self:GetOwner() 
	
    if not IsValid(ply) or not ply:IsPlayer() or not ply:IsOnGround() then return end

    self:SetHoldType("anim_ninjutsu2") 

    if CurTime() < (self.NextSpecialMove or 0) then return end
    self.NextSpecialMove = CurTime() + 3

	ply:SetAnimation(PLAYER_ATTACK1)

	if SERVER then

		local entity = ents.Create("nara_zone")
		if not IsValid(entity) then return end
		
		
		entity:SetPos(ply:GetPos()) 
		entity:Spawn()
		entity:Activate()

		entity.Owner = ply


	end
end

