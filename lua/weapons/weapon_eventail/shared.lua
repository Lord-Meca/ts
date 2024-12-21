if (SERVER) then
	AddCSLuaFile()
    util.AddNetworkString("DisplayDamage")
	util.AddNetworkString("Eventail_State")
end

if (CLIENT) then
	SWEP.Slot = 0
	SWEP.SlotPos = 0
	SWEP.DrawAmmo = false
	SWEP.PrintName = "Eventail"
	SWEP.DrawCrosshair = true


end



SWEP.ViewModelFOV = 77
SWEP.UseHands = false
SWEP.Category = "TypeShit | Armes"
SWEP.Purpose = ""
SWEP.Contact = ""
SWEP.Author = "Lord_Meca"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/silverhawks/foc_arme_epouventail_close_shigi.mdl"
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
SWEP.NextRepulsiveTornadoMove = 0
SWEP.NextAttractiveTornadoMove = 0
--SWEP.eventailModelHolster = nil
SWEP.eventailHolstered = true

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
		net.Start("Eventail_State")
		net.WriteEntity(self.Owner)
		net.WriteBool(self.eventailHolstered)
		net.Broadcast()
	end

	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_coat_03.mdl")

 
end


function SWEP:Initialize()
	self.combo = 11
	self:SetHoldType("none")
	self.duringattack = false
	self.backtime = 0
	self.duringattacktime = 0
	self.dodgetime = 0
	self.plyindirction = false
	self.npcfreezetime = 0
	self.DownSlashed = true
	self.downslashingdelay = 0
	self.back = true




end

function SWEP:DoAnimation( anim1 )
self:SetHoldType(anim1)
self.Owner:SetAnimation(PLAYER_ATTACK1)
end


function SWEP:Think()
	local ply = self.Owner

	if self.eventailHolstered then
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


--==================--
function SWEP:DoCombo( hitsound, combonumber, force, freezetime, attackdelay, anim, viewbob, primarystuntime, stuntime, sound, sounddelay, hastrail, haspush, push, pushdelay, aircombo ,pushenemy)
	local ply = self.Owner
	self.back = false
	self.combo = combonumber
	if anim != "weapon_art" then
		self:SetHoldType(anim)
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
		for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 50, 120 ) ) do 

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

if self.eventailHolstered then
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

	if self.eventailHolstered then
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

	ply:SetNWBool("freezePlayer", true )
	target:SetNWBool("freezePlayer", true )

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

	self.eventailHolstered = true
	self:SetHoldType("none")
	self:SetNoDraw(true)  

	return true
end

hook.Add("PostPlayerDraw", "EventailModelInBack", function(ply)
    local activeWeapon = ply:GetActiveWeapon()
    if not IsValid(activeWeapon) or activeWeapon:GetClass() ~= "weapon_eventail" then return end

    if activeWeapon.eventailHolstered then
        if not IsValid(ply.eventailModelHolster) then
            local model = ClientsideModel("models/silverhawks/foc_arme_epouventail_close_shigi.mdl")
            if IsValid(model) then
                model:SetNoDraw(true)
                ply.eventailModelHolster = model
            end
        end

        local bone = ply:LookupBone("ValveBiped.Bip01_Spine2")
        if not bone then return end

        local matrix = ply:GetBoneMatrix(bone)
        if not matrix then return end

        local pos = matrix:GetTranslation()
        local ang = matrix:GetAngles()

        pos = pos + ang:Forward() * -10 + ang:Up() * 20 + ang:Right() * 4
        ang:RotateAroundAxis(ang:Forward(), 180)
        ang:RotateAroundAxis(ang:Right(), 30)
        ang:RotateAroundAxis(ang:Up(), 180)

        if IsValid(ply.eventailModelHolster) then
            ply.eventailModelHolster:SetRenderOrigin(pos)
            ply.eventailModelHolster:SetRenderAngles(ang)
            ply.eventailModelHolster:DrawModel()
        end
    else
        if IsValid(ply.eventailModelHolster) then
            ply.eventailModelHolster:Remove()
        end
    end
end)



function spawnTornado(ply, isAttractive)
    local modelEntity = ents.Create("prop_dynamic")
    local moveTimeLeft = 1
    local damage = 150
    local affectedNearbyEntities = {}

    if not IsValid(modelEntity) then return end

    modelEntity:SetModel("models/foc/foc_wind.mdl")

    local spawnPos = ply:GetPos()
    modelEntity:SetPos(spawnPos)
    modelEntity:SetAngles(Angle(0, 0, 0))
    modelEntity:SetModelScale(1)
    modelEntity:Spawn()

    ply:EmitSound(Sound("ambient/explosions/explode_5.wav"))

    local animID = modelEntity:LookupSequence("idle")
    if animID < 0 then return end

    modelEntity:SetSequence(animID)
    modelEntity:SetCycle(0)
    modelEntity:SetPlaybackRate(1)

    local currentScale = isAttractive and 15 or 1
    local targetScale = isAttractive and 0.5 or 15
    local scaleIncrement = (targetScale - currentScale) / (moveTimeLeft * 10)

    timer.Create("TornadoEffect_"..modelEntity:EntIndex(), 0.03, moveTimeLeft * 10, function()
        if IsValid(modelEntity) then
 
            currentScale = currentScale + scaleIncrement
            modelEntity:SetModelScale(currentScale, 0)

            for _, entity in pairs(ents.FindInSphere(modelEntity:GetPos(), 60 * currentScale)) do
                if IsValid(entity) and (entity:IsPlayer() or entity:IsNPC()) then
                    if entity ~= ply and not affectedNearbyEntities[entity] then
                        local plyPos = ply:GetPos() + Vector(0, 0, 150)
                        local entityPos = entity:GetPos()
						local direction
						if isAttractive then
					
							direction = (plyPos - entityPos):GetNormalized()
							entity:SetVelocity(direction*1700)

						else
						
							direction = (entityPos - plyPos):GetNormalized()
							local horizontalBoost = 2000 
							local verticalBoost = 800 
							local finalVelocity = direction * horizontalBoost
							finalVelocity.z = verticalBoost 
							entity:SetVelocity(finalVelocity)
						end
                    
                        local damageInfo = DamageInfo()
                        damageInfo:SetDamage(damage)
                        damageInfo:SetDamageType(DMG_BLAST)
                        damageInfo:SetAttacker(ply)
                        damageInfo:SetInflictor(ply)

                        entity:TakeDamageInfo(damageInfo)

                        affectedNearbyEntities[entity] = true

                  
                        net.Start("DisplayDamage")
                        net.WriteInt(damage, 32)
                        net.WriteEntity(entity)
                        net.WriteColor(Color(51, 125, 255, 255))
                        net.Send(ply)
                    end
                end
            end
        else
            timer.Remove("TornadoEffect_"..modelEntity:EntIndex())
        end
    end)

    timer.Simple(moveTimeLeft, function()
        if IsValid(modelEntity) then
            timer.Simple(1, function()
                if IsValid(modelEntity) then
                    modelEntity:Remove()
                end
                timer.Remove("TornadoEffect_"..modelEntity:EntIndex())
            end)
        end
    end)
end


function invokeFuret(ply,self)

	local startPos = ply:GetShootPos()
    local aimDir = ply:GetAimVector()

    ply:EmitSound("content/shukaku_scream2.wav",39,100,5)

	local speed = 1500
    local velocity = aimDir * speed  
    local affectedNearbyEntities = {}
	local kamatari = ents.Create("prop_dynamic")
	kamatari:SetModel("models/fsc/billy/furetprout.mdl")
	kamatari:SetPos(startPos + ply:EyeAngles():Forward() * 200)
	kamatari:SetModelScale(2)
	kamatari:SetAngles(aimDir:Angle()+Angle(0,0,60))
	kamatari:Spawn()

	local kusarigama = ents.Create("prop_physics")
	kusarigama:SetModel("models/warwax_et_tsu/foc/naruto/faux_kusarigama2.mdl")
	kusarigama:SetModelScale(2)
	kusarigama:SetAngles(aimDir:Angle()+Angle(0,70,60))
	kusarigama:Spawn()


	local offset = Vector(-120,-20,-40) 
	local offset = Vector(-120,-20,-30) 
	local furetAngles = kamatari:GetAngles()
	local attachedPos = kamatari:GetPos() + furetAngles:Forward() * offset.x + furetAngles:Right() * offset.y + furetAngles:Up() * offset.z
	kusarigama:SetPos(attachedPos)

	constraint.Weld(kamatari, kusarigama, 0, 0, 0, true)
  

	util.SpriteTrail(kamatari, 0, Color(255,255,255), false, 50, 50, 1, 50, "trails/laser.vmt")
	util.SpriteTrail(kusarigama, 0, Color(255,255,255), false, 50, 50, 1, 50, "trails/laser.vmt")

	local phys = kamatari:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableGravity(false)
		phys:EnableMotion(true) 
		phys:SetVelocity(velocity)
	end

    hook.Add("Think", "kamatariMove" .. kamatari:EntIndex(), function()
        if not IsValid(kamatari) or not IsValid(kusarigama) then return end
    
        local currentAngles = kamatari:GetAngles()
        local newAngles = currentAngles + Angle(0, 500 * FrameTime(), 0)
        kamatari:SetAngles(newAngles)
    
        local kusarigamaAngles = kusarigama:GetAngles()
        local newkusarigamaAngles = kusarigamaAngles + Angle(300 * FrameTime(), 0, 0)
        kusarigama:SetAngles(newkusarigamaAngles)

        local trace = util.TraceLine({
            start = kamatari:GetPos(),
            endpos = kamatari:GetPos() + velocity * 0.2,
            filter = kamatari
        })
    
        if trace.Hit then
     
            if trace.Entity == kamatari or trace.Entity == kusarigama then
                return
            end

            local effectdata = EffectData()
            effectdata:SetOrigin(trace.HitPos)
            effectdata:SetNormal(trace.HitNormal)
            ParticleEffect("nrp_tool_invocation", kamatari:GetPos(), Angle(0, 0, 0), nil)
            ply:EmitSound("ambient/explosions/explode_9.wav", 50, 100, 0.5)
    
            for _, entity in ipairs(ents.FindInSphere(trace.HitPos, 350)) do
                if entity:IsPlayer() or entity:IsNPC() then
                    if entity ~= ply then
                    
                        ParticleEffect("nrp_kenjutsu_tranchant", kamatari:GetPos(),kamatari:GetAngles(), nil)
                        ParticleEffect("blood_advisor_puncture_withdraw", entity:GetPos(), Angle(0, 45, 0), nil)
           
                        local damageInfo = DamageInfo()
                        damageInfo:SetDamage(350) 
                        damageInfo:SetAttacker(kamatari) 
                        damageInfo:SetInflictor(self)
                        entity:TakeDamageInfo(damageInfo)
    
          
                        net.Start("DisplayDamage")
                        net.WriteInt(350, 32)
                        net.WriteEntity(entity)
                        net.WriteColor(Color(249, 148, 6, 255))
                        net.Send(ply)
                    end
                end
            end
    

            kamatari:Remove()
            kusarigama:Remove()
            hook.Remove("Think", "kamatariMove" .. kamatari:EntIndex())
        else
   
            kamatari:SetPos(kamatari:GetPos() + velocity * FrameTime())
            kusarigama:SetPos(kusarigama:GetPos() + velocity * FrameTime())

            for _, entity in ipairs(ents.FindInSphere(kamatari:GetPos(), 200)) do
                if entity:IsPlayer() or entity:IsNPC() then
                    if entity ~= ply and not affectedNearbyEntities[entity] then

                        ply:EmitSound("physics/body/body_medium_break3.wav", 50, 100, 0.5)
                        local damageInfo = DamageInfo()
                        damageInfo:SetDamage(100)
                        damageInfo:SetAttacker(kamatari)
                        damageInfo:SetInflictor(self)
                        entity:TakeDamageInfo(damageInfo)

                        net.Start("DisplayDamage")
                        net.WriteInt(100, 32)
                        net.WriteEntity(entity)
                        net.WriteColor(Color(249, 148, 6, 255))
                        net.Send(ply)
 
                        affectedNearbyEntities[entity] = true

                        ParticleEffect("nrp_kenjutsu_slash", kamatari:GetPos(), kamatari:GetAngles(), nil)
                        ParticleEffect("blood_advisor_puncture_withdraw", entity:GetPos(), Angle(0, 45, 0), nil)
                      
                    end
                end
            end
        end
    end)

    timer.Simple(5, function()

        if not IsValid(ent) then return end

        ParticleEffect("nrp_tool_invocation", kamatari:GetPos(), Angle(0, 0, 0), nil)
        ply:EmitSound("ambient/explosions/explode_9.wav", 50, 100, 0.5)

        for _, entity in ipairs(ents.FindInSphere(kamatari:GetPos(), 350)) do
            if entity:IsPlayer() or entity:IsNPC() then
                if entity ~= ply then

                
                    ParticleEffect("blood_advisor_puncture_withdraw", entity:GetPos(), Angle(0, 45, 0), nil)

       
                    local damageInfo = DamageInfo()
                    damageInfo:SetDamage(350) 
                    damageInfo:SetAttacker(kamatari) 
                    damageInfo:SetInflictor(self)
                    entity:TakeDamageInfo(damageInfo)

      
                    net.Start("DisplayDamage")
                    net.WriteInt(350, 32)
                    net.WriteEntity(entity)
                    net.WriteColor(Color(249, 148, 6, 255))
                    net.Send(ply)
                end
            end
        end

        kamatari:Remove()
        kusarigama:Remove()
        hook.Remove("Think", "kamatariMove" .. kamatari:EntIndex())

    end)
    
end


function SWEP:Reload()
    local ply = self.Owner

	if self.eventailHolstered then
		return
	end

    if CurTime() < (self.NextSpecialMove or 0) then return end
    self.NextSpecialMove = CurTime() + 25

	self:SetHoldType("weapon_art")
	self.WorldModel = "models/silverhawks/foc_arme_epouventail_shigi.mdl"
	self:SetModel(self.WorldModel)
	ply:SetAnimation(PLAYER_ATTACK1)


	ply:EmitSound("ambient/explosions/explode_9.wav")
	ParticleEffect("nrp_tool_invocation", ply:GetPos(), Angle(0,0,0), nil)
	timer.Simple(0.7, function()

		if SERVER then
			invokeFuret(ply,self)
		end
		
		self:StopParticles()
		   
		self.WorldModel = "models/silverhawks/foc_arme_epouventail_close_shigi.mdl"
		self:SetModel(self.WorldModel) 
		
	end)
end



hook.Add("PlayerButtonDown", "eventailSweps", function(ply, button)

	local activeWeapon = ply:GetActiveWeapon()

    if not IsValid(activeWeapon) or activeWeapon:GetClass() ~= "weapon_eventail" then
        return
    end

    if button == MOUSE_MIDDLE then

        if CurTime() < activeWeapon.NextHolsterWeapon then return end
        activeWeapon.NextHolsterWeapon = CurTime() + 0.5

        activeWeapon.eventailHolstered = not activeWeapon.eventailHolstered

        if SERVER then
            net.Start("Eventail_State")
            net.WriteEntity(ply)
            net.WriteBool(activeWeapon.eventailHolstered)
            net.Broadcast()
        end
    
	elseif button == KEY_E then

		if activeWeapon.eventailHolstered or ply:GetNWBool("freezePlayer") then
			return
		end

		if CurTime() < activeWeapon.NextRepulsiveTornadoMove then return end
		activeWeapon.NextRepulsiveTornadoMove = CurTime() + 20

		activeWeapon:SetHoldType("weapon_art")
		activeWeapon.WorldModel = "models/silverhawks/foc_arme_epouventail_shigi.mdl"
		activeWeapon:SetModel(activeWeapon.WorldModel)
		ply:SetAnimation(PLAYER_ATTACK1)

		
		for i = 1,6 do
			ParticleEffectAttach("[4]_kitsushi_aura", PATTACH_POINT_FOLLOW, ply, i)
		end
		
	
		timer.Simple(0.7, function()
	
			ply:StopParticles()
			if SERVER then
				spawnTornado(ply, false)
			end
			
			activeWeapon:StopParticles()
			   
			activeWeapon.WorldModel = "models/silverhawks/foc_arme_epouventail_close_shigi.mdl"
			activeWeapon:SetModel(activeWeapon.WorldModel) 
			
		end)
	elseif button == KEY_F then

		if activeWeapon.eventailHolstered or ply:GetNWBool("freezePlayer") then
			return
		end

		if CurTime() < activeWeapon.NextAttractiveTornadoMove then return end
		activeWeapon.NextAttractiveTornadoMove = CurTime() + 20

		activeWeapon:SetHoldType("weapon_art")
		activeWeapon.WorldModel = "models/silverhawks/foc_arme_epouventail_shigi.mdl"
		activeWeapon:SetModel(activeWeapon.WorldModel)
		ply:SetAnimation(PLAYER_ATTACK1)

		for i = 1,6 do
			ParticleEffectAttach("[4]_kitsushi_aura", PATTACH_POINT_FOLLOW, ply, i)
		end
		
	
		timer.Simple(0.7, function()
	
			ply:StopParticles()
			if SERVER then
				spawnTornado(ply, true)
			end
			
			activeWeapon:StopParticles()
			   
			activeWeapon.WorldModel = "models/silverhawks/foc_arme_epouventail_close_shigi.mdl"
			activeWeapon:SetModel(activeWeapon.WorldModel) 
			
		end)
	end

	
end)

if CLIENT then
    net.Receive("Eventail_State", function()
        local ply = net.ReadEntity()
        local holstered = net.ReadBool()

        if not IsValid(ply) or not ply:IsPlayer() then return end
        local activeWeapon = ply:GetActiveWeapon()

        if IsValid(activeWeapon) and activeWeapon:GetClass() == "weapon_eventail" then
            activeWeapon.eventailHolstered = holstered

            if holstered then
                activeWeapon:SetHoldType("none")
                activeWeapon:SetNoDraw(true)
            else
                activeWeapon:SetHoldType("g_combo1")
                activeWeapon:SetNoDraw(false)

            end
        end
    end)
end
