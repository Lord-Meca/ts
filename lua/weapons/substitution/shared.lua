AddCSLuaFile()

SWEP.PrintName = "Substitution | Ninjutsu"
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

function SWEP:Deploy()
    self.Owner:SetModel("models/falko_naruto_foc/body_upper/man_anbublackops_ame_hood_01.mdl")
end

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

local function substitutionJutsu(ply)
    if not IsValid(ply) then return end

    local modelEntity = ents.Create("prop_physics")
    if not IsValid(modelEntity) then return end

    modelEntity:SetModel("models/foc_props_jutsu/jutsu_substitution/foc_jutsu_substitution.mdl")
    modelEntity:SetPos(ply:GetPos() + Vector(0, 0, 50))
    modelEntity:SetModelScale(1)
    modelEntity:Spawn()
    modelEntity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    ParticleEffect("nrp_tool_invocation", modelEntity:GetPos(), Angle(0, 0, 0), nil)

    timer.Simple(5, function()
        if IsValid(modelEntity) then
            modelEntity:Remove()
        end
    end)

    ply:SetPos(Vector(math.random(-300, 600), math.random(-300, 600), math.random(20, 50)))
end

hook.Add("EntityTakeDamage", "SubstitutionJutsuTrigger", function(target, dmginfo)
    if not target:IsPlayer() or not target:GetActiveWeapon() then return end

    local weapon = target:GetActiveWeapon()
    if weapon:GetClass() ~= "substitution" then return end 

    if dmginfo:GetDamage() >= 10 and CurTime() > weapon.NextSpecialMove then
        weapon.NextSpecialMove = CurTime() + 2
        dmginfo:SetDamage(0)
        substitutionJutsu(target)
    end
end)

function SWEP:Reload()
    local ply = self.Owner

    if CurTime() < self.NextSpecialMove then return end
    self.NextSpecialMove = CurTime() + 5

    if SERVER then
        substitutionJutsu(ply)
    end
end
