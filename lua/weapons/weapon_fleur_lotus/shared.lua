

if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("DisplayDamage")
end


SWEP.PrintName = "Fleur du Lotus | Taijutsu"
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
--SWEP.NextSpecialMove = 0

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



	self.Weapon:SetNextSecondaryFire(CurTime() + 2 )

	local force = Vector(0, 0, 750)
	
    local maxDistance = 800
    local ply = self.Owner
    local trace = ply:GetEyeTrace()
    local target = trace.Entity

    if not (IsValid(target) and target:IsPlayer() and trace.HitPos:DistToSqr(ply:GetPos()) <= maxDistance ^ 2) then
        return
    end
       
	ply:Freeze(true)
	target:Freeze(true)

	self:SetHoldType("anim_ninjutsu2")
	ply:SetAnimation(PLAYER_RELOAD)

	local targetPos = target:GetPos() + target:GetAngles():Forward() * 50
	ply:EmitSound("physics/body/body_medium_break2.wav", 50, 100, 0.5)
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
							damageInfo:SetDamage(10) 
							damageInfo:SetAttacker(ply) 
							damageInfo:SetInflictor(self)
							target:TakeDamageInfo(damageInfo)
						end
						
		
						net.Start("DisplayDamage")
						net.WriteInt(10, 32)
						net.WriteEntity(target)
						net.WriteColor(Color(249,148,6,255))
						net.Send(ply)

						timer.Simple(0.4,function()
							target:Freeze(false)
						end)
				
					end
				end)

			end)
		end)
	end)

end
