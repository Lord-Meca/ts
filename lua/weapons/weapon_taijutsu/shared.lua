if (SERVER) then
	AddCSLuaFile()
    util.AddNetworkString("DisplayDamage")
end

SWEP.PrintName = "Taijutsu | The Only One"
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
SWEP.specialMoveActive = false

local Roll = Sound( "npc/combine_soldier/gear2.wav")
local AttackHit2 = Sound( "content/hitsound1.wav")
local AttackHit1 = Sound( "content/hitsound2.wav")
local Hitground2 = Sound( "physics/concrete/concrete_break2.wav")
local Hitground = Sound( "physics/concrete/concrete_break3.wav")


function SWEP:Deploy()
    local ply = self.Owner
	if IsValid(ply) then

		if ply:GetMaxHealth() != 2000 then 

			ply:SetMaxHealth(2000)
			ply:SetHealth(ply:GetMaxHealth())
		end
	end

	ply:SetModel("models/falko_naruto_foc/body_upper/sogeki_man_armorbandana_suna01.mdl")
	ply:ConCommand( "thirdperson_etp 1" )
		hook.Add("GetFallDamage", "RemoveFallDamage"..ply:GetName(), function(ply, speed)
			if( GetConVarNumber( "mp_falldamage" ) > 0 ) then
				return ( speed - 826.5 ) * ( 100 / 896 )
			end
			
			return 0
		end)



end

function SWEP:Initialize()
    self:SetHoldType( "taijutsu1" )

    self.combo = 11
    self.duringattack = false
	self.backtime = 0
	self.duringattacktime = 0
	self.dodgetime = 0
	self.plyindirction = false
	self.back = true
    self.lastDamageTime = 0


end

function SWEP:DoAnimation( self,anim,type )
    self:SetHoldType(anim)
    self.Owner:SetAnimation(type)
end

function SWEP:Think()
	local ply = self.Owner

    if self.specialMoveActive then

        for _, ply in ipairs(player.GetAll()) do
            if self.specialMoveActive then
              
                if CurTime() - self.lastDamageTime >= 1 then
                    self.lastDamageTime = CurTime()

                    if ply:Alive() then 
                        ply:SetHealth(math.max(ply:Health() - 2, 0)) 

                        if ply:Health() <= 0 then
                            ply:Kill()
                        end
                    end
                end
            end
        end


    end

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

    end 

    if ply:KeyDown(IN_SPEED) then 
        if self.specialMoveActive then
    
            ply:SetWalkSpeed(800)
            ply:SetRunSpeed(800)
        else
            ply:SetWalkSpeed( 250 )
            ply:SetRunSpeed( 450 )
        end
    
    
    
    end
    

    if self.duringattack == true and not self.Owner:KeyDown( IN_ATTACK ) and self.Owner:KeyDown( IN_JUMP ) and CurTime() > self.dodgetime then
    self.Owner:SetRunSpeed( 100 )
    self.Owner:SetJumpPower(300)
    if self.Owner:KeyDown( IN_MOVELEFT ) then
    if SERVER then
    self.Owner:EmitSound(Roll)
    end
    
    self:SetHoldType("taijutsu_rollleft")
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    self.dodgetime = CurTime() + 1.3
    self.Owner:SetVelocity((self.Owner:GetRight() * -1) * 400 - Vector(0,0,200))	
    self.Weapon:SetNextPrimaryFire(CurTime() + 1.3 )
    elseif self.Owner:KeyDown( IN_MOVERIGHT ) then
    if SERVER then
    self.Owner:EmitSound(Roll)
    end
    self:SetHoldType("taijutsu_rollright")
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    self.dodgetime = CurTime() + 1.4
    self.Owner:SetVelocity((self.Owner:GetRight() * 1) * 400 - Vector(0,0,200))	
    self.Weapon:SetNextPrimaryFire(CurTime() + 1.3 )
    elseif self.Owner:KeyDown( IN_BACK ) then
    if SERVER then
    self.Owner:EmitSound(Roll)
    end
    self:SetHoldType("taijutsu_rollback")
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    self.dodgetime = CurTime() + 1.6
    self.Owner:SetVelocity(Vector(0,0,100))	
    self.Weapon:SetNextPrimaryFire(CurTime() + 1.3 )
    end
    
    self.duringattacktime = CurTime() + 0.76
    self.back = false
    end
end

function SWEP:Holster()
	self.duringattack = true
	self.Owner:SetWalkSpeed( 250 )
	self.Owner:SetRunSpeed( 450 )
	self.Owner:SetJumpPower(300)
	self.Owner:SetSlowWalkSpeed( 120 )
	self.combo = 11

	return true
end

function SWEP:SecondaryAttack()

	local force = Vector(0, 0, 750)
	
    local maxDistance = 800
    local ply = self.Owner
    local trace = ply:GetEyeTrace()
    local target = trace.Entity

    if not (IsValid(target) and target:IsPlayer() and trace.HitPos:DistToSqr(ply:GetPos()) <= maxDistance ^ 2) then return end
    
    local dmglotus = 120
    if self.specialMoveActive then
        dmglotus = dmglotus*2
    end

	ply:Freeze(true)
	target:Freeze(true)

    ply:EmitSound(Sound("content/fleurlotus.wav",100,100,5))

	self:SetHoldType("anim_ninjutsu2")
	ply:SetAnimation(PLAYER_RELOAD)

	local targetPos = target:GetPos() + target:GetAngles():Forward() * 50

	ply:SetPos(targetPos)

	timer.Simple(0.5, function()
	
		target:SetVelocity(force)
		ply:SetVelocity(force)
		

		timer.Simple(0.5, function()
			self:SetHoldType("anim_launch")
			ply:SetAnimation(PLAYER_RELOAD)
			ply:Freeze(false)
		
			timer.Simple(0.5, function()
			
				timer.Simple(0.2,function()

					target:SetPos(ply:GetPos()+Vector(0,0,-100))
					target:SetVelocity(-force*100)
			
					ply:EmitSound("ambient/explosions/explode_9.wav",50,100,0.5)
					ParticleEffect("[5]_blackexplosion8", target:GetPos(), Angle(0, 0, 0), nil)

					if SERVER then
						if IsValid(target) and target:IsPlayer() then
							local damageInfo = DamageInfo()
							damageInfo:SetDamage(dmglotus) 
							damageInfo:SetAttacker(ply) 
							damageInfo:SetInflictor(self)
							target:TakeDamageInfo(damageInfo)
						end
						
		
						net.Start("DisplayDamage")
						net.WriteInt(dmglotus, 32)
						net.WriteEntity(target)
						net.WriteColor(Color(249,148,6,255))
						net.Send(ply)

						timer.Simple(0.6,function()
							target:Freeze(false)
							self:SetHoldType("taijutsu1")
						end)
				
					end
				end)

			end)
		end)
	end)

end

function SWEP:KillMove()
    self.Weapon:SetNextPrimaryFire(CurTime() + 1.3 )
    local ply = self.Owner
    self:SetHoldType("taijutsu2")
    ply:SetAnimation( PLAYER_ATTACK1 )
    self.duringattack = true
    self.duringattacktime = CurTime() 
    self.dodgetime = CurTime()
    --self.Owner:ViewPunch(Angle(5, 1, 0))
    timer.Simple(0.2, function() 
    --ply:SetVelocity((self.Owner:GetForward() * 1) * 500 + Vector(0,0,50) )	

            local k, v
            local dmg = DamageInfo()
                dmg:SetDamage( 1 ) 
                dmg:SetDamageType(DMG_SLASH)
                dmg:SetAttacker(self.Owner) 
                dmg:SetInflictor(self.Owner)
            for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 10, 50 ) ) do 
                if v:IsValid() and v ~= self.Owner then

                if v:IsNPC() then
                if SERVER then
            		
                v:SetCondition( 67 )
                timer.Simple(3, function()
                if IsValid(v) then 
                v:SetCondition( 68 )
                end
                end)			
                --v:SetVelocity((self.Owner:GetForward() * 1) * 100  )	
               -- ParticleEffect("nrp_hit_main",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
                end
                end
                if v:IsPlayer() then
         
                ply:EmitSound(AttackHit2)		
                v:Freeze( true )
                timer.Simple(0.9, function()
                if IsValid(v) then 
                v:Freeze( false )
                end
                end)			
                --v:SetVelocity((self.Owner:GetForward() * 1) * 100 )	
               -- ParticleEffect("nrp_hit_main",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
                end
                    dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
                    if SERVER then
                    v:TakeDamageInfo( dmg )
                    end
                end	
            end	
    end)
end
function SWEP:DoCombo(hitsound, combonumber, force, freezetime, attackdelay, anim, attacktype, viewbob, primarystuntime, stuntime, sound, sounddelay, hastrail, haspush, push, pushdelay, aircombo, pushenemy)
    local ply = self.Owner
    self.back = false
    self.combo = combonumber

    if anim ~= "taijutsu4_bourrasque" then
        self:SetHoldType(string.Replace(anim, "_talon", ""))
        ply:SetAnimation(attacktype)
    end

    self.backtime = CurTime() + stuntime
    self.dodgetime = CurTime() + primarystuntime

    self.duringattack = true
    self.duringattacktime = CurTime() + stuntime
 
    if self.specialMoveActive then
        if not string.find(anim, "_bourrasque") and not string.find(anim, "_talon") then
            force = force *3
            primarystuntime = 0.3
        end
    end


    self.Weapon:SetNextPrimaryFire(CurTime() + primarystuntime)

    timer.Simple(attackdelay, function()
        local dmg = DamageInfo()
        dmg:SetDamage(force)
        dmg:SetDamageType(DMG_SLASH)
        dmg:SetAttacker(self.Owner)
        dmg:SetInflictor(self.Owner)



        for _, v in pairs(ents.FindInSphere(self.Owner:GetPos() + Vector(0, 0, 40) + (self.Owner:GetForward() * 10), 50)) do
            if v:IsValid() and v ~= self.Owner then
                if v:IsNPC() then
                    if SERVER then
                        v:SetCondition(67)
                        v:EmitSound(hitsound)
                        timer.Simple(freezetime, function()
                            if self.combo ~= 14 and self.combo ~= 24 then
                                if IsValid(v) and self.combo == 11 then
                                    v:SetCondition(68)
                                end
                                if IsValid(v) and self.combo == combonumber + 1 then
                                    v:SetCondition(68)
                                end
                            end
                        end)
                    end

                    net.Start("DisplayDamage")
                    net.WriteInt(force, 32)
                    net.WriteEntity(v)
                    net.WriteColor(Color(249, 148, 6, 255))
                    net.Send(ply)

                    v:TakeDamageInfo(dmg)
                    ParticleEffect("nrp_hit_main", v:GetPos() + v:GetForward() * 0 + Vector(0, 0, 40), Angle(0, 45, 0), nil)
                elseif v:IsPlayer() then
                    if SERVER then
                        net.Start("DisplayDamage")
                        net.WriteInt(force, 32)
                        net.WriteEntity(v)
                        net.WriteColor(Color(249, 148, 6, 255))
                        net.Send(ply)
                    end

                    if anim == "taijutsu3_talon" then
                        local forceTalon = 650
                        if self.specialMoveActive then
                            forceTalon = 350
                        end
                        v:SetVelocity(Vector(0, 0, forceTalon))
                    end

                    ply:EmitSound(sound)
                    ParticleEffect("nrp_hit_main", v:GetPos() + v:GetForward() * 0 + Vector(0, 0, 40), Angle(0, 45, 0))
                end

                dmg:SetDamageForce((v:GetPos() - self.Owner:GetPos()):GetNormalized() * 100)
                if SERVER then
                    v:TakeDamageInfo(dmg)
                end
            end
        end
    end)
end


function SWEP:PrimaryAttack()

local cooldown = 0.6

if self.specialMoveActive then
    cooldown = 0.3
end

self.Weapon:SetNextSecondaryFire(CurTime() + cooldown )

if self.combo == 0 then

return end



if self.Owner:KeyDown(IN_WALK) and self.Owner:KeyDown(IN_ATTACK) and (self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_FORWARD)) then
else
if self.Owner:IsOnGround() then
if self.combo == 11 then
	self:DoCombo( AttackHit1, 11, 22, 1.2, 0.16, "taijutsu1", PLAYER_ATTACK1, Angle(3, -3, 0),0.5, 0.7, AttackHit1, 0.14, false, true, 150, 0.2,false)

	self.combo = 12
timer.Simple(1, function()
	if self.combo == 12 then
	self.combo = 11 
	end
end)
elseif self.combo == 12 then
	self:DoCombo( AttackHit2, 12, 23, 1.2, 0.15, "taijutsu1", PLAYER_RELOAD, Angle(1, 3, 0), 0.5, 0.8, AttackHit2, 0.12, false, true, 230, 0.2,false )
	self.combo = 13
timer.Simple(1, function()
	if self.combo == 13 then
	self.combo = 11
	end
end)
elseif self.combo == 13 then
	self:DoCombo( AttackHit1, 13, 26, 1.2,  0.17, "taijutsu2", PLAYER_ATTACK1, Angle(-2, -3, 0),0.5, 0.9, AttackHit1, 0.17, false, true, 300, 0.2,false )
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

	self:DoCombo( AttackHit2, 14, 57, 2.7, 0.4, "taijutsu2", PLAYER_RELOAD, Angle(3, -5, 0), 0.5, 1.2, AttackHit2, 0.4, true, true, 600, 0.3, false, true,false )
	self.combo = 11

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
	self:DoCombo( AttackHit2, 21, 22, 1.2, 0.16, "taijutsu2", PLAYER_ATTACK1, Angle(3, -3, 0), 0.5, 0.7, AttackHit1, 0.14, false, false, 150, 0.2 , true,false)
	self.combo = 12
timer.Simple(1, function()
	if self.combo == 12 then
	self.combo = 11 
	end
end)
elseif self.combo == 12 then
	self:DoCombo( AttackHit1, 22, 22, 1.2, 0.15, "taijutsu1", PLAYER_RELOAD, Angle(-2, 3, 0), 0.5, 0.8, AttackHit2, 0.12, false, false, 230, 0.2, true,false )
	self.combo = 13
timer.Simple(1, function()
	if self.combo == 13 then
	self.combo = 11
	end
end)
elseif self.combo == 13 then
	self:DoCombo( AttackHit1, 23, 23, 1.2, 0.15, "taijutsu2", PLAYER_ATTACK1, Angle(1, 3, 0), 0.5, 0.8, AttackHit1, 0.12, false, false, 230, 0.2, true,false )
	self.combo = 14
timer.Simple(1, function()
	if self.combo == 14 then
	self.combo = 11
	end
end)
elseif self.combo == 14 then

	self.combo = 11
end
end
end
end

function SWEP:Reload()
    local ply = self.Owner

    if CurTime() < (self.NextSpecialMove or 0) then return end
    self.NextSpecialMove = CurTime() + 3

    if self.specialMoveActive then

		if IsValid(self) and IsValid(ply) then
			
			ply:StopParticles()
			self.specialMoveActive = false
		end

    else

        self:SetHoldType("anim_nuibari")
        ply:SetAnimation(PLAYER_ATTACK1)	
     
        for i = 5,6 do
            ParticleEffectAttach("[0]_senju_renfo", PATTACH_POINT_FOLLOW, ply, i)
        end

        ParticleEffectAttach("izoxfoc_taijutsu_respiration_orange", PATTACH_ABSORIGIN_FOLLOW, ply, 0)
        self:SetHoldType("taijutsu1")

        self.specialMoveActive = true

  
    end
end

hook.Add("PlayerButtonDown", "taijutsuSweps", function(ply, button)
    if ply:GetActiveWeapon():GetClass() == "weapon_taijutsu" then
        if button == KEY_E then 

            local talonDmg = 95
            if ply:GetActiveWeapon().specialMoveActive then
                talonDmg = talonDmg*2
            end
            
            ply:GetActiveWeapon():DoCombo( AttackHit1, 11, talonDmg, 1.2, 0.16, "taijutsu3_talon", PLAYER_ATTACK1, Angle(3, -3, 0),0.5, 0.7, AttackHit1, 0.14, false, true, 150, 0.2,false)
            ply:GetActiveWeapon():SetHoldType("taijutsu3")
            ply:SetAnimation(PLAYER_ATTACK1)
            


        elseif button == KEY_F then

            local pos = ply:GetPos()
            local forward = ply:GetForward()

            local dashDistance = 1000
            local endPos = pos + forward * dashDistance
            
            local chargeDmg = 110
            if ply:GetActiveWeapon().specialMoveActive then
                chargeDmg = chargeDmg*2
            end

            timer.Simple(0.2, function()
                local margin = 50 
                local traceStart = pos
                local traceEnd = endPos

                local function checkPathForEntities(start, finish)
                    local directions = {
                        Vector(0, 0, 0),
                        Vector(margin, margin, 0),
                        Vector(-margin, margin, 0), 
                        Vector(margin, -margin, 0),
                        Vector(-margin, -margin, 0)
                    }
                    
                    for _, offset in pairs(directions) do
                        local trace = util.TraceLine({
                            start = start + offset,
                            endpos = finish + offset,
                            filter = ply
                        })

                        if trace.Hit then
                            return trace
                        end
                    end
                    return nil
                end

                local traceResult = checkPathForEntities(traceStart, traceEnd)
            
                if traceResult then
                    local entity = traceResult.Entity
                    
                
                    if entity:IsPlayer() and IsValid(entity) then
                        ply:EmitSound(AttackHit2)
                        
     
                        local distanceBeforeImpact = 100
                        local stopPos = traceResult.HitPos - forward * distanceBeforeImpact
            
     
                        ply:SetPos(stopPos)
            
                   
                        local dmg = DamageInfo()
                        dmg:SetDamage(chargeDmg)
                        dmg:SetDamageType(DMG_SLASH)
                        dmg:SetAttacker(ply)
                        dmg:SetInflictor(ply)
                        entity:TakeDamageInfo(dmg)
            
              
                        if SERVER then
                            net.Start("DisplayDamage")
                            net.WriteInt(chargeDmg, 32)
                            net.WriteEntity(entity)
                            net.WriteColor(Color(249, 148, 6, 255))
                            net.Send(ply)
                        end
            
                        print(entity)
                    end
                else
    
                    ply:SetPos(traceEnd)
                end
            
                ply:GetActiveWeapon():SetHoldType("taijutsu3")
                ply:SetAnimation(PLAYER_RELOAD)
            end)
            
            
            

        elseif button == KEY_G then
            
            local bourrasqueDmg = 60
            if ply:GetActiveWeapon().specialMoveActive then
                bourrasqueDmg = bourrasqueDmg*2
            end

           
            ply:GetActiveWeapon():SetHoldType("taijutsu4")
            ply:SetAnimation(PLAYER_ATTACK1)

            timer.Simple(0.5, function()
                ply:GetActiveWeapon():DoCombo( AttackHit1, 11, bourrasqueDmg, 1.2, 0.16, "taijutsu4_bourrasque", PLAYER_ATTACK1, Angle(3, -3, 0),0.5, 0.7, AttackHit1, 0.14, false, true, 150, 0.2,false)
            end)

        end
                
    end
end)





