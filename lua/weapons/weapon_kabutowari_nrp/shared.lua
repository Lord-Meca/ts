if (SERVER) then
	AddCSLuaFile()
	util.AddNetworkString("DisplayDamage")
	util.AddNetworkString("Kabutowari_State")
end

if (CLIENT) then
	SWEP.Slot = 0
	SWEP.SlotPos = 4
	SWEP.DrawAmmo = false
	SWEP.PrintName = "Kabutowari"
	SWEP.DrawCrosshair = true


end



SWEP.ViewModelFOV = 77
SWEP.UseHands = false
SWEP.Category = "TypeShit | Armes"
SWEP.Purpose = ""
SWEP.Contact = ""
SWEP.Author = "Lord_Meca"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/naruto/unique/unique3/foc_nr_unique3_bane.mdl"
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
SWEP.canParry = false

SWEP.kabutowariHolstered = true
SWEP.NextHolsterWeapon = 0

local AttackHit2 = Sound( "physics/body/body_meeum_break3.wav")
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
		net.Start("Kabutowari_State")
		net.WriteEntity(self.Owner)
		net.WriteBool(self.kabutowariHolstered)
		net.Broadcast()
	end
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_custom_armor_nass_02.mdl")




end


function SWEP:Initialize()
	self.combo = 11

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
	if self.kabutowariHolstered then
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
	if anim != "anim_kiba" then
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
	if anim != "anim_kiba" then
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
				ply:EmitSound(sound)

				if SERVER then
					net.Start("DisplayDamage")
					net.WriteInt(force, 32)
					net.WriteEntity(v)
					net.WriteColor(Color(249,148,6,255))
					net.Send(ply)
				end
				
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
			v:SetVelocity((ply:GetForward() * 10) * 250 + Vector(0,0,300) )			
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
if self.kabutowariHolstered then
	return
end
self.Weapon:SetNextSecondaryFire(CurTime() + 0.6 )
if self.combo == 0 then

return end

if self.Owner:KeyDown(IN_WALK) and self.Owner:KeyDown(IN_ATTACK) and (self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_FORWARD)) then
else
if self.Owner:IsOnGround() then
if self.combo == 11 then
	self:DoCombo( AttackHit1, 11, 22, 1.2, 0.16, "g_combo1", Angle(3, -3, 0),0.3, 0.7, Combo1, 0.14, false, true, 150, 0.2 )
	self.combo = 12
timer.Simple(1, function()
	if self.combo == 12 then
	self.combo = 11 
	end
end)
elseif self.combo == 12 then
	self:DoCombo( AttackHit2, 12, 23, 1.2, 0.15, "g_combo2", Angle(1, 3, 0), 0.4, 0.8, Combo4, 0.12, false, true, 230, 0.2 )
	self.combo = 13
timer.Simple(1, function()
	if self.combo == 13 then
	self.combo = 11
	end
end)
elseif self.combo == 13 then
	self:DoCombo( AttackHit1, 13, 26, 1.2,  0.17, "g_combo3", Angle(-2, -3, 0),0.3, 0.9, Combo2, 0.17, false, true, 300, 0.2 )
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
	self:DoCombo( Stapout, 14, 57, 2.7, 0.4, "g_combo4", Angle(3, -5, 0), 1.3, 1.2, Combo3, 0.4, true, true, 600, 0.3, false, true )
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
	self:DoCombo( AttackHit2, 21, 22, 1.2, 0.16, "a_combo1", Angle(3, -3, 0), 0.25, 0.7, Combo1, 0.14, false, false, 150, 0.2 , true)
	self.combo = 12
timer.Simple(1, function()
	if self.combo == 12 then
	self.combo = 11 
	end
end)
elseif self.combo == 12 then
	self:DoCombo( AttackHit1, 22, 22, 1.2, 0.15, "a_combo2", Angle(-2, 3, 0), 0.25, 0.8, Combo4, 0.12, false, false, 230, 0.2, true )
	self.combo = 13
timer.Simple(1, function()
	if self.combo == 13 then
	self.combo = 11
	end
end)
elseif self.combo == 13 then
	self:DoCombo( AttackHit1, 23, 23, 1.2, 0.15, "a_combo3", Angle(1, 3, 0), 0.32, 0.8, Combo2, 0.12, false, false, 230, 0.2, true )
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
	if self.kabutowariHolstered then
		return
	end
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
end

function SWEP:Holster()
	self.duringattack = true
	self.Owner:SetWalkSpeed( 250 )
	self.Owner:SetRunSpeed( 450 )
	self.Owner:SetJumpPower(300)
	self.Owner:SetSlowWalkSpeed( 120 )
	self.combo = 11
	self.DownSlashed = true
	return true
end

function SWEP:Reload()
	if self.kabutowariHolstered then
		return
	end
    local ply = self.Owner
    local cooldownTime = 10

    if CurTime() < self.NextSpecialMove then return end
    self.NextSpecialMove = CurTime() + cooldownTime


	self:SetHoldType("slashdown")
	ply:SetAnimation(PLAYER_RELOAD)
    timer.Simple(0.3, function()
	
		self:DoCombo( AttackHit1, 11, 350, 0, 0.16, "anim_kiba", Angle(3, -3, 0),0, 0, Combo1, 0.14, false, false, 0, 0,false,true, true)
		ParticleEffect("[0]_chakra_charge_groundhit",ply:GetPos() + ply:GetForward() * 0 + Vector( 0, 0, 0 ),Angle(0,0,0),nil)
		ply:EmitSound(Hitground2)
		

    end)
end

hook.Add("PostPlayerDraw", "KabutowariModelInBack", function(ply)
    local activeWeapon = ply:GetActiveWeapon()
    if not IsValid(activeWeapon) or activeWeapon:GetClass() ~= "weapon_kabutowari_nrp" then return end

    if activeWeapon.kabutowariHolstered then
        if not IsValid(ply.kabutowariModelHolster) then
            local model = ClientsideModel("models/naruto/unique_props/unique_props3/foc_nr_unique_props3_bane.mdl")
            if IsValid(model) then
                model:SetNoDraw(true)
                ply.kabutowariModelHolster = model
            end
        end

        local bone = ply:LookupBone("ValveBiped.Bip01_Spine2")
        if not bone then return end

        local matrix = ply:GetBoneMatrix(bone)
        if not matrix then return end

        local pos = matrix:GetTranslation()
        local ang = matrix:GetAngles()

        pos = pos + ang:Forward() * 5 + ang:Up() * 0 + ang:Right() * 15
        ang:RotateAroundAxis(ang:Forward(), 90)

        ang:RotateAroundAxis(ang:Up(), 180)

        if IsValid(ply.kabutowariModelHolster) then
            ply.kabutowariModelHolster:SetRenderOrigin(pos)
            ply.kabutowariModelHolster:SetRenderAngles(ang)
            ply.kabutowariModelHolster:DrawModel()
        end
    else
        if IsValid(ply.kabutowariModelHolster) then
            ply.kabutowariModelHolster:Remove()
        end
    end
end)


hook.Add("PlayerButtonDown", "kabutowariSweps", function(ply, button)

	local activeWeapon = ply:GetActiveWeapon()

    if not IsValid(activeWeapon) or activeWeapon:GetClass() ~= "weapon_kabutowari_nrp" then
        return
    end

    if button == MOUSE_MIDDLE then

        if CurTime() < activeWeapon.NextHolsterWeapon then return end
        activeWeapon.NextHolsterWeapon = CurTime() + 0.5

        activeWeapon.kabutowariHolstered = not activeWeapon.kabutowariHolstered

        if SERVER then
            net.Start("Kabutowari_State")
            net.WriteEntity(ply)
            net.WriteBool(activeWeapon.kabutowariHolstered)
            net.Broadcast()
        end
    
	end

	
end)

if CLIENT then
    net.Receive("Kabutowari_State", function()
        local ply = net.ReadEntity()
        local holstered = net.ReadBool()

        if not IsValid(ply) or not ply:IsPlayer() then return end
        local activeWeapon = ply:GetActiveWeapon()

        if IsValid(activeWeapon) and activeWeapon:GetClass() == "weapon_kabutowari_nrp" then
            activeWeapon.kabutowariHolstered = holstered

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