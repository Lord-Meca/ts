if (SERVER) then
	AddCSLuaFile()
    util.AddNetworkString("DisplayDamage")
	util.AddNetworkString("Claws_State")
end

if (CLIENT) then
	SWEP.Slot = 0
	SWEP.SlotPos = 0
	SWEP.DrawAmmo = false
	SWEP.PrintName = "Griffes"
	SWEP.DrawCrosshair = true


end

SWEP.ViewModelFOV = 77
SWEP.UseHands = false
SWEP.Category = "TypeShit | Armes"
SWEP.Purpose = ""
SWEP.Contact = ""
SWEP.Author = "Lord_Meca"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/foc_nr_unique_props10_bane.mdl"
SWEP.AdminSpawnable = false
SWEP.Spawnable = true
SWEP.Primary.NeverRaised = true
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 90
SWEP.Primary.Delay = 3
SWEP.Primary.Ammo = ""
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 0
SWEP.Secondary.Ammo = ""
SWEP.NoIronSightFovChange = true
SWEP.NoIronSightAttack = true
SWEP.LowegreenAngles = Angle(60, 60, 60)
SWEP.IronSightPos = Vector(0, 0, 0)
SWEP.IronSightAng = Vector(0, 0, 0)

SWEP.NextSpecialMove = 0
SWEP.NextHolsterWeapon = 0
SWEP.NextTagMove = 0
SWEP.clawsHolstered = true

local AttackHit2 = Sound( "physics/body/body_medium_break3.wav")
local AttackHit1 = Sound( "physics/body/body_medium_break2.wav")
local Hitground2 = Sound( "physics/concrete/concrete_break2.wav")
local Hitground = Sound( "physics/concrete/concrete_break3.wav")
local Ready = Sound( "sound/custom characters/sword_ready.wav")
local Stapout = Sound( "sound/custom characters/sword_stapouthit.wav")
local Stapin = Sound( "sound/custom characters/sword_stabinhit.wav")
local Stap = Sound( "sound/custom characters/sword_stap.wav")
local Cloth = Sound( "sound/custom characters/player_cloth.wav")
local Roll = Sound( "npc/combine_soldier/gear2.wav")
local Combo1 = Sound( "physics/body/body_medium_break2.wav")
local Combo2 = Sound( "physics/body/body_medium_break3.wav")
local Combo3 = Sound( "physics/body/body_medium_break4.wav")
local Combo4 = Sound( "physics/body/body_medium_break2.wav")
local SwordTrail = Sound ( "sound/custom characters/sword_trail.mp3" )

function SWEP:Deploy()
	
	self:SetNoDraw(true)

	if SERVER then
		net.Start("Claws_State")
		net.WriteEntity(self.Owner)
		net.WriteBool(self.clawsHolstered)
		net.Broadcast()
	end

	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_kusa_armor_04.mdl")

 
end


function SWEP:Initialize()
	self.combo = 11
	self:SetHoldType("normal")
	self.duringattack = false
	self.backtime = 0
	self.duringattacktime = 0
	self.dodgetime = 0
	self.plyindirction = false
	self.npcfreezetime = 0
	self.DownSlashed = true
	self.downslashingdelay = 0
	self.back = true

	self.listTargetPlayers = {}
end

function SWEP:DoAnimation( anim1 )
self:SetHoldType(anim1)
self.Owner:SetAnimation(PLAYER_ATTACK1)
end


function SWEP:Think()
	local ply = self.Owner


	if self.clawsHolstered then
		self:SetHoldType("normal")
	end

--====================--
if self.Owner:KeyDown( IN_WALK ) and self.Owner:KeyDown( IN_ATTACK ) and self.duringattack == true and self.Owner:KeyDown( IN_FORWARD ) then
if IsValid(self) and self.Owner:IsOnGround() then
self:LeapAttack()
end
end

--====================--
if self.Owner:KeyDown( IN_WALK ) and self.Owner:KeyDown( IN_ATTACK ) and self.duringattack == true and self.Owner:KeyDown( IN_BACK ) then
if IsValid(self) and self.Owner:IsOnGround() then
self:SlashUp()
end
end

--====================--

if self.Owner:KeyDown( IN_WALK ) and self.Owner:KeyDown( IN_ATTACK ) and self.duringattack == true and self.Owner:KeyDown( IN_BACK ) then
if IsValid(self) and not self.Owner:IsOnGround() then
self:SlashDown()
end
end

--====================--
if self.Owner:KeyDown( IN_JUMP ) or self.Owner:KeyDown( IN_FORWARD ) or self.Owner:KeyDown( IN_BACK ) or
 self.Owner:KeyDown( IN_MOVELEFT ) or self.Owner:KeyDown( IN_MOVERIGHT ) then
 self.plyindirction = true
 else
 self.plyindirction = false
end

if self.duringattacktime < CurTime() then
self.duringattack = true
elseif self.duringattacktime > CurTime() then
self.duringattack = false
end

if self.duringattack == true then
self.Owner:SetWalkSpeed( 250 )
self.Owner:SetRunSpeed( 450 )
self.Owner:SetJumpPower(300)
self.Owner:SetSlowWalkSpeed( 120 )
elseif self.duringattack == false  then
self.Owner:SetWalkSpeed( 7 )
self.Owner:SetSlowWalkSpeed( 10 )
self.Owner:SetJumpPower(50)
self.Owner:SetRunSpeed( 200 )
end 

--==============================--
if self.duringattack == true and not self.Owner:KeyDown( IN_ATTACK ) and self.Owner:KeyDown( IN_JUMP ) and CurTime() > self.dodgetime then
self.Owner:SetRunSpeed( 100 )
self.Owner:SetJumpPower(300)
if self.Owner:KeyDown( IN_MOVELEFT ) then
if SERVER then
self.Owner:EmitSound(Roll)
end
self:SetHoldType("g_rollleft")
self.Owner:SetAnimation(PLAYER_ATTACK1)
self.dodgetime = CurTime() + 1.3
self.Owner:SetVelocity((self.Owner:GetRight() * -1) * 400 - Vector(0,0,200))	
self.Weapon:SetNextPrimaryFire(CurTime() + 1.3 )
elseif self.Owner:KeyDown( IN_MOVERIGHT ) then
if SERVER then
self.Owner:EmitSound(Roll)
end
self:SetHoldType("g_rollright")
self.Owner:SetAnimation(PLAYER_ATTACK1)
self.dodgetime = CurTime() + 1.4
self.Owner:SetVelocity((self.Owner:GetRight() * 1) * 400 - Vector(0,0,200))	
self.Weapon:SetNextPrimaryFire(CurTime() + 1.3 )
elseif self.Owner:KeyDown( IN_BACK ) then
if SERVER then
self.Owner:EmitSound(Roll)
end
self:SetHoldType("g_rollback")
self.Owner:SetAnimation(PLAYER_ATTACK1)
self.dodgetime = CurTime() + 1.6
self.Owner:SetVelocity(Vector(0,0,100))	
self.Weapon:SetNextPrimaryFire(CurTime() + 1.3 )
end

self.duringattacktime = CurTime() + 0.76
self.back = false
end

--==============================--


if ply:IsOnGround() and self.DownSlashed == false then
self:FinialDownSlash()
if SERVER then
	ply:EmitSound(Hitground)
	ply:EmitSound(Hitground2)



end
ParticleEffect("blood_impact_synth_01",self.Owner:GetPos() + self.Owner:GetForward() * 0 + Vector( 0, 0, 20 ),Angle(0,45,0),nil)
end

if ply:IsOnGround() then
self.DownSlashed = true
end


if not ply:IsOnGround() and self.DownSlashed == false then
if self.downslashingdelay < CurTime() then
self.downslashingdelay = CurTime() + 0.05
self:DownSlashing()
end
end

--==============================--
if  self.duringattacktime == CurTime() then
self.back = true
end

if  self.duringattacktime < CurTime() and self.back == false and self.Owner:IsOnGround() and self.plyindirction == true then
self.back = true
self:SetHoldType("g_restart")
ply:SetAnimation( PLAYER_ATTACK1 )
end
end
SWEP.SlashUph = false
SWEP.enemystuntime = 0
--==================--
function SWEP:LeapAttack()
self.combo = 0
self.Owner:ViewPunch(Angle(3, 4, 3))
self.Weapon:SetNextPrimaryFire(CurTime() + 1.2 )
self.back = false
local ply = self.Owner
self:SetHoldType("leap")
ply:SetAnimation( PLAYER_ATTACK1 )
if SERVER then
ply:EmitSound(Ready)
ply:EmitSound(Cloth)
end
self.duringattack = true
self.duringattacktime = CurTime() + 1
self.dodgetime = CurTime() + 1.2
ply:SetVelocity((self.Owner:GetForward() * 1) * 1 + Vector(0,0,200) )	
timer.Simple(0.05, function()
ply:SetVelocity((self.Owner:GetForward() * 1) * 10100 + Vector(0,0,-100) )
end)
timer.Simple(0.3, function() 
self:SetHoldType("leapattack")
ply:SetAnimation( PLAYER_ATTACK1 )
-- if SERVER then
-- ply:EmitSound(Hitground)
-- end
self.Owner:ViewPunch(Angle(-6, -5, 0))
self.combo = 11
if SERVER then
-- combo2 position originale
ply:EmitSound(SwordTrail)
end
		local k, v
		local dmg = DamageInfo()
			dmg:SetDamage( 43 ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)

		for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 50, 140 ) ) do 
			if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
			if v:IsNPC() then	--
			if SERVER then
			v:SetCondition( 67 )
			v:EmitSound(AttackHit2)
			timer.Simple(2.3, function()
			if IsValid(v) then 
			v:SetCondition( 68 )
			end
			end)			
			v:SetVelocity((self.Owner:GetForward() * 1) * 120 + Vector(0,0,50) )	
			ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
			end
			end
			if v:IsPlayer() then
			v:Freeze( true )
			v:EmitSound(AttackHit2)
			ply:EmitSound(Combo2)


			timer.Simple(1, function()
			if IsValid(v) then 
			v:Freeze( false )
			end
			end)			
			v:SetVelocity((self.Owner:GetForward() * 1) * 120 + Vector(0,0,50) )	
			ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
			end
				dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
				if SERVER then
				v:TakeDamageInfo( dmg )
				end
			end


		end	
end)
end


--==================--
function SWEP:FinialDownSlash()
self.duringattacktime = CurTime() + 0.5
self.back = false
if IsValid(self.Owner) then
		local k, v
		local dmg = DamageInfo()
			dmg:SetDamage(45)
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner)
			dmg:SetInflictor(self.Owner)
		
		for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,10) + (self.Owner:GetForward() * 1) * 50, 120 ) ) do
			if v:IsValid() and v != self.Owner then
				dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
				if SERVER then
				v:TakeDamageInfo( dmg )
				end
				if v:IsNPC() or v:IsPlayer() then
				v:EmitSound(Stapout)
				ParticleEffect("blood_advisor_puncture_withdraw",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
				end	
			end
		end
	end
end

function SWEP:DownSlashing()
if IsValid(self.Owner) then
		local k, v
		local dmg = DamageInfo()
			dmg:SetDamage(10)
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner)
			dmg:SetInflictor(self.Owner)
		
		for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,10) + (self.Owner:GetForward() * 1) * 50, 120 ) ) do
			if v:IsValid() and v != self.Owner then
				dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
				if SERVER then
				v:TakeDamageInfo( dmg )
				end
				if v:IsNPC() or v:IsPlayer() then
				ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
				end	
			end
		end
	end
end

--==================--
function SWEP:SlashDown()
local ply = self.Owner
self.combo = 0
self.Owner:ViewPunch(Angle(-4, 4, 6))
if SERVER then
ply:EmitSound(Ready)
ply:EmitSound(Cloth)
end
if self.Owner:IsOnGround() then	
	local k, v
	if v == nil then return end
	v:TakeDamageInfo( dmg )
		local dmg = DamageInfo()
			dmg:SetDamage( 15 ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)
		for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,10) + (self.Owner:GetForward() * 1) * 50, 120 ) ) do 
			if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
			if v:IsNPC() then	
			if SERVER then
			v:EmitSound(AttackHit1)
			v:SetCondition( 67 )
			timer.Simple(3, function()
			if IsValid(v) then 
			v:SetCondition( 68 )
			end
			end)			
			v:SetVelocity((self.Owner:GetForward() * 1) * 300 + Vector(0,0,500) )	
			ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
			end
			end
			if v:IsPlayer() then
			v:EmitSound(AttackHit1)


			
			v:Freeze( true )
			timer.Simple(0.5, function()
			if IsValid(v) then 
			v:Freeze( false )
			end
			end)			
			v:SetVelocity((self.Owner:GetForward() * 1) * 300 + Vector(0,0,500) )	
			ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
			end
				dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
				if SERVER then
				v:TakeDamageInfo( dmg )
				end
			end	
		end	

end
self.Weapon:SetNextPrimaryFire(CurTime() + 0.7 )
local ply = self.Owner
self:SetHoldType("slashdown")
ply:SetAnimation( PLAYER_ATTACK1 )
self.duringattack = true
self.duringattacktime = CurTime() + 0.7
self.dodgetime = CurTime() + 1
		local pl = self.Owner
		local ang = pl:GetAngles()
		local forward, right = ang:Forward(), ang:Right()
		
		local vel = -1 * pl:GetVelocity() 
		vel = vel + Vector(0, 0, 300) 
		
		local spd = pl:GetMaxSpeed()
		
		if pl:KeyDown(IN_FORWARD) then
			vel = vel + forward * spd
		elseif pl:KeyDown(IN_BACK) then
			vel = vel - forward * spd
		end
		
		if pl:KeyDown(IN_MOVERIGHT) then
			vel = vel + right * spd
		elseif pl:KeyDown(IN_MOVELEFT) then
			vel = vel - right * spd
		end
		
		pl:SetVelocity(vel) 

timer.Simple(0.4, function() 
if SERVER then
ply:EmitSound(Cloth)
end
self.combo = 11
self.DownSlashed = false
self.Owner:ViewPunch(Angle(4, -1, 0))
		local pl = self.Owner
		local ang = pl:GetAngles()
		local forward, right = ang:Forward(), ang:Right()
		
		local vel = -1 * pl:GetVelocity()
		vel = vel + Vector(0, 0, -2500)
		
		local spd = pl:GetMaxSpeed()
		
		if pl:KeyDown(IN_FORWARD) then
			vel = vel + forward * spd
		elseif pl:KeyDown(IN_BACK) then
			vel = vel - forward * spd
		end
		
		if pl:KeyDown(IN_MOVERIGHT) then
			vel = vel + right * spd
		elseif pl:KeyDown(IN_MOVELEFT) then
			vel = vel - right * spd
		end
		
		pl:SetVelocity(vel)
end)
timer.Simple(0.3, function() 
if SERVER then
--ply:EmitSound(Combo2)
ply:EmitSound(SwordTrail)
end
		local k, v
		local dmg = DamageInfo()
			dmg:SetDamage( 15 ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)
		for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() + (self.Owner:GetForward() * 1) * 50, 120 ) ) do 
			if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
			if v:IsNPC() then		
			if SERVER then
			v:SetCondition( 67 )
			timer.Simple(3, function()
			if IsValid(v) then 
			v:SetCondition( 68 )
			end
			end)
			v:SetVelocity((self.Owner:GetForward() * 1) * 1 + Vector(0,0,-2500) + (ply:GetForward() * 1) * 700 )	
			ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
			end
			end
			if v:IsPlayer() then
			ply:EmitSound(Combo2)
			v:Freeze( true )
			timer.Simple(0.5, function()
			if IsValid(v) then 
			v:Freeze( false )
			end
			end)			
			v:SetVelocity((self.Owner:GetForward() * 1) * 1 + Vector(0,0,-2500) + (ply:GetForward() * 1) * 700 )	
			ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
			end
			dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
				if SERVER then
				v:TakeDamageInfo( dmg )
				end
			end	
		end	
end)
end

function SWEP:SlashUp()
self.combo = 0
self.back = false
if SERVER then
self.Owner:EmitSound(Ready)
end
self.SlashUph = false
self.Owner:ViewPunch(Angle(3, 2, 3))
self.Weapon:SetNextSecondaryFire(CurTime() + 0.7 )
self.Weapon:SetNextPrimaryFire(CurTime() + 0.7 )
local ply = self.Owner
self:SetHoldType("slashready")
ply:SetAnimation( PLAYER_ATTACK1 )
self.duringattack = true
self.duringattacktime = CurTime() + 0.7
self.dodgetime = CurTime() + 1
timer.Simple(0.2, function() 
ParticleEffect("blood_impact_synth_01",self.Owner:GetPos() + self.Owner:GetForward() * 0 + Vector( 0, 0, 20 ),Angle(0,45,0),nil)
if SERVER then
ply:EmitSound(Hitground)
ply:EmitSound(Cloth)
end
self.Owner:ViewPunch(Angle(-6, -2, 0))
self.combo = 11
if SERVER then
--ply:EmitSound(Combo2)
ply:EmitSound(SwordTrail)
end
if self.Owner:KeyDown( IN_ATTACK ) or self.Owner:KeyDown( IN_ATTACK2 ) then
self:SetHoldType("slashuph")
self.SlashUph = true
		local pl = self.Owner
		local ang = pl:GetAngles()
		local forward, right = ang:Forward(), ang:Right()
		
		local vel = -1 * pl:GetVelocity() 
		vel = vel + Vector(0, 0, 450) 
		
		local spd = pl:GetMaxSpeed()
		
		if pl:KeyDown(IN_FORWARD) then
			vel = vel + forward * spd
		elseif pl:KeyDown(IN_BACK) then
			vel = vel - forward * spd
		end
		
		if pl:KeyDown(IN_MOVERIGHT) then
			vel = vel + right * spd
		elseif pl:KeyDown(IN_MOVELEFT) then
			vel = vel - right * spd
		end
		
		pl:SetVelocity(vel) 
	
else
self:SetHoldType("slashup")
end
		local k, v
		local dmg = DamageInfo()
			dmg:SetDamage( 20 ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)
		for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 50, 120 ) ) do 
			if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
			if v:IsNPC() then	--
			if SERVER then
			v:SetCondition( 67 )
			v:EmitSound(AttackHit2)


			timer.Simple(2.3, function()
			if IsValid(v) then 
			v:SetCondition( 68 )
			end
			end)			
			v:SetVelocity((self.Owner:GetForward() * 1) * 1 + Vector(0,0,400) )	
			ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
			end
			end
			if v:IsPlayer() then --
			v:Freeze( true )
			v:EmitSound(AttackHit2)
			ply:EmitSound(Combo2)

		
			

			timer.Simple(0.9, function()
			if IsValid(v) then 
			v:Freeze( false )
			end
			end)			
			v:SetVelocity((self.Owner:GetForward() * 1) * 1 + Vector(0,0,400) )	
			ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
			end
				dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
				if SERVER then
				v:TakeDamageInfo( dmg )
				end
			end	
		end	
ply:SetAnimation( PLAYER_ATTACK1 )
end)
end
	
function SWEP:KillMove()
self.Weapon:SetNextPrimaryFire(CurTime() + 1.3 )
local ply = self.Owner
self:SetHoldType("g_combo32")
ply:SetAnimation( PLAYER_ATTACK1 )
self.duringattack = true
self.duringattacktime = CurTime() + 1.2
self.dodgetime = CurTime() + 1.3
self.Owner:ViewPunch(Angle(5, 1, 0))
timer.Simple(0.2, function() 
ply:SetVelocity((self.Owner:GetForward() * 1) * 500 + Vector(0,0,50) )	
--ply:EmitSound(Combo2)
		local k, v
		local dmg = DamageInfo()
			dmg:SetDamage( 1 ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)
		for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 50, 120 ) ) do 
			if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
			ply:EmitSound(Stap)
			if v:IsNPC() then	--
			if SERVER then
			v:EmitSound(Stapin)			
			v:SetCondition( 67 )
			timer.Simple(3, function()
			if IsValid(v) then 
			v:SetCondition( 68 )
			end
			end)			
			v:SetVelocity((self.Owner:GetForward() * 1) * 100  )	
			ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
			end
			end
			if v:IsPlayer() then--
			v:EmitSound(Stapin)
			ply:EmitSound(Combo2)		
			v:Freeze( true )
			timer.Simple(0.9, function()
			if IsValid(v) then 
			v:Freeze( false )
			end
			end)			
			v:SetVelocity((self.Owner:GetForward() * 1) * 100 )	
			ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
			end
				dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
				if SERVER then
				v:TakeDamageInfo( dmg )
				end
			end	
		end	
end)

timer.Simple(0.75, function() 
ply:SetVelocity((self.Owner:GetForward() * 1) * -400 + Vector(0,0,50) )	
--ply:EmitSound(Combo3)
ply:EmitSound(Stap)
self.Owner:ViewPunch(Angle(-5, -1, 0))
		local k, v
		local dmg = DamageInfo()
			dmg:SetDamage( 80 ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)
		for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 50, 150 ) ) do 
			if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
			if v:IsNPC() then--
			if SERVER then
			v:SetCondition( 67 )
			v:EmitSound(Stapout)			
			timer.Simple(2, function()
			if IsValid(v) then 
			v:SetCondition( 68 )
			end
			end)			
			v:SetVelocity((self.Owner:GetForward() * 1) * 100  )	
			ParticleEffect("blood_advisor_puncture_withdraw",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
			end
			end
			if v:IsPlayer() then--
			v:Freeze( true )
			v:EmitSound(Stapout)
			ply:EmitSound(Combo3)
			timer.Simple(0.9, function()
			if IsValid(v) then 
			v:Freeze( false )
			end
			end)			
			v:SetVelocity((self.Owner:GetForward() * 1) * 100 )	
			ParticleEffect("blood_advisor_puncture_withdraw",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
			end
				dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
				if SERVER then
				v:TakeDamageInfo( dmg )
				end
			end	
		end	
end)
end

function table_contains(tbl, x)
    found = false
    for _, v in pairs(tbl) do
        if v == x then 
            found = true 
        end
    end
    return found
end
--==================--
function SWEP:DoCombo( hitsound, combonumber, force, freezetime, attackdelay, anim, viewbob, primarystuntime, stuntime, sound, sounddelay, hastrail, haspush, push, pushdelay, aircombo ,pushenemy)
	local ply = self.Owner
	self.back = false
	self.combo = combonumber
	if anim != "weapon_art" then
		self:SetHoldType(string.Replace(anim, "_tag", ""))
	end
	ply:ViewPunch(viewbob)
	self.backtime = CurTime() + stuntime
	if haspush == true then
	timer.Simple(pushdelay, function()
	ply:SetVelocity((self.Owner:GetForward() * 1) * push + Vector(0,0,50) )	
	end)
	end
	timer.Simple(sounddelay, function() 
	
	if hastrail == true then
	ply:EmitSound(SwordTrail)
	end
	end)
	self.dodgetime = CurTime() + primarystuntime
	if anim != "weapon_art" then
		ply:SetAnimation( PLAYER_ATTACK1 )
	end
	self.duringattack = true
	self.duringattacktime = CurTime() + stuntime
	self.Weapon:SetNextPrimaryFire(CurTime() + primarystuntime )
	
	if aircombo == true then
		local pl = self.Owner
		local ang = pl:GetAngles()
		local forward, right = ang:Forward(), ang:Right()
		
		local vel = -1 * pl:GetVelocity()
		vel = vel + Vector(0, 0, 240) 
		
		local spd = pl:GetMaxSpeed()
		
		if pl:KeyDown(IN_FORWARD) then
			vel = vel + forward * spd
		elseif pl:KeyDown(IN_BACK) then
			vel = vel - forward * spd
		end
		
		if pl:KeyDown(IN_MOVERIGHT) then
			vel = vel + right * spd
		elseif pl:KeyDown(IN_MOVELEFT) then
			vel = vel - right * spd
		end
		
		pl:SetVelocity(vel) 
	end

	timer.Simple(attackdelay, function()
		local k, v
		local dmg = DamageInfo()
			dmg:SetDamage( force ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)

		local origin = self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 50
		local radius = 120

		if anim == "g_combo2_tag" then
			origin = self.Owner:GetPos() + Vector(0, 0, 40) + (self.Owner:GetForward() * 10)
			radius = 50
		end

		for k, v in pairs ( ents.FindInSphere( origin,radius ) ) do 

			if v:IsValid() and self.Owner:Alive() and  v != self.Owner then

				if v:IsNPC() then
			
					if SERVER then
						v:SetCondition( 67 )
						v:EmitSound(hitsound)
						timer.Simple(freezetime, function()
						self:Think(v)
						if self.combo != 14 and self.combo != 24 then
						if IsValid(v) and self.combo == 11 then 
						v:SetCondition( 68 )
						end
						if IsValid(v) and self.combo == combonumber + 1 then 
						v:SetCondition( 68 )

						

				end
			end
		end)



		net.Start("DisplayDamage")
		net.WriteInt(force, 32)
		net.WriteEntity(v)
		net.WriteColor(Color(249,148,6,255))
		net.Send(ply)

		v:TakeDamageInfo( dmg )	ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
		if aircombo == true then
			
		local ang = v:GetAngles()
		local forward, right = ang:Forward(), ang:Right()
		
		local vel = -1 * v:GetVelocity()
		vel = vel + Vector(0, 0, 220) 
		
		
		v:SetVelocity(vel)
		


		end
			
		end
		end
	--========================================================--
			if v:IsPlayer() then
			
				if anim == "g_combo2_tag" then

					if not table_contains(self.listTargetPlayers, v) then

						table.insert(self.listTargetPlayers, v)
					
					end

				
					-- if #self.listTargetPlayers == 3 then
					-- 	timer.Simple(5, function()
					-- 		table.Empty(self.listTargetPlayers)
						
					-- 	end)
				
					-- end
				end

				if SERVER then

					net.Start("DisplayDamage")
					net.WriteInt(force, 32)
					net.WriteEntity(v)
					net.WriteColor(Color(249,148,6,255))
					net.Send(ply)
				end

				ply:EmitSound(sound)
		
			ParticleEffect("blood_advisor_puncture", v:GetPos() + v:GetForward() * 0 + Vector(0, 0, 40), Angle(0, 45, 0))

			if aircombo == true then
			
		local ang = v:GetAngles()
		local forward, right = ang:Forward(), ang:Right()
		
		local vel = -1 * v:GetVelocity()
		vel = vel + Vector(0, 0, 220)
		
		
		v:SetVelocity(vel) 
			end
			
			end
			if pushenemy == true then
			v:SetVelocity((ply:GetForward() * 10) * 2700 + Vector(0,0,300) )			
			end
				dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
				if SERVER then
				v:TakeDamageInfo( dmg )
				end
			end	
		end
	end)
end

function SWEP:PrimaryAttack()

if self.clawsHolstered then
	return
end


self.Weapon:SetNextSecondaryFire(CurTime() + 0.6 )
if self.combo == 0 then

return end

if self.Owner:KeyDown(IN_WALK) and self.Owner:KeyDown(IN_ATTACK) and (self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_FORWARD)) then
else
if self.Owner:IsOnGround() then
if self.combo == 11 then
	self:DoCombo( AttackHit1, 11, 22, 1.2, 0.16, "g_combo1", Angle(3, -3, 0),0.3, 0.7, Combo1, 0.14, false, true, 150, 0.2,false)
	self.combo = 12
timer.Simple(1, function()
	if self.combo == 12 then
	self.combo = 11 
	end
end)
elseif self.combo == 12 then
	self:DoCombo( AttackHit2, 12, 23, 1.2, 0.15, "g_combo2", Angle(1, 3, 0), 0.4, 0.8, Combo4, 0.12, false, true, 230, 0.2,false )
	self.combo = 13
timer.Simple(1, function()
	if self.combo == 13 then
	self.combo = 11
	end
end)
elseif self.combo == 13 then
	self:DoCombo( AttackHit1, 13, 26, 1.2,  0.17, "g_combo3", Angle(-2, -3, 0),0.3, 0.9, Combo2, 0.17, false, true, 300, 0.2,false )
	self.combo = 14
timer.Simple(0.8, function()
	if self.combo == 14 then
	self.combo = 15
	timer.Simple(0.7, function()
	if self.combo == 15 then
	self.combo = 11
	end
	end)
	end
end)
elseif self.combo == 14 then
self.Owner:EmitSound(Ready)
	self:DoCombo( Stapout, 14, 57, 2.7, 0.4, "g_combo4", Angle(3, -5, 0), 1.3, 1.2, Combo3, 0.4, true, true, 600, 0.3, false, true,false )
	self.combo = 11
	self.Owner:EmitSound(Cloth)
elseif self.combo == 15 then
self:KillMove()
self.combo = 14
timer.Simple(1.8, function()
	if self.combo == 14 then
	self.combo = 11
	end
end)
end
end
if not self.Owner:IsOnGround() then
if self.combo == 11 then
	self:DoCombo( AttackHit2, 21, 22, 1.2, 0.16, "a_combo1", Angle(3, -3, 0), 0.25, 0.7, Combo1, 0.14, false, false, 150, 0.2 , true,false)
	self.combo = 12
timer.Simple(1, function()
	if self.combo == 12 then
	self.combo = 11 
	end
end)
elseif self.combo == 12 then
	self:DoCombo( AttackHit1, 22, 22, 1.2, 0.15, "a_combo2", Angle(-2, 3, 0), 0.25, 0.8, Combo4, 0.12, false, false, 230, 0.2, true,false )
	self.combo = 13
timer.Simple(1, function()
	if self.combo == 13 then
	self.combo = 11
	end
end)
elseif self.combo == 13 then
	self:DoCombo( AttackHit1, 23, 23, 1.2, 0.15, "a_combo3", Angle(1, 3, 0), 0.32, 0.8, Combo2, 0.12, false, false, 230, 0.2, true,false )
	self.combo = 14
timer.Simple(1, function()
	if self.combo == 14 then
	self.combo = 11
	end
end)
elseif self.combo == 14 then
	self:SlashDown()
	self.combo = 11
end
end
end
end

 
function SWEP:SecondaryAttack()

	if self.clawsHolstered then
		return
	end

    local ply = self.Owner

	local force = Vector(0, 0, 750)
	
    local maxDistance = 800

    local trace = ply:GetEyeTrace()
    local target = trace.Entity

    if not (IsValid(target) and target:IsPlayer() and trace.HitPos:DistToSqr(ply:GetPos()) <= maxDistance ^ 2) then
		local ply = self.Owner
		if not ply:IsOnGround() then
			self:SlashDown()
			self.Weapon:SetNextSecondaryFire(CurTime() + 0.8 )
	
	 
			
		else
			if ply:KeyDown( IN_FORWARD ) then
				
				local particleName1 = "[6]_wind_blade"
				local attachment = ply:LookupBone("ValveBiped.Bip01_R_Foot")
	
				if attachment then
					ParticleEffectAttach(particleName1, PATTACH_ABSORIGIN_FOLLOW, ply, attachment)
				end
				timer.Simple(0.5, function()
					ply:StopParticles()	
				end)
	
				self:LeapAttack()
				self.Weapon:SetNextSecondaryFire(CurTime() + 1.3 )
	
	
			else ply:KeyDown( IN_BACK )
				self:SlashUp()
	
				self.Weapon:SetNextSecondaryFire(CurTime() + 0.8 )
			end
		end
		return
    end

	ply:SetNWBool("freezePlayer", true)
	target:SetNWBool("freezePlayer", true)

	self:SetNoDraw(true)

	self:SetHoldType("anim_ninjutsu2")
	ply:SetAnimation(PLAYER_RELOAD)

	local targetPos = target:GetPos() + target:GetAngles():Forward() * 50
	ply:EmitSound(Sound( "content/fleurlotus.wav"))
	ply:SetPos(targetPos)

	timer.Simple(0.5, function()
	
		target:SetVelocity(force)
		ply:SetVelocity(force)
		

		timer.Simple(0.5, function()
			self:SetHoldType("anim_launch")
			ply:SetAnimation(PLAYER_RELOAD)
			ply:SetNWBool("freezePlayer", false)
			self:SetNoDraw(false)

			timer.Simple(0.5, function()
			
				self:SlashDown()
			

				timer.Simple(0.2,function()

					target:SetPos(ply:GetPos()+Vector(0,0,-100))
					target:SetVelocity(-force*100)
			
					if not table_contains(self.listTargetPlayers, target) then

						table.insert(self.listTargetPlayers, target)
					
					end

					ply:EmitSound("ambient/explosions/explode_9.wav",50,100,0.5)
					ParticleEffect("[5]_blackexplosion8", target:GetPos(), Angle(0, 0, 0), nil)

					if SERVER then
						if IsValid(target) and target:IsPlayer() then
							local damageInfo = DamageInfo()
							damageInfo:SetDamage(50) 
							damageInfo:SetAttacker(ply) 
							damageInfo:SetInflictor(self)
							target:TakeDamageInfo(damageInfo)
						end
						
		
						net.Start("DisplayDamage")
						net.WriteInt(50, 32)
						net.WriteEntity(target)
						net.WriteColor(Color(249,148,6,255))
						net.Send(ply)

						timer.Simple(0.4,function()
					
							target:SetNWBool("freezePlayer", false)
							self:SetHoldType("a_combo1")
						end)
				
					end
				end)

			end)
		end)
	end)

end

function SWEP:Holster()
	self.duringattack = true
	self.Owner:SetWalkSpeed( 250 )
	self.Owner:SetRunSpeed( 450 )
	self.Owner:SetJumpPower(300)
	self.Owner:SetSlowWalkSpeed( 120 )
	self.combo = 11
	self.DownSlashed = true

	self.clawsHolstered = true
	self:SetHoldType("normal")
	self:SetNoDraw(true)  

	return true
end

hook.Add("PostPlayerDraw", "ClawsModelInBack", function(ply)
    local activeWeapon = ply:GetActiveWeapon()
    if not IsValid(activeWeapon) or activeWeapon:GetClass() ~= "weapon_claws" then return end

    if activeWeapon.clawsHolstered then
        if not IsValid(ply.clawsModelHolster) then
            local model = ClientsideModel("models/naruto/unique_props/unique_props10/foc_nr_unique_props10_bane.mdl")
            if IsValid(model) then
                model:SetNoDraw(true)
                ply.clawsModelHolster = model
            end
        end

        local bone = ply:LookupBone("ValveBiped.Bip01_Spine2")
        if not bone then return end

        local matrix = ply:GetBoneMatrix(bone)
        if not matrix then return end

        local pos = matrix:GetTranslation()
        local ang = matrix:GetAngles()

        pos = pos + ang:Forward() + ang:Up()*2 + ang:Right() * 6
        ang:RotateAroundAxis(ang:Right(), 90)

        ang:RotateAroundAxis(ang:Up()*50, -190)

        if IsValid(ply.clawsModelHolster) then
            ply.clawsModelHolster:SetRenderOrigin(pos)
            ply.clawsModelHolster:SetRenderAngles(ang)
            ply.clawsModelHolster:DrawModel()
        end
    else
        if IsValid(ply.clawsModelHolster) then
            ply.clawsModelHolster:Remove()
        end
    end
end)




local function CreatePlayerTrail(ply, attachment, color, duration)
    if not ply:IsValid() then return end

    local trail = util.SpriteTrail(
        ply,                    
        attachment,              
        color,                   
        false,                  
        5,                     
        0,                       
        duration,               
        1 / (15 + 1) * 0.5,     
        "trails/laser"           
    )

    timer.Simple(duration, function()
        if IsValid(trail) then trail:Remove() end
    end)
end

function SWEP:Reload()
    local ply = self.Owner

	if self.clawsHolstered then
		return
	end

    if CurTime() < (self.NextSpecialMove or 0) then return end
    self.NextSpecialMove = CurTime() + 3
	for i = 5,6 do
		ParticleEffectAttach("nrp_vi_shield", PATTACH_POINT_FOLLOW, ply, i)
	end
	self:SetHoldType("anim_claws")
	ply:SetNWBool("freezePlayer", true)
	if SERVER then
				
		for i = 5,6 do
			CreatePlayerTrail(ply, i, Color(255,255,255), 5)
		end


	end
	timer.Simple(1, function()

		-- local maxDistance = 2000

		-- local trace = ply:GetEyeTrace()
		-- local target = trace.Entity

		-- if not (IsValid(target) and target:IsPlayer() and trace.HitPos:DistToSqr(ply:GetPos()) <= maxDistance ^ 2) then
		-- 	return
		-- end

		for index, target in ipairs(self.listTargetPlayers) do
			local delay = (index - 1) * 0.5  
		
			timer.Simple(delay, function()
		
				if IsValid(target) then
					
					local targetPos = target:GetPos() + target:GetAngles():Forward() * 50
					ply:SetPos(targetPos)
					ply:SetAnimation(PLAYER_ATTACK1)
					timer.Simple(0.2, function()
						ply:SetAnimation(PLAYER_RELOAD)
					end)
			
					ply:EmitSound(AttackHit1)
		
				
					if SERVER then
				
						ParticleEffect("nrp_kenjutsu_slash", target:GetPos(), Angle(0, 0, 0), nil)
		
						if IsValid(target) and target:IsPlayer() then
							local damageInfo = DamageInfo()
							damageInfo:SetDamage(950) 
							damageInfo:SetAttacker(ply) 
							damageInfo:SetInflictor(self)
							target:TakeDamageInfo(damageInfo)
						end
		
						net.Start("DisplayDamage")
						net.WriteInt(950, 32)
						net.WriteEntity(target)
						net.WriteColor(Color(249, 148, 6, 255))
						net.Send(ply)
					end
				end
			end)
		end
		

		timer.Simple((#self.listTargetPlayers - 1) * 0.5 + 0.5, function()
			self:SetHoldType("g_combo1")
			table.Empty(self.listTargetPlayers)
			ply:SetNWBool("freezePlayer", false)
			ply:StopParticles()
		end)
		

	end)
end



hook.Add("PlayerButtonDown", "clawsSweps", function(ply, button)

	local activeWeapon = ply:GetActiveWeapon()

    if not IsValid(activeWeapon) or activeWeapon:GetClass() ~= "weapon_claws" then
        return
    end

    if button == MOUSE_MIDDLE then

        if CurTime() < activeWeapon.NextHolsterWeapon then return end
        activeWeapon.NextHolsterWeapon = CurTime() + 0.5

        activeWeapon.clawsHolstered = not activeWeapon.clawsHolstered

        if SERVER then
            net.Start("Claws_State")
            net.WriteEntity(ply)
            net.WriteBool(activeWeapon.clawsHolstered)
            net.Broadcast()
        end

	elseif button == KEY_E then

        if CurTime() < activeWeapon.NextTagMove or ply:GetNWBool("freezePlayer", true) or #activeWeapon.listTargetPlayers == 10 or activeWeapon.clawsHolstered then return end
        activeWeapon.NextTagMove = CurTime() + 1

        activeWeapon:DoCombo( AttackHit1, 11, 5, 1.2, 0.16, "g_combo2_tag", Angle(3, -3, 0),0.3, 0.7, Combo1, 0.14, false, true, 150, 0.2,false)
		
	end
	
end)

if CLIENT then
    net.Receive("Claws_State", function()
        local ply = net.ReadEntity()
        local holstered = net.ReadBool()

        if not IsValid(ply) or not ply:IsPlayer() then return end
        local activeWeapon = ply:GetActiveWeapon()

        if IsValid(activeWeapon) and activeWeapon:GetClass() == "weapon_claws" then
            activeWeapon.clawsHolstered = holstered

            if holstered then
                activeWeapon:SetHoldType("normal")
                activeWeapon:SetNoDraw(true)
            else
                activeWeapon:SetHoldType("g_combo1")
                activeWeapon:SetNoDraw(false)
				
            end
        end
    end)
end

