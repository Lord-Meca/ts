
AddCSLuaFile()

SWEP.PrintName = "Libération Spirituelle | Camélia"
SWEP.Author = "Lord_Meca"
SWEP.Instructions = ""

SWEP.Base = "weapon_base"

SWEP.Category = "TypeShit | Invocations"

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

SWEP.PlayerStates = {} 
SWEP.PlayerState = {
	DEFAULT = 0,
    ACTIVE = 1
}

SWEP.clonePos = {loc = Vector(0, 0, 0), ang = Angle(0, 0, 0)}
SWEP.oldPosToad = 0
SWEP.oldPosVision = 0


function SWEP:Deploy()
	self.Owner:SetModel("models/falko_naruto_foc/body_upper/sogeki_man_clansamurai_1.mdl")

	
end


function SWEP:Initialize()

    self:SetHoldType( "normal" )
	self:SetPlayerState(self.Owner, self.PlayerState.DEFAULT)
 	self.tempClone = nil
end



function SWEP:PrimaryAttack()

end



function SWEP:DoAnimation( anim, type )
	self:SetHoldType(anim)
	self.Owner:SetAnimation(type)
end

function SWEP:SetPlayerState(ply, state)
    if not IsValid(ply) then return end
    self.PlayerStates[ply] = state
end

function SWEP:GetPlayerState(ply)
    if not IsValid(ply) then return nil end
    return self.PlayerStates[ply]
end



function createPlyClone(ply, self)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    if IsValid(self.tempClone) then
        self.tempClone:Remove()
    end

    self.tempClone = ents.Create("prop_physics")
    if not IsValid(self.tempClone) then return end

    self.tempClone:SetModel(ply:GetModel())
    self.tempClone:SetPos(ply:GetPos() + ply:GetRight() * 50 + Vector(0, 0, 5)) 
    self.tempClone:SetAngles(ply:GetAngles())
    self.tempClone:SetKeyValue("solid", "6")
    self.tempClone:Spawn()

    self.tempClone:SetMoveType(MOVETYPE_NONE)

    self.tempClone:SetColor(ply:GetColor())
    self.tempClone:SetMaterial(ply:GetMaterial())
    self.tempClone:SetSkin(ply:GetSkin())

    for i = 0, ply:GetNumBodyGroups() - 1 do
        self.tempClone:SetBodygroup(i, ply:GetBodygroup(i))
    end

    if self.tempClone:LookupSequence("pose_ducking_02") >= 0 then
        self.tempClone:ResetSequence("pose_ducking_02")
    end

	local playerAttachPos = ply:EyePos() - Vector(0, 0, 20)
	local cloneAttachPos = Vector(0, 0, 10)

	constraint.Rope(
		self.tempClone,
		ply,
		0,
		0,
		cloneAttachPos,
		playerAttachPos - ply:GetPos(),
		0,
		0,
		0,
		15,
		"cable/xbeam",
		Color(255, 0, 216, 171)
	)
	
end

function removeClone(self)
    if IsValid(self.tempClone) then

		
	    self.tempClone:Remove()
        self.tempClone = nil


    end
end


function SWEP:Reload()
	local ply = self.Owner

	if not ply:IsOnGround() then return end

	if CurTime() < self.NextSpecialMove then return end
	self.NextSpecialMove = CurTime() + 1

	local currentState = self:GetPlayerState(ply)

	self:SetHoldType("anim_jashin")
    ply:SetAnimation(PLAYER_RELOAD)
	self:SetHoldType("normal")
	timer.Simple(1, function()
		if currentState == 0 or currentState == nil then


		
			self:SetPlayerState(ply, self.PlayerState.ACTIVE)	
			if SERVER then
				createPlyClone(ply, self)
			end	
	
			self.clonePos = {
				loc = ply:GetPos(),
				ang = ply:EyeAngles()
			}
			ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
			ply:SetColor(Color(255,255,255,150))
			ParticleEffectAttach("[0]_camelia_aura", PATTACH_ABSORIGIN_FOLLOW, ply, 0)
			
			-- timer.Simple(20, function()
			-- 	if self:GetPlayerState(ply) == 1 then
			-- 		if IsValid(ply) then
			-- 			removeClone(self)
			-- 			ply:StopParticles()
			-- 			self:SetPlayerState(ply, self.PlayerState.DEFAULT)	
				
			-- 			ply:SetColor(Color(255,255,255,255))
			-- 			ply:SetRenderMode(RENDERMODE_TRANSCOLOR)

			-- 			ply:SetWalkSpeed( 250 )
			-- 			ply:SetRunSpeed( 450 )
			-- 		end
			-- 	end
			-- end)

			ply:SetWalkSpeed(650)
			ply:SetRunSpeed(650)
				
		elseif currentState == 1 then
			
			removeClone(self)
			ply:StopParticles()
			self:SetPlayerState(ply, self.PlayerState.DEFAULT)	
			ply:SetPos(self.clonePos.loc)	
			ply:SetEyeAngles(self.clonePos.ang)	
			ply:SetColor(Color(255,255,255,255))
			ply:SetRenderMode(RENDERMODE_TRANSCOLOR)

			ply:SetWalkSpeed( 250 )
			ply:SetRunSpeed( 450 )
		end
	
	end)






end
