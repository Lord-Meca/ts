AddCSLuaFile()

SWEP.PrintName = "Jinton | Kekkei Genkai"
SWEP.Author = "Lord_Meca"
SWEP.Instructions = ""

SWEP.Base = "weapon_base"

SWEP.Category = "TypeShit | Armes"

SWEP.Spawnable = true
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = "models/foc/ska/maskonoki.mdl"

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
    self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_ym_ohnoki.mdl")
end

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

local function cubeJinton(ply, self)
    if not IsValid(ply) then return end

    local duration = 2
    local damage = 600
    local maxDistance = 1000
    local affectedNearbyEntities = {}

    local modelCone = ents.Create("prop_physics")
    local modelCube = ents.Create("prop_physics")

    if not IsValid(modelCone) or not IsValid(modelCube) then return end

    ply:SetVelocity(Vector(0, 0, 600))
    timer.Simple(1, function()

    
        modelCone:SetModel("models/fsc/billy/conejinton.mdl")
        modelCone:SetPos(ply:GetPos()-Vector(0,0,40))
        modelCone:SetModelScale(0.5)
        modelCone:SetAngles(Angle(0,0,180))
        modelCone:Spawn()
        modelCone:SetMoveType(MOVETYPE_NOCLIP)
        ply:SetMoveType(MOVETYPE_NONE)
        self:SetHoldType("weapon_art2")
        ply:SetAnimation(PLAYER_RELOAD)
    end)

    local trace = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * maxDistance,
        filter = ply 
    })

    local cubePos = trace.HitPos 
    if trace.HitWorld then
        cubePos = cubePos + trace.HitNormal * 10 
    end



    modelCube:SetModel("models/fsc/billy/cubeonoki.mdl")
    modelCube:SetPos(cubePos)
    modelCube:SetModelScale(0.3)
    modelCube:Spawn()
    modelCube:SetMoveType(MOVETYPE_NOCLIP)

    local currentScale = 0.1
    local targetScale = 6
    local scaleIncrement = (targetScale - currentScale) / (duration * 10)

    timer.Create("CubeJintonEffect_" .. modelCube:EntIndex(), 0.1, duration * 10, function()
        if IsValid(modelCube) then
            if self:GetHoldType() == "weapon_art2" then
                ply:SetAnimation(PLAYER_RELOAD)
            end
        
            currentScale = currentScale + scaleIncrement
            modelCube:SetModelScale(currentScale, 0)

            for _, entity in pairs(ents.FindInSphere(modelCube:GetPos(), 60 * currentScale)) do
                if IsValid(entity) and (entity:IsPlayer() or entity:IsNPC()) then
                    if entity ~= ply and not affectedNearbyEntities[entity] then
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
            timer.Remove("CubeJintonEffect_" .. modelCube:EntIndex())
        end
    end)

    timer.Simple(duration, function()
        if IsValid(ply) then
            ply:SetMoveType(MOVETYPE_WALK)
        end

        if IsValid(modelCube) then
            modelCube:Remove()
            modelCone:Remove()
            self:SetHoldType("anim_invoke")
            ply:SetAnimation(PLAYER_ATTACK1)
            timer.Remove("CubeJintonEffect_" .. modelCube:EntIndex())
        end
    end)
end


function SWEP:Reload()
    local ply = self.Owner

    if CurTime() < self.NextSpecialMove then return end
    self.NextSpecialMove = CurTime() + 2

    self:SetHoldType("anim_ninjutsu2")
    ply:SetAnimation(PLAYER_RELOAD)

    if SERVER then
        cubeJinton(ply, self)
    end
end

hook.Add("PlayerButtonDown", "jintonSweps", function(ply, button)

	local activeWeapon = ply:GetActiveWeapon()

    if not IsValid(activeWeapon) or activeWeapon:GetClass() ~= "jinton_kg" then
        return
    end

   if button == KEY_E then

		if ply:GetNWBool("freezePlayer") then
			return
		end

		
		
	end

	
end)
