
AddCSLuaFile()

SWEP.PrintName = "Mains"
SWEP.Author = "Lord_Meca"
SWEP.Instructions = ""

SWEP.Base = "weapon_base"

SWEP.Category = "Other"

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

function SWEP:Initialize()
    self:SetHoldType( "none" )
	self.plyindirction = false
	self.duringattacktime = 0
    self.duringattack = false
	self.dodgetime = 0
end


function SWEP:PrimaryAttack()


end





function SWEP:SecondaryAttack()
 
end

-- function SWEP:Think()
-- 	local ply = self.Owner

-- --====================--
-- if self.Owner:KeyDown( IN_JUMP ) or self.Owner:KeyDown( IN_FORWARD ) or self.Owner:KeyDown( IN_BACK ) or
--  self.Owner:KeyDown( IN_MOVELEFT ) or self.Owner:KeyDown( IN_MOVERIGHT ) then
--  self.plyindirction = true
--  else
--  self.plyindirction = false
-- end

-- if self.duringattacktime < CurTime() then
-- self.duringattack = true
-- elseif self.duringattacktime > CurTime() then
-- self.duringattack = false
-- end

-- if self.duringattack == true then
-- self.Owner:SetWalkSpeed( 250 )
-- self.Owner:SetRunSpeed( 450 )
-- self.Owner:SetJumpPower(300)
-- self.Owner:SetSlowWalkSpeed( 120 )
-- elseif self.duringattack == false  then
-- self.Owner:SetWalkSpeed( 7 )
-- self.Owner:SetSlowWalkSpeed( 10 )
-- self.Owner:SetJumpPower(50)
-- self.Owner:SetRunSpeed( 200 )
-- end 

-- --==============================--
-- if self.duringattack == true and not self.Owner:KeyDown( IN_ATTACK ) and self.Owner:KeyDown( IN_JUMP ) and CurTime() > self.dodgetime then
-- self.Owner:SetRunSpeed( 100 )
-- self.Owner:SetJumpPower(300)
-- if self.Owner:KeyDown( IN_MOVELEFT ) then
-- if SERVER then

-- end
-- self:SetHoldType("g_rollleft")
-- self.Owner:SetAnimation(PLAYER_ATTACK1)
-- self.dodgetime = CurTime() + 1.3
-- self.Owner:SetVelocity((self.Owner:GetRight() * -1) * 400 - Vector(0,0,200))	
-- self.Weapon:SetNextPrimaryFire(CurTime() + 1.3 )
-- elseif self.Owner:KeyDown( IN_MOVERIGHT ) then
-- if SERVER then

-- end
-- self:SetHoldType("g_rollright")
-- self.Owner:SetAnimation(PLAYER_ATTACK1)
-- self.dodgetime = CurTime() + 1.4
-- self.Owner:SetVelocity((self.Owner:GetRight() * 1) * 400 - Vector(0,0,200))	
-- self.Weapon:SetNextPrimaryFire(CurTime() + 1.3 )
-- elseif self.Owner:KeyDown( IN_BACK ) then
-- if SERVER then

-- end
-- self:SetHoldType("g_rollback")
-- self.Owner:SetAnimation(PLAYER_ATTACK1)
-- self.dodgetime = CurTime() + 1.6
-- self.Owner:SetVelocity(Vector(0,0,100))	
-- self.Weapon:SetNextPrimaryFire(CurTime() + 1.3 )
-- end

-- self.duringattacktime = CurTime() + 0.76
-- self.back = false
-- end

-- --==============================--
-- end